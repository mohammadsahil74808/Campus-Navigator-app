// lib/navigation/ar_navigation_view.dart
//
// Pure UI layer. No business logic.
// All state comes from ARController via ChangeNotifier/Consumer.
//
// Structural improvements:
//  1. AnimationController runs at 60fps independent of sensor updates
//  2. Direction panel uses TurnType (enum) not raw angle string — correct icons
//  3. Proximity-zone-aware UI: changes colour/style as user approaches destination
//  4. Arrived state: shows confirmation with room name + dismiss prompt
//  5. Dev overlay: optional debug panel showing OCR status, heading, path
//  6. Reroute toast: brief message when rerouting happens

import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation_model.dart';
import 'ar_controller.dart';
import 'ar_overlay_painter.dart';
import '../services/sensor_service.dart';


class ARNavigationView extends StatefulWidget {
  final NavigationNode targetNode;
  final CampusGraph graph;
  final bool showDevOverlay;

  const ARNavigationView({
    super.key,
    required this.targetNode,
    required this.graph,
    this.showDevOverlay = false,
  });

  @override
  State<ARNavigationView> createState() => _ARNavigationViewState();
}

class _ARNavigationViewState extends State<ARNavigationView>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late ARController _ctrl;
  bool _showDev = false;
  String? _rerouteMessage;

  @override
  void initState() {
    super.initState();
    _anim =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _showDev = widget.showDevOverlay;
    _ctrl = ARController(
      graph: widget.graph,
      targetNode: widget.targetNode,
      sensorService: SensorService(),
    );
    _ctrl.initialize();
    _ctrl.addListener(_checkForReroute);
  }

  String? _prevStatus;
  void _checkForReroute() {
    final msg = _ctrl.state.statusMessage;
    if (msg.startsWith('Recalculating') && msg != _prevStatus) {
      setState(() => _rerouteMessage = 'Route recalculated');
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _rerouteMessage = null);
      });
    }
    _prevStatus = msg;
  }

  @override
  void dispose() {
    _ctrl.removeListener(_checkForReroute);
    _anim.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ARController>.value(
      value: _ctrl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<ARController>(
          builder: (ctx, ctrl, _) {
            if (!ctrl.isCameraReady) return const _LoadingScreen();

            final st = ctrl.state;
            return Stack(children: [
              // ── Camera ────────────────────────────────────────────────────
              Positioned.fill(child: CameraPreview(ctrl.cameraController!)),

              // ── AR Path Overlay ───────────────────────────────────────────
              if (!st.isLocalizing && st.hasPath && !st.isArrived)
                AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => Positioned.fill(
                    child: CustomPaint(
                      painter: AROverlayPainter(
                        turnAngle: st.turnAngle,
                        distanceMeters: st.distanceToNextMeters,
                        nextNode: st.nextNode,
                        targetNode: st.targetNode,
                        proximityZone: st.proximityZone,
                        confidence: st.confidence,
                        animValue: _anim.value,
                      ),
                    ),
                  ),
                ),

              // ── Localization Scan UI ──────────────────────────────────────
              if (st.isLocalizing) const _ScanOverlay(),

              // ── Arrived Screen ────────────────────────────────────────────
              if (st.isArrived) _buildArrivedScreen(ctx, st),

              // ── Direction Panel ───────────────────────────────────────────
              if (!st.isLocalizing && !st.isArrived && st.hasPath)
                _buildDirectionPanel(st),

              // ── HUD Bar ───────────────────────────────────────────────────
              _buildHud(st),

              // ── Reroute Toast ─────────────────────────────────────────────
              if (_rerouteMessage != null) _buildToast(_rerouteMessage!),

              // ── Close Button ──────────────────────────────────────────────
              _buildClose(ctx),

              // ── Signal Dot ───────────────────────────────────────────────
              _buildSignalDot(st.confidence),

              // ── Dev Overlay ───────────────────────────────────────────────
              if (_showDev) _buildDevOverlay(st),

              // ── Dev Toggle ───────────────────────────────────────────────
              _buildDevToggle(),
            ]);
          },
        ),
      ),
    );
  }

  // ─── Direction Panel ───────────────────────────────────────────────────────

  Widget _buildDirectionPanel(NavigationState st) {
    final next = st.nextNode!;
    final zoneColor = _zoneAccent(st.proximityZone);

    return Positioned(
      top: 56,
      left: 0,
      right: 0,
      child: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DirectionArrowWidget(turnType: st.turnType),
          const SizedBox(height: 10),
          _glassChip(
            children: [
              Text(
                st.turnType.label,
                style: TextStyle(
                    color: zoneColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4),
              ),
              const SizedBox(height: 2),
              Text(
                next.displayLabel.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800),
              ),
              if (st.distanceToNextMeters > 0) ...[
                const SizedBox(height: 2),
                Text(
                  '${st.distanceToNextMeters.toStringAsFixed(1)} m  ·  '
                  '${st.totalRemainingMeters.toStringAsFixed(0)} m total',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 11),
                ),
              ],
            ],
            borderColor: zoneColor.withValues(alpha: 0.55),
          ),
        ],
      )),
    );
  }

  Color _zoneAccent(ProximityZone z) => switch (z) {
        ProximityZone.arrived => const Color(0xFF69FF47),
        ProximityZone.near => const Color(0xFF69FF47),
        ProximityZone.approaching => const Color(0xFFFFD600),
        ProximityZone.far => const Color(0xFF00E5FF),
      };

  // ─── Arrived Screen ────────────────────────────────────────────────────────

  Widget _buildArrivedScreen(BuildContext ctx, NavigationState st) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        child: Center(
            child: _glassChip(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF69FF47), size: 56),
            const SizedBox(height: 12),
            const Text('YOU HAVE ARRIVED',
                style: TextStyle(
                    color: Color(0xFF69FF47),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8)),
            const SizedBox(height: 6),
            Text(
              st.targetNode?.displayLabel ?? '',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('DONE',
                  style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4)),
            ),
          ],
          borderColor: const Color(0xFF69FF47).withValues(alpha: 0.6),
        )),
      ),
    );
  }

  // ─── HUD Bar ──────────────────────────────────────────────────────────────

  Widget _buildHud(NavigationState st) {
    return Positioned(
      bottom: 28,
      left: 18,
      right: 18,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(st.statusMessage,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
              if (st.isLocalizing) ...[
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation(
                      st.confidence == LocalizationConfidence.medium
                          ? const Color(0xFF00E5FF)
                          : Colors.white30),
                ),
                const SizedBox(height: 5),
                Text('Scanning for room signs…',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11)),
              ],
              if (!st.isLocalizing && st.path.length > 1) ...[
                const SizedBox(height: 7),
                _buildPathRow(st.path),
              ],
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildPathRow(List<NavigationNode> path) {
    final nodes = path.take(5).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < nodes.length; i++) ...[
          Text(nodes[i].displayLabel,
              style: TextStyle(
                color: i == 0 ? const Color(0xFF00E5FF) : Colors.white38,
                fontSize: 10,
                fontWeight: i == 0 ? FontWeight.w700 : FontWeight.normal,
              )),
          if (i < nodes.length - 1)
            const Icon(Icons.chevron_right, color: Colors.white24, size: 13),
        ],
        if (path.length > 5)
          Text(' +${path.length - 5}',
              style: const TextStyle(color: Colors.white24, fontSize: 10)),
      ],
    );
  }

  // ─── Misc UI ──────────────────────────────────────────────────────────────

  Widget _buildToast(String msg) => Positioned(
        top: 120,
        left: 30,
        right: 30,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9800).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(msg,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
        ),
      );

  Widget _buildClose(BuildContext ctx) => Positioned(
        top: 48,
        left: 14,
        child: GestureDetector(
          onTap: () => Navigator.of(ctx).pop(),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.55),
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ),
      );

  Widget _buildSignalDot(LocalizationConfidence c) {
    final color = switch (c) {
      LocalizationConfidence.high => const Color(0xFF69FF47),
      LocalizationConfidence.medium => const Color(0xFFFFD600),
      LocalizationConfidence.low => const Color(0xFFFF6D00),
      LocalizationConfidence.none => Colors.white24,
    };
    return Positioned(
      top: 56,
      right: 16,
      child: Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 8)
          ],
        ),
      ),
    );
  }

  Widget _buildDevToggle() => Positioned(
        top: 48,
        right: 14,
        child: GestureDetector(
          onTap: () => setState(() => _showDev = !_showDev),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _showDev
                  ? const Color(0xFF00E5FF).withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.4),
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.developer_mode,
                color: Colors.white70, size: 16),
          ),
        ),
      );

  Widget _buildDevOverlay(NavigationState st) => Positioned(
        top: 90,
        left: 10,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: DefaultTextStyle(
            style: const TextStyle(
                color: Colors.white70, fontSize: 10, fontFamily: 'monospace'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HDG: ${st.headingDegrees.toStringAsFixed(1)}°'),
                Text(
                    'TURN: ${st.turnAngle.toStringAsFixed(1)}° [${st.turnType.name}]'),
                Text('CURR: ${st.currentNode?.id ?? "—"}'),
                Text('NEXT: ${st.nextNode?.id ?? "—"}'),
                Text('DEST: ${st.targetNode?.id ?? "—"}'),
                Text('DIST: ${st.distanceToNextMeters.toStringAsFixed(1)}m'),
                Text('ZONE: ${st.proximityZone.name}'),
                Text('CONF: ${st.confidence.name}'),
                Text('PATH: ${st.path.length} nodes'),
              ],
            ),
          ),
        ),
      );

  // ─── Shared Glass Widget ──────────────────────────────────────────────────

  Widget _glassChip(
      {required List<Widget> children, required Color borderColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}

// ─── Loading Screen ───────────────────────────────────────────────────────────

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: Color(0xFF00E5FF)),
          SizedBox(height: 14),
          Text('Initializing AR…',
              style: TextStyle(color: Colors.white60, fontSize: 13)),
        ])),
      );
}

