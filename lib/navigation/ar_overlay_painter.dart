import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:campus_prototype/navigation/navigation_model.dart';

// ─── AROverlayPainter ─────────────────────────────────────────────────────────
// Draws the holographic AR navigation overlay on the camera feed.
// Renders:
//   1. A perspective floor-following navigation corridor
//   2. Animated chevron arrows along the path
//   3. A pulsing destination beacon
//
// shouldRepaint is gated — only repaints when state meaningfully changes.

class AROverlayPainter extends CustomPainter {
  final double turnAngle; // Degrees: negative=left, positive=right
  final double distanceMeters;
  final NavigationNode? nextNode;
  final LocalizationConfidence confidence;
  final double animationValue; // 0.0 → 1.0 from AnimationController

  const AROverlayPainter({
    required this.turnAngle,
    required this.distanceMeters,
    required this.nextNode,
    required this.confidence,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nextNode == null) return;

    _drawFloorCorridor(canvas, size);
    _drawChevronArrows(canvas, size);
    _drawDestinationBeacon(canvas, size);
  }

  // ── 1. Floor Corridor ──────────────────────────────────────────────────────

  void _drawFloorCorridor(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final horizon = size.height * 0.42; // Horizon line

    // Vanishing point shifts with turn angle (clamped to avoid extreme offsets)
    final vpX =
        (cx + turnAngle * 3.2).clamp(size.width * 0.1, size.width * 0.9);

    final corridorPath = Path()
      ..moveTo(cx - size.width * 0.42, size.height)
      ..lineTo(cx + size.width * 0.42, size.height)
      ..lineTo(vpX + 18, horizon)
      ..lineTo(vpX - 18, horizon)
      ..close();

    // Gradient fill: cyan glow fades toward horizon
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.35),
          const Color(0xFF00E5FF).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(
          Rect.fromLTWH(0, horizon, size.width, size.height - horizon));

    canvas.drawPath(corridorPath, gradientPaint);

    // Glowing edge lines
    final edgePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final leftEdge = Path()
      ..moveTo(cx - size.width * 0.42, size.height)
      ..lineTo(vpX - 18, horizon);
    final rightEdge = Path()
      ..moveTo(cx + size.width * 0.42, size.height)
      ..lineTo(vpX + 18, horizon);

    canvas.drawPath(leftEdge, edgePaint);
    canvas.drawPath(rightEdge, edgePaint);

    // Animated dashed centre lane lines (conveyor belt effect)
    _drawAnimatedLaneLines(canvas, size, cx, vpX, horizon);
  }

  void _drawAnimatedLaneLines(
      Canvas canvas, Size size, double cx, double vpX, double horizon) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    const numSegments = 5;
    for (int i = 0; i < numSegments; i++) {
      // Animate segments flowing toward user (0→1 loop via animationValue)
      final t = ((i / numSegments) + animationValue) % 1.0;
      // Perspective lerp: t=0 at horizon, t=1 at bottom
      final y = lerpDouble(horizon, size.height, t)!;
      final tLeft = lerpDouble(vpX, cx - size.width * 0.42, t)!;
      final tRight = lerpDouble(vpX, cx + size.width * 0.42, t)!;

      // Narrow dash length near horizon (perspective shrink)
      final dashLen = lerpDouble(4, 28, t)!;
      final opacity = lerpDouble(0.0, 0.5, t)!;
      linePaint.color = Colors.white.withValues(alpha: opacity);

      canvas.drawLine(
        Offset((tLeft + tRight) / 2 - dashLen / 2, y),
        Offset((tLeft + tRight) / 2 + dashLen / 2, y),
        linePaint,
      );
    }
  }

  // ── 2. Chevron Arrows ──────────────────────────────────────────────────────

  void _drawChevronArrows(Canvas canvas, Size size) {
    final cx = size.width / 2 + turnAngle * 1.5;
    final positions = [
      size.height * 0.72,
      size.height * 0.57,
      size.height * 0.47,
    ];

    for (int i = 0; i < positions.length; i++) {
      // Stagger animation phase per chevron so they pulse in sequence
      final phase = (animationValue + i * 0.33) % 1.0;
      final opacity = _chevronOpacity(phase);
      final scale = lerpDouble(0.6, 1.0, i / 2.0)!; // Smaller near horizon

      _drawSingleChevron(canvas, Offset(cx, positions[i]), scale, opacity);
    }
  }

  double _chevronOpacity(double phase) {
    // Fade in fast, fade out slow — creates "flowing" pulse
    if (phase < 0.3) return phase / 0.3;
    if (phase < 0.7) return 1.0;
    return 1.0 - (phase - 0.7) / 0.3;
  }

  void _drawSingleChevron(
      Canvas canvas, Offset center, double scale, double opacity) {
    final w = 28.0 * scale;
    final h = 16.0 * scale;

    final path = Path()
      ..moveTo(center.dx - w, center.dy + h / 2)
      ..lineTo(center.dx, center.dy - h / 2)
      ..lineTo(center.dx + w, center.dy + h / 2);

    final paint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: opacity * 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0 * scale);

    canvas.drawPath(path, paint);

    // Inner bright core
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, corePaint);
  }

  // ── 3. Destination Beacon ──────────────────────────────────────────────────

  void _drawDestinationBeacon(Canvas canvas, Size size) {
    if (distanceMeters > 8) return; // Only show when close

    final cx = size.width / 2 + turnAngle * 1.2;
    final cy = size.height * 0.4;
    final pulse = 0.5 + 0.5 * math.sin(animationValue * 2 * math.pi);
    final radius = 22.0 + 10.0 * pulse;

    final beaconPaint = Paint()
      ..color = const Color(0xFF69FF47).withValues(alpha: 0.25 + 0.15 * pulse)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18 + 8 * pulse);

    canvas.drawCircle(Offset(cx, cy), radius, beaconPaint);

    final ringPaint = Paint()
      ..color = const Color(0xFF69FF47).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(Offset(cx, cy), 14, ringPaint);

    // Centre dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 5, dotPaint);
  }

  @override
  bool shouldRepaint(AROverlayPainter old) {
    return (turnAngle - old.turnAngle).abs() > 0.4 ||
        (animationValue - old.animationValue).abs() > 0.01 ||
        (distanceMeters - old.distanceMeters).abs() > 0.1 ||
        nextNode?.id != old.nextNode?.id;
  }
}

// ─── DirectionArrowWidget ─────────────────────────────────────────────────────
// The top-center rotating 3D navigation arrow widget.

class DirectionArrowWidget extends StatelessWidget {
  final double turnAngle;
  final bool isFloorChange;
  final bool goingUp;

  const DirectionArrowWidget({
    super.key,
    required this.turnAngle,
    this.isFloorChange = false,
    this.goingUp = true,
  });

  @override
  Widget build(BuildContext context) {
    final icon = isFloorChange
        ? (goingUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded)
        : Icons.navigation_rounded;

    final rotationRad = isFloorChange ? 0.0 : turnAngle * math.pi / 180;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspective entry
          ..rotateZ(rotationRad),
        alignment: Alignment.center,
        child: Icon(icon, size: 88, color: Colors.white),
      ),
    );
  }
}
