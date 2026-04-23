import 'package:campus_prototype/campus_data.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CampusUIScreen(),
    );
  }
}

class CampusUIScreen extends StatefulWidget {
  const CampusUIScreen({super.key});

  @override
  State<CampusUIScreen> createState() => _CampusUIScreenState();
}

class _CampusUIScreenState extends State<CampusUIScreen> {
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  Timer? _debounce;

  final List<Map<String, dynamic>> _blocks = campusBlocks;

  String? selectedBlock;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedBlock == null ? "Campus Blocks" : selectedBlock!,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F2027),
        leading: selectedBlock != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    selectedBlock = null;
                  });
                },
              )
            : null,
      ),
      backgroundColor: const Color(0xFF0F2027),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: selectedBlock == null ? _buildBlockList() : _buildRoomList(),
      ),
    );
  }

  Widget _buildBlockList() {
    return ListView.builder(
      itemCount: _blocks.length,
      itemBuilder: (context, index) {
        final block = _blocks[index];

        return ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.04)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.apartment_rounded,
                      color: Colors.deepPurpleAccent, size: 28),
                ),
                title: Text(
                  block['name'],
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white60, size: 18),
                onTap: () {
                  setState(() {
                    selectedBlock = block['name'];
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoomList() {
    final block = _blocks.firstWhere((b) => b['name'] == selectedBlock);

    final rooms = (block['rooms'] as List<dynamic>).where((room) {
      final name = room['name'].toString().toLowerCase();
      return name.contains(searchQuery);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 300), () {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search room...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white60),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];

              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                        width: 1.2,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.03)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.15),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.meeting_room_rounded,
                            color: Colors.blueAccent, size: 26),
                      ),
                      title: Text(
                        room['name'],
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      subtitle: Text(
                        room['floor'] == 0 ? "Ground Floor" : "Floor ${room['floor']}",
                        style: TextStyle(color: Colors.white.withOpacity(0.6)),
                      ),
                      trailing:
                          const Icon(Icons.info_outline_rounded, color: Colors.white60, size: 22),
                      onTap: () => _showRoomDetails(room),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showRoomDetails(Map<String, dynamic> room) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F2027),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                room['name'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
              Text(room['floor'] == 0 ? "Ground Floor" : "Floor: ${room['floor']}",
                  style: const TextStyle(fontSize: 16, color: Colors.white70)),
              const SizedBox(height: 12),
              const Text(
                "Directions:",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54),
              ),
              const SizedBox(height: 5),
              Text(
                room['directions'],
                style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.4),
              ),
              const SizedBox(height: 25),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Got it"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
