import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'campus_ui.dart';
import 'splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'event_screen.dart';


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
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
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
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
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

  // ---------- Updated Structure (Blocks + Rooms) ----------
  final List<Map<String, dynamic>> _blocks = [
    {
      "name": "Computing Block",
      "lat": 28.409845,
      "lng": 77.403381,
      "markerColor": BitmapDescriptor.hueRed,
      "rooms": [
        {
          "name": "CS101",
          "floor": 1,
          "directions": "Ground floor, right wing near main lab."
        },
        {
          "name": "CS201",
          "floor": 2,
          "directions":
              "Go to 2nd floor using left stairs, 3rd room on the right."
        },
        {
      "name": "IBM Lab",
      "floor": 2,
      "directions":
          "Go to 2nd floor, take a right, then right again, and once more right. The IBM Lab (Room 2205) is located just beside the Departmental Library."
    },

    {
      "name": "2205",
      "floor": 2,
      "directions":
          "Go to 2nd floor, take a right, then right again, and once more right. The IBM Lab (Room 2205) is located just beside the Departmental Library."
    },
      ]
    },
    {
      "name": "Canteen",
      "lat": 28.409884,
      "lng": 77.404012,
      "markerColor": BitmapDescriptor.hueGreen,
      "rooms": []
    },
        {
      "name": "Gym & NSS",
      "lat": 28.409882,
      "lng": 77.403647,
      "markerColor": BitmapDescriptor.hueOrange,
      "rooms": []
    },
        {
      "name": "lawn Tennis court",
      "lat": 28.409382,
      "lng": 77.404283,
      "markerColor": BitmapDescriptor.hueBlue,
      "rooms": []
    },

        {
      "name": "School of Architecture",
      "lat": 28.409860,
      "lng": 77.404119,
      "markerColor": BitmapDescriptor.hueAzure,
      "rooms": []
    },

        {
      "name": "Mess",
      "lat": 28.409950,
      "lng": 77.402982,
      "markerColor": BitmapDescriptor.hueYellow,
      "rooms": []
    },
        {
      "name": "Parking",
      "lat": 28.409643,
      "lng": 77.402250,
      "markerColor": BitmapDescriptor.hueCyan,
      "rooms": []
    },
    {
      "name": "Girls Hostel",
      "lat": 28.410125,
      "lng": 77.402669,
      "markerColor": BitmapDescriptor.hueRose,
      "rooms": []
    },
    
    {
      "name": "Komati Block",
      "lat": 28.408725,
      "lng": 77.403140,
      "markerColor": BitmapDescriptor.hueMagenta,
      "rooms": []
    },

    {
      "name": "Music and Dance",
      "lat": 28.408769,
      "lng": 77.402810,
      "markerColor": 30.0,
      "rooms": []
    },

    {
      "name": "Central Block",
      "lat": 28.409265,
      "lng": 77.403197,
      "markerColor": BitmapDescriptor.hueViolet,
      "rooms": []
    },
  ];

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

  // ---------- Show Block Info (Updated & Improved) ----------
void _showBlockInfo(Map<String, dynamic> block) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              block['name'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Latitude: ${block['lat'].toStringAsFixed(6)}   |   Longitude: ${block['lng'].toStringAsFixed(6)}",
              style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 255, 255, 255)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Instruction Text
            Text(
              "After reaching the block, return to this app for room-level directions.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: const Color.fromARGB(255, 255, 255, 255)),
            ),
            const SizedBox(height: 10),

            // Full-width Navigate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.navigation, color: Colors.white),
                label: const Text(
                  "Navigate in Google Maps",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await _openInGoogleMaps(block['lat'], block['lng']);
                },
              ),
            ),

            const SizedBox(height: 15),
          ],
        ),
      );
    },
  );
}


  // ---------- Search Room or Block ----------
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

    // 2. Otherwise, search block name
    final blockResult = _blocks.firstWhere(
      (b) => b['name'].toString().toLowerCase() == query,
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
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (_) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2C5364), Color(0xFF203A43), Color(0xFF0F2027)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 5,
                width: 50,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.meeting_room, color: Colors.deepPurpleAccent, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${room['name']} (${block['name']})",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.deepPurpleAccent,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.layers, color: Colors.blueAccent, size: 22),
                const SizedBox(width: 8),
                Text(
                  "Floor: ${room['floor']}",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.directions, color: Colors.orangeAccent, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    room['directions'],
                    style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.navigation, color: Colors.white),
                label: const Text(
                  "Navigate to Block",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 8,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await _openInGoogleMaps(block['lat'], block['lng']);
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
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
      top: 90,
      right: 12,
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
    )..repeat(reverse: true);
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
          // BACKGROUND ANIMATED WAVES
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(Colors.deepPurple, Colors.blue, _controller.value)!,
                      Color.lerp(Colors.indigo, Colors.black, _controller.value)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),

          // MAIN UI
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: Colors.purple.shade300,
                    size: 90,
                  ),
                  const SizedBox(height: 25),

                  Text(
                    "Campus Navigator",
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: Colors.deepPurpleAccent,
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Navigate your campus effortlessly",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
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
      child: Container(
        width: 260,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white30, width: 1),
          color: Colors.white.withOpacity(0.12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }
}