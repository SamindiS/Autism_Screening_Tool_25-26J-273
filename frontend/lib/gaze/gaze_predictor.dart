/// Gaze Predictor (Clean Version)
///
/// Predicts where on screen the user is looking using:
/// 1. Pixel-based iris detection (finds darkest spot in eye = pupil)
/// 2. Head pose from ML Kit
/// 3. Improved calibration model that learns iris→screen mapping
///
/// Flow:
/// 1. Before calibration: Uses default weights (rough estimate)
/// 2. During calibration: Collects training samples
/// 3. After calibration: Uses trained model for accurate prediction

import 'dart:ui';
import 'gaze_tracker.dart';
import 'improved_gaze_model.dart';

/// Main gaze prediction class
class GazePredictor {
  /// The trainable model
  final ImprovedGazeModel _model = improvedGazeModel;

  /// Whether predictor is ready
  bool _isInitialized = false;

  /// Debug counter for logging
  int _debugCounter = 0;

  // ============= Public API =============

  /// Whether the predictor is ready
  bool get isInitialized => _isInitialized;

  /// Whether the model has been trained with calibration data
  bool get isCalibrated => _model.isCalibrated;

  /// Training loss (lower = better fit)
  double get trainingLoss => _model.lastMSE;

  /// Number of training samples collected
  int get trainingSampleCount => _model.sampleCount;

  /// Initialize the predictor
  Future<bool> initialize() async {
    _isInitialized = true;
    print('GazePredictor: Initialized with improved iris-based model');
    return true;
  }

  /// Predict gaze coordinates from eye landmarks
  ///
  /// Returns normalized screen coordinates (0-1)
  Future<Offset> predict(EyeLandmarks landmarks) async {
    if (!_isInitialized) {
      throw Exception('GazePredictor not initialized');
    }

    final prediction = _model.predict(landmarks);

    // Debug logging (every 15 frames for more visibility)
    _debugCounter++;
    if (_debugCounter % 15 == 0) {
      final leftIris = landmarks.leftIrisCenter ?? const Offset(0.5, 0.5);
      final rightIris = landmarks.rightIrisCenter ?? const Offset(0.5, 0.5);
      final avgIrisX = (leftIris.dx + rightIris.dx) / 2;
      final avgIrisY = (leftIris.dy + rightIris.dy) / 2;
      final pitch = landmarks.headEulerAngleX ?? 0.0;
      final yaw = landmarks.headEulerAngleY ?? 0.0;

      print('=== GAZE DEBUG ===');
      print(
          '  Left iris:  (${leftIris.dx.toStringAsFixed(3)}, ${leftIris.dy.toStringAsFixed(3)})');
      print(
          '  Right iris: (${rightIris.dx.toStringAsFixed(3)}, ${rightIris.dy.toStringAsFixed(3)})');
      print(
          '  Avg iris:   (${avgIrisX.toStringAsFixed(3)}, ${avgIrisY.toStringAsFixed(3)})');
      print(
          '  Head pose:  pitch=${pitch.toStringAsFixed(1)}, yaw=${yaw.toStringAsFixed(1)}');
      print(
          '  Prediction: (${prediction.dx.toStringAsFixed(3)}, ${prediction.dy.toStringAsFixed(3)})');
      print('  Model calibrated: ${_model.isCalibrated}');
    }

    return prediction;
  }

  /// Get raw prediction (same as predict, for compatibility)
  Future<Offset> predictRaw(EyeLandmarks landmarks) async {
    return _model.predictRaw(landmarks);
  }

  // ============= Calibration API =============

  /// Start collecting calibration data (call before calibration starts)
  void startCalibration() {
    _model.reset();
    print('GazePredictor: Calibration started, model reset');
  }

  /// Add a calibration sample
  ///
  /// Call this when the user is looking at a known target position
  void addCalibrationSample(EyeLandmarks landmarks, Offset targetPosition) {
    _model.addSample(landmarks, targetPosition);
  }

  /// Finish calibration and train the model
  ///
  /// Call this after all calibration points have been collected
  void finishCalibration() {
    if (_model.sampleCount == 0) {
      print('GazePredictor: No calibration samples to train on!');
      return;
    }

    print('GazePredictor: Training model on ${_model.sampleCount} samples...');
    _model.train();
    print('GazePredictor: Calibration complete!');
  }

  /// Dispose resources
  void dispose() {
    _isInitialized = false;
    print('GazePredictor: Disposed');
  }

  // ============= Legacy Compatibility =============

  /// Legacy calibration property (for backward compatibility)
  GazeCalibration get calibration => GazeCalibration();
  set calibration(GazeCalibration value) {
    // No longer used - model handles calibration internally
  }
}

/// Legacy calibration class (kept for backward compatibility)
class GazeCalibration {
  double scaleX = 1.0;
  double scaleY = 1.0;
  double offsetX = 0.0;
  double offsetY = 0.0;
  bool isCalibrated = false;

  GazeCalibration({
    this.scaleX = 1.0,
    this.scaleY = 1.0,
    this.offsetX = 0.0,
    this.offsetY = 0.0,
    this.isCalibrated = false,
  });

  Offset apply(Offset rawPrediction) {
    return rawPrediction;
  }

  static GazeCalibration fromPoints(
      List<Offset> predictions, List<Offset> targets) {
    return GazeCalibration(isCalibrated: true);
  }
}
