// lib/data/computing_block_graph.dart
//
// COMPLETE REBUILD — based on the actual floor plan photos.
//
// Architecture enforced in this graph:
//  ┌─────────────────────────────────────────────────────────────┐
//  │  ROOMS only connect to their DOOR node (1 edge)             │
//  │  DOOR nodes sit in the corridor, 0.5m outside room entry    │
//  │  CORRIDOR nodes form the actual walkable hallway spine       │
//  │  JUNCTION nodes are T/X intersections of corridors          │
//  │  STAIRCASE/LIFT nodes connect floors (vertical edges only)  │
//  └─────────────────────────────────────────────────────────────┘
//
// Coordinate origin: Centre of the main staircase / lift shaft.
// Scale: 1 unit = 1 metre
// +X = East (right on floor plan)
// +Z = North (up on floor plan)
// Y  = elevation (floor 1 = 0m, floor 2 = 4m)
//
// Floor 1 layout (from photo):
//  Building is roughly 32m wide × 30m deep.
//  Outer corridor runs around the perimeter of the courtyard.
//  Inner corridor runs along the south face.
//  Rooms open off the outer walls on all four sides.
//
// Floor 2 layout (from photo):
//  Same footprint. Classrooms on west, labs on east, library+IBM on north.

import 'package:vector_math/vector_math_64.dart';
import '../navigation/navigation_model.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// FLOOR 1 NODES
// ═══════════════════════════════════════════════════════════════════════════════

// ── Entrance & Vertical Access ────────────────────────────────────────────────

final _f1Entrance = NavigationNode(
  id: 'f1_ent',
  name: 'Main Entrance',
  displayLabel: 'ENTRANCE',
  floor: 1,
  position: Vector3(0, 0, -16),
  type: NavNodeType.entrance,
  aliases: ['entrance', 'main entrance', 'entry', 'gate'],
);
final _f1Lift = NavigationNode(
  id: 'f1_lift',
  name: 'Lift / Main Stairs',
  displayLabel: 'LIFT F1',
  floor: 1,
  position: Vector3(0, 0, 0),
  type: NavNodeType.lift,
  aliases: ['lift', 'elevator', 'staircase', 'stairs'],
);
final _f1StairsWest = NavigationNode(
  id: 'f1_sw',
  name: 'West Staircase F1',
  displayLabel: 'W.STAIRS F1',
  floor: 1,
  position: Vector3(-14, 0, 12),
  type: NavNodeType.staircase,
  aliases: ['west stairs', 'west staircase'],
);
final _f1StairsEast = NavigationNode(
  id: 'f1_se',
  name: 'East Staircase F1',
  displayLabel: 'E.STAIRS F1',
  floor: 1,
  position: Vector3(14, 0, 12),
  type: NavNodeType.staircase,
  aliases: ['east stairs', 'east staircase'],
);

// ── South Corridor (connects entrance to inner ring) ─────────────────────────
// This is the horizontal corridor running east-west at the south face.

final _f1CS1 = NavigationNode(
  id: 'f1_cs1',
  name: 'South Corridor W',
  displayLabel: 'S.CORR',
  floor: 1,
  position: Vector3(-8, 0, -8),
  type: NavNodeType.corridor,
  corridorHeading: 90,
);
final _f1CS2 = NavigationNode(
  id: 'f1_cs2',
  name: 'South Corridor Centre',
  displayLabel: 'S.CORR',
  floor: 1,
  position: Vector3(0, 0, -8),
  type: NavNodeType.corridor,
  corridorHeading: 90,
);
final _f1CS3 = NavigationNode(
  id: 'f1_cs3',
  name: 'South Corridor E',
  displayLabel: 'S.CORR',
  floor: 1,
  position: Vector3(8, 0, -8),
  type: NavNodeType.corridor,
  corridorHeading: 90,
);

// ── Main Inner Junction (connects all four corridor arms) ─────────────────────

final _f1JMain = NavigationNode(
  id: 'f1_jmain',
  name: 'Main Junction F1',
  displayLabel: 'JUNCTION',
  floor: 1,
  position: Vector3(0, 0, 0),
  type: NavNodeType.junction,
);

// ── West Corridor (connects inner ring to west-wing rooms) ────────────────────

final _f1CW1 = NavigationNode(
  id: 'f1_cw1',
  name: 'West Corridor S',
  displayLabel: 'W.CORR',
  floor: 1,
  position: Vector3(-8, 0, 4),
  type: NavNodeType.corridor,
  corridorHeading: 0,
);
final _f1JW = NavigationNode(
  id: 'f1_jw',
  name: 'West Junction F1',
  displayLabel: 'W.JNC',
  floor: 1,
  position: Vector3(-14, 0, 4),
  type: NavNodeType.junction,
);
final _f1CW2 = NavigationNode(
  id: 'f1_cw2',
  name: 'West Corridor N1',
  displayLabel: 'W.CORR',
  floor: 1,
  position: Vector3(-14, 0, 8),
  type: NavNodeType.corridor,
  corridorHeading: 0,
);
final _f1CW3 = NavigationNode(
  id: 'f1_cw3',
  name: 'West Corridor N2',
  displayLabel: 'W.CORR',
  floor: 1,
  position: Vector3(-14, 0, 12),
  type: NavNodeType.corridor,
  corridorHeading: 0,
);
final _f1CW4 = NavigationNode(
  id: 'f1_cw4',
  name: 'West Corridor N3',
  displayLabel: 'W.CORR',
  floor: 1,
  position: Vector3(-14, 0, 16),
  type: NavNodeType.corridor,
  corridorHeading: 0,
);

// ── East Corridor ──────────────────────────────────────────────────────────────

