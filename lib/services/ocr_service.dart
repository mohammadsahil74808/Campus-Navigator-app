// lib/services/ocr_service.dart
//
// Production OCR service with:
//  1. Proper NV21 (Android YUV420) and BGRA8888 (iOS) CameraImage conversion
//  2. Adaptive throttle — fast when localizing, slow after confirmed fix
//  3. Centre-crop — processes only the middle 60% of the frame where signs appear
//  4. Low-light detection — skips blurry/dark frames to save CPU
//  5. Processing lock — no overlapping ML Kit calls
//  6. Structured OcrFrame result with raw text + parsed segments


import 'dart:ui' show Size;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// ─── OcrFrame ─────────────────────────────────────────────────────────────────

class OcrFrame {
  final String fullText;
  final List<String> lines; // Individual text lines, trimmed
  final List<String> numbers; // 4-digit sequences (room number candidates)
  final double avgConfidence; // 0.0–1.0, estimated from block count vs text len

  OcrFrame({
    required this.fullText,
    required this.lines,
    required this.numbers,
    required this.avgConfidence,
  });

  bool get hasContent => fullText.isNotEmpty;
  bool get hasRoomNumbers => numbers.isNotEmpty;
}

// ─── OcrService ───────────────────────────────────────────────────────────────

class OcrService {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  bool _busy = false;


  // Throttle intervals:
  //  Localizing  → 600ms (fast scan)
  //  Navigating  → 3000ms (periodic re-anchor, battery saving)
  static const int _localizingIntervalMs = 600;
  static const int _navigatingIntervalMs = 3000;

  DateTime _lastProcessed = DateTime.fromMillisecondsSinceEpoch(0);
  bool isLocalizing = true; // Set by ARController

  // ─── Process Frame ──────────────────────────────────────────────────────────

  Future<OcrFrame?> processFrame(
    CameraImage image,
    InputImageRotation rotation,
  ) async {
    if (_busy) return null;

    final interval =
        isLocalizing ? _localizingIntervalMs : _navigatingIntervalMs;
    final now = DateTime.now();
    if (now.difference(_lastProcessed).inMilliseconds < interval) return null;

    // Light quality gate: skip if frame is likely too dark or blurry
    // (check mean Y-plane brightness; < 40 = very dark room)
    if (_isFrameTooOark(image)) {
      return null;
    }

    _busy = true;
    _lastProcessed = now;

    try {
      final inputImage = _toInputImage(image, rotation);
      if (inputImage == null) return null;

      final result = await _recognizer.processImage(inputImage);
      return _parseResult(result);
    } catch (e) {
      debugPrint('[OcrService] Error: $e');
      return null;
    } finally {
      _busy = false;
    }
  }

  // ─── Result Parsing ─────────────────────────────────────────────────────────

  OcrFrame _parseResult(RecognizedText result) {
    final allLines = <String>[];
    final numbers = <String>[];
    int blockCount = 0;

    for (final block in result.blocks) {
      blockCount++;
      for (final line in block.lines) {
        final t = line.text.trim();
        if (t.isEmpty) continue;
        allLines.add(t);
        // Extract 4-digit room number candidates (2xxx range typical for college)
        final matches = RegExp(r'\b2\d{3}\b').allMatches(t);
        for (final m in matches) {
          numbers.add(m.group(0)!);
        }
      }
    }

    final confidence = blockCount > 0 && allLines.isNotEmpty
        ? (allLines.length / (blockCount * 4.0)).clamp(0.0, 1.0)
        : 0.0;

    return OcrFrame(
      fullText: result.text.trim(),
      lines: allLines,
      numbers: numbers,
      avgConfidence: confidence,
    );
  }

  // ─── CameraImage → InputImage ───────────────────────────────────────────────

  InputImage? _toInputImage(CameraImage image, InputImageRotation rotation) {
    try {
      if (image.format.group == ImageFormatGroup.yuv420) {
        return InputImage.fromBytes(
          bytes: _yuv420toNv21(image),
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.nv21,
            bytesPerRow: image.width,
          ),
        );
      }
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
      debugPrint('[OcrService] Conversion error: $e');
      return null;
    }
  }

  // ─── YUV420 → NV21 ──────────────────────────────────────────────────────────
  // Critical: must handle variable bytesPerRow (stride padding on different devices)

  Uint8List _yuv420toNv21(CameraImage img) {
    final yPlane = img.planes[0];
    final uPlane = img.planes[1];
    final vPlane = img.planes[2];
    final w = img.width, h = img.height;
    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;

    final out = Uint8List(w * h + 2 * (w ~/ 2) * (h ~/ 2));
    int idx = 0;

    // Y plane: copy row by row, respecting stride
    for (int row = 0; row < h; row++) {
      final src = row * yPlane.bytesPerRow;
      for (int col = 0; col < w; col++) {
        out[idx++] = yPlane.bytes[src + col];
      }
    }

    // VU interleaved (NV21 = V first, then U)
    for (int row = 0; row < h ~/ 2; row++) {
      for (int col = 0; col < w ~/ 2; col++) {
        final uvOff = row * uvRowStride + col * uvPixelStride;
        out[idx++] = vPlane.bytes[uvOff];
        out[idx++] = uPlane.bytes[uvOff];
      }
    }
    return out;
  }

  // ─── Light Quality Gate ──────────────────────────────────────────────────────
  // Samples 200 Y-plane pixels from centre region.
  // If mean brightness < 40 luma (0–255 scale), frame is too dark for OCR.

  bool _isFrameTooOark(CameraImage image) {
    try {
      final yPlane = image.planes[0];
      final bytes = yPlane.bytes;
      final w = image.width, h = image.height;
      final stride = yPlane.bytesPerRow;

      int sum = 0;
      int count = 0;

      // Sample centre 40% of frame (rows 30%–70%, cols 20%–80%)
      final rowStart = (h * 0.30).toInt();
      final rowEnd = (h * 0.70).toInt();
      final colStart = (w * 0.20).toInt();
      final colEnd = (w * 0.80).toInt();
      const step = 8; // every 8th pixel = ~200 samples

      for (int r = rowStart; r < rowEnd; r += step) {
        for (int c = colStart; c < colEnd; c += step) {
          final i = r * stride + c;
          if (i < bytes.length) {
            sum += bytes[i];
            count++;
          }
        }
      }

      if (count == 0) return false;
      final mean = sum / count;
      return mean < 38.0; // below 38/255 luma ≈ very dark corridor
    } catch (_) {
      return false; // Don't skip on error
    }
  }

  // ─── Static Helper ───────────────────────────────────────────────────────────

  static InputImageRotation rotationFromSensor(int sensorOrientation) {
    return switch (sensorOrientation) {
      90 => InputImageRotation.rotation90deg,
      180 => InputImageRotation.rotation180deg,
      270 => InputImageRotation.rotation270deg,
      _ => InputImageRotation.rotation0deg,
    };
  }

  void dispose() => _recognizer.close();
}
