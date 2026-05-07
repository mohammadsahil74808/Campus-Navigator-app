import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'navigation_model.dart';
import 'pathfinding.dart';
import 'vision_engine.dart';

class ARNavigationView extends StatefulWidget {
  final NavigationNode targetNode;
  final CampusGraph graph;

  const ARNavigationView({super.key, required this.targetNode, required this.graph});

  @override
  State<ARNavigationView> createState() => _ARNavigationViewState();
}

class _ARNavigationViewState extends State<ARNavigationView> {
  CameraController? _cameraController;
  StreamSubscription? _compassSubscription;
  double _heading = 0;
  
  NavigationNode? currentNode;
  List<NavigationNode> currentPath = [];
  late PathFinder pathFinder;
  late VisionEngine visionEngine;

  bool isLocalizing = true;
  String statusMessage = "Point camera at a room number to localize...";

  @override
  void initState() {
    super.initState();
    pathFinder = PathFinder(widget.graph);
    visionEngine = VisionEngine(widget.graph);
    _initializeCamera();
    _startCompass();
    _startLocalization();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  void _startCompass() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (mounted) {
        setState(() {
          _heading = event.heading ?? 0;
        });
      }
    });
  }

  void _startLocalization() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          currentNode = widget.graph.nodes.firstWhere((n) => n.type == NavNodeType.entrance);
          isLocalizing = false;
          statusMessage = "Located! Following path to ${widget.targetNode.name}";
          _calculatePath();
        });
      }
    });
  }

  void _calculatePath() {
    if (currentNode == null) return;
    
    NavigationNode? targetInGraph;
    try {
      targetInGraph = widget.graph.nodes.firstWhere(
        (n) => n.name.toLowerCase().contains(widget.targetNode.name.toLowerCase()) || 
               widget.targetNode.name.toLowerCase().contains(n.name.toLowerCase())
      );
    } catch (e) {
      targetInGraph = widget.graph.nodes.last;
    }

    currentPath = pathFinder.findPath(currentNode!.id, targetInGraph.id);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _compassSubscription?.cancel();
    visionEngine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          ),
          
          if (!isLocalizing && currentPath.isNotEmpty)
            _buildNavigationOverlay(),

          _buildHUD(),
          
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationOverlay() {
    if (currentPath.length < 2) return const SizedBox();
    
    final nextNode = currentPath[1];
    final currentPos = currentNode!.position;
    final nextPos = nextNode.position;
    
    double bearing = math.atan2(nextPos.x - currentPos.x, nextPos.z - currentPos.z) * 180 / math.pi;
    double diff = (bearing - _heading + 360) % 360;
    if (diff > 180) diff -= 360;

    return Stack(
      children: [
        // Perspective Road on Floor
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.45,
          child: CustomPaint(
            painter: PerspectiveRoadPainter(diff),
          ),
        ),
        
        // 3D-style Fixed Top Arrow
        Align(
          alignment: const Alignment(0, -0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: diff * math.pi / 180),
                duration: const Duration(milliseconds: 300),
                builder: (context, double angle, child) {
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateZ(angle),
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.cyanAccent.withOpacity(0.4), blurRadius: 40, spreadRadius: 5),
                        ],
                      ),
                      child: const Icon(
                        Icons.navigation_rounded,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          nextNode.name.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                        ),
                        Text(
                          "${(nextPos - currentPos).length.toStringAsFixed(1)} METERS AWAY",
                          style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHUD() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              statusMessage,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (isLocalizing)
              const Padding(
                padding: EdgeInsets.only(top: 15),
                child: LinearProgressIndicator(color: Colors.blueAccent),
              ),
          ],
        ),
      ),
    );
  }
}

class PerspectiveRoadPainter extends CustomPainter {
  final double diff;
  PerspectiveRoadPainter(this.diff);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.cyanAccent.withOpacity(0.5),
          Colors.cyanAccent.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    double centerX = size.width / 2;
    double bottomWidth = size.width * 0.9;
    double topWidth = size.width * 0.15;
    
    double targetX = centerX + (diff * 3);
    targetX = targetX.clamp(size.width * 0.1, size.width * 0.9);

    path.moveTo(centerX - bottomWidth / 2, size.height);
    path.lineTo(centerX + bottomWidth / 2, size.height);
    path.lineTo(targetX + topWidth / 2, 0);
    path.lineTo(targetX - topWidth / 2, 0);
    path.close();

    canvas.drawPath(path, paint);
    
    final edgePaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(path, edgePaint);

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      
    for (int i = 1; i < 4; i++) {
      double y = size.height * (1 - (i * 0.25));
      double currentCenterX = centerX + (targetX - centerX) * (i * 0.25);
      canvas.drawLine(Offset(currentCenterX - 10, y + 5), Offset(currentCenterX, y), linePaint);
      canvas.drawLine(Offset(currentCenterX + 10, y + 5), Offset(currentCenterX, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
