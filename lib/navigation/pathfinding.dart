import 'dart:math';
import 'dart:collection';
import 'package:campus_prototype/navigation/navigation_model.dart';

// ─── Priority Queue Entry ─────────────────────────────────────────────────────

class _PQEntry implements Comparable<_PQEntry> {
  final String nodeId;
  final double priority;
  _PQEntry(this.nodeId, this.priority);

  @override
  int compareTo(_PQEntry other) => priority.compareTo(other.priority);
}

// ─── PathFinder (A* with binary heap priority queue) ─────────────────────────

class PathFinder {
  final CampusGraph graph;

  PathFinder(this.graph);

  /// Returns a list of NavigationNodes from startId to endId.
  /// Returns empty list if no path exists.
  /// Multi-floor routing works via staircase/lift nodes that connect floors.
  List<NavigationNode> findPath(String startId, String endId) {
    if (startId == endId) {
      final node = graph.nodeById(startId);
      return node != null ? [node] : [];
    }

    final startNode = graph.nodeById(startId);
    final endNode = graph.nodeById(endId);
    if (startNode == null || endNode == null) return [];

    // --- A* with heap-based priority queue ---
    final openSet = SplayTreeSet<_PQEntry>((a, b) {
      final c = a.priority.compareTo(b.priority);
      return c != 0 ? c : a.nodeId.compareTo(b.nodeId); // Tie-break by id
    });

    final gScore = <String, double>{startId: 0.0};
    final cameFrom = <String, String>{};

    openSet.add(_PQEntry(startId, _heuristic(startNode, endNode)));

    while (openSet.isNotEmpty) {
      final current = openSet.first;
      openSet.remove(current);

      if (current.nodeId == endId) {
        return _reconstructPath(cameFrom, endId);
      }

      final edges = graph.edgesFrom(current.nodeId);
      for (final edge in edges) {
        final neighborId =
            edge.fromId == current.nodeId ? edge.toId : edge.fromId;
        final neighbor = graph.nodeById(neighborId);
        if (neighbor == null) continue;

        // Add floor-change penalty (4m penalty per floor change via stair/lift)
        final moveCost = edge.distance + (edge.isStairOrLift ? 2.0 : 0.0);
        final tentativeG =
            (gScore[current.nodeId] ?? double.infinity) + moveCost;

        if (tentativeG < (gScore[neighborId] ?? double.infinity)) {
          cameFrom[neighborId] = current.nodeId;
          gScore[neighborId] = tentativeG;
          final fScore = tentativeG + _heuristic(neighbor, endNode);
          openSet.add(_PQEntry(neighborId, fScore));
        }
      }
    }

    return []; // No path found
  }

  /// Find the nearest node to a given node ID (useful for localization snapping)
  NavigationNode? nearestNodeOnFloor(String referenceId, int floor) {
    final ref = graph.nodeById(referenceId);
    if (ref == null) return null;

    NavigationNode? nearest;
    double bestDist = double.infinity;

    for (final node in graph.nodes) {
      if (node.id == referenceId || node.floor != floor) continue;
      final d = _euclidean3D(
          ref.position.x, ref.position.z, node.position.x, node.position.z);
      if (d < bestDist) {
        bestDist = d;
        nearest = node;
      }
    }
    return nearest;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  double _heuristic(NavigationNode a, NavigationNode b) {
    // 3D Euclidean with floor transition cost
    final floorPenalty = (a.floor - b.floor).abs() * 4.0;
    return _euclidean3D(
            a.position.x, a.position.z, b.position.x, b.position.z) +
        floorPenalty;
  }

  double _euclidean3D(double ax, double az, double bx, double bz) {
    return sqrt(pow(ax - bx, 2) + pow(az - bz, 2));
  }

  List<NavigationNode> _reconstructPath(
      Map<String, String> cameFrom, String current) {
    final path = <NavigationNode>[];
    String? cursor = current;
    while (cursor != null) {
      final node = graph.nodeById(cursor);
      if (node != null) path.add(node);
      cursor = cameFrom[cursor];
    }
    return path.reversed.toList();
  }
}