final _f1CE1 = NavigationNode(
  id: 'f1_ce1',
  name: 'East Corridor S',
  displayLabel: 'E.CORR',
  floor: 1,
  position: Vector3(8, 0, 4),
  type: NavNodeType.corridor,
  corridorHeading: 0,
);
final _f1JE = NavigationNode(
  id: 'f1_je',
  name: 'East Junction F1',
  displayLabel: 'E.JNC',
  floor: 1,
  position: Vector3(14, 0, 4),
  type: NavNodeType.junction,
);
final _f1CE2 = NavigationNode(
  id: 'f1_ce2',
  name: 'East Corridor N1',
  displayLabel: 'E.CORR',
  floor: 1,
  position: Vector3(14, 0, 8),
  type: NavNodeType.corridor,
  corridorHeading: 0,
);
final _f1CE3 = NavigationNode(
  id: 'f1_ce3',
  name: 'East Corridor N2',
  displayLabel: 'E.CORR',
  floor: 1,
  position: Vector3(14, 0, 12),
  type: NavNodeType.corridor,
  corridorHeading: 0,
);
final _f1CE4 = NavigationNode(
  id: 'f1_ce4',
  name: 'East Corridor N3',
  displayLabel: 'E.CORR',
  floor: 1,
  position: Vector3(14, 0, 16),
  type: NavNodeType.corridor,
  corridorHeading: 0,
);

// ── North Corridor ──────────────────────────────────────────────────────────────

final _f1JNW = NavigationNode(
  id: 'f1_jnw',
  name: 'North-West Junction F1',
  displayLabel: 'NW.JNC',
  floor: 1,
  position: Vector3(-14, 0, 20),
  type: NavNodeType.junction,
);
final _f1CN1 = NavigationNode(
  id: 'f1_cn1',
  name: 'North Corridor W',
  displayLabel: 'N.CORR',
  floor: 1,
  position: Vector3(-8, 0, 20),
  type: NavNodeType.corridor,
  corridorHeading: 90,
);
final _f1JN = NavigationNode(
  id: 'f1_jn',
  name: 'North Junction F1',
  displayLabel: 'N.JNC',
  floor: 1,
  position: Vector3(0, 0, 20),
  type: NavNodeType.junction,
);
final _f1CN2 = NavigationNode(
  id: 'f1_cn2',
  name: 'North Corridor E',
  displayLabel: 'N.CORR',
  floor: 1,
  position: Vector3(8, 0, 20),
  type: NavNodeType.corridor,
  corridorHeading: 90,
);
final _f1JNE = NavigationNode(
  id: 'f1_jne',
  name: 'North-East Junction F1',
  displayLabel: 'NE.JNC',
  floor: 1,
  position: Vector3(14, 0, 20),
  type: NavNodeType.junction,
);

// ── Floor 1 Room Door Nodes ────────────────────────────────────────────────────
// Door nodes sit 0.5m into the corridor at the room opening.
// This ensures pathfinding never enters a room to reach another room.

final _d2101 = NavigationNode(
    id: 'd_2101',
    name: 'Door 2101',
    displayLabel: 'DR-2101',
    floor: 1,
    position: Vector3(-6, 0, -6),
    type: NavNodeType.door);
final _d2102 = NavigationNode(
    id: 'd_2102',
    name: 'Door 2102',
    displayLabel: 'DR-2102',
    floor: 1,
    position: Vector3(-10, 0, -6),
    type: NavNodeType.door);
final _dRec = NavigationNode(
    id: 'd_rec',
    name: 'Door Reception',
    displayLabel: 'DR-REC',
    floor: 1,
    position: Vector3(3, 0, -10),
    type: NavNodeType.door);
final _dIT16 = NavigationNode(
    id: 'd_2116',
    name: 'Door IT Dep',
    displayLabel: 'DR-2116',
    floor: 1,
    position: Vector3(8, 0, -10),
    type: NavNodeType.door);
final _dIT = NavigationNode(
    id: 'd_its',
    name: 'Door IT Service',
    displayLabel: 'DR-ITS',
    floor: 1,
    position: Vector3(12, 0, -10),
    type: NavNodeType.door);
final _d2103 = NavigationNode(
    id: 'd_2103',
    name: 'Door 2103',
    displayLabel: 'DR-2103',
    floor: 1,
    position: Vector3(-13, 0, 6),
    type: NavNodeType.door);
final _d2104 = NavigationNode(
    id: 'd_2104',
    name: 'Door 2104',
    displayLabel: 'DR-2104',
    floor: 1,
    position: Vector3(-13, 0, 10),
    type: NavNodeType.door);
final _d2105 = NavigationNode(
    id: 'd_2105',
    name: 'Door 2105',
    displayLabel: 'DR-2105',
    floor: 1,
    position: Vector3(-13, 0, 14),
    type: NavNodeType.door);
final _d2106 = NavigationNode(
    id: 'd_2106',
    name: 'Door 2106',
    displayLabel: 'DR-2106',
    floor: 1,
    position: Vector3(-13, 0, 18),
    type: NavNodeType.door);
final _d2107 = NavigationNode(
    id: 'd_2107',
    name: 'Door 2107',
    displayLabel: 'DR-2107',
    floor: 1,
    position: Vector3(-12, 0, 21),
    type: NavNodeType.door);
final _d2108 = NavigationNode(
    id: 'd_2108',
    name: 'Door 2108',
    displayLabel: 'DR-2108',
    floor: 1,
    position: Vector3(-6, 0, 21),
    type: NavNodeType.door);
final _d2109 = NavigationNode(
    id: 'd_2109',
    name: 'Door 2109',
    displayLabel: 'DR-2109',
    floor: 1,
    position: Vector3(0, 0, 21),
    type: NavNodeType.door);
final _d2110 = NavigationNode(
    id: 'd_2110',
    name: 'Door 2110',
    displayLabel: 'DR-2110',
    floor: 1,
    position: Vector3(8, 0, 21),
    type: NavNodeType.door);
final _d2112 = NavigationNode(
    id: 'd_2112',
    name: 'Door 2112',
    displayLabel: 'DR-2112',
    floor: 1,
    position: Vector3(13, 0, 18),
    type: NavNodeType.door);
final _d2113 = NavigationNode(
    id: 'd_2113',
    name: 'Door 2113',
    displayLabel: 'DR-2113',
    floor: 1,
    position: Vector3(13, 0, 14),
    type: NavNodeType.door);
