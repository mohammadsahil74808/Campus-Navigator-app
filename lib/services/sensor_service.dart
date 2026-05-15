// lib/services/sensor_service.dart
//
// Sensor fusion for stable indoor heading:
//
//  Problem in original: gyro Z-axis only works when phone is held vertically.
//  When tilted (common walking posture), Z-axis mixes with pitch/roll and
//  gives wrong rotation estimates. Fix: use gravity vector to isolate
//  the true yaw component regardless of device tilt.
//
//  Filter: complementary — 98% gyro short-term + 2% compass long-term.
//  Compass is the ground truth but noisy; gyro is smooth but drifts.
//  The fusion gives smooth, drift-free heading at 15 Hz output.

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService extends ChangeNotifier {
  // ── Public ──────────────────────────────────────────────────────────────
  double heading = 0.0; // 0–360, North=0, East=90
  double tiltDegrees = 0.0; // Device pitch (for AR perspective)
  double rollDegrees = 0.0; // Device roll (for arrow rotation correction)
  bool compassReady = false;

  // ── Internals ────────────────────────────────────────────────────────────
  StreamSubscription? _compassSub;
  StreamSubscription? _gyroSub;
  StreamSubscription? _accelSub;

  double _rawCompass = 0.0;
  double _smoothHeading = 0.0;

  DateTime _lastGyroTime = DateTime.now();

  // Gravity vector (from accelerometer, low-pass filtered)
  double _gx = 0, _gy = -9.8, _gz = 0;

  static const double _alpha = 0.02; // complementary filter weight
  static const double _gravityLP = 0.85; // gravity low-pass coefficient
  static const _notifyInterval = Duration(milliseconds: 67); // 15 Hz
  DateTime _lastNotify = DateTime.now();

  void start() {
    _compassSub = FlutterCompass.events?.listen(_onCompass);
    _gyroSub = gyroscopeEventStream().listen(_onGyro);
    _accelSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 40),
    ).listen(_onAccel);
  }

  void stop() {
    _compassSub?.cancel();
    _gyroSub?.cancel();
    _accelSub?.cancel();
    _compassSub = _gyroSub = _accelSub = null;
  }

  void _onCompass(CompassEvent e) {
    if (e.heading != null) {
      _rawCompass = e.heading!;
      compassReady = true;
    }
  }

  // Low-pass filter on raw accelerometer to track gravity direction
  void _onAccel(AccelerometerEvent e) {
    _gx = _gravityLP * _gx + (1 - _gravityLP) * e.x;
    _gy = _gravityLP * _gy + (1 - _gravityLP) * e.y;
    _gz = _gravityLP * _gz + (1 - _gravityLP) * e.z;

    // Compute tilt (pitch) from gravity
    final gMag = math.sqrt(_gx * _gx + _gy * _gy + _gz * _gz);
    if (gMag > 0.1) {
      tiltDegrees = math.asin((_gz / gMag).clamp(-1.0, 1.0)) * 180 / math.pi;
      rollDegrees = math.atan2(_gx, -_gy) * 180 / math.pi;
    }
  }

  void _onGyro(GyroscopeEvent e) {
    final now = DateTime.now();
    final dt = now.difference(_lastGyroTime).inMicroseconds / 1e6;
    _lastGyroTime = now;

    if (dt <= 0 || dt > 0.5) return; // skip bad intervals

    // Gravity-corrected yaw rate:
    // Project gyro vector onto the gravity axis to get true vertical rotation.
    final gMag = math.sqrt(_gx * _gx + _gy * _gy + _gz * _gz);
    double yawRate;
    if (gMag < 0.1) {
      yawRate = e.z; // fallback: phone perfectly flat
    } else {
      // Unit gravity vector
      final ux = _gx / gMag;
      final uy = _gy / gMag;
      final uz = _gz / gMag;
      // Dot product of gyro with gravity axis = yaw component
      yawRate = e.x * ux + e.y * uy + e.z * uz;
    }

    // Integrate yaw
    final gyroPred = _smoothHeading + (yawRate * 180 / math.pi) * dt;

    // Complementary fusion with compass
    double diff = _normalise(_rawCompass) - _normalise(gyroPred);
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;

    _smoothHeading = _normalise(gyroPred + _alpha * diff);

    // Throttle UI notifications to 15 Hz
    if (now.difference(_lastNotify) >= _notifyInterval) {
      _lastNotify = now;
      heading = _smoothHeading;
      notifyListeners();
    }
  }

  double _normalise(double d) => ((d % 360) + 360) % 360;

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
