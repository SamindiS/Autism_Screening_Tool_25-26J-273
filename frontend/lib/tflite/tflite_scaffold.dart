import 'dart:math';

/// Lightweight scaffold for TFLite model. This is a stub that emulates
/// predictions. Replace with real tflite_flutter interpreter usage.
class TFLiteScaffold {
  final Random _rng = Random();
  TFLiteScaffold();

  /// Initialize model (load assets). Placeholder. When integrating real model,
  /// load interpreter and allocate tensors here.
  Future<void> loadModel() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Predict gaze as normalized [x, y] from an abstract model (no input).
  Future<List<double>> predictGaze() async {
    // placeholder random gaze near center
    final nx = 0.5 + (_rng.nextDouble() - 0.5) * 0.2;
    final ny = 0.5 + (_rng.nextDouble() - 0.5) * 0.2;
    await Future.delayed(const Duration(milliseconds: 30));
    return [nx.clamp(0.0, 1.0), ny.clamp(0.0, 1.0)];
  }

  /// Predict gaze from a flattened landmarks vector (normalized coords).
  /// landmarks: [x1,y1,x2,y2,...] normalized relative to face box or image.
  /// Returns normalized screen coordinates [x,y].
  Future<List<double>> predictFromLandmarks(List<double> landmarks) async {
    // Current stub: simple heuristic combining a few landmark indexes if available.
    // Replace this with tflite interpreter invocation that consumes the landmarks tensor.
    if (landmarks.isEmpty) return predictGaze();
    // heuristic: average left-eye and right-eye landmarks if present
    double avgX = 0.0, avgY = 0.0;
    int count = 0;
    for (var i = 0; i + 1 < landmarks.length && count < 10; i += 2) {
      avgX += landmarks[i];
      avgY += landmarks[i + 1];
      count += 1;
    }
    avgX /= max(1, count);
    avgY /= max(1, count);
    // map average face-relative coords to screen space roughly
    final nx = (0.5 + (avgX - 0.5) * 1.2).clamp(0.0, 1.0);
    final ny = (0.5 + (avgY - 0.5) * 1.2).clamp(0.0, 1.0);
    // add tiny noise to avoid perfectly flat outputs
    final nxj = nx + (_rng.nextDouble() - 0.5) * 0.02;
    final nyj = ny + (_rng.nextDouble() - 0.5) * 0.02;
    await Future.delayed(const Duration(milliseconds: 20));
    return [nxj.clamp(0.0, 1.0), nyj.clamp(0.0, 1.0)];
  }
}
