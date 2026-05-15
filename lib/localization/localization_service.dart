// lib/localization/localization_service.dart
//
// Hybrid indoor localization engine:
//
//   Layer 1 — OCR anchors (primary, high confidence when room sign visible)
//   Layer 2 — Accelerometer dead reckoning (bridges OCR gaps during walking)
//   Layer 3 — Compass heading (corrects reckoning drift)
//   Layer 4 — Graph snapping (constrains position to walkable nodes)
//
// Position is always expressed as a (nodeId, offsetMeters) pair.
// Between OCR fixes the estimated node advances via step counting.
// When a new OCR fix arrives, position jumps to the confirmed node and
// dead reckoning resets — eliminating cumulative drift.

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../navigation/navigation_model.dart';
import '../navigation/pathfinding.dart';

// ─── Step Detector ────────────────────────────────────────────────────────────
// Peak-detection on the accelerometer magnitude signal.
// Typical adult step = 0.75m. Typical stride frequency = 1.5-2.5 Hz.

class _StepDetector {
  static const double _threshold = 11.5; // m/s² peak above baseline (~9.8)
  static const int _cooldownMs = 350; // min ms between steps


  bool _rising = false;
  int _lastStepMs = 0;

  // Returns true if a step was detected in this accelerometer sample
  bool update(double ax, double ay, double az) {
    final mag = math.sqrt(ax * ax + ay * ay + az * az);
    final now = DateTime.now().millisecondsSinceEpoch;

    bool stepped = false;
    if (mag > _threshold && !_rising && (now - _lastStepMs) > _cooldownMs) {
      _rising = true;
    } else if (_rising && mag < _threshold - 1.5) {
      stepped = true;
      _rising = false;
      _lastStepMs = now;
    }

    return stepped;
  }

  void reset() {
    _rising = false;
  }
}

// ─── OCR Vote Buffer ──────────────────────────────────────────────────────────
// Accumulates OCR detection results over a sliding window.
// Only commits a position when the SAME node appears N times in M detections.
// Prevents single-frame false positives (e.g. poster text misread as room #).

class _OcrVoteBuffer {
  static const int _windowSize = 5; // keep last 5 detections
  static const int _minVotes = 3; // need 3/5 same node to confirm

  final _votes = <String>[]; // nodeId history

  /// Add a detection result. Returns confirmed nodeId if threshold met, else null.
  String? add(String nodeId) {
    _votes.add(nodeId);
    if (_votes.length > _windowSize) _votes.removeAt(0);

    // Count majority
    final counts = <String, int>{};
    for (final v in _votes) {
      counts[v] = (counts[v] ?? 0) + 1;
    }

    final best = counts.entries.reduce((a, b) => a.value > b.value ? a : b);
    if (best.value >= _minVotes) {
      clear(); // reset after confirming to avoid re-triggering same fix
      return best.key;
    }
    return null;
  }

  void clear() => _votes.clear();
}

// ─── Localization Service ─────────────────────────────────────────────────────

class LocalizationService extends ChangeNotifier {
  final CampusGraph graph;
  final PathFinder pathFinder;

  // ── Published State ────────────────────────────────────────────────────────
  NavigationNode? currentNode;
  LocalizationConfidence confidence = LocalizationConfidence.none;
  double estimatedDistanceWalked = 0; // since last OCR fix
  int stepCount = 0;

  // ── Internal ──────────────────────────────────────────────────────────────
  final _stepDetector = _StepDetector();
  final _ocrVoteBuffer = _OcrVoteBuffer();
  StreamSubscription<AccelerometerEvent>? _accelSub;

  // Dead reckoning: tracks estimated node progress along current path
  List<NavigationNode> _currentPath = [];
  int _pathIndex = 0; // which segment we think we're on
  double _segmentWalked = 0; // meters walked on current segment

  static const double _metersPerStep = 0.76;

  LocalizationService({required this.graph, required this.pathFinder});

  // ── Start / Stop ──────────────────────────────────────────────────────────

