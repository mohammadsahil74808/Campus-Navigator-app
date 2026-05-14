import 'dart:async';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// ─── OCR Service ──────────────────────────────────────────────────────────────
// Converts CameraImage to InputImage properly for both Android (NV21/YUV420)
// and iOS (BGRA8888), then runs ML Kit text recognition.
// Uses a lock to prevent overlapping inference calls.

class OcrService {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  bool _isProcessing = false;

  /// Processes a CameraImage from the camera stream.
  /// Returns recognized text, or null if busy / failed.
  Future<String?> processFrame(
    CameraImage image,
    int sensorOrientation,
    InputImageRotation rotation,
  ) async {
    if (_isProcessing) return null;
    _isProcessing = true;

    try {
      final inputImage = _cameraImageToInputImage(image, rotation);
      if (inputImage == null) return null;

      final result = await _recognizer.processImage(inputImage);
      return result.text.trim();
    } catch (e) {
      debugPrint('[OcrService] Error: $e');
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  /// Converts [CameraImage] → [InputImage] for ML Kit.
  /// Handles NV21 (Android) and BGRA8888 (iOS) formats.
  InputImage? _cameraImageToInputImage(
    CameraImage image,
    InputImageRotation rotation,
  ) {
    try {
      // Android YUV_420_888 / NV21 path
      if (image.format.group == ImageFormatGroup.yuv420) {
        final nv21Bytes = _yuv420ToNv21(image);
        return InputImage.fromBytes(
          bytes: nv21Bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.nv21,
            bytesPerRow: image.width,
          ),
        );
      }

      // iOS BGRA8888 path
      if (image.format.group == ImageFormatGroup.bgra8888) {
        return InputImage.fromBytes(
          bytes: image.planes[0].bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.bgra8888,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );
      }

      return null;
    } catch (e) {
      debugPrint('[OcrService] Image conversion error: $e');
      return null;
    }
  }

  /// Converts YUV_420_888 CameraImage planes → NV21 byte array
  Uint8List _yuv420ToNv21(CameraImage image) {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = uPlane.bytesPerRow;
    final int uvPixelStride = uPlane.bytesPerPixel ?? 1;

    final nv21 = Uint8List(width * height + 2 * ((width ~/ 2) * (height ~/ 2)));

    // Copy Y plane
    int nv21Index = 0;
    for (int row = 0; row < height; row++) {
      final rowOffset = row * yPlane.bytesPerRow;
      for (int col = 0; col < width; col++) {
        nv21[nv21Index++] = yPlane.bytes[rowOffset + col];
      }
    }

    // Interleave V and U for NV21
    for (int row = 0; row < height ~/ 2; row++) {
      for (int col = 0; col < width ~/ 2; col++) {
        final uvOffset = row * uvRowStride + col * uvPixelStride;
        nv21[nv21Index++] = vPlane.bytes[uvOffset]; // V first (NV21)
        nv21[nv21Index++] = uPlane.bytes[uvOffset]; // U second
      }
    }

    return nv21;
  }

  /// Maps device orientation + sensor orientation → InputImageRotation
  static InputImageRotation rotationFromSensor(int sensorOrientation) {
    switch (sensorOrientation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  void dispose() {
    _recognizer.close();
  }
}
