import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'campus_ui.dart';
import 'splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'event_screen.dart';
import 'campus_data.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Navigator"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Button 1
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 166, 127, 234),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.map),
              label: const Text("Open Blocks/Rooms"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CampusUIScreen()),
                );
              },
            ),

            const SizedBox(height: 20),

            // Button 2
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 166, 127, 234),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.dashboard_customize),
              label: const Text("Open Campus Map"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CampusMapScreen()),
                );
              },
            ),

            const SizedBox(height: 20),

            // Button 3 (NEW EVENTS BUTTON)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 166, 127, 234),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.event),
              label: const Text("Events"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EventScreen()),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Campus Navigator",
      theme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurpleAccent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F2027),
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const SplashScreen(),
        "/home": (context) => const HomeScreen(),
      },
    );
  }
}


class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  Widget _colorLegend() {
  return IgnorePointer(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(160),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withAlpha(30), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 10,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_blocks.length, (index) {
          final block = _blocks[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: HSVColor.fromAHSV(
                    1,
                    (block['markerColor'] ?? 210).toDouble(),
                    1,
                    1,
                  ).toColor(),
                ),
                const SizedBox(width: 6),
                Text(
                  block['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    ),
  );
}



  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();

  static const LatLng _campusCenter = LatLng(28.409845, 77.403381);

  // ---------- Synchronized Data Source ----------
  final List<Map<String, dynamic>> _blocks = allCampusBlocks;

  final Set<Marker> _markers = {};
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _initMarkers();
    _determinePosition();
  }

  // ---------- Initialize Markers ----------
  void _initMarkers() {
    for (var block in _blocks) {
      _markers.add(Marker(
        markerId: MarkerId(block['name']),
        position: LatLng(block['lat'], block['lng']),
        infoWindow: InfoWindow(title: block['name']),
        icon: BitmapDescriptor.defaultMarkerWithHue(
  block['markerColor'] ?? BitmapDescriptor.hueAzure,),
        onTap: () => _showBlockInfo(block),
      ));
    }
  }

  // ---------- Show Block Info ----------
void _showBlockInfo(Map<String, dynamic> block) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BlockInfoSheet(block: block, onNavigate: (lat, lng) => _openInGoogleMaps(lat, lng)),
  );
}

  // ---------- Search Room or Block (FLEXIBLE) ----------
  Future<void> _searchLocation(String query) async {
    query = query.trim().toLowerCase();

    // 1. Check if it's a room
    for (var block in _blocks) {
      for (var room in block['rooms']) {
        if (room['name'].toString().toLowerCase() == query) {
          await _animateToLocation(LatLng(block['lat'], block['lng']));
          _showRoomInfo(block, room);
          return;
        }
      }
    }

    // 2. Otherwise, search block name (Flexible contains)
    final blockResult = _blocks.firstWhere(
      (b) => b['name'].toString().toLowerCase().contains(query),
      orElse: () => {},
    );

    if (blockResult.isNotEmpty) {
      await _animateToLocation(LatLng(blockResult['lat'], blockResult['lng']));
      _showBlockInfo(blockResult);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No match found')));
    }
  }

  // ---------- Room Info Sheet ----------
  void _showRoomInfo(Map<String, dynamic> block, Map<String, dynamic> room) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _RoomInfoSheet(block: block, room: room, onNavigate: (lat, lng) => _openInGoogleMaps(lat, lng)),
  );
}

  // ---------- Open in Google Maps ----------
  Future<void> _openInGoogleMaps(double lat, double lng) async {
    final Uri googleMapUrl = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking");
    if (!await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  // ---------- Animate Camera ----------
  Future<void> _animateToLocation(LatLng target) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: target, zoom: 18.0),
    ));
  }

  // ---------- Detect User Location ----------
  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(pos.latitude, pos.longitude);
        _markers.add(Marker(
          markerId: const MarkerId('You'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'You are here'),
        ));
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                const CameraPosition(target: _campusCenter, zoom: 17.0),
            markers: _markers,
            myLocationEnabled: true,
            onMapCreated: (controller) {
              if (!_controller.isCompleted) _controller.complete(controller);
            },
          ),
          // 🔥 LEGEND ALWAYS ON TOP
    Positioned(
      top: 105, // Increased from 90 to avoid search bar attachment
      right: 15,
      child: _colorLegend(),
    ),
          SafeArea(
  child: Padding(
    padding: const EdgeInsets.all(12.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: Colors.black, // Pure black text while typing
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: "Search block or room...",
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
          prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, color: Colors.deepPurple),
            onPressed: () => _searchController.clear(),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          border: InputBorder.none,
        ),
        onSubmitted: _searchLocation,
      ),
    ),
  ),
),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Go to My Location",
        onPressed: () =>
            _animateToLocation(_currentLocation ?? _campusCenter),
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