final _d2114 = NavigationNode(
    id: 'd_2114',
    name: 'Door 2114',
    displayLabel: 'DR-2114',
    floor: 1,
    position: Vector3(13, 0, 10),
    type: NavNodeType.door);
final _d2115 = NavigationNode(
    id: 'd_2115',
    name: 'Door 2115',
    displayLabel: 'DR-2115',
    floor: 1,
    position: Vector3(13, 0, 6),
    type: NavNodeType.door);
final _d2118 = NavigationNode(
    id: 'd_2118',
    name: 'Door Dean',
    displayLabel: 'DR-DEAN',
    floor: 1,
    position: Vector3(-3, 0, 1),
    type: NavNodeType.door);
final _d2119 = NavigationNode(
    id: 'd_2119',
    name: 'Door HOD',
    displayLabel: 'DR-HOD',
    floor: 1,
    position: Vector3(-4, 0, 4),
    type: NavNodeType.door);

// ── Floor 1 Rooms ──────────────────────────────────────────────────────────────

final _r2101 = NavigationNode(
    id: 'r_2101',
    name: 'IoT Lab / AI ML Lab 2101',
    displayLabel: '2101',
    floor: 1,
    position: Vector3(-8, 0, -6),
    type: NavNodeType.room,
    aliases: ['2101', 'iot lab', 'ai ml lab', 'aiml lab', 'iot', 'ai ml'],
    doorNodeId: 'd_2101');
final _r2102 = NavigationNode(
    id: 'r_2102',
    name: 'Lab 2102',
    displayLabel: '2102',
    floor: 1,
    position: Vector3(-13, 0, -6),
    type: NavNodeType.room,
    aliases: ['2102', 'lab 2102'],
    doorNodeId: 'd_2102');
final _rRec = NavigationNode(
    id: 'r_rec',
    name: 'Reception Room 2117',
    displayLabel: 'RECEPTION',
    floor: 1,
    position: Vector3(4, 0, -13),
    type: NavNodeType.room,
    aliases: ['reception', '2117', 'reception rm'],
    doorNodeId: 'd_rec');
final _rIT16 = NavigationNode(
    id: 'r_2116',
    name: 'IT Dep Office 2116',
    displayLabel: '2116',
    floor: 1,
    position: Vector3(10, 0, -13),
    type: NavNodeType.room,
    aliases: ['2116', 'it dep', 'it office', 'it dep office'],
    doorNodeId: 'd_2116');
final _rITS = NavigationNode(
    id: 'r_its',
    name: 'IT Service Centre',
    displayLabel: 'IT SERVICE',
    floor: 1,
    position: Vector3(14, 0, -13),
    type: NavNodeType.room,
    aliases: ['it service centre', 'it service', 'service centre'],
    doorNodeId: 'd_its');
final _r2103 = NavigationNode(
    id: 'r_2103',
    name: 'Open Service Software Lab 2103',
    displayLabel: '2103',
    floor: 1,
    position: Vector3(-17, 0, 6),
    type: NavNodeType.room,
    aliases: ['2103', 'open service software', 'oss lab'],
    doorNodeId: 'd_2103');
final _r2104 = NavigationNode(
    id: 'r_2104',
    name: 'Operating System Lab 2104',
    displayLabel: '2104',
    floor: 1,
    position: Vector3(-17, 0, 10),
    type: NavNodeType.room,
    aliases: ['2104', 'operating system lab', 'os lab'],
    doorNodeId: 'd_2104');
final _r2105 = NavigationNode(
    id: 'r_2105',
    name: 'Computer Network Lab 2105',
    displayLabel: '2105',
    floor: 1,
    position: Vector3(-17, 0, 14),
    type: NavNodeType.room,
    aliases: ['2105', 'computer network', 'cn lab', 'network lab'],
    doorNodeId: 'd_2105');
final _r2106 = NavigationNode(
    id: 'r_2106',
    name: 'DBSM Lab 2106',
    displayLabel: '2106',
    floor: 1,
    position: Vector3(-17, 0, 18),
    type: NavNodeType.room,
    aliases: ['2106', 'dbsm lab', 'dbsm'],
    doorNodeId: 'd_2106');
final _r2107 = NavigationNode(
    id: 'r_2107',
    name: 'Data Structural Lab 2107',
    displayLabel: '2107',
    floor: 1,
    position: Vector3(-16, 0, 24),
    type: NavNodeType.room,
    aliases: ['2107', 'data structural lab', 'ds lab', 'data structure'],
    doorNodeId: 'd_2107');
final _r2108 = NavigationNode(
    id: 'r_2108',
    name: 'CAD/CAM Lab 2108',
    displayLabel: '2108',
    floor: 1,
    position: Vector3(-8, 0, 24),
    type: NavNodeType.room,
    aliases: ['2108', 'cad cam lab', 'cad cam', 'cadcam'],
    doorNodeId: 'd_2108');
final _r2109 = NavigationNode(
    id: 'r_2109',
    name: 'Research & Project Lab 2109',
    displayLabel: '2109',
    floor: 1,
    position: Vector3(2, 0, 24),
    type: NavNodeType.room,
    aliases: ['2109', 'research lab', 'project lab', 'research project'],
    doorNodeId: 'd_2109');
final _r2110 = NavigationNode(
    id: 'r_2110',
    name: 'VLSI Design Lab 2110',
    displayLabel: '2110',
    floor: 1,
    position: Vector3(10, 0, 24),
    type: NavNodeType.room,
    aliases: ['2110', 'vlsi design lab', 'vlsi', 'vlsi lab'],
    doorNodeId: 'd_2110');
final _r2112 = NavigationNode(
    id: 'r_2112',
    name: 'Embedded System Lab 2112',
    displayLabel: '2112',
    floor: 1,
    position: Vector3(18, 0, 18),
    type: NavNodeType.room,
    aliases: ['2112', 'embedded system lab', 'embedded systems', 'esl'],
    doorNodeId: 'd_2112');
