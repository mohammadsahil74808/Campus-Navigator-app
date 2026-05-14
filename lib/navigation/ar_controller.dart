import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:campus_prototype/navigation/navigation_model.dart';
import 'package:campus_prototype/navigation/pathfinding.dart';
import 'package:campus_prototype/services/ocr_service.dart';
import 'package:campus_prototype/services/sensor_service.dart';

// ─── ARController ─────────────────────────────────────────────────────────────
// The single source of truth for all AR navigation state.
// Widgets listen via ChangeNotifier — only notified on meaningful state change,
// never on every compass tick.

class ARController extends ChangeNotifier {
  final CampusGraph graph;
  final NavigationNode targetNode;
  final SensorService sensorService;

  late final PathFinder _pathFinder;
  late final OcrService _ocrService;

  // ── Camera ──────────────────────────────────────────────────────────────
  CameraController? cameraController;
  bool get isCameraReady =>
      cameraController != null && cameraController!.value.isInitialized;

  // ── Navigation State ────────────────────────────────────────────────────
  NavigationState _state = const NavigationState();
  NavigationState get state => _state;

  // ── Localization ────────────────────────────────────────────────────────
  bool _ocrActive = false;
  Timer? _ocrThrottle;
  int _sensorOrientation = 0;

  // Confidence accumulator: N consecutive OCR matches required to accept a position
  String? _lastOcrNodeId;
  int _ocrConfidenceCount = 0;
  static const int _requiredConfidence = 3;

  ARController({
    required this.graph,
    required this.targetNode,
    required this.sensorService,
  }) {
    _pathFinder = PathFinder(graph);
    _ocrService = OcrService();
  }

