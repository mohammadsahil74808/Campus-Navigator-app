import 'dart:async';
import 'dart:math';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/foundation.dart';

// ─── SensorService ────────────────────────────────────────────────────────────
// Fuses compass + gyroscope to produce:
//   • A smooth, low-jitter heading (degrees, 0–360)
//   • Tilt angle for AR perspective correction
//
// Uses a complementary filter:
//   heading = α × (compassHeading) + (1−α) × (prevHeading + gyroRate×dt)
// This eliminates compass noise while gyro keeps it snappy during fast rotation.

class SensorService extends ChangeNotifier {
  // ── Public state ──────────────────────────────────────────────────────────
  double heading = 0.0; // Degrees 0–360 (north=0, east=90)
  double tiltDegrees = 0.0; // Device tilt (for perspective plane calculation)

  // ── Internal ──────────────────────────────────────────────────────────────
  StreamSubscription? _compassSub;
  StreamSubscription? _gyroSub;

  double _rawCompass = 0.0;
  double _smoothedHeading = 0.0;
  double _gyroZ = 0.0; // rad/s around z-axis
  DateTime _lastGyroTime = DateTime.now();

  // Complementary filter alpha: 0.0 = pure gyro, 1.0 = pure compass
  // 0.02 means 98% gyro (fast, smooth) + 2% compass (drift correction)
  static const double _alpha = 0.02;

  // Throttle notifyListeners to max 15 Hz to prevent widget rebuild thrashing
  DateTime _lastNotify = DateTime.now();
  static const _notifyInterval = Duration(milliseconds: 67); // ~15 Hz

  void start() {
    _compassSub = FlutterCompass.events?.listen(_onCompass);
    _gyroSub = gyroscopeEventStream().listen(_onGyro);
  }

  void _onCompass(CompassEvent event) {
    _rawCompass = event.heading ?? _rawCompass;
  }

  void _onGyro(GyroscopeEvent event) {
    final now = DateTime.now();
    final dt = now.difference(_lastGyroTime).inMicroseconds / 1e6;
    _lastGyroTime = now;

    // event.z = rotation rate around vertical axis (rad/s)
    _gyroZ = event.z;

    // Integrate gyro to predict new heading
    final gyroPredict = _smoothedHeading + (_gyroZ * 180 / pi) * dt;

    // Complementary filter fusion
    final compassNorm = _normalizeAngle(_rawCompass);
    final gyroPredNorm = _normalizeAngle(gyroPredict);

    // Handle 0/360 wrap-around by working in the shortest arc
    double diff = compassNorm - gyroPredNorm;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;

    _smoothedHeading = _normalizeAngle(gyroPredNorm + _alpha * diff);

    // Throttle UI updates
    if (now.difference(_lastNotify) >= _notifyInterval) {
      _lastNotify = now;
      heading = _smoothedHeading;
      tiltDegrees = _computeTilt(event);
      notifyListeners();
    }
  }

  double _computeTilt(GyroscopeEvent event) {
    // Approximate tilt from gyro x-axis (pitch)
    return (event.x * 180 / pi).clamp(-45.0, 45.0);
  }

  double _normalizeAngle(double deg) {
    return ((deg % 360) + 360) % 360;
  }

  void stop() {
    _compassSub?.cancel();
    _gyroSub?.cancel();
    _compassSub = null;
    _gyroSub = null;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