final _r2113 = NavigationNode(
    id: 'r_2113',
    name: 'ECE Computing Lab 2113',
    displayLabel: '2113',
    floor: 1,
    position: Vector3(18, 0, 14),
    type: NavNodeType.room,
    aliases: ['2113', 'ece computing lab', 'ece computing', 'ece lab'],
    doorNodeId: 'd_2113');
final _r2114 = NavigationNode(
    id: 'r_2114',
    name: 'Store 2114',
    displayLabel: '2114',
    floor: 1,
    position: Vector3(18, 0, 10),
    type: NavNodeType.room,
    aliases: ['2114', 'store', 'storage'],
    doorNodeId: 'd_2114');
final _r2115 = NavigationNode(
    id: 'r_2115',
    name: 'Classroom 2115',
    displayLabel: '2115',
    floor: 1,
    position: Vector3(18, 0, 6),
    type: NavNodeType.room,
    aliases: ['2115', 'classroom 2115'],
    doorNodeId: 'd_2115');
final _r2118 = NavigationNode(
    id: 'r_2118',
    name: 'Dean Room 2118',
    displayLabel: '2118 DEAN',
    floor: 1,
    position: Vector3(-5, 0, 1),
    type: NavNodeType.room,
    aliases: ['2118', 'dean room', 'dean office', 'dean'],
    doorNodeId: 'd_2118');
final _r2119 = NavigationNode(
    id: 'r_2119',
    name: 'HOD CSE 2119',
    displayLabel: '2119 HOD',
    floor: 1,
    position: Vector3(-6, 0, 5),
    type: NavNodeType.room,
    aliases: ['2119', 'hod cse', 'hod office', 'hod'],
    doorNodeId: 'd_2119');

// ═══════════════════════════════════════════════════════════════════════════════
// FLOOR 2 NODES
// ═══════════════════════════════════════════════════════════════════════════════

final _f2Lift = NavigationNode(
  id: 'f2_lift',
  name: 'Lift / Main Stairs F2',
  displayLabel: 'LIFT F2',
  floor: 2,
  position: Vector3(0, 4, 0),
  type: NavNodeType.lift,
  aliases: ['lift', 'elevator', 'staircase', 'stairs'],
);
final _f2StairsWest = NavigationNode(
  id: 'f2_sw',
  name: 'West Staircase F2',
  displayLabel: 'W.STAIRS F2',
  floor: 2,
  position: Vector3(-14, 4, 12),
  type: NavNodeType.staircase,
);
final _f2StairsEast = NavigationNode(
  id: 'f2_se',
  name: 'East Staircase F2',
  displayLabel: 'E.STAIRS F2',
  floor: 2,
  position: Vector3(14, 4, 12),
  type: NavNodeType.staircase,
);

// ── Floor 2 Corridor Spine ────────────────────────────────────────────────────

final _f2JMain = NavigationNode(
    id: 'f2_jmain',
    name: 'Main Junction F2',
    displayLabel: 'JUNCTION',
    floor: 2,
    position: Vector3(0, 4, 0),
    type: NavNodeType.junction);
final _f2CS2 = NavigationNode(
    id: 'f2_cs2',
    name: 'South Corridor F2',
    displayLabel: 'S.CORR F2',
    floor: 2,
    position: Vector3(0, 4, -8),
    type: NavNodeType.corridor,
    corridorHeading: 0);

final _f2CW1 = NavigationNode(
    id: 'f2_cw1',
    name: 'West Corridor S F2',
    displayLabel: 'W.CORR F2',
    floor: 2,
    position: Vector3(-8, 4, 4),
    type: NavNodeType.corridor,
    corridorHeading: 0);
final _f2JW = NavigationNode(
    id: 'f2_jw',
    name: 'West Junction F2',
    displayLabel: 'W.JNC F2',
    floor: 2,
    position: Vector3(-14, 4, 4),
    type: NavNodeType.junction);
final _f2CW2 = NavigationNode(
    id: 'f2_cw2',
    name: 'West Corridor N1 F2',
    displayLabel: 'W.CORR F2',
    floor: 2,
    position: Vector3(-14, 4, 8),
    type: NavNodeType.corridor,
    corridorHeading: 0);
final _f2CW3 = NavigationNode(
    id: 'f2_cw3',
    name: 'West Corridor N2 F2',
    displayLabel: 'W.CORR F2',
    floor: 2,
    position: Vector3(-14, 4, 16),
    type: NavNodeType.corridor,
    corridorHeading: 0);

final _f2CE1 = NavigationNode(
    id: 'f2_ce1',
    name: 'East Corridor S F2',
    displayLabel: 'E.CORR F2',
    floor: 2,
    position: Vector3(8, 4, 4),
    type: NavNodeType.corridor,
    corridorHeading: 0);
final _f2JE = NavigationNode(
    id: 'f2_je',
    name: 'East Junction F2',
    displayLabel: 'E.JNC F2',
    floor: 2,
    position: Vector3(14, 4, 4),
    type: NavNodeType.junction);
final _f2CE2 = NavigationNode(
    id: 'f2_ce2',
    name: 'East Corridor N1 F2',
    displayLabel: 'E.CORR F2',
    floor: 2,
    position: Vector3(14, 4, 8),
    type: NavNodeType.corridor,
    corridorHeading: 0);
final _f2CE3 = NavigationNode(
    id: 'f2_ce3',
    name: 'East Corridor N2 F2',
    displayLabel: 'E.CORR F2',
    floor: 2,
    position: Vector3(14, 4, 16),
    type: NavNodeType.corridor,
    corridorHeading: 0);

final _f2JNW = NavigationNode(
    id: 'f2_jnw',
    name: 'NW Junction F2',
    displayLabel: 'NW.JNC F2',
    floor: 2,
    position: Vector3(-14, 4, 20),
    type: NavNodeType.junction);
final _f2CN1 = NavigationNode(
    id: 'f2_cn1',
    name: 'North Corridor W F2',
    displayLabel: 'N.CORR F2',
    floor: 2,
    position: Vector3(-8, 4, 20),
    type: NavNodeType.corridor,
    corridorHeading: 90);
