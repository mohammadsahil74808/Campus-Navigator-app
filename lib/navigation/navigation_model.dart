import 'package:vector_math/vector_math_64.dart';

// ─── Node Types ───────────────────────────────────────────────────────────────

enum NavNodeType { room, staircase, intersection, entrance, lift }

// ─── Navigation Node ─────────────────────────────────────────────────────────

class NavigationNode {
  final String id;
  final String name;
  final String displayLabel; // Short label shown on AR overlay
  final int floor;
  final Vector3
      position; // Relative meters from building entrance (x=east, z=north, y=up)
  final NavNodeType type;
  final List<String>
      aliases; // For OCR matching (e.g. ["2101", "DBMS Lab", "IoT Lab"])

  const NavigationNode({
    required this.id,
    required this.name,
    required this.displayLabel,
    required this.floor,
    required this.position,
    required this.type,
    this.aliases = const [],
  });

  /// Euclidean distance to another node (2D floor distance only)
  double distanceTo(NavigationNode other) {
    final dx = position.x - other.position.x;
    final dz = position.z - other.position.z;
    return (dx * dx + dz * dz).abs() > 0 ? (dx * dx + dz * dz) : 0.0;
  }

  @override
  String toString() => 'Node($name, F$floor)';
}

// ─── Navigation Edge ─────────────────────────────────────────────────────────

class NavigationEdge {
  final String fromId;
  final String toId;
  final double distance; // meters
  final bool isStairOrLift; // Used for multi-floor routing hints

  const NavigationEdge({
    required this.fromId,
    required this.toId,
    required this.distance,
    this.isStairOrLift = false,
  });
}

// ─── Campus Graph ─────────────────────────────────────────────────────────────

class CampusGraph {
  final List<NavigationNode> nodes;
  final List<NavigationEdge> edges;

  // Fast lookup maps built once at construction
  late final Map<String, NavigationNode> _nodeById;
  late final Map<String, List<NavigationEdge>> _edgesByNode;

  CampusGraph({required this.nodes, required this.edges}) {
    _nodeById = {for (final n in nodes) n.id: n};
    _edgesByNode = {};
    for (final e in edges) {
      _edgesByNode.putIfAbsent(e.fromId, () => []).add(e);
      _edgesByNode.putIfAbsent(e.toId, () => []).add(e); // Undirected
    }
  }

  NavigationNode? nodeById(String id) => _nodeById[id];

  List<NavigationEdge> edgesFrom(String nodeId) =>
      _edgesByNode[nodeId] ?? const [];

  /// OCR text → best matching node
  NavigationNode? matchFromOcrText(String text) {
    final lower = text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    NavigationNode? best;
    int bestScore = 0;

    for (final node in nodes) {
      int score = 0;
      // Exact room number match is highest priority
      for (final alias in [node.displayLabel, ...node.aliases]) {
        final a = alias.toLowerCase();
        if (lower.contains(a)) {
          score = a.length; // Longer match = more specific = higher score
          break;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        best = node;
      }
    }
    return bestScore >= 3
        ? best
        : null; // Min 3-char match to avoid false positives
  }
}

// ─── Navigation State (used by ARController) ─────────────────────────────────

class NavigationState {
  final NavigationNode? currentNode;
  final NavigationNode? targetNode;
  final List<NavigationNode> path;
  final double headingDegrees;
  final double turnAngle; // Degrees: negative=left, positive=right
  final double distanceToNextMeters;
  final bool isLocalizing;
  final String statusMessage;
  final LocalizationConfidence confidence;

  const NavigationState({
    this.currentNode,
    this.targetNode,
    this.path = const [],
    this.headingDegrees = 0,
    this.turnAngle = 0,
    this.distanceToNextMeters = 0,
    this.isLocalizing = true,
    this.statusMessage = 'Point camera at a room sign to localize...',
    this.confidence = LocalizationConfidence.none,
  });

  bool get hasPath => path.length >= 2;
  NavigationNode? get nextNode => path.length >= 2 ? path[1] : null;

  NavigationState copyWith({
    NavigationNode? currentNode,
    NavigationNode? targetNode,
    List<NavigationNode>? path,
    double? headingDegrees,
    double? turnAngle,
    double? distanceToNextMeters,
    bool? isLocalizing,
    String? statusMessage,
    LocalizationConfidence? confidence,
  }) {
    return NavigationState(
      currentNode: currentNode ?? this.currentNode,
      targetNode: targetNode ?? this.targetNode,
      path: path ?? this.path,
      headingDegrees: headingDegrees ?? this.headingDegrees,
      turnAngle: turnAngle ?? this.turnAngle,
      distanceToNextMeters: distanceToNextMeters ?? this.distanceToNextMeters,
      isLocalizing: isLocalizing ?? this.isLocalizing,
      statusMessage: statusMessage ?? this.statusMessage,
      confidence: confidence ?? this.confidence,
    );
  }
}

enum LocalizationConfidence { none, low, medium, high }
