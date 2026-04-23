import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';
import 'admin_login_screen.dart';
import 'add_event_screen.dart';
import 'event_detail_screen.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: Text("Campus Events", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.withOpacity(0.8), Colors.blue.withOpacity(0.4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logged out")),
                );
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          // Subtle Mesh Background for Events
          const _MeshBackground(),
          
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('events')
                .orderBy('date')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Something went wrong", style: TextStyle(color: Colors.white70)));
              }

              if (!snapshot.hasData) {
                return _buildSkeletonLoader();
              }

              final events = snapshot.data!.docs;

              if (events.isEmpty) {
                return Center(
                  child: Text("No events available", 
                  style: GoogleFonts.outfit(color: Colors.white54, fontSize: 18))
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 10, bottom: 80),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final Timestamp timestamp = event['date'];
                  final DateTime date = timestamp.toDate();

                  return _EventCard(event: event, date: date, user: user, index: index);
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 10,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          if (user != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEventScreen()));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
          }
        },
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
        ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: Colors.white10);
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final QueryDocumentSnapshot event;
  final DateTime date;
  final User? user;
  final int index;

  const _EventCard({required this.event, required this.date, this.user, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.2),
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.02)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailScreen(
                        title: event['title'],
                        venue: event['venue'],
                        description: event['description'] ?? '',
                        date: date,
                      ),
                    ),
                  );
                },
                onLongPress: user != null ? () => _confirmDelete(context) : null,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              event['title'],
                              style: GoogleFonts.outfit(
                                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white,
                                shadows: [Shadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 10)],
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _IconText(icon: Icons.location_on_outlined, text: event['venue'], color: Colors.blueAccent),
                      const SizedBox(height: 8),
                      _IconText(
                        icon: Icons.calendar_today_outlined, 
                        text: "${date.day}-${date.month}-${date.year} | ${TimeOfDay.fromDateTime(date).format(context)}",
                        color: Colors.orangeAccent
                      ),
                      if (event['description'] != null && event['description'].toString().isNotEmpty) ...[
                        const SizedBox(height: 15),
                        Text(
                          event['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, height: 1.4),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    )
    .animate()
    .fade(duration: 400.ms);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B2735),
        title: Text("Delete Event", style: GoogleFonts.outfit(color: Colors.white)),
        content: Text("Are you sure you want to delete this event?", style: GoogleFonts.outfit(color: Colors.white70)),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('events').doc(event.id).delete();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _IconText({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 15)),
      ],
    );
  }
}

class _MeshBackground extends StatelessWidget {
  const _MeshBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _Blob(color: Colors.deepPurple.withOpacity(0.15), size: 300, top: -100, left: -100, duration: 15),
        _Blob(color: Colors.blue.withOpacity(0.1), size: 400, bottom: -150, right: -100, duration: 20),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  final double? top, bottom, left, right;
  final int duration;

  const _Blob({required this.color, required this.size, this.top, this.bottom, this.left, this.right, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ).animate()
       .move(begin: const Offset(-20, -20), end: const Offset(20, 20), duration: duration.seconds, curve: Curves.easeInOut)
       .blur(begin: const Offset(60, 60), end: const Offset(60, 60)),
    );
  }
}