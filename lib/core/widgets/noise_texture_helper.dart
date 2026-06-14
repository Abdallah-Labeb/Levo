import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Helper to generate and cache a repeating noise texture image for skeuomorphic backgrounds.
class NoiseTextureHelper {
  NoiseTextureHelper._();

  static ui.Image? _noiseImage;

  /// Pre-generates the noise texture image at startup.
  static Future<void> pregenerateNoise() async {
    if (_noiseImage != null) return;
    _noiseImage = await _generateNoise(200, 200);
  }

  static Future<ui.Image> _generateNoise(int width, int height) async {
    final completer = Completer<ui.Image>();
    final size = width * height;
    final pixels = Uint8List(size * 4);
    final random = math.Random();

    for (int i = 0; i < size; i++) {
      // Small random alpha value (representing 3% to 7% opacity grain)
      final alpha = random.nextInt(10) + 8; // 8 to 17 alpha value (out of 255)
      const grey = 128; // neutral grey grain
      final index = i * 4;
      pixels[index] = grey;      // Red
      pixels[index + 1] = grey;  // Green
      pixels[index + 2] = grey;  // Blue
      pixels[index + 3] = alpha; // Alpha
    }

    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );

    return completer.future;
  }

  /// Returns a decoration image shader that repeats the generated noise texture.
  static Shader? getNoiseShader(Rect rect) {
    if (_noiseImage == null) return null;
    return ImageShader(
      _noiseImage!,
      TileMode.repeated,
      TileMode.repeated,
      Float64List.fromList([
        1.0,
        0.0,
        0.0,
        0.0,
        0.0,
        1.0,
        0.0,
        0.0,
        0.0,
        0.0,
        1.0,
        0.0,
        0.0,
        0.0,
        0.0,
        1.0,
      ]),
    );
  }
}