final _f2JN = NavigationNode(
    id: 'f2_jn',
    name: 'North Junction F2',
    displayLabel: 'N.JNC F2',
    floor: 2,
    position: Vector3(0, 4, 20),
    type: NavNodeType.junction);
final _f2CN2 = NavigationNode(
    id: 'f2_cn2',
    name: 'North Corridor E F2',
    displayLabel: 'N.CORR F2',
    floor: 2,
    position: Vector3(8, 4, 20),
    type: NavNodeType.corridor,
    corridorHeading: 90);
final _f2JNE = NavigationNode(
    id: 'f2_jne',
    name: 'NE Junction F2',
    displayLabel: 'NE.JNC F2',
    floor: 2,
    position: Vector3(14, 4, 20),
    type: NavNodeType.junction);

// ── Floor 2 Door Nodes ────────────────────────────────────────────────────────

final _d2201B = NavigationNode(
    id: 'd_2201b',
    name: 'Door 2201B',
    displayLabel: 'DR-2201B',
    floor: 2,
    position: Vector3(-13, 4, 6),
    type: NavNodeType.door);
final _d2202B = NavigationNode(
    id: 'd_2202b',
    name: 'Door 2202B',
    displayLabel: 'DR-2202B',
    floor: 2,
    position: Vector3(-13, 4, 10),
    type: NavNodeType.door);
final _d2202A = NavigationNode(
    id: 'd_2202a',
    name: 'Door 2202A',
    displayLabel: 'DR-2202A',
    floor: 2,
    position: Vector3(-13, 4, 14),
    type: NavNodeType.door);
final _d2203A = NavigationNode(
    id: 'd_2203a',
    name: 'Door 2203A',
    displayLabel: 'DR-2203A',
    floor: 2,
    position: Vector3(-13, 4, 18),
    type: NavNodeType.door);
final _d2203B = NavigationNode(
    id: 'd_2203b',
    name: 'Door 2203B',
    displayLabel: 'DR-2203B',
    floor: 2,
    position: Vector3(-13, 4, 21),
    type: NavNodeType.door);
final _d2204 = NavigationNode(
    id: 'd_2204',
    name: 'Door Library',
    displayLabel: 'DR-LIB',
    floor: 2,
    position: Vector3(-8, 4, 21),
    type: NavNodeType.door);
final _d2110IBM = NavigationNode(
    id: 'd_2110ibm',
    name: 'Door IBM',
    displayLabel: 'DR-IBM',
    floor: 2,
    position: Vector3(8, 4, 21),
    type: NavNodeType.door);
final _d2206L1 = NavigationNode(
    id: 'd_2206l1',
    name: 'Door Lab-1',
    displayLabel: 'DR-LAB1',
    floor: 2,
    position: Vector3(13, 4, 18),
    type: NavNodeType.door);
final _d2207 = NavigationNode(
    id: 'd_2207',
    name: 'Door Lab-2 2207',
    displayLabel: 'DR-2207',
    floor: 2,
    position: Vector3(13, 4, 14),
    type: NavNodeType.door);
final _d2206L2 = NavigationNode(
    id: 'd_2206l2',
    name: 'Door Lab-2 2206',
    displayLabel: 'DR-2206',
    floor: 2,
    position: Vector3(13, 4, 10),
    type: NavNodeType.door);
final _d2208B = NavigationNode(
    id: 'd_2208b',
    name: 'Door 2208B',
    displayLabel: 'DR-2208B',
    floor: 2,
    position: Vector3(13, 4, 4),
    type: NavNodeType.door);
final _d2201A = NavigationNode(
    id: 'd_2201a',
    name: 'Door 2201A',
    displayLabel: 'DR-2201A',
    floor: 2,
    position: Vector3(-6, 4, -6),
    type: NavNodeType.door);
final _d2208A = NavigationNode(
    id: 'd_2208a',
    name: 'Door 2208A',
    displayLabel: 'DR-2208A',
    floor: 2,
    position: Vector3(4, 4, -6),
    type: NavNodeType.door);
final _dDoubleHT = NavigationNode(
    id: 'd_dht',
    name: 'Door Double HT',
    displayLabel: 'DR-DHT',
    floor: 2,
    position: Vector3(-1, 4, -6),
    type: NavNodeType.door);

// ── Floor 2 Rooms ──────────────────────────────────────────────────────────────

final _r2201B = NavigationNode(
    id: 'r_2201b',
    name: 'Classroom 2201 B',
    displayLabel: '2201B',
    floor: 2,
    position: Vector3(-17, 4, 6),
    type: NavNodeType.room,
    aliases: ['2201b', '2201 b', 'classroom 2201b'],
    doorNodeId: 'd_2201b');
final _r2202B = NavigationNode(
    id: 'r_2202b',
    name: 'Classroom 2202 B',
    displayLabel: '2202B',
    floor: 2,
    position: Vector3(-17, 4, 10),
    type: NavNodeType.room,
    aliases: ['2202b', '2202 b', 'classroom 2202b'],
    doorNodeId: 'd_2202b');
final _r2202A = NavigationNode(
    id: 'r_2202a',
    name: 'Classroom 2202 A',
    displayLabel: '2202A',
    floor: 2,
    position: Vector3(-17, 4, 14),
    type: NavNodeType.room,
    aliases: ['2202a', '2202 a', 'classroom 2202a'],
    doorNodeId: 'd_2202a');
final _r2203A = NavigationNode(
    id: 'r_2203a',
    name: 'Classroom 2203 A',
    displayLabel: '2203A',
    floor: 2,
    position: Vector3(-17, 4, 18),
    type: NavNodeType.room,
    aliases: ['2203a', '2203 a', 'classroom 2203a'],
    doorNodeId: 'd_2203a');
final _r2203B = NavigationNode(
    id: 'r_2203b',
    name: 'Classroom 2303 B',
    displayLabel: '2303B',
    floor: 2,
    position: Vector3(-17, 4, 22),
    type: NavNodeType.room,
    aliases: ['2303b', '2303 b', '2203b', 'classroom 2303b'],
    doorNodeId: 'd_2203b');
