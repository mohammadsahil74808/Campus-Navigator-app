import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController textController;
  late Animation<double> fade;

  @override
  void initState() {
    super.initState();

    textController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));

    fade = CurvedAnimation(parent: textController, curve: Curves.easeIn);

    textController.forward();

    Timer(const Duration(seconds:5), () {
      Navigator.pushReplacementNamed(context, "/home");
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // FIRST: BIG LOGO
            Image.asset(
              "assets/logo.png",
              width: 160,
              height: 160,
            ),

            const SizedBox(height: 20),

            FadeTransition(
              opacity: fade,
              child: Column(
                children: const [
                  Text(
                    "Lingayas",
                    style: TextStyle(
                      color: Color.fromARGB(133, 255, 152, 8),
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Vidyapeeth",
                    style: TextStyle(
                      color: Color.fromARGB(124, 218, 62, 62),
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Faridabad",
                    style: TextStyle(
                      color: Color.fromARGB(160, 157, 153, 153),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
