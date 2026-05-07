import 'package:vector_math/vector_math_64.dart';

enum NavNodeType { room, staircase, intersection, entrance, lift }

class NavigationNode {
  final String id;
  final String name;
  final int floor;
  final Vector3 position; // Relative coordinates in meters
  final NavNodeType type;

  NavigationNode({
    required this.id,
    required this.name,
    required this.floor,
    required this.position,
    required this.type,
  });

  @override
  String toString() => 'Node($name, Floor $floor)';
}

class NavigationEdge {
  final String fromId;
  final String toId;
  final double distance;

  NavigationEdge({
    required this.fromId,
    required this.toId,
    required this.distance,
  });
}

class CampusGraph {
  final List<NavigationNode> nodes;
  final List<NavigationEdge> edges;

  CampusGraph({required this.nodes, required this.edges});

  // Shortest path logic (A* or Dijkstra) will be implemented here
}
