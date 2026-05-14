import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_prototype/navigation/navigation_model.dart';
import 'package:campus_prototype/navigation/ar_controller.dart';
import 'package:campus_prototype/navigation/ar_overlay_painter.dart';
import 'package:campus_prototype/services/sensor_service.dart';

// ─── ARNavigationView ─────────────────────────────────────────────────────────
// Pure UI layer — reads state from ARController via Provider.
// Does NOT manage sensors, OCR, or pathfinding directly.
// Uses an AnimationController for smooth 60fps overlay animation,
// completely decoupled from compass/sensor rebuilds.

class ARNavigationView extends StatefulWidget {
  final NavigationNode targetNode;
  final CampusGraph graph;

  const ARNavigationView({
    super.key,
    required this.targetNode,
    required this.graph,
  });

  @override
  State<ARNavigationView> createState() => _ARNavigationViewState();
}

class _ARNavigationViewState extends State<ARNavigationView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late ARController _arController;

  @override
  void initState() {
    super.initState();
    // 60fps animation loop for holographic effects
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // ARController owns all business logic
    _arController = ARController(
      graph: widget.graph,
      targetNode: widget.targetNode,
      sensorService: SensorService(),
    );
    _arController.initialize();
  }

  @override
  void dispose() {
    _animController.dispose();
    _arController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ARController>.value(
      value: _arController,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<ARController>(
          builder: (context, controller, _) {
            if (!controller.isCameraReady) {
              return const _LoadingScreen();
            }

            return Stack(
              children: [
                // ── Camera Feed ────────────────────────────────────────────
                Positioned.fill(
                  child: CameraPreview(controller.cameraController!),
                ),

                // ── AR Overlay (only when navigating) ─────────────────────
                if (!controller.state.isLocalizing && controller.state.hasPath)
                  _buildAROverlay(controller.state),

                // ── Localization Scan UI ───────────────────────────────────
                if (controller.state.isLocalizing)
                  const _LocalizationScanOverlay(),

                // ── Top Compass/Direction Panel ────────────────────────────
                if (!controller.state.isLocalizing && controller.state.hasPath)
                  _buildDirectionPanel(controller.state),

                // ── Bottom HUD ────────────────────────────────────────────
                _buildBottomHUD(controller.state),

                // ── Close Button ──────────────────────────────────────────
                _buildCloseButton(context),

                // ── Confidence Indicator ─────────────────────────────────
                _buildConfidenceDot(controller.state.confidence),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── AR Overlay ────────────────────────────────────────────────────────────

  Widget _buildAROverlay(NavigationState state) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return Positioned.fill(
          child: CustomPaint(
            painter: AROverlayPainter(
              turnAngle: state.turnAngle,
              distanceMeters: state.distanceToNextMeters,
              nextNode: state.nextNode,
              confidence: state.confidence,
              animationValue: _animController.value,
            ),
          ),
        );
      },
    );
  }

  // ─── Direction Panel ───────────────────────────────────────────────────────

  Widget _buildDirectionPanel(NavigationState state) {
    final next = state.nextNode;
    if (next == null) return const SizedBox();

    final isFloorChange =
        next.type == NavNodeType.staircase || next.type == NavNodeType.lift;
    final goingUp = next.floor > (state.currentNode?.floor ?? 1);

    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 3D rotating arrow
            DirectionArrowWidget(
              turnAngle: state.turnAngle,
              isFloorChange: isFloorChange,
              goingUp: goingUp,
            ),
            const SizedBox(height: 12),
            // Destination label chip
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.55),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _turnLabel(state.turnAngle, isFloorChange, goingUp),
                        style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        next.displayLabel.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      if (state.distanceToNextMeters > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${state.distanceToNextMeters.toStringAsFixed(1)} m',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _turnLabel(double angle, bool floorChange, bool goingUp) {
    if (floorChange)
      return goingUp ? 'TAKE STAIRS / LIFT UP' : 'TAKE STAIRS / LIFT DOWN';
    if (angle.abs() < 15) return 'CONTINUE STRAIGHT';
    if (angle < -60) return 'SHARP LEFT';
    if (angle < 0) return 'TURN LEFT';
    if (angle > 60) return 'SHARP RIGHT';
    return 'TURN RIGHT';
  }

  // ─── Bottom HUD ────────────────────────────────────────────────────────────

  Widget _buildBottomHUD(NavigationState state) {
    return Positioned(
      bottom: 32,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.statusMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (state.isLocalizing) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(
                      state.confidence == LocalizationConfidence.medium
                          ? const Color(0xFF00E5FF)
                          : Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Scanning for room signs...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
                if (!state.isLocalizing && state.path.length > 1) ...[
                  const SizedBox(height: 8),
                  _buildMiniPathRow(state.path),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniPathRow(List<NavigationNode> path) {
    final shown = path.take(4).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < shown.length; i++) ...[
          Text(
            shown[i].displayLabel,
            style: TextStyle(
              color: i == 0
                  ? const Color(0xFF00E5FF)
                  : Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: i == 0 ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
          if (i < shown.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.chevron_right, color: Colors.white24, size: 14),
            ),
        ],
        if (path.length > 4)
          Text(
            ' +${path.length - 4}',
            style: const TextStyle(color: Colors.white30, fontSize: 11),
          ),
      ],
    );
  }

  // ─── Misc UI ──────────────────────────────────────────────────────────────

  Widget _buildCloseButton(BuildContext context) {
    return Positioned(
      top: 52,
      left: 18,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.55),
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceDot(LocalizationConfidence confidence) {
    final color = switch (confidence) {
      LocalizationConfidence.high => const Color(0xFF69FF47),
      LocalizationConfidence.medium => const Color(0xFFFFD600),
      LocalizationConfidence.low => const Color(0xFFFF6D00),
      LocalizationConfidence.none => Colors.white30,
    };
    return Positioned(
      top: 60,
      right: 20,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8)],
        ),
      ),
    );
  }
}

// ─── Loading Screen ───────────────────────────────────────────────────────────

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF00E5FF)),
            SizedBox(height: 16),
            Text(
              'Initializing AR Camera...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Localization Scan Overlay ────────────────────────────────────────────────

class _LocalizationScanOverlay extends StatelessWidget {
  const _LocalizationScanOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Corner scan brackets
          Positioned(
            top: 120,
            left: 40,
            child: _ScanBracket(corner: Alignment.topLeft),
          ),
          Positioned(
            top: 120,
            right: 40,
            child: _ScanBracket(corner: Alignment.topRight),
          ),
          Positioned(
            bottom: 180,
            left: 40,
            child: _ScanBracket(corner: Alignment.bottomLeft),
          ),
          Positioned(
            bottom: 180,
            right: 40,
            child: _ScanBracket(corner: Alignment.bottomRight),
          ),
          // Scan label
          Positioned(
            top: 110,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'POINT AT ROOM NUMBER',
                style: TextStyle(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanBracket extends StatelessWidget {
  final Alignment corner;
  const _ScanBracket({required this.corner});

  @override
  Widget build(BuildContext context) {
    final isLeft =
        corner == Alignment.topLeft || corner == Alignment.bottomLeft;
    final isTop = corner == Alignment.topLeft || corner == Alignment.topRight;
    const size = 24.0;
    const thickness = 3.0;
    const color = Color(0xFF00E5FF);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BracketPainter(
          isLeft: isLeft,
          isTop: isTop,
          color: color,
          thickness: thickness,
        ),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final bool isLeft, isTop;
  final Color color;
  final double thickness;

  const _BracketPainter({
    required this.isLeft,
    required this.isTop,
    required this.color,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final x = isLeft ? 0.0 : size.width;
    final y = isTop ? 0.0 : size.height;
    final dx = isLeft ? size.width : -size.width;
    final dy = isTop ? size.height : -size.height;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_BracketPainter old) => false;
}
