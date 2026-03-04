/// =============================================================================
/// Fake Gaze Stream - Testing Without Camera
/// =============================================================================
///
/// Generates synthetic gaze data for testing the game without a camera.
/// Useful for development and debugging.
/// =============================================================================

import 'dart:async';
import 'dart:math';
import 'gaze_point.dart';

/// Generate a fake circular gaze stream
Stream<GazePoint> fakeGazeStreamCircular({
  Duration interval = const Duration(milliseconds: 33), // ~30 FPS
  double radius = 0.3,
  double centerX = 0.5,
  double centerY = 0.5,
  double speed = 1.0,
}) async* {
  final random = Random();
  double angle = 0.0;

  while (true) {
    // Circular motion
    final x = centerX + radius * cos(angle);
    final y = centerY + radius * sin(angle);

    yield GazePoint(
      xNorm: x.clamp(0.0, 1.0),
      yNorm: y.clamp(0.0, 1.0),
      tsMs: DateTime.now().millisecondsSinceEpoch,
      confidence: 1.0,
    );

    angle += speed * 0.05; // Adjust speed
    if (angle > 2 * pi) angle -= 2 * pi;

    await Future.delayed(interval);
  }
}

/// Generate a fake random gaze stream
Stream<GazePoint> fakeGazeStreamRandom({
  Duration interval = const Duration(milliseconds: 33),
  double minX = 0.2,
  double maxX = 0.8,
  double minY = 0.2,
  double maxY = 0.8,
}) async* {
  final random = Random();

  while (true) {
    yield GazePoint(
      xNorm: minX + random.nextDouble() * (maxX - minX),
      yNorm: minY + random.nextDouble() * (maxY - minY),
      tsMs: DateTime.now().millisecondsSinceEpoch,
      confidence: 0.8 + random.nextDouble() * 0.2, // 0.8-1.0
    );

    await Future.delayed(interval);
  }
}

/// Generate a fake figure-8 pattern gaze stream
Stream<GazePoint> fakeGazeStreamFigure8({
  Duration interval = const Duration(milliseconds: 33),
  double scale = 0.25,
  double centerX = 0.5,
  double centerY = 0.5,
  double speed = 1.0,
}) async* {
  double t = 0.0;

  while (true) {
    // Figure-8 pattern (Lissajous curve)
    final x = centerX + scale * sin(t);
    final y = centerY + scale * sin(2 * t) / 2;

    yield GazePoint(
      xNorm: x.clamp(0.0, 1.0),
      yNorm: y.clamp(0.0, 1.0),
      tsMs: DateTime.now().millisecondsSinceEpoch,
      confidence: 1.0,
    );

    t += speed * 0.05;
    if (t > 2 * pi) t -= 2 * pi;

    await Future.delayed(interval);
  }
}
