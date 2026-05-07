import 'dart:math';
import 'navigation_model.dart';

class PathFinder {
  final CampusGraph graph;

  PathFinder(this.graph);

  List<NavigationNode> findPath(String startId, String endId) {
    Map<String, NavigationNode> nodeMap = {for (var n in graph.nodes) n.id: n};
    
    if (!nodeMap.containsKey(startId) || !nodeMap.containsKey(endId)) return [];

    Map<String, double> gScore = {for (var n in graph.nodes) n.id: double.infinity};
    Map<String, double> fScore = {for (var n in graph.nodes) n.id: double.infinity};
    Map<String, String?> cameFrom = {for (var n in graph.nodes) n.id: null};

    gScore[startId] = 0;
    fScore[startId] = _heuristic(nodeMap[startId]!, nodeMap[endId]!);

    List<String> openSet = [startId];

    while (openSet.isNotEmpty) {
      // Get node with lowest fScore
      String current = openSet.reduce((a, b) => fScore[a]! < fScore[b]! ? a : b);

      if (current == endId) {
        return _reconstructPath(cameFrom, current, nodeMap);
      }

      openSet.remove(current);

      for (var edge in graph.edges.where((e) => e.fromId == current || e.toId == current)) {
        String neighbor = edge.fromId == current ? edge.toId : edge.fromId;
        double tentativeGScore = gScore[current]! + edge.distance;

        if (tentativeGScore < gScore[neighbor]!) {
          cameFrom[neighbor] = current;
          gScore[neighbor] = tentativeGScore;
          fScore[neighbor] = gScore[neighbor]! + _heuristic(nodeMap[neighbor]!, nodeMap[endId]!);
          if (!openSet.contains(neighbor)) {
            openSet.add(neighbor);
          }
        }
      }
    }

    return [];
  }

  double _heuristic(NavigationNode a, NavigationNode b) {
    // 3D Euclidean distance
    return sqrt(
      pow(a.position.x - b.position.x, 2) +
      pow(a.position.y - b.position.y, 2) +
      pow((a.floor - b.floor) * 3, 2), // Assume floor height is 3m
    );
  }

  List<NavigationNode> _reconstructPath(Map<String, String?> cameFrom, String current, Map<String, NavigationNode> nodeMap) {
    List<NavigationNode> totalPath = [nodeMap[current]!];
    while (cameFrom[current] != null) {
      current = cameFrom[current]!;
      totalPath.add(nodeMap[current]!);
    }
    return totalPath.reversed.toList();
  }
}