// ─── Scan Overlay ─────────────────────────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(children: [
        for (final (dx, dy, alignX, alignY) in [
          (40.0, 120.0, true, true),
          (-40.0, 120.0, false, true),
          (40.0, -180.0, true, false),
          (-40.0, -180.0, false, false),
        ])
          Positioned(
            left: alignX ? dx : null,
            right: !alignX ? -dx : null,
            top: alignY ? dy : null,
            bottom: !alignY ? -dy : null,
            child: _Bracket(
                topLeft: alignX && alignY,
                topRight: !alignX && alignY,
                btmLeft: alignX && !alignY,
                btmRight: !alignX && !alignY),
          ),
        const Positioned(
          top: 108,
          left: 0,
          right: 0,
          child: Center(
              child: Text(
            'POINT AT ROOM NUMBER SIGN',
            style: TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.2),
          )),
        ),
      ]),
    );
  }
}

class _Bracket extends StatelessWidget {
  final bool topLeft, topRight, btmLeft, btmRight;
  const _Bracket(
      {required this.topLeft,
      required this.topRight,
      required this.btmLeft,
      required this.btmRight});

  @override
  Widget build(BuildContext ctx) => CustomPaint(
        size: const Size(22, 22),
        painter: _BracketPainter(
          isLeft: topLeft || btmLeft,
          isTop: topLeft || topRight,
        ),
      );
}

class _BracketPainter extends CustomPainter {
  final bool isLeft, isTop;
  const _BracketPainter({required this.isLeft, required this.isTop});

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    final x = isLeft ? 0.0 : s.width;
    final y = isTop ? 0.0 : s.height;
    final dx = isLeft ? s.width : -s.width;
    final dy = isTop ? s.height : -s.height;
    c.drawLine(Offset(x, y), Offset(x + dx, y), p);
    c.drawLine(Offset(x, y), Offset(x, y + dy), p);
  }

  @override
  bool shouldRepaint(_BracketPainter o) => false;
}
