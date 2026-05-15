// lib/navigation/ar_controller.dart
//
// Central navigation brain. Owns all state. UI reads via ChangeNotifier.
//
// Key fixes over the original:
//  1. Bearing computed from corridor geometry, NOT raw node coordinates
//     → arrows align with the actual hallway direction
//  2. Path uses smoothed waypoints — user only sees decision-point turns
//  3. Dead reckoning advances position between OCR fixes
//  4. Reroute detection: if walked too far past expected junction → recalculate
//  5. Proximity zones: far/approaching/near/arrived trigger beacon + UI changes
//  6. OCR continues at low rate after localization to catch re-anchor moments
//  7. Position snaps to corridor entry (door node) when room sign is scanned

import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'navigation_model.dart';
import 'pathfinding.dart';
import '../localization/localization_service.dart';
import '../services/ocr_service.dart';
import '../services/sensor_service.dart';

class ARController extends ChangeNotifier {
  final CampusGraph graph;
  final NavigationNode targetNode;
  final SensorService sensorService;

  late final PathFinder _pathFinder;
  late final OcrService _ocrService;
  late final LocalizationService _locService;

  CameraController? cameraController;
  bool get isCameraReady =>
      cameraController != null && cameraController!.value.isInitialized;

  NavigationState _state = NavigationState();
  NavigationState get state => _state;

  int _sensorOrientation = 0;
  Timer? _rerouteTimer;

  ARController({
    required this.graph,
    required this.targetNode,
    required this.sensorService,
  }) {
    _pathFinder = PathFinder(graph);
    _ocrService = OcrService();
    _locService = LocalizationService(graph: graph, pathFinder: _pathFinder);
  }

  // ─── Initialize ───────────────────────────────────────────────────────────

  Future<void> initialize() async {
    // Validate graph in debug builds to catch topology errors early
    assert(() {
      final issues = graph.validate();
      for (final i in issues) {
        debugPrint('[GraphValidation] $i');
      }
      return true;
    }());

    sensorService.addListener(_onSensorUpdate);
    sensorService.start();
    _locService.start();
    await _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _emit(_state.copyWith(statusMessage: 'No camera found.'));
        return;
      }
      final cam = cameras.first;
      _sensorOrientation = cam.sensorOrientation;

