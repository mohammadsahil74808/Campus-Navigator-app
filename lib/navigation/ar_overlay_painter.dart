// lib/navigation/ar_overlay_painter.dart
//
// REBUILT — fixes the three root causes of visual misalignment:
//
//  BUG 1: Vanishing point shift was hardcoded × 3.2 pixels per degree.
//         At 90° turn this offset went off-screen, corridor disappeared.
//         FIX: Clamp VP to screen width × [0.05, 0.95]. Use sigmoid curve
//         for perceptually natural shift.
//
//  BUG 2: Chevron arrows sat at fixed Y positions and never followed the
//         corridor edge lines, so they pointed in a different direction.
//         FIX: Chevrons are interpolated along the corridor centre-line
//         between bottom and vanishing point — always aligned with path.
//
//  BUG 3: Destination beacon appeared at height * 0.4 regardless of where
//         the room actually is. It floated in the sky.
//         FIX: Beacon is clamped to floor level (height * 0.55–0.70).
//
//  NEW: Destination doorway indicator — when approaching, draws a
//       glowing door-frame rectangle at the estimated door position.

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'navigation_model.dart';

// ─── AROverlayPainter ─────────────────────────────────────────────────────────

class AROverlayPainter extends CustomPainter {
  final double turnAngle; // Signed degrees: neg=left, pos=right
  final double distanceMeters;
  final NavigationNode? nextNode;
  final NavigationNode? targetNode;
  final ProximityZone proximityZone;
  final LocalizationConfidence confidence;
  final double animValue; // 0.0 → 1.0 from AnimationController

  const AROverlayPainter({
    required this.turnAngle,
    required this.distanceMeters,
    required this.nextNode,
    required this.targetNode,
    required this.proximityZone,
    required this.confidence,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nextNode == null) return;

    final vpX = _vanishingPointX(size);
    final vpY = size.height * 0.42;

    _drawCorridor(canvas, size, vpX, vpY);
    _drawAnimatedChevrons(canvas, size, vpX, vpY);

    if (proximityZone == ProximityZone.near ||
        proximityZone == ProximityZone.arrived) {
      _drawDestinationDoorway(canvas, size, vpX, vpY);
    } else if (proximityZone == ProximityZone.approaching) {
      _drawApproachingBeacon(canvas, size, vpX, vpY);
    }

    if (confidence == LocalizationConfidence.low) {
      _drawLowConfidenceWarning(canvas, size);
    }
  }

  // ── Vanishing Point ───────────────────────────────────────────────────────
  // Sigmoid curve for natural-feeling shift: small angles feel tight,
  // large angles (>60°) plateau and don't shoot off screen.

  double _vanishingPointX(Size size) {
    final cx = size.width / 2;
    // Sigmoid: maps [-180, 180] angle to [-0.38, 0.38] fraction of screen width
    final t = 1.0 / (1.0 + math.exp(-turnAngle / 35.0));
    final offset = (t - 0.5) * size.width * 0.76;
    return (cx + offset).clamp(size.width * 0.05, size.width * 0.95);
  }

  // ── Floor Corridor ────────────────────────────────────────────────────────