final _r2204 = NavigationNode(
    id: 'r_2204',
    name: 'Dep Library CSE 2204',
    displayLabel: '2204 LIB',
    floor: 2,
    position: Vector3(-10, 4, 24),
    type: NavNodeType.room,
    aliases: [
      '2204',
      'dep library cse',
      'cse library',
      'library',
      'dep library'
    ],
    doorNodeId: 'd_2204');
final _r2110IBM = NavigationNode(
    id: 'r_2110ibm',
    name: 'IBM Centre Computer Centre 2110',
    displayLabel: '2110 IBM',
    floor: 2,
    position: Vector3(10, 4, 24),
    type: NavNodeType.room,
    aliases: ['2110', 'ibm centre', 'computer centre', 'ibm', 'ibm center'],
    doorNodeId: 'd_2110ibm');
final _r2206L1 = NavigationNode(
    id: 'r_2206l1',
    name: 'Lab-1 2206',
    displayLabel: '2206 LAB1',
    floor: 2,
    position: Vector3(18, 4, 18),
    type: NavNodeType.room,
    aliases: ['2206', 'lab-1 2206', 'lab 1 2206', 'lab 1'],
    doorNodeId: 'd_2206l1');
final _r2207 = NavigationNode(
    id: 'r_2207',
    name: 'Lab-2 2207',
    displayLabel: '2207',
    floor: 2,
    position: Vector3(18, 4, 14),
    type: NavNodeType.room,
    aliases: ['2207', 'lab-2 2207', 'lab 2 2207'],
    doorNodeId: 'd_2207');
final _r2206L2 = NavigationNode(
    id: 'r_2206l2',
    name: 'Lab-2 2206',
    displayLabel: '2206 LAB2',
    floor: 2,
    position: Vector3(18, 4, 10),
    type: NavNodeType.room,
    aliases: ['lab-2 2206', 'lab 2 2206'],
    doorNodeId: 'd_2206l2');
final _r2208B = NavigationNode(
    id: 'r_2208b',
    name: 'Room 2208 B',
    displayLabel: '2208B',
    floor: 2,
    position: Vector3(18, 4, 4),
    type: NavNodeType.room,
    aliases: ['2208b', '2208 b', 'room 2208b'],
    doorNodeId: 'd_2208b');
final _r2201A = NavigationNode(
    id: 'r_2201a',
    name: 'Dep Computer Science 2201 A',
    displayLabel: '2201A',
    floor: 2,
    position: Vector3(-9, 4, -10),
    type: NavNodeType.room,
    aliases: [
      '2201a',
      '2201 a',
      'dep computer science',
      'dept cse',
      'computer science dept'
    ],
    doorNodeId: 'd_2201a');
final _r2208A = NavigationNode(
    id: 'r_2208a',
    name: 'Lab-2 2208 A',
    displayLabel: '2208A',
    floor: 2,
    position: Vector3(6, 4, -10),
    type: NavNodeType.room,
    aliases: ['2208a', '2208 a', 'lab 2208a'],
    doorNodeId: 'd_2208a');
final _rDoubleHT = NavigationNode(
    id: 'r_dht',
    name: 'Double HT Area',
    displayLabel: 'DOUBLE HT',
    floor: 2,
    position: Vector3(-1, 4, -10),
    type: NavNodeType.room,
    aliases: ['double ht', 'double ht area', 'ht area'],
    doorNodeId: 'd_dht');

// ═══════════════════════════════════════════════════════════════════════════════
// FULL GRAPH ASSEMBLY
// ═══════════════════════════════════════════════════════════════════════════════