      cameraController = CameraController(
        cam,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await cameraController!.initialize();
      notifyListeners();
      _startOcrStream();
    } catch (e) {
      _emit(_state.copyWith(statusMessage: 'Camera error: $e'));
    }
  }

  // ─── OCR Stream ───────────────────────────────────────────────────────────

  void _startOcrStream() {
    final rotation = OcrService.rotationFromSensor(_sensorOrientation);
    _ocrService.isLocalizing = true;

    cameraController?.startImageStream((image) async {
      final frame = await _ocrService.processFrame(image, rotation);
      if (frame == null || !frame.hasContent) return;
      _handleOcrFrame(frame);
    });
  }

  void _handleOcrFrame(OcrFrame frame) {
    final match = graph.matchFromOcrText(frame.fullText);
    if (match == null) {
      if (_state.isLocalizing) {
        _emit(_state.copyWith(
          statusMessage: 'Scanning... saw: "${_truncate(frame.fullText, 30)}"',
          confidence: LocalizationConfidence.low,
        ));
      }
      return;
    }

    // Snap detected node to corridor (user is reading sign from hallway)
    final corridorNode = _locService.snapToCorridorEntry(match.node);

    if (_state.isLocalizing) {
      // Submit to vote buffer — only confirmed after N matches
      final confirmed = _locService.submitOcrDetection(corridorNode);
      if (confirmed == null) {
        _emit(_state.copyWith(
          statusMessage: 'Detected: ${match.node.displayLabel} (confirming…)',
          confidence: LocalizationConfidence.medium,
        ));
        return;
      }
      // Confirmed localization
      _ocrService.isLocalizing = false;
      _calculateAndStartNavigation(confirmed);
    } else {
      // Re-anchor while navigating (if OCR sees a room we expect to be near)
      _tryReanchor(corridorNode, match.node);
    }
  }

  // ─── Pathfinding & Navigation Start ───────────────────────────────────────

  void _calculateAndStartNavigation(NavigationNode fromNode) {
    // Find target node in graph — match by id first, then by alias
    NavigationNode? target;
    target = graph.nodeById(targetNode.id);
    if (target == null) {
      // The target was created from campus_ui.dart with a raw name — fuzzy match
      final lower = targetNode.name.toLowerCase();
      for (final n in graph.nodes) {
        if (n.id.contains(lower) ||
            n.name.toLowerCase().contains(lower) ||
            n.aliases.any((a) => lower.contains(a) || a.contains(lower))) {
          target = n;
          break;
        }
      }
    }

    if (target == null) {
      _emit(_state.copyWith(
        statusMessage:
            'Room "${targetNode.name}" not in map. Check room number.',
        isLocalizing: false,
        confidence: LocalizationConfidence.high,
      ));
      return;
    }

    final result = _pathFinder.findPath(fromNode.id, target.id);
    if (!result.reachable) {
      _emit(_state.copyWith(
        statusMessage: 'No path found: ${result.errorReason}',
        isLocalizing: false,
      ));
      return;
    }

    // Use smoothed path for navigation (removes straight-run corridor nodes)
    final navPath = result.smoothed;
    _locService.setActivePath(result.nodes); // DR uses full path

    _emit(_state.copyWith(
      currentNode: fromNode,
      targetNode: target,
      path: navPath,
      isLocalizing: false,
      statusMessage: 'Navigating to ${target.displayLabel}',
      confidence: LocalizationConfidence.high,
      totalRemainingMeters: result.totalDistanceMeters,
    ));

    _scheduleRerouteCheck();
  }

  // ─── Re-anchor During Navigation ─────────────────────────────────────────
  // If OCR spots a node that's on our expected path ahead, jump to it.
  // If it's completely off-path, trigger a reroute.

  void _tryReanchor(NavigationNode corridorNode, NavigationNode rawDetected) {
    final path = _state.path;
    if (path.isEmpty) return;

    // Is this node on the upcoming path (within next 4 steps)?
    final upcoming = path.take(4).map((n) => n.id).toSet();
    if (upcoming.contains(corridorNode.id)) {
      // Jump ahead to this position
      final idx = path.indexWhere((n) => n.id == corridorNode.id);
      final newPath = path.sublist(idx);
      final dist = newPath.fold<double>(
          0,
          (sum, n) =>
              sum +
              (newPath.indexOf(n) < newPath.length - 1
                  ? n.floorDistanceTo(newPath[newPath.indexOf(n) + 1])
                  : 0));

      _locService.anchorToNode(corridorNode);
      _emit(_state.copyWith(
        currentNode: corridorNode,
        path: newPath,
        totalRemainingMeters: dist,
        confidence: LocalizationConfidence.high,
        statusMessage: 'On track → ${_state.targetNode?.displayLabel}',
      ));
      return;
    }

    // Off-path detection: OCR sees a room that's NOT on our route
    // This means the user took a wrong turn — reroute from here
    debugPrint(
        '[ARController] Off-path detected at ${corridorNode.id}, rerouting');
    _locService.anchorToNode(corridorNode);
    _calculateAndStartNavigation(corridorNode);
  }

  // ─── Sensor Updates → Turn Angle ─────────────────────────────────────────

  void _onSensorUpdate() {
    if (!_state.hasPath) return;

    final current = _state.currentNode;
    final next = _state.nextNode;
    if (current == null || next == null) return;

    final heading = sensorService.heading;

    // Use corridor-aligned bearing when available.
    // If both nodes have corridorHeading set and agree → use that.
    // Otherwise compute bearing from node positions.
    double bearing;
    if (next.corridorHeading != null) {
      bearing = next.corridorHeading!;
    } else {
      final dx = next.position.x - current.position.x;
      final dz = next.position.z - current.position.z;
      bearing = (math.atan2(dx, dz) * 180 / math.pi + 360) % 360;
    }

    // Turn angle: how much user must rotate to face next waypoint
    double turn = bearing - heading;
    if (turn > 180) turn -= 360;
    if (turn < -180) turn += 360;

    final dist = current.floorDistanceTo(next);

    // Proximity zone logic
    final target = _state.targetNode;
    final targetDist = target != null ? current.floorDistanceTo(target) : dist;
    final zone = _proximityZone(targetDist, dist, next, target);

    // Dead reckoning advancement (DR service updates currentNode internally)
    final drNode = _locService.currentNode;
    NavigationNode effectiveCurrent = current;
    List<NavigationNode> updatedPath = _state.path;

    if (drNode != null && drNode.id != current.id) {
      final idx = _state.path.indexWhere((n) => n.id == drNode.id);
      if (idx > 0 && idx < _state.path.length) {
        updatedPath = _state.path.sublist(idx);
        effectiveCurrent = drNode;
        debugPrint('[ARController] DR advanced to ${drNode.displayLabel}');
      }
    }

    final newState = _state.copyWith(
      currentNode: effectiveCurrent,
      path: updatedPath,
      headingDegrees: heading,
      turnAngle: turn,
      turnType: turnTypeFromAngle(
        turn,
        isVertical:
            next.type == NavNodeType.staircase || next.type == NavNodeType.lift,
        goingUp: next.floor > (current.floor),
        isLift: next.type == NavNodeType.lift,
      ),
      distanceToNextMeters: dist,
      proximityZone: zone,
      showDestinationBeacon:
          zone == ProximityZone.near || zone == ProximityZone.arrived,
      statusMessage: zone == ProximityZone.arrived
          ? 'You have arrived at ${target?.displayLabel ?? "destination"}'
          : 'Head to ${next.displayLabel}',
      confidence: _locService.confidence,
    );

    // Only notify on meaningful change (< 0.5° turn or < 0.2m distance)
    if ((newState.turnAngle - _state.turnAngle).abs() > 0.5 ||
        (newState.distanceToNextMeters - _state.distanceToNextMeters).abs() >
            0.2 ||
        newState.currentNode?.id != _state.currentNode?.id ||
        newState.proximityZone != _state.proximityZone) {
      _state = newState;
      notifyListeners();
    }
  }

  ProximityZone _proximityZone(double targetDist, double nextDist,
      NavigationNode next, NavigationNode? target) {
    if (next.id == target?.id || target?.id == _state.currentNode?.id) {
      if (targetDist < 1.5) return ProximityZone.arrived;
      if (targetDist < 4.0) return ProximityZone.near;
    }
    if (targetDist < 8.0) return ProximityZone.approaching;
    return ProximityZone.far;
  }

  // ─── Reroute Check Timer ──────────────────────────────────────────────────
  // Every 5s, check if dead reckoning thinks we've deviated.

  void _scheduleRerouteCheck() {
    _rerouteTimer?.cancel();
    _rerouteTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_locService.isLikelyDeviating() && _locService.currentNode != null) {
        debugPrint('[ARController] Reroute triggered by dead reckoning');
        _calculateAndStartNavigation(_locService.currentNode!);
      }
    });
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  void _emit(NavigationState s) {
    _state = s;
    notifyListeners();
  }

  String _truncate(String s, int n) =>
      s.length > n ? '${s.substring(0, n)}…' : s;

  // ─── Dispose ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    sensorService.removeListener(_onSensorUpdate);
    sensorService.stop();
    _locService.dispose();
    _rerouteTimer?.cancel();
    cameraController?.stopImageStream();
    cameraController?.dispose();
    _ocrService.dispose();
    super.dispose();
  }
}