// --------------------- DARK STYLISH HOME SCREEN ---------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward(); // Only move blobs once
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. DYNAMIC MESH BACKGROUND (Lag-Free)
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  children: [
                    // Base Dark Layer
                    Container(color: const Color(0xFF0F2027)),

                    // Moving Blob 1
                    Positioned(
                      top: -100 + (50 * _controller.value),
                      left: -50 + (30 * _controller.value),
                      child: _MeshBlob(
                        size: 400,
                        color: Colors.deepPurpleAccent.withOpacity(0.3),
                      ),
                    ),

                    // Moving Blob 2
                    Positioned(
                      bottom: -80 + (40 * (1 - _controller.value)),
                      right: -60 + (50 * _controller.value),
                      child: _MeshBlob(
                        size: 350,
                        color: Colors.blueAccent.withOpacity(0.2),
                      ),
                    ),

                    // Moving Blob 3 (Center subtle)
                    Positioned(
                      top: 200 + (30 * _controller.value),
                      right: 100 - (20 * _controller.value),
                      child: _MeshBlob(
                        size: 300,
                        color: Colors.indigoAccent.withOpacity(0.15),
                      ),
                    ),

                    // Tech Grid Overlay
                    Opacity(
                      opacity: 0.12,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _GridPainter(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // MAIN UI
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // NEON GLOW ICON
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purpleAccent.withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: Colors.purple.shade300,
                      size: 90,
                    ).animate()
                     .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 800.ms, curve: Curves.easeOutBack),
                  ),
                  const SizedBox(height: 25),

                  Text(
                    "Campus Navigator",
                    style: GoogleFonts.outfit(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 25,
                          color: Colors.deepPurpleAccent.withOpacity(0.8),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Navigate your campus effortlessly",
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 50),

                  _menuButton(
                    icon: Icons.map_rounded,
                    label: "Open Campus Map",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CampusMapScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  _menuButton(
                    icon: Icons.apartment_rounded,
                    label: "Open Blocks / Rooms",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CampusUIScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

_menuButton(
  icon: Icons.event,
  label: "Events",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EventScreen(),
      ),
    );
  },
),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 280,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 600.ms),
    );
  }
}

// --------------------- PERFORMANCE OPTIMIZED HUD HELPERS ---------------------

class _MeshBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _MeshBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 20,
          )
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 0.5;

    const double step = 30.0;

    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Add dots at intersections
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.8);
    for (double i = 0; i < size.width; i += step) {
      for (double j = 0; j < size.height; j += step) {
        canvas.drawCircle(Offset(i, j), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BlockInfoSheet extends StatefulWidget {
  final Map<String, dynamic> block;
  final Function(double, double) onNavigate;
  const _BlockInfoSheet({required this.block, required this.onNavigate});

  @override
  State<_BlockInfoSheet> createState() => _BlockInfoSheetState();
}

class _BlockInfoSheetState extends State<_BlockInfoSheet> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        decoration: BoxDecoration(
          color: const Color(0xFF0F2027).withOpacity(0.7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurpleAccent.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4, width: 40,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            Text(
              widget.block['name'],
              style: GoogleFonts.outfit(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white,
                shadows: [Shadow(color: Colors.deepPurpleAccent.withOpacity(0.8), blurRadius: 10)],
              ),
              textAlign: TextAlign.center,
            ).animate().fade(duration: 400.ms),
            const SizedBox(height: 10),
            Text(
              "LAT: ${widget.block['lat'].toStringAsFixed(6)} | LNG: ${widget.block['lng'].toStringAsFixed(6)}",
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.white60, letterSpacing: 1),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            Text(
              "Navigate to this building for room-level guidance.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.white),
            ).animate().fade(delay: 200.ms),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                icon: const Icon(Icons.navigation),
                label: Text("Navigate in Google Maps", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  Navigator.pop(context);
                  widget.onNavigate(widget.block['lat'], widget.block['lng']);
                },
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

class _RoomInfoSheet extends StatefulWidget {
  final Map<String, dynamic> block;
  final Map<String, dynamic> room;
  final Function(double, double) onNavigate;

  const _RoomInfoSheet({required this.block, required this.room, required this.onNavigate});

  @override
  State<_RoomInfoSheet> createState() => _RoomInfoSheetState();
}

class _RoomInfoSheetState extends State<_RoomInfoSheet> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF0F2027).withOpacity(0.7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 4, width: 40,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.hub_outlined, color: Colors.blueAccent, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "${widget.room['name']}",
                    style: GoogleFonts.outfit(
                      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white,
                      shadows: [Shadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 10)],
                    ),
                  ),
                ),
              ],
            ).animate().fade(),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                "Located in ${widget.block['name']}",
                style: GoogleFonts.outfit(fontSize: 14, color: Colors.white60),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.layers_outlined, color: Colors.blueAccent, size: 20),
                  const SizedBox(width: 10),
                  Text(widget.room['floor'] == 0 ? "GROUND FLOOR" : "FLOOR ${widget.room['floor']}", style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ],
              ),
            ).animate().fade(delay: 200.ms),
            const SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.near_me_outlined, color: Colors.orangeAccent, size: 20),
                    const SizedBox(width: 10),
                    Text("DIRECTIONS", style: GoogleFonts.outfit(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.room['directions'],
                  style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.85), fontSize: 15, height: 1.5),
                ),
              ],
            ).animate().fade(delay: 400.ms),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.navigation),
                label: Text("Navigate to Block", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  widget.onNavigate(widget.block['lat'], widget.block['lng']);
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}