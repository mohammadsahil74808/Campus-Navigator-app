// lib/navigation/navigation_model.dart
//
// REBUILT: Full typed indoor navigation model.
// Key design principles:
//  1. Rooms NEVER connect directly to each other — only to corridor nodes
//  2. Corridor/junction nodes are the only legal pathways
//  3. Every edge has a real measured distance (meters)
//  4. Multi-floor transitions only via staircase/lift typed nodes
//  5. NavigationState is immutable — no accidental mutation

import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';

// ─── Node Types ───────────────────────────────────────────────────────────────

enum NavNodeType {
  room, // Classroom, lab, office — NOT walkable as corridor
  corridor, // Straight hallway segment — primary walkable path
  junction, // T/X/L intersection of corridors — turn decision point
  staircase, // Staircase landing — connects floors
  lift, // Elevator landing — connects floors
  entrance, // Building entry/exit point
  door, // Room door node — bridges room and corridor (1m offset into corridor)
}

// Utility: Is this node type walkable as a through-path?
extension NavNodeTypeX on NavNodeType {
  bool get isWalkable =>
      this == NavNodeType.corridor ||
      this == NavNodeType.junction ||
      this == NavNodeType.staircase ||
      this == NavNodeType.lift ||
      this == NavNodeType.entrance ||
      this == NavNodeType.door;
}

// ─── Navigation Node ─────────────────────────────────────────────────────────

class NavigationNode {
  final String id;
  final String name;
  final String displayLabel;
  final int floor;

  // Real-world XZ position in meters from building origin.
  // Origin = centre of the lift/staircase shaft at ground floor.
  // +X = East, +Z = North, Y = floor height (floor1=0, floor2=4, floor3=8)
  final Vector3 position;

  final NavNodeType type;

  // Heading of the corridor segment this node lies on (degrees, 0=North, 90=East).
  // Used to align AR arrows to real hallway direction.
  // null = omnidirectional (junctions, rooms)
  final double? corridorHeading;

  // OCR detection aliases — room number variations, abbreviations, signs
  final List<String> aliases;

  // For room nodes: which door node connects this room to its corridor
  final String? doorNodeId;

  const NavigationNode({
    required this.id,
    required this.name,
    required this.displayLabel,
    required this.floor,
    required this.position,
    required this.type,
    this.corridorHeading,
    this.aliases = const [],
    this.doorNodeId,
  });

  // 2D distance (ignores floor height)
  double floorDistanceTo(NavigationNode other) {
    final dx = position.x - other.position.x;
    final dz = position.z - other.position.z;
    return math.sqrt(dx * dx + dz * dz);
  }

  @override
  String toString() => 'Node($id @ F$floor)';
}

// ─── Navigation Edge ─────────────────────────────────────────────────────────

class NavigationEdge {
  final String fromId;
  final String toId;
  final double distance; // meters
  final bool isVertical; // true = staircase/lift transition

  const NavigationEdge({
    required this.fromId,
    required this.toId,
    required this.distance,
    this.isVertical = false,
  });
}

// ─── Turn Instruction ────────────────────────────────────────────────────────

enum TurnType {
  straight,
  slightLeft,
  turnLeft,
  sharpLeft,
  slightRight,
  turnRight,
  sharpRight,
  uTurn,
  takeStairsUp,
  takeStairsDown,
  takeLiftUp,
  takeLiftDown,
  arrived
}

extension TurnTypeLabel on TurnType {
  String get label {
    switch (this) {
      case TurnType.straight:
        return 'CONTINUE STRAIGHT';
      case TurnType.slightLeft:
        return 'BEAR LEFT';
      case TurnType.turnLeft:
        return 'TURN LEFT';
      case TurnType.sharpLeft:
        return 'SHARP LEFT';
      case TurnType.slightRight:
        return 'BEAR RIGHT';
      case TurnType.turnRight:
        return 'TURN RIGHT';
      case TurnType.sharpRight:
        return 'SHARP RIGHT';
      case TurnType.uTurn:
        return 'U-TURN';
      case TurnType.takeStairsUp:
        return 'TAKE STAIRS UP';
      case TurnType.takeStairsDown:
        return 'TAKE STAIRS DOWN';
      case TurnType.takeLiftUp:
        return 'TAKE LIFT UP';
      case TurnType.takeLiftDown:
        return 'TAKE LIFT DOWN';
      case TurnType.arrived:
        return 'YOU HAVE ARRIVED';
    }
  }
}