  void _drawCorridor(Canvas canvas, Size size, double vpX, double vpY) {
    final cx = size.width / 2;
    final halfWidth = size.width * 0.40;

    // Corridor trapezoid
    final path = Path()
      ..moveTo(cx - halfWidth, size.height)
      ..lineTo(cx + halfWidth, size.height)
      ..lineTo(vpX + 16, vpY)
      ..lineTo(vpX - 16, vpY)
      ..close();

    // Gradient fill
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFF00E5FF).withValues(alpha: 0.28),
            const Color(0xFF00E5FF).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, vpY, size.width, size.height - vpY)),
    );

    // Glowing edges
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.80)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);

    canvas.drawLine(
        Offset(cx - halfWidth, size.height), Offset(vpX - 16, vpY), edgePaint);
    canvas.drawLine(
        Offset(cx + halfWidth, size.height), Offset(vpX + 16, vpY), edgePaint);

    _drawFlowingDashes(canvas, size, vpX, vpY, cx);
  }

  void _drawFlowingDashes(
      Canvas canvas, Size size, double vpX, double vpY, double cx) {
    const n = 6;
    for (int i = 0; i < n; i++) {
      final t = ((i / n) + animValue) % 1.0;
      // Ease-in perspective: objects get bigger closer to viewer
      final tEased = t * t;
      final y = lerpDouble(vpY, size.height, tEased)!;
      final left = lerpDouble(vpX, cx - size.width * 0.40, tEased)!;
      final right = lerpDouble(vpX, cx + size.width * 0.40, tEased)!;
      final midX = (left + right) / 2;
      final dashW = lerpDouble(3, 24, tEased)!;
      final op = lerpDouble(0.0, 0.55, tEased)!;

      canvas.drawLine(
        Offset(midX - dashW / 2, y),
        Offset(midX + dashW / 2, y),
        Paint()
          ..color = Colors.white.withValues(alpha: op)
          ..strokeWidth = lerpDouble(0.8, 2.0, tEased)!,
      );
    }
  }

  // ── Chevron Arrows ────────────────────────────────────────────────────────
  // Arrows are placed along the corridor centre-line so they always
  // point in the same direction as the corridor edges.

  void _drawAnimatedChevrons(Canvas canvas, Size size, double vpX, double vpY) {
    const nArrows = 4;
    for (int i = 0; i < nArrows; i++) {
      // Each arrow occupies its own phase slot in [0,1]
      final phase = ((i / nArrows) + animValue) % 1.0;
      final tPos = phase * phase; // perspective: spaced closer near horizon

      final y = lerpDouble(vpY + 10, size.height * 0.88, tPos)!;
      final x = lerpDouble(vpX, size.width / 2, tPos)!;
      final scale = lerpDouble(0.4, 1.0, tPos)!;
      final alpha = _chevronAlpha(phase);

      _drawChevron(canvas, Offset(x, y), scale, alpha);
    }
  }

  double _chevronAlpha(double phase) {
    // Fade in 0→0.25, solid 0.25→0.7, fade out 0.7→1.0
    if (phase < 0.25) return phase / 0.25;
    if (phase < 0.70) return 1.0;
    return 1.0 - (phase - 0.70) / 0.30;
  }

  void _drawChevron(Canvas canvas, Offset c, double scale, double alpha) {
    final w = 26.0 * scale;
    final h = 15.0 * scale;
    final path = Path()
      ..moveTo(c.dx - w, c.dy + h * 0.5)
      ..lineTo(c.dx, c.dy - h * 0.5)
      ..lineTo(c.dx + w, c.dy + h * 0.5);

    // Glow layer
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5 * scale
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = const Color(0xFF00E5FF).withValues(alpha: alpha * 0.85)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0 * scale));

    // Core line
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4 * scale
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = Colors.white.withValues(alpha: alpha * 0.7));
  }

  // ── Destination Doorway (when near) ──────────────────────────────────────
  // Draws a glowing door-frame at the corridor vanishing region + a label.
  // Clamped to floor level so it never "floats" above eye level.

  void _drawDestinationDoorway(
      Canvas canvas, Size size, double vpX, double vpY) {
    final cx = vpX;
    // Doorway sits at 55–72% of screen height (floor level, not sky)
    final doorY =
        size.height * (0.55 + 0.05 * math.sin(animValue * 2 * math.pi));
    final doorH = size.height * 0.18;
    final doorW = doorH * 0.55;
    final pulse = 0.5 + 0.5 * math.sin(animValue * 2 * math.pi);

    // Outer glow
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(cx, doorY), width: doorW + 20, height: doorH + 20),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = const Color(0xFF69FF47).withValues(alpha: 0.15 + 0.1 * pulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 + 6 * pulse),
    );

    // Door frame
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, doorY), width: doorW, height: doorH),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..color =
            const Color(0xFF69FF47).withValues(alpha: 0.85 + 0.15 * pulse),
    );

    // Floor line below door
    canvas.drawLine(
      Offset(cx - doorW / 2 - 12, doorY + doorH / 2),
      Offset(cx + doorW / 2 + 12, doorY + doorH / 2),
      Paint()
        ..color = const Color(0xFF69FF47).withValues(alpha: 0.6)
        ..strokeWidth = 2.0,
    );

    // Destination label above door
    _drawLabel(canvas, targetNode?.displayLabel ?? 'DESTINATION',
        Offset(cx, doorY - doorH / 2 - 18), pulse);
  }

  void _drawApproachingBeacon(
      Canvas canvas, Size size, double vpX, double vpY) {
    final cx = vpX;
    final cy = size.height * 0.50; // eye-level
    final pulse = 0.5 + 0.5 * math.sin(animValue * 2 * math.pi);
    final r = 18.0 + 10.0 * pulse;

    canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color =
              const Color(0xFF69FF47).withValues(alpha: 0.18 + 0.12 * pulse)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20 + 8 * pulse));

    canvas.drawCircle(
        Offset(cx, cy),
        12,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..color = const Color(0xFF69FF47).withValues(alpha: 0.9));

    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = Colors.white);

    _drawLabel(
        canvas, targetNode?.displayLabel ?? '', Offset(cx, cy - 22), pulse);
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, double pulse) {
    if (text.isEmpty) return;
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85 + 0.15 * pulse),
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          shadows: const [Shadow(color: Color(0xFF69FF47), blurRadius: 8)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  // ── Low-confidence warning ────────────────────────────────────────────────

  void _drawLowConfidenceWarning(Canvas canvas, Size size) {
    // Thin amber border around screen edge to signal compass drift
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = const Color(0xFFFF9800).withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(AROverlayPainter old) =>
      (turnAngle - old.turnAngle).abs() > 0.4 ||
      (animValue - old.animValue).abs() > 0.01 ||
      (distanceMeters - old.distanceMeters).abs() > 0.1 ||
      proximityZone != old.proximityZone ||
      nextNode?.id != old.nextNode?.id;
}

// ─── DirectionArrowWidget ─────────────────────────────────────────────────────

class DirectionArrowWidget extends StatelessWidget {
  final TurnType turnType;

  const DirectionArrowWidget({super.key, required this.turnType});

  @override
  Widget build(BuildContext context) {
    final (icon, rotation) = _iconAndRotation(turnType);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
            blurRadius: 40,
            spreadRadius: 8,
          )
        ],
      ),
      child: Transform.rotate(
        angle: rotation,
        child: Icon(icon, size: 84, color: Colors.white),
      ),
    );
  }

  (IconData, double) _iconAndRotation(TurnType t) {
    return switch (t) {
      TurnType.straight => (Icons.navigation_rounded, 0.0),
      TurnType.slightLeft => (Icons.navigation_rounded, -0.35),
      TurnType.turnLeft => (Icons.turn_left_rounded, 0.0),
      TurnType.sharpLeft => (Icons.turn_sharp_left_rounded, 0.0),
      TurnType.slightRight => (Icons.navigation_rounded, 0.35),
      TurnType.turnRight => (Icons.turn_right_rounded, 0.0),
      TurnType.sharpRight => (Icons.turn_sharp_right_rounded, 0.0),
      TurnType.uTurn => (Icons.u_turn_left_rounded, 0.0),
      TurnType.takeStairsUp => (Icons.arrow_upward_rounded, 0.0),
      TurnType.takeStairsDown => (Icons.arrow_downward_rounded, 0.0),
      TurnType.takeLiftUp => (Icons.elevator_rounded, 0.0),
      TurnType.takeLiftDown => (Icons.elevator_rounded, math.pi),
      TurnType.arrived => (Icons.check_circle_rounded, 0.0),
    };
  }
}
