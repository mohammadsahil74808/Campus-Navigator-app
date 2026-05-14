import 'package:vector_math/vector_math_64.dart';
import 'package:campus_prototype/navigation/navigation_model.dart';

final CampusGraph computingBlockGraph = CampusGraph(
  nodes: [
    // ─── FLOOR 1 ─────────────────────────────────────────────────────────────
    NavigationNode(displayLabel: 'ENTRANCE', id: 'c_ent', name: 'Main Entrance', floor: 1, position: Vector3(0, 0, 0), type: NavNodeType.entrance, aliases: ['entrance', 'gate']),
    NavigationNode(displayLabel: 'RECEPTION', id: 'c_rec', name: 'Reception', floor: 1, position: Vector3(5, 0, 0), type: NavNodeType.room, aliases: ['reception', 'desk']),
    NavigationNode(displayLabel: 'STAIRS F1', id: 'c_stairs_1', name: 'Main Staircase', floor: 1, position: Vector3(3, 0, 0), type: NavNodeType.staircase, aliases: ['stairs', 'staircase']),
    
    // Corridors (F1)
    NavigationNode(displayLabel: 'JUNC 1', id: 'c_j1_1', name: 'F1 Corridor 1', floor: 1, position: Vector3(0, 0, 10), type: NavNodeType.intersection),
    NavigationNode(displayLabel: 'JUNC 2', id: 'c_j1_2', name: 'F1 Corridor 2', floor: 1, position: Vector3(0, 0, 20), type: NavNodeType.intersection),
    NavigationNode(displayLabel: 'JUNC 3', id: 'c_j1_3', name: 'F1 Corridor 3', floor: 1, position: Vector3(0, 0, 30), type: NavNodeType.intersection),
    NavigationNode(displayLabel: 'JUNC 4', id: 'c_j1_4', name: 'F1 Corridor 4', floor: 1, position: Vector3(0, 0, 40), type: NavNodeType.intersection),
    NavigationNode(displayLabel: 'JUNC 5', id: 'c_j1_5', name: 'F1 Corridor 5', floor: 1, position: Vector3(0, 0, 50), type: NavNodeType.intersection),
    NavigationNode(displayLabel: 'JUNC 6', id: 'c_j1_6', name: 'F1 Corridor 6', floor: 1, position: Vector3(0, 0, 60), type: NavNodeType.intersection),
    NavigationNode(displayLabel: 'JUNC 7', id: 'c_j1_7', name: 'F1 Corridor 7', floor: 1, position: Vector3(0, 0, 70), type: NavNodeType.intersection),
    NavigationNode(displayLabel: 'JUNC 8', id: 'c_j1_8', name: 'F1 Corridor 8', floor: 1, position: Vector3(0, 0, 80), type: NavNodeType.intersection),

    // Rooms (F1)
    NavigationNode(displayLabel: '2101', id: 'c_2101', name: '2101 DBMS Lab', floor: 1, position: Vector3(-5, 0, 10), type: NavNodeType.room, aliases: ['2101', 'dbms lab']),
    NavigationNode(displayLabel: '2102', id: 'c_2102', name: '2102', floor: 1, position: Vector3(5, 0, 10), type: NavNodeType.room, aliases: ['2102']),
    NavigationNode(displayLabel: '2103', id: 'c_2103', name: '2103 CSE Office', floor: 1, position: Vector3(-5, 0, 20), type: NavNodeType.room, aliases: ['2103', 'cse office']),
    NavigationNode(displayLabel: '2104', id: 'c_2104', name: '2104', floor: 1, position: Vector3(5, 0, 20), type: NavNodeType.room, aliases: ['2104']),
    NavigationNode(displayLabel: '2105', id: 'c_2105', name: '2105', floor: 1, position: Vector3(-5, 0, 30), type: NavNodeType.room, aliases: ['2105']),
    NavigationNode(displayLabel: '2106', id: 'c_2106', name: '2106', floor: 1, position: Vector3(5, 0, 30), type: NavNodeType.room, aliases: ['2106']),
    NavigationNode(displayLabel: '2107', id: 'c_2107', name: '2107', floor: 1, position: Vector3(-5, 0, 40), type: NavNodeType.room, aliases: ['2107']),
    NavigationNode(displayLabel: '2108', id: 'c_2108', name: '2108', floor: 1, position: Vector3(5, 0, 40), type: NavNodeType.room, aliases: ['2108']),
    NavigationNode(displayLabel: '2109', id: 'c_2109', name: '2109', floor: 1, position: Vector3(-5, 0, 50), type: NavNodeType.room, aliases: ['2109']),
    NavigationNode(displayLabel: '2110', id: 'c_2110', name: '2110', floor: 1, position: Vector3(5, 0, 50), type: NavNodeType.room, aliases: ['2110']),
    NavigationNode(displayLabel: '2112', id: 'c_2112', name: '2112 IoT Lab', floor: 1, position: Vector3(-5, 0, 60), type: NavNodeType.room, aliases: ['2112', 'iot lab']),
    NavigationNode(displayLabel: '2113', id: 'c_2113', name: '2113 ECE Computing Lab', floor: 1, position: Vector3(5, 0, 60), type: NavNodeType.room, aliases: ['2113', 'ece computing lab']),
    NavigationNode(displayLabel: '2114', id: 'c_2114', name: '2114', floor: 1, position: Vector3(-5, 0, 70), type: NavNodeType.room, aliases: ['2114']),
    NavigationNode(displayLabel: '2115', id: 'c_2115', name: '2115', floor: 1, position: Vector3(5, 0, 70), type: NavNodeType.room, aliases: ['2115']),
    NavigationNode(displayLabel: '2118', id: 'c_2118', name: '2118 Dean Office', floor: 1, position: Vector3(-5, 0, 80), type: NavNodeType.room, aliases: ['2118', 'dean office']),
    NavigationNode(displayLabel: '2119', id: 'c_2119', name: '2119 HOD Office', floor: 1, position: Vector3(5, 0, 80), type: NavNodeType.room, aliases: ['2119', 'hod office']),

    // ─── FLOOR 2 ─────────────────────────────────────────────────────────────
    NavigationNode(displayLabel: 'STAIRS F2', id: 'c_stairs_2', name: 'Main Staircase F2', floor: 2, position: Vector3(3, 4, 0), type: NavNodeType.staircase, aliases: ['stairs', 'staircase']),
    
    // Corridors (F2)
    NavigationNode(displayLabel: 'JUNC 2-1', id: 'c_j2_1', name: 'F2 Corridor 1', floor: 2, position: Vector3(0, 4, 10), type: NavNodeType.intersection),
    NavigationNode(displayLabel: 'JUNC 2-2', id: 'c_j2_2', name: 'F2 Corridor 2', floor: 2, position: Vector3(0, 4, 20), type: NavNodeType.intersection),
    NavigationNode(displayLabel: 'JUNC 2-3', id: 'c_j2_3', name: 'F2 Corridor 3', floor: 2, position: Vector3(0, 4, 30), type: NavNodeType.intersection),
    NavigationNode(displayLabel: 'JUNC 2-4', id: 'c_j2_4', name: 'F2 Corridor 4', floor: 2, position: Vector3(0, 4, 40), type: NavNodeType.intersection),
    NavigationNode(displayLabel: 'JUNC 2-5', id: 'c_j2_5', name: 'F2 Corridor 5', floor: 2, position: Vector3(0, 4, 50), type: NavNodeType.intersection),

    // Rooms (F2)
    NavigationNode(displayLabel: '2201A', id: 'c_2201A', name: '2201A', floor: 2, position: Vector3(-5, 4, 10), type: NavNodeType.room, aliases: ['2201a']),
    NavigationNode(displayLabel: '2201B', id: 'c_2201B', name: '2201B', floor: 2, position: Vector3(5, 4, 10), type: NavNodeType.room, aliases: ['2201b']),
    NavigationNode(displayLabel: '2202A', id: 'c_2202A', name: '2202A', floor: 2, position: Vector3(-5, 4, 20), type: NavNodeType.room, aliases: ['2202a']),
    NavigationNode(displayLabel: '2202B', id: 'c_2202B', name: '2202B', floor: 2, position: Vector3(5, 4, 20), type: NavNodeType.room, aliases: ['2202b']),
    NavigationNode(displayLabel: '2203A', id: 'c_2203A', name: '2203A', floor: 2, position: Vector3(-5, 4, 30), type: NavNodeType.room, aliases: ['2203a']),
    NavigationNode(displayLabel: '2203B', id: 'c_2203B', name: '2203B', floor: 2, position: Vector3(5, 4, 30), type: NavNodeType.room, aliases: ['2203b']),
    NavigationNode(displayLabel: '2204', id: 'c_2204', name: '2204 CSE Library', floor: 2, position: Vector3(-5, 4, 40), type: NavNodeType.room, aliases: ['2204', 'cse library']),
    NavigationNode(displayLabel: '2206', id: 'c_2206', name: '2206 Lab-1', floor: 2, position: Vector3(5, 4, 40), type: NavNodeType.room, aliases: ['2206', 'lab 1']),
    NavigationNode(displayLabel: '2207', id: 'c_2207', name: '2207 Lab-2', floor: 2, position: Vector3(-5, 4, 50), type: NavNodeType.room, aliases: ['2207', 'lab 2']),
    NavigationNode(displayLabel: '2208A', id: 'c_2208A', name: '2208A', floor: 2, position: Vector3(5, 4, 50), type: NavNodeType.room, aliases: ['2208a']),
  ],
  edges: [
    // Floor 1 Connectivity
    const NavigationEdge(fromId: 'c_ent', toId: 'c_stairs_1', distance: 3),
    const NavigationEdge(fromId: 'c_ent', toId: 'c_rec', distance: 5),
    const NavigationEdge(fromId: 'c_ent', toId: 'c_j1_1', distance: 10),
    const NavigationEdge(fromId: 'c_j1_1', toId: 'c_j1_2', distance: 10),
    const NavigationEdge(fromId: 'c_j1_2', toId: 'c_j1_3', distance: 10),
    const NavigationEdge(fromId: 'c_j1_3', toId: 'c_j1_4', distance: 10),
    const NavigationEdge(fromId: 'c_j1_4', toId: 'c_j1_5', distance: 10),
    const NavigationEdge(fromId: 'c_j1_5', toId: 'c_j1_6', distance: 10),
    const NavigationEdge(fromId: 'c_j1_6', toId: 'c_j1_7', distance: 10),
    const NavigationEdge(fromId: 'c_j1_7', toId: 'c_j1_8', distance: 10),

    // Room connections (F1)
    const NavigationEdge(fromId: 'c_j1_1', toId: 'c_2101', distance: 5),
    const NavigationEdge(fromId: 'c_j1_1', toId: 'c_2102', distance: 5),
    const NavigationEdge(fromId: 'c_j1_2', toId: 'c_2103', distance: 5),
    const NavigationEdge(fromId: 'c_j1_2', toId: 'c_2104', distance: 5),
    const NavigationEdge(fromId: 'c_j1_3', toId: 'c_2105', distance: 5),
    const NavigationEdge(fromId: 'c_j1_3', toId: 'c_2106', distance: 5),
    const NavigationEdge(fromId: 'c_j1_4', toId: 'c_2107', distance: 5),
    const NavigationEdge(fromId: 'c_j1_4', toId: 'c_2108', distance: 5),
    const NavigationEdge(fromId: 'c_j1_5', toId: 'c_2109', distance: 5),
    const NavigationEdge(fromId: 'c_j1_5', toId: 'c_2110', distance: 5),
    const NavigationEdge(fromId: 'c_j1_6', toId: 'c_2112', distance: 5),
    const NavigationEdge(fromId: 'c_j1_6', toId: 'c_2113', distance: 5),
    const NavigationEdge(fromId: 'c_j1_7', toId: 'c_2114', distance: 5),
    const NavigationEdge(fromId: 'c_j1_7', toId: 'c_2115', distance: 5),
    const NavigationEdge(fromId: 'c_j1_8', toId: 'c_2118', distance: 5),
    const NavigationEdge(fromId: 'c_j1_8', toId: 'c_2119', distance: 5),

    // Vertical Connectivity (Stairs)
    const NavigationEdge(fromId: 'c_stairs_1', toId: 'c_stairs_2', distance: 4, isStairOrLift: true),

    // Floor 2 Connectivity
    const NavigationEdge(fromId: 'c_stairs_2', toId: 'c_j2_1', distance: 10),
    const NavigationEdge(fromId: 'c_j2_1', toId: 'c_j2_2', distance: 10),
    const NavigationEdge(fromId: 'c_j2_2', toId: 'c_j2_3', distance: 10),
    const NavigationEdge(fromId: 'c_j2_3', toId: 'c_j2_4', distance: 10),
    const NavigationEdge(fromId: 'c_j2_4', toId: 'c_j2_5', distance: 10),

    // Room connections (F2)
    const NavigationEdge(fromId: 'c_j2_1', toId: 'c_2201A', distance: 5),
    const NavigationEdge(fromId: 'c_j2_1', toId: 'c_2201B', distance: 5),
    const NavigationEdge(fromId: 'c_j2_2', toId: 'c_2202A', distance: 5),
    const NavigationEdge(fromId: 'c_j2_2', toId: 'c_2202B', distance: 5),
    const NavigationEdge(fromId: 'c_j2_3', toId: 'c_2203A', distance: 5),
    const NavigationEdge(fromId: 'c_j2_3', toId: 'c_2203B', distance: 5),
    const NavigationEdge(fromId: 'c_j2_4', toId: 'c_2204', distance: 5),
    const NavigationEdge(fromId: 'c_j2_4', toId: 'c_2206', distance: 5),
    const NavigationEdge(fromId: 'c_j2_5', toId: 'c_2207', distance: 5),
    const NavigationEdge(fromId: 'c_j2_5', toId: 'c_2208A', distance: 5),
  ],
);