TurnType turnTypeFromAngle(double angleDeg,
    {bool isVertical = false, bool goingUp = false, bool isLift = false}) {
  if (isVertical) {
    if (isLift) return goingUp ? TurnType.takeLiftUp : TurnType.takeLiftDown;
    return goingUp ? TurnType.takeStairsUp : TurnType.takeStairsDown;
  }
  final a = angleDeg;
  if (a.abs() < 12) return TurnType.straight;
  if (a < -150) return TurnType.uTurn;
  if (a < -65) return TurnType.sharpLeft;
  if (a < -25) return TurnType.turnLeft;
  if (a < 0) return TurnType.slightLeft;
  if (a < 25) return TurnType.slightRight;
  if (a < 65) return TurnType.turnRight;
  if (a < 150) return TurnType.sharpRight;
  return TurnType.uTurn;
}

// ─── Campus Graph ─────────────────────────────────────────────────────────────

class CampusGraph {
  final List<NavigationNode> nodes;
  final List<NavigationEdge> edges;

  late final Map<String, NavigationNode> _byId;
  late final Map<String, List<NavigationEdge>> _edgesByNode;

  CampusGraph({required this.nodes, required this.edges}) {
    _byId = {for (final n in nodes) n.id: n};
    _edgesByNode = {};
    for (final e in edges) {
      _edgesByNode.putIfAbsent(e.fromId, () => []).add(e);
      _edgesByNode.putIfAbsent(e.toId, () => []).add(e);
    }
  }

  NavigationNode? nodeById(String id) => _byId[id];
  List<NavigationEdge> edgesFrom(String id) => _edgesByNode[id] ?? const [];

  // ── Graph Integrity Check (run at startup in debug) ───────────────────────
  List<String> validate() {
    final issues = <String>[];
    // 1. All edge endpoints must exist
    for (final e in edges) {
      if (!_byId.containsKey(e.fromId)) {
        issues.add('Edge from unknown node: ${e.fromId}');
      }
      if (!_byId.containsKey(e.toId)) {
        issues.add('Edge to unknown node: ${e.toId}');
      }
    }
    // 2. No room-to-room direct edges (must go through corridor/door)
    for (final e in edges) {
      final from = _byId[e.fromId];
      final to = _byId[e.toId];
      if (from != null &&
          to != null &&
          from.type == NavNodeType.room &&
          to.type == NavNodeType.room) {
        issues.add('ILLEGAL: direct room-to-room edge ${e.fromId} → ${e.toId}');
      }
    }
    // 3. Rooms should only connect to door or corridor nodes
    for (final e in edges) {
      final from = _byId[e.fromId];
      final to = _byId[e.toId];
      if (from?.type == NavNodeType.room && to?.type == NavNodeType.room) {
        issues.add('Room ${from!.id} connects directly to room ${to!.id}');
      }
    }
    return issues;
  }

  // ── OCR Matching ──────────────────────────────────────────────────────────
  // Returns the best matching node for raw OCR text.
  // Strategy: exact number match > long alias match > fuzzy digit match
  OcrMatchResult? matchFromOcrText(String rawText) {
    if (rawText.isEmpty) return null;

    final cleaned = _cleanOcrText(rawText);
    final words = cleaned.split(' ').where((w) => w.length >= 2).toList();

    NavigationNode? bestNode;
    double bestScore = 0;
    MatchType bestType = MatchType.none;

    for (final node in nodes) {
      final result = _scoreNode(node, cleaned, words);
      if (result.score > bestScore) {
        bestScore = result.score;
        bestNode = node;
        bestType = result.type;
      }
    }

    // Require minimum confidence: 4-digit room number = 12pts, word = variable
    if (bestScore < 8.0 || bestNode == null) return null;
    return OcrMatchResult(
        node: bestNode, score: bestScore, matchType: bestType);
  }

  _NodeScore _scoreNode(
      NavigationNode node, String cleaned, List<String> words) {
    double best = 0;
    MatchType type = MatchType.none;
    final allAliases = [
      node.displayLabel.toLowerCase(),
      node.id,
      ...node.aliases.map((a) => a.toLowerCase())
    ];

    for (final alias in allAliases) {
      // Exact substring match
      if (cleaned.contains(alias)) {
        final score = alias.length * 3.0; // 4-char room# = 12pts
        if (score > best) {
          best = score;
          type = MatchType.exact;
        }
      }
      // Digit-sequence fuzzy: allow 1 OCR digit error (e.g. "2lO7" → "2107")
      if (RegExp(r'^\d{4}$').hasMatch(alias)) {
        final digitScore = _fuzzyDigitScore(cleaned, alias);
        if (digitScore > best) {
          best = digitScore;
          type = MatchType.fuzzy;
        }
      }
    }
    // Word-level match for lab names
    for (final word in words) {
      if (word.length < 3) continue;
      for (final alias in allAliases) {
        if (alias.contains(word)) {
          final score = word.length * 1.5;
          if (score > best) {
            best = score;
            type = MatchType.wordMatch;
          }
        }
      }
    }
    return _NodeScore(score: best, type: type);
  }

