import 'package:vector_math/vector_math_64.dart';
import 'navigation_model.dart';

final CampusGraph computingBlockGraph = CampusGraph(
  nodes: [
    NavigationNode(id: 'c_ent', name: 'Main Entrance', floor: 1, position: Vector3(0, 0, 0), type: NavNodeType.entrance),
    NavigationNode(id: 'c_rec', name: 'Reception', floor: 1, position: Vector3(5, 0, 0), type: NavNodeType.room),
    NavigationNode(id: 'c_stairs_1', name: 'Main Staircase', floor: 1, position: Vector3(3, 0, 0), type: NavNodeType.staircase),
    NavigationNode(id: 'c_2101', name: 'Room 2101', floor: 1, position: Vector3(-5, 0, 10), type: NavNodeType.room),
    NavigationNode(id: 'c_2107', name: 'Room 2107', floor: 1, position: Vector3(-10, 0, 20), type: NavNodeType.room),
    NavigationNode(id: 'c_junc_1', name: 'Corridor Junction 1', floor: 1, position: Vector3(0, 0, 10), type: NavNodeType.intersection),
  ],
  edges: [
    NavigationEdge(fromId: 'c_ent', toId: 'c_stairs_1', distance: 3),
    NavigationEdge(fromId: 'c_ent', toId: 'c_junc_1', distance: 10),
    NavigationEdge(fromId: 'c_junc_1', toId: 'c_2101', distance: 5),
    NavigationEdge(fromId: 'c_2101', toId: 'c_2107', distance: 15),
  ],
);