  void start() {
    _accelSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 40), // 25 Hz
    ).listen(_onAccel);
  }

  void stop() {
    _accelSub?.cancel();
    _accelSub = null;
  }

  // ── OCR Fix: called by ARController when OCR confirms a room ──────────────
  // Returns the confirmed NavigationNode if the vote threshold is met.

  NavigationNode? submitOcrDetection(NavigationNode detected) {
    final confirmedId = _ocrVoteBuffer.add(detected.id);
    if (confirmedId == null) {
      // Not yet confirmed — update confidence indicator only
      confidence = LocalizationConfidence.medium;
      notifyListeners();
      return null;
    }

    // Confirmed — anchor here
    final node = graph.nodeById(confirmedId) ?? detected;
    _anchorToNode(node);
    return node;
  }

  /// Public wrapper — called by ARController after OCR confirmation.
  void anchorToNode(NavigationNode node) => _anchorToNode(node);

  void _anchorToNode(NavigationNode node) {
    currentNode = node;
    confidence = LocalizationConfidence.high;
    estimatedDistanceWalked = 0;
    _segmentWalked = 0;
    _stepDetector.reset();
    notifyListeners();
    debugPrint('[Localization] Anchored to ${node.name}');
  }

  // ── Set Active Path (called after pathfinding) ────────────────────────────
  // Dead reckoning uses the path to estimate position advancement.

  void setActivePath(List<NavigationNode> path) {
    _currentPath = path;
    _pathIndex = 0;
    _segmentWalked = 0;
  }

  // ── Accelerometer → Step → Dead Reckoning ────────────────────────────────

  void _onAccel(AccelerometerEvent e) {
    final stepped = _stepDetector.update(e.x, e.y, e.z);
    if (!stepped) return;

    stepCount++;
    _segmentWalked += _metersPerStep;
    estimatedDistanceWalked += _metersPerStep;

    // Advance along path based on distance walked
    if (_currentPath.length > 1) {
      _advanceAlongPath();
    }

    // Decay confidence if walking without OCR fix
    if (estimatedDistanceWalked > 8 &&
        confidence == LocalizationConfidence.high) {
      confidence = LocalizationConfidence.medium;
      notifyListeners();
    } else if (estimatedDistanceWalked > 16) {
      confidence = LocalizationConfidence.low;
      notifyListeners();
    }
  }

  void _advanceAlongPath() {
    if (_pathIndex >= _currentPath.length - 1) return;

    final segStart = _currentPath[_pathIndex];
    final segEnd = _currentPath[_pathIndex + 1];
    final segLen = segStart.floorDistanceTo(segEnd);

    if (_segmentWalked >= segLen) {
      // Crossed into next segment
      _segmentWalked -= segLen;
      _pathIndex = math.min(_pathIndex + 1, _currentPath.length - 1);
      currentNode = _currentPath[_pathIndex];
      debugPrint('[Localization] DR advanced to ${currentNode!.displayLabel}');
      notifyListeners();
    }
  }

  // ── Reroute Detection ─────────────────────────────────────────────────────
  // Returns true if the user seems to have deviated from expected path.
  // Trigger: walked > 1.5× the expected segment distance without advancing.

  bool isLikelyDeviating() {
    if (_currentPath.length <= 1 || _pathIndex >= _currentPath.length - 1) {
      return false;
    }
    final expected =
        _currentPath[_pathIndex].floorDistanceTo(_currentPath[_pathIndex + 1]);
    return _segmentWalked > expected * 1.5;
  }

  // ── Nearest Corridor Snap ─────────────────────────────────────────────────
  // If OCR detects a room node, snap position to its door node instead
  // (since the user is in the corridor reading the sign, not inside the room).

  NavigationNode snapToCorridorEntry(NavigationNode roomNode) {
    if (roomNode.type != NavNodeType.room) return roomNode;
    if (roomNode.doorNodeId != null) {
      return graph.nodeById(roomNode.doorNodeId!) ?? roomNode;
    }
    // Fallback: find nearest walkable node
    final floor = roomNode.floor;
    return pathFinder.snapToNearestCorridor(
      roomNode.position.x,
      roomNode.position.z,
      floor,
    );
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