  double _fuzzyDigitScore(String text, String roomNumber) {
    // Extract all 4-digit sequences from OCR text and compare char by char
    final matches = RegExp(r'\d{4}').allMatches(text);
    double best = 0;
    for (final m in matches) {
      final candidate = m.group(0)!;
      int matches4 = 0;
      for (int i = 0; i < 4; i++) {
        if (candidate[i] == roomNumber[i]) matches4++;
      }
      if (matches4 >= 3) best = math.max(best, matches4 * 3.0);
    }
    return best;
  }

  String _cleanOcrText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _NodeScore {
  final double score;
  final MatchType type;
  _NodeScore({required this.score, required this.type});
}

enum MatchType { none, exact, fuzzy, wordMatch }

class OcrMatchResult {
  final NavigationNode node;
  final double score;
  final MatchType matchType;
  OcrMatchResult(
      {required this.node, required this.score, required this.matchType});
}

// ─── Navigation State ─────────────────────────────────────────────────────────

enum ProximityZone { far, approaching, near, arrived }

class NavigationState {
  final NavigationNode? currentNode;
  final NavigationNode? targetNode;
  final List<NavigationNode> path;
  final double headingDegrees;
  final double turnAngle;
  final TurnType turnType;
  final double distanceToNextMeters;
  final double totalRemainingMeters;
  final bool isLocalizing;
  final String statusMessage;
  final LocalizationConfidence confidence;
  final ProximityZone proximityZone;
  final bool showDestinationBeacon;
  // For dead reckoning between OCR fixes
  final double estimatedMetersWalked;
  final DateTime lastOcrFix;

  NavigationState({
    this.currentNode,
    this.targetNode,
    this.path = const [],
    this.headingDegrees = 0,
    this.turnAngle = 0,
    this.turnType = TurnType.straight,
    this.distanceToNextMeters = 0,
    this.totalRemainingMeters = 0,
    this.isLocalizing = true,
    this.statusMessage = 'Point camera at a room number sign',
    this.confidence = LocalizationConfidence.none,
    this.proximityZone = ProximityZone.far,
    this.showDestinationBeacon = false,
    this.estimatedMetersWalked = 0,
    DateTime? lastOcrFix,
  }) : lastOcrFix = lastOcrFix ?? DateTime(2000);

  bool get hasPath => path.length >= 2;
  NavigationNode? get nextNode => path.length >= 2 ? path[1] : null;
  bool get isArrived => proximityZone == ProximityZone.arrived;

  NavigationState copyWith({
    NavigationNode? currentNode,
    NavigationNode? targetNode,
    List<NavigationNode>? path,
    double? headingDegrees,
    double? turnAngle,
    TurnType? turnType,
    double? distanceToNextMeters,
    double? totalRemainingMeters,
    bool? isLocalizing,
    String? statusMessage,
    LocalizationConfidence? confidence,
    ProximityZone? proximityZone,
    bool? showDestinationBeacon,
    double? estimatedMetersWalked,
    DateTime? lastOcrFix,
  }) =>
      NavigationState(
        currentNode: currentNode ?? this.currentNode,
        targetNode: targetNode ?? this.targetNode,
        path: path ?? this.path,
        headingDegrees: headingDegrees ?? this.headingDegrees,
        turnAngle: turnAngle ?? this.turnAngle,
        turnType: turnType ?? this.turnType,
        distanceToNextMeters: distanceToNextMeters ?? this.distanceToNextMeters,
        totalRemainingMeters: totalRemainingMeters ?? this.totalRemainingMeters,
        isLocalizing: isLocalizing ?? this.isLocalizing,
        statusMessage: statusMessage ?? this.statusMessage,
        confidence: confidence ?? this.confidence,
        proximityZone: proximityZone ?? this.proximityZone,
        showDestinationBeacon:
            showDestinationBeacon ?? this.showDestinationBeacon,
        estimatedMetersWalked:
            estimatedMetersWalked ?? this.estimatedMetersWalked,
        lastOcrFix: lastOcrFix ?? this.lastOcrFix,
      );
}

enum LocalizationConfidence { none, low, medium, high }