  // ─── Initialization ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    sensorService.addListener(_onSensorUpdate);
    sensorService.start();
    await _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _updateState(_state.copyWith(
          statusMessage: 'No camera available on this device.',
        ));
        return;
      }

      final camera = cameras.first;
      _sensorOrientation = camera.sensorOrientation;

      cameraController = CameraController(
        camera,
        ResolutionPreset.high, // Increased from medium for better text clarity
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await cameraController!.initialize();
      notifyListeners(); // Camera is ready — trigger UI rebuild

      _startOcrStream();
    } catch (e) {
      debugPrint('[ARController] Camera init error: $e');
      _updateState(_state.copyWith(
        statusMessage: 'Camera error: ${e.toString()}',
      ));
    }
  }

  // ─── OCR Stream ────────────────────────────────────────────────────────────

  void _startOcrStream() {
    cameraController?.startImageStream((image) {
      if (_ocrActive || _state.confidence == LocalizationConfidence.high)
        return;
      // Throttle: process at most 1 frame every 500ms (faster for debugging)
      _ocrThrottle ??= Timer(const Duration(milliseconds: 500), () {
        _ocrThrottle = null;
        _processFrame(image);
      });
    });
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_ocrActive) return;
    _ocrActive = true;

    try {
      final rotation = OcrService.rotationFromSensor(_sensorOrientation);
      final text =
          await _ocrService.processFrame(image, _sensorOrientation, rotation);

      if (text != null && text.isNotEmpty) {
        final matchedNode = graph.matchFromOcrText(text);
        if (matchedNode != null) {
          _handleOcrMatch(matchedNode);
        } else {
          // DEBUG: Show what the app is seeing
          _updateState(_state.copyWith(
            statusMessage: 'Seeing: "$text" (No match)',
            confidence: LocalizationConfidence.low,
          ));
        }
      } else {
        _updateState(_state.copyWith(
          statusMessage: 'Scanning... (No text detected)',
          confidence: LocalizationConfidence.none,
        ));
      }
    } finally {
      _ocrActive = false;
    }
  }

  void _handleOcrMatch(NavigationNode detected) {
    if (detected.id == _lastOcrNodeId) {
      _ocrConfidenceCount++;
    } else {
      _lastOcrNodeId = detected.id;
      _ocrConfidenceCount = 1;
    }

    final confidence = _ocrConfidenceCount >= _requiredConfidence
        ? LocalizationConfidence.high
        : LocalizationConfidence.medium;

    if (_ocrConfidenceCount >= _requiredConfidence) {
      // Confirmed position — calculate route
      debugPrint('[ARController] Localized to: ${detected.name}');
      cameraController?.stopImageStream();
      _calculatePath(detected);
    } else {
      _updateState(_state.copyWith(
        statusMessage: 'Detected: ${detected.displayLabel} (confirming...)',
        confidence: confidence,
      ));
    }
  }

  // ─── Pathfinding ───────────────────────────────────────────────────────────

  void _calculatePath(NavigationNode from) {
    NavigationNode? target;
    try {
      target = graph.nodes.firstWhere(
        (n) => n.id == targetNode.id || n.name == targetNode.name,
      );
    } catch (_) {
      // Fuzzy fallback
      for (final n in graph.nodes) {
        if (n.aliases.any((a) =>
            targetNode.name.toLowerCase().contains(a.toLowerCase()) ||
            a.toLowerCase().contains(targetNode.name.toLowerCase()))) {
          target = n;
          break;
        }
      }
    }

    if (target == null) {
      _updateState(_state.copyWith(
        statusMessage: 'Destination not found in map.',
        isLocalizing: false,
      ));
      return;
    }

    final path = _pathFinder.findPath(from.id, target.id);
    if (path.isEmpty) {
      _updateState(_state.copyWith(
        statusMessage: 'No route to ${target.displayLabel}.',
        isLocalizing: false,
      ));
      return;
    }

    _updateState(_state.copyWith(
      currentNode: from,
      targetNode: target,
      path: path,
      isLocalizing: false,
      statusMessage: 'Navigating to ${target.displayLabel}',
      confidence: LocalizationConfidence.high,
    ));
  }

  // ─── Sensor Updates → Turn Angle Calculation ──────────────────────────────

  void _onSensorUpdate() {
    if (!_state.hasPath) return;

    final current = _state.currentNode;
    final next = _state.nextNode;
    if (current == null || next == null) return;

    final heading = sensorService.heading;

    // Bearing to next waypoint
    final dx = next.position.x - current.position.x;
    final dz = next.position.z - current.position.z;
    final bearing = (math.atan2(dx, dz) * 180 / math.pi + 360) % 360;

    // Turn angle: positive = right, negative = left
    double turn = bearing - heading;
    if (turn > 180) turn -= 360;
    if (turn < -180) turn += 360;

    // Distance to next node (2D)
    final dist = math.sqrt(dx * dx + dz * dz);

    // Auto-advance: if user is close to next node, pop path
    final updatedPath = List<NavigationNode>.from(_state.path);
    if (dist < 2.0 && updatedPath.length > 2) {
      updatedPath.removeAt(0);
      debugPrint(
          '[ARController] Reached ${current.name}, advancing to ${updatedPath[1].name}');
    }

    // Build updated state (no rebuild if values are same-ish)
    final newState = _state.copyWith(
      path: updatedPath,
      currentNode: updatedPath.first,
      headingDegrees: heading,
      turnAngle: turn,
      distanceToNextMeters: dist,
    );

    // Only notify if values changed meaningfully (saves rebuilds)
    if ((newState.turnAngle - _state.turnAngle).abs() > 0.5 ||
        (newState.distanceToNextMeters - _state.distanceToNextMeters).abs() >
            0.2 ||
        newState.currentNode?.id != _state.currentNode?.id) {
      _state = newState;
      notifyListeners();
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _updateState(NavigationState newState) {
    _state = newState;
    notifyListeners();
  }

  // ─── Dispose ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    sensorService.removeListener(_onSensorUpdate);
    sensorService.stop();
    _ocrThrottle?.cancel();
    cameraController?.dispose();
    _ocrService.dispose();
    super.dispose();
  }
}