final CampusGraph computingBlockGraph = CampusGraph(
  nodes: [
    // ── F1 Infrastructure ──
    _f1Entrance, _f1Lift, _f1StairsWest, _f1StairsEast,
    // ── F1 South Corridors ──
    _f1CS1, _f1CS2, _f1CS3,
    // ── F1 Main Junction ──
    _f1JMain,
    // ── F1 West Wing ──
    _f1CW1, _f1JW, _f1CW2, _f1CW3, _f1CW4,
    // ── F1 East Wing ──
    _f1CE1, _f1JE, _f1CE2, _f1CE3, _f1CE4,
    // ── F1 North ──
    _f1JNW, _f1CN1, _f1JN, _f1CN2, _f1JNE,
    // ── F1 Door Nodes ──
    _d2101, _d2102, _dRec, _dIT16, _dIT,
    _d2103, _d2104, _d2105, _d2106,
    _d2107, _d2108, _d2109, _d2110,
    _d2112, _d2113, _d2114, _d2115,
    _d2118, _d2119,
    // ── F1 Rooms ──
    _r2101, _r2102, _rRec, _rIT16, _rITS,
    _r2103, _r2104, _r2105, _r2106,
    _r2107, _r2108, _r2109, _r2110,
    _r2112, _r2113, _r2114, _r2115,
    _r2118, _r2119,
    // ── F2 Infrastructure ──
    _f2Lift, _f2StairsWest, _f2StairsEast,
    // ── F2 Corridors ──
    _f2JMain, _f2CS2,
    _f2CW1, _f2JW, _f2CW2, _f2CW3,
    _f2CE1, _f2JE, _f2CE2, _f2CE3,
    _f2JNW, _f2CN1, _f2JN, _f2CN2, _f2JNE,
    // ── F2 Door Nodes ──
    _d2201B, _d2202B, _d2202A, _d2203A, _d2203B,
    _d2204, _d2110IBM, _d2206L1, _d2207, _d2206L2,
    _d2208B, _d2201A, _d2208A, _dDoubleHT,
    // ── F2 Rooms ──
    _r2201B, _r2202B, _r2202A, _r2203A, _r2203B,
    _r2204, _r2110IBM, _r2206L1, _r2207, _r2206L2,
    _r2208B, _r2201A, _r2208A, _rDoubleHT,
  ],
  edges: [
    // ════════════════════════════════════════════════
    // FLOOR 1 CORRIDOR CONNECTIVITY
    // All edges are corridor-to-corridor or corridor-to-door.
    // NEVER room-to-room or room-to-remote-corridor.
    // ════════════════════════════════════════════════

    // Entrance → South Corridor
    const NavigationEdge(fromId: 'f1_ent', toId: 'f1_cs2', distance: 8),
    const NavigationEdge(fromId: 'f1_cs2', toId: 'f1_cs1', distance: 8),
    const NavigationEdge(fromId: 'f1_cs2', toId: 'f1_cs3', distance: 8),

    // South Corridor → Main Junction (north into building)
    const NavigationEdge(fromId: 'f1_cs2', toId: 'f1_jmain', distance: 8),
    const NavigationEdge(fromId: 'f1_lift', toId: 'f1_jmain', distance: 0.5),

    // Main Junction → West arm
    const NavigationEdge(fromId: 'f1_jmain', toId: 'f1_cw1', distance: 8),
    const NavigationEdge(fromId: 'f1_cw1', toId: 'f1_jw', distance: 6),
    const NavigationEdge(fromId: 'f1_jw', toId: 'f1_cw2', distance: 4),
    const NavigationEdge(fromId: 'f1_cw2', toId: 'f1_sw', distance: 4), // West stairs
    const NavigationEdge(fromId: 'f1_cw2', toId: 'f1_cw3', distance: 4),
    const NavigationEdge(fromId: 'f1_cw3', toId: 'f1_cw4', distance: 4),
    const NavigationEdge(fromId: 'f1_cw4', toId: 'f1_jnw', distance: 4),

    // Main Junction → East arm
    const NavigationEdge(fromId: 'f1_jmain', toId: 'f1_ce1', distance: 8),
    const NavigationEdge(fromId: 'f1_ce1', toId: 'f1_je', distance: 6),
    const NavigationEdge(fromId: 'f1_je', toId: 'f1_ce2', distance: 4),
    const NavigationEdge(fromId: 'f1_ce2', toId: 'f1_se', distance: 4), // East stairs
    const NavigationEdge(fromId: 'f1_ce2', toId: 'f1_ce3', distance: 4),
    const NavigationEdge(fromId: 'f1_ce3', toId: 'f1_ce4', distance: 4),
    const NavigationEdge(fromId: 'f1_ce4', toId: 'f1_jne', distance: 4),

    // North Corridor connecting NW ↔ N ↔ NE
    const NavigationEdge(fromId: 'f1_jnw', toId: 'f1_cn1', distance: 6),
    const NavigationEdge(fromId: 'f1_cn1', toId: 'f1_jn', distance: 6),
    const NavigationEdge(fromId: 'f1_jn', toId: 'f1_cn2', distance: 6),
    const NavigationEdge(fromId: 'f1_cn2', toId: 'f1_jne', distance: 6),

    // Dean/HOD inner zone
    const NavigationEdge(fromId: 'f1_jmain', toId: 'd_2118', distance: 3),
    const NavigationEdge(fromId: 'f1_cw1', toId: 'd_2119', distance: 3),

    // South rooms (door → corridor connections)
    const NavigationEdge(fromId: 'f1_cs1', toId: 'd_2101', distance: 2),
    const NavigationEdge(fromId: 'f1_cs1', toId: 'd_2102', distance: 4),
    const NavigationEdge(fromId: 'f1_cs3', toId: 'd_rec', distance: 2),
    const NavigationEdge(fromId: 'f1_cs3', toId: 'd_2116', distance: 4),
    const NavigationEdge(fromId: 'f1_cs3', toId: 'd_its', distance: 6),

    // West-wing room doors → corridor
    const NavigationEdge(fromId: 'f1_jw', toId: 'd_2103', distance: 2),
    const NavigationEdge(fromId: 'f1_cw2', toId: 'd_2104', distance: 2),
    const NavigationEdge(fromId: 'f1_cw3', toId: 'd_2105', distance: 2),
    const NavigationEdge(fromId: 'f1_cw4', toId: 'd_2106', distance: 2),

    // North-wing room doors → corridor
    const NavigationEdge(fromId: 'f1_jnw', toId: 'd_2107', distance: 2),
    const NavigationEdge(fromId: 'f1_cn1', toId: 'd_2108', distance: 2),
    const NavigationEdge(fromId: 'f1_jn', toId: 'd_2109', distance: 2),
    const NavigationEdge(fromId: 'f1_cn2', toId: 'd_2110', distance: 2),

    // East-wing room doors → corridor
    const NavigationEdge(fromId: 'f1_ce4', toId: 'd_2112', distance: 2),
    const NavigationEdge(fromId: 'f1_ce3', toId: 'd_2113', distance: 2),
    const NavigationEdge(fromId: 'f1_ce2', toId: 'd_2114', distance: 2),
    const NavigationEdge(fromId: 'f1_je', toId: 'd_2115', distance: 2),

    // Door → Room (final 1-step hop into room)
    const NavigationEdge(fromId: 'd_2101', toId: 'r_2101', distance: 2),
    const NavigationEdge(fromId: 'd_2102', toId: 'r_2102', distance: 3),
    const NavigationEdge(fromId: 'd_rec', toId: 'r_rec', distance: 3),
    const NavigationEdge(fromId: 'd_2116', toId: 'r_2116', distance: 3),
    const NavigationEdge(fromId: 'd_its', toId: 'r_its', distance: 2),
    const NavigationEdge(fromId: 'd_2103', toId: 'r_2103', distance: 4),
    const NavigationEdge(fromId: 'd_2104', toId: 'r_2104', distance: 4),
    const NavigationEdge(fromId: 'd_2105', toId: 'r_2105', distance: 4),
    const NavigationEdge(fromId: 'd_2106', toId: 'r_2106', distance: 4),
    const NavigationEdge(fromId: 'd_2107', toId: 'r_2107', distance: 4),
    const NavigationEdge(fromId: 'd_2108', toId: 'r_2108', distance: 4),
    const NavigationEdge(fromId: 'd_2109', toId: 'r_2109', distance: 4),
    const NavigationEdge(fromId: 'd_2110', toId: 'r_2110', distance: 4),
    const NavigationEdge(fromId: 'd_2112', toId: 'r_2112', distance: 4),
    const NavigationEdge(fromId: 'd_2113', toId: 'r_2113', distance: 4),
    const NavigationEdge(fromId: 'd_2114', toId: 'r_2114', distance: 4),
    const NavigationEdge(fromId: 'd_2115', toId: 'r_2115', distance: 4),
    const NavigationEdge(fromId: 'd_2118', toId: 'r_2118', distance: 2),
    const NavigationEdge(fromId: 'd_2119', toId: 'r_2119', distance: 2),

    // ════════════════════════════════════════════════
    // VERTICAL CONNECTIONS (Floor 1 ↔ Floor 2)
    // ════════════════════════════════════════════════
    const NavigationEdge(
        fromId: 'f1_lift', toId: 'f2_lift', distance: 5, isVertical: true),
    const NavigationEdge(
        fromId: 'f1_sw', toId: 'f2_sw', distance: 5, isVertical: true),
    const NavigationEdge(
        fromId: 'f1_se', toId: 'f2_se', distance: 5, isVertical: true),

    // ════════════════════════════════════════════════
    // FLOOR 2 CORRIDOR CONNECTIVITY
    // ════════════════════════════════════════════════

    const NavigationEdge(fromId: 'f2_lift', toId: 'f2_jmain', distance: 0.5),
    const NavigationEdge(fromId: 'f2_jmain', toId: 'f2_cs2', distance: 8),
    const NavigationEdge(fromId: 'f2_jmain', toId: 'f2_cw1', distance: 8),
    const NavigationEdge(fromId: 'f2_cw1', toId: 'f2_jw', distance: 6),
    const NavigationEdge(fromId: 'f2_jw', toId: 'f2_cw2', distance: 4),
    const NavigationEdge(fromId: 'f2_cw2', toId: 'f2_sw', distance: 4),
    const NavigationEdge(fromId: 'f2_cw2', toId: 'f2_cw3', distance: 8),
    const NavigationEdge(fromId: 'f2_cw3', toId: 'f2_jnw', distance: 4),
    const NavigationEdge(fromId: 'f2_jmain', toId: 'f2_ce1', distance: 8),
    const NavigationEdge(fromId: 'f2_ce1', toId: 'f2_je', distance: 6),
    const NavigationEdge(fromId: 'f2_je', toId: 'f2_ce2', distance: 4),
    const NavigationEdge(fromId: 'f2_ce2', toId: 'f2_se', distance: 4),
    const NavigationEdge(fromId: 'f2_ce2', toId: 'f2_ce3', distance: 8),
    const NavigationEdge(fromId: 'f2_ce3', toId: 'f2_jne', distance: 4),
    const NavigationEdge(fromId: 'f2_jnw', toId: 'f2_cn1', distance: 6),
    const NavigationEdge(fromId: 'f2_cn1', toId: 'f2_jn', distance: 6),
    const NavigationEdge(fromId: 'f2_jn', toId: 'f2_cn2', distance: 6),
    const NavigationEdge(fromId: 'f2_cn2', toId: 'f2_jne', distance: 6),

    // F2 West-wing door connections
    const NavigationEdge(fromId: 'f2_jw', toId: 'd_2201b', distance: 2),
    const NavigationEdge(fromId: 'f2_cw2', toId: 'd_2202b', distance: 2),
    const NavigationEdge(fromId: 'f2_cw3', toId: 'd_2202a', distance: 2),
    const NavigationEdge(fromId: 'f2_cw3', toId: 'd_2203a', distance: 4),
    const NavigationEdge(fromId: 'f2_jnw', toId: 'd_2203b', distance: 2),

    // F2 North doors
    const NavigationEdge(fromId: 'f2_cn1', toId: 'd_2204', distance: 2),
    const NavigationEdge(fromId: 'f2_cn2', toId: 'd_2110ibm', distance: 2),

    // F2 East doors
    const NavigationEdge(fromId: 'f2_ce3', toId: 'd_2206l1', distance: 2),
    const NavigationEdge(
        fromId: 'f2_cw3', toId: 'd_2207', distance: 2), // note: east side
    const NavigationEdge(fromId: 'f2_ce2', toId: 'd_2206l2', distance: 2),
    const NavigationEdge(fromId: 'f2_je', toId: 'd_2208b', distance: 2),

    // F2 South/inner doors
    const NavigationEdge(fromId: 'f2_cs2', toId: 'd_2201a', distance: 3),
    const NavigationEdge(fromId: 'f2_cs2', toId: 'd_2208a', distance: 4),
    const NavigationEdge(fromId: 'f2_cs2', toId: 'd_dht', distance: 2),

    // F2 Door → Room
    const NavigationEdge(fromId: 'd_2201b', toId: 'r_2201b', distance: 4),
    const NavigationEdge(fromId: 'd_2202b', toId: 'r_2202b', distance: 4),
    const NavigationEdge(fromId: 'd_2202a', toId: 'r_2202a', distance: 4),
    const NavigationEdge(fromId: 'd_2203a', toId: 'r_2203a', distance: 4),
    const NavigationEdge(fromId: 'd_2203b', toId: 'r_2203b', distance: 4),
    const NavigationEdge(fromId: 'd_2204', toId: 'r_2204', distance: 4),
    const NavigationEdge(fromId: 'd_2110ibm', toId: 'r_2110ibm', distance: 4),
    const NavigationEdge(fromId: 'd_2206l1', toId: 'r_2206l1', distance: 4),
    const NavigationEdge(fromId: 'd_2207', toId: 'r_2207', distance: 4),
    const NavigationEdge(fromId: 'd_2206l2', toId: 'r_2206l2', distance: 4),
    const NavigationEdge(fromId: 'd_2208b', toId: 'r_2208b', distance: 4),
    const NavigationEdge(fromId: 'd_2201a', toId: 'r_2201a', distance: 4),
    const NavigationEdge(fromId: 'd_2208a', toId: 'r_2208a', distance: 4),
    const NavigationEdge(fromId: 'd_dht', toId: 'r_dht', distance: 4),
  ],
);
