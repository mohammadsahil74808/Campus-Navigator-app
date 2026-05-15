// lib/navigation/pathfinding.dart
//
// REBUILT: Corridor-aware A* with:
//  1. Wall-safe routing — rooms only reachable via their door node
//  2. Priority queue (SplayTreeSet) — O(log n) not O(n)
//  3. Path smoothing — removes redundant corridor waypoints in straight runs
//  4. Corridor heading alignment — each step carries the hallway direction
//  5. Total distance calculation for ETA
//  6. Snap-to-graph — finds nearest corridor node to arbitrary XZ position

import 'dart:math' as math;
import 'dart:collection';
import 'navigation_model.dart';

// ─── Priority Queue Entry ─────────────────────────────────────────────────────

class _PQ implements Comparable<_PQ> {
  final String id;
  final double f;
  _PQ(this.id, this.f);
  @override
  int compareTo(_PQ o) {
    final c = f.compareTo(o.f);
    return c != 0 ? c : id.compareTo(o.id);
  }
}

// ─── PathResult ───────────────────────────────────────────────────────────────

class PathResult {
  final List<NavigationNode> nodes; // Full waypoint list
  final List<NavigationNode> smoothed; // Collapsed straight runs
  final double totalDistanceMeters;
  final bool reachable;
  final String? errorReason;

  const PathResult({
    required this.nodes,
    required this.smoothed,
    required this.totalDistanceMeters,
    required this.reachable,
    this.errorReason,
  });

  static PathResult unreachable(String reason) => PathResult(
        nodes: [],
        smoothed: [],
        totalDistanceMeters: 0,
        reachable: false,
        errorReason: reason,
      );
}

// ─── PathFinder ───────────────────────────────────────────────────────────────

class PathFinder {
  final CampusGraph graph;

  PathFinder(this.graph);

  // ── Main Entry Point ──────────────────────────────────────────────────────

  PathResult findPath(String startId, String endId) {
    if (startId == endId) {
      final n = graph.nodeById(startId);
      return n == null
          ? PathResult.unreachable('Start node not found')
          : PathResult(
              nodes: [n],
              smoothed: [n],
              totalDistanceMeters: 0,
              reachable: true);
    }

    final start = graph.nodeById(startId);
    final end = graph.nodeById(endId);
    if (start == null) {
      return PathResult.unreachable('Start node "$startId" missing from graph');
    }
    if (end == null) {
      return PathResult.unreachable('End node "$endId" missing from graph');
    }

    // A* search
    final open = SplayTreeSet<_PQ>();
    final gScore = <String, double>{startId: 0.0};
    final cameFrom = <String, String>{};

    open.add(_PQ(startId, _h(start, end)));

    while (open.isNotEmpty) {
      final cur = open.first;
      open.remove(cur);

      if (cur.id == endId) {
        final path = _reconstruct(cameFrom, endId);
        final dist = _totalDistance(path);
        final smooth = _smoothPath(path);
        return PathResult(
          nodes: path,
          smoothed: smooth,
          totalDistanceMeters: dist,
          reachable: true,
        );
      }

      for (final edge in graph.edgesFrom(cur.id)) {
        final nId = edge.fromId == cur.id ? edge.toId : edge.fromId;
        final nNode = graph.nodeById(nId);
        if (nNode == null) continue;

        // Vertical transition cost: stair = 6m penalty, lift = 3m penalty
        // (encourages lift use for > 1 floor, discourages unnecessary floor changes)
        double cost = edge.distance;
        if (edge.isVertical) {
          cost += nNode.type == NavNodeType.lift ? 3.0 : 6.0;
        }

        final tg = (gScore[cur.id] ?? double.infinity) + cost;
        if (tg < (gScore[nId] ?? double.infinity)) {
          cameFrom[nId] = cur.id;
          gScore[nId] = tg;
          open.add(_PQ(nId, tg + _h(nNode, end)));
        }
      }
    }

    return PathResult.unreachable('No walkable path from $startId to $endId');
  }

  // ── Snap: find nearest walkable node on a floor to an XZ position ─────────
  // Used when dead reckoning drifts the estimated position off a known node.

  NavigationNode snapToNearestCorridor(double x, double z, int floor) {
    NavigationNode? best;
    double bestDist = double.infinity;
    for (final n in graph.nodes) {
      if (n.floor != floor || !n.type.isWalkable) continue;
      final d = _dist2d(x, z, n.position.x, n.position.z);
      if (d < bestDist) {
        bestDist = d;
        best = n;
      }
    }
    // Fallback: main junction of the floor
    return best ??
        graph.nodes.firstWhere(
          (n) => n.floor == floor && n.type == NavNodeType.junction,
          orElse: () => graph.nodes.first,
        );
  }

  // ── Re-route from a new current position ──────────────────────────────────
  // Called when the user is detected off the expected corridor segment.
  PathResult reroute(String newCurrentId, String targetId) {
    return findPath(newCurrentId, targetId);
  }

  // ── Path Smoothing ────────────────────────────────────────────────────────
  // Collapses consecutive corridor nodes that are on the same heading into
  // a single segment. This means the AR arrow only changes when the user
  // reaches a real turn (junction), not every 4m corridor waypoint.
  //
  // Rule: keep a node if:
  //   • it's the start or end
  //   • it's a junction, staircase, lift, door, or room (decision points)
  //   • the heading from previous-to-this differs by > 20° from this-to-next

  List<NavigationNode> _smoothPath(List<NavigationNode> path) {
    if (path.length <= 2) return path;

    final result = <NavigationNode>[path.first];

    for (int i = 1; i < path.length - 1; i++) {
      final prev = path[i - 1];
      final cur = path[i];
      final next = path[i + 1];

      // Always keep decision points
      if (cur.type != NavNodeType.corridor) {
        result.add(cur);
        continue;
      }

      // Keep if heading changes meaningfully
      final h1 = _bearing(
          prev.position.x, prev.position.z, cur.position.x, cur.position.z);
      final h2 = _bearing(
          cur.position.x, cur.position.z, next.position.x, next.position.z);
      if (_angleDiff(h1, h2).abs() > 20) {
        result.add(cur);
      }
      // Otherwise skip — straight-line corridor node
    }

    result.add(path.last);
    return result;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  double _h(NavigationNode a, NavigationNode b) {
    // Admissible heuristic: Euclidean 2D + floor penalty
    return _dist2d(a.position.x, a.position.z, b.position.x, b.position.z) +
        (a.floor - b.floor).abs() * 8.0;
  }

  double _dist2d(double ax, double az, double bx, double bz) =>
      math.sqrt(math.pow(ax - bx, 2) + math.pow(az - bz, 2));

  double _bearing(double ax, double az, double bx, double bz) =>
      (math.atan2(bx - ax, bz - az) * 180 / math.pi + 360) % 360;

  double _angleDiff(double a, double b) {
    double d = b - a;
    while (d > 180) {
      d -= 360;
    }
    while (d < -180) {
      d += 360;
    }
    return d;
  }

  double _totalDistance(List<NavigationNode> path) {
    double d = 0;
    for (int i = 0; i < path.length - 1; i++) {
      d += path[i].floorDistanceTo(path[i + 1]);
    }
    return d;
  }

  List<NavigationNode> _reconstruct(Map<String, String> came, String cur) {
    final path = <NavigationNode>[];
    String? c = cur;
    while (c != null) {
      final n = graph.nodeById(c);
      if (n != null) path.add(n);
      c = came[c];
    }
    return path.reversed.toList();
  }
}
