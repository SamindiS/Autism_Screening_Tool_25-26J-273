/// =============================================================================
/// Gaze Service - Eye Tracking System
/// =============================================================================
///
/// High-level service that combines:
/// - Camera capture (front camera)
/// - Face detection (ML Kit) with pixel-based iris detection
/// - Real-time trainable gaze model
///
/// The model is trained during calibration using actual user data to provide
/// personalized gaze tracking for each child.
///
/// Usage:
/// 1. Initialize: await gazeService.initialize();
/// 2. Start tracking: await gazeService.startTracking();
/// 3. Listen to gaze: gazeService.gazeStream.listen((data) => ...);
/// 4. Stop tracking: await gazeService.stopTracking();
///
/// Calibration:
/// - Use addCalibrationPoint() during 9-point calibration
/// - Call finishCalibration() to train the model
/// - Model adapts to each child's eye geometry
/// =============================================================================

import 'dart:async';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'gaze_tracker.dart';
import 'gaze_predictor.dart';

/// Gaze data with confidence
class GazeData {
  /// Predicted gaze position (normalized 0-1)
  final Offset position;

  /// Raw eye landmarks
  final EyeLandmarks? landmarks;

  /// Timestamp
  final DateTime timestamp;

  /// Whether face was detected
  final bool faceDetected;

  GazeData({
    required this.position,
    this.landmarks,
    required this.timestamp,
    this.faceDetected = true,
  });

  /// Convert to screen coordinates
  Offset toScreenPosition(Size screenSize) {
    return Offset(
      position.dx * screenSize.width,
      position.dy * screenSize.height,
    );
  }
}

/// Main gaze tracking service
class GazeService {
  GazeTracker? _tracker;
  GazePredictor? _predictor;

  bool _isInitialized = false;
  bool _isTracking = false;
  bool _faceDetected = false;
  DateTime? _lastFaceTime;

  StreamSubscription? _trackingSubscription;
  final _gazeController = StreamController<GazeData>.broadcast();

  Timer? _faceTimeoutTimer;
  static const _faceTimeoutDuration = Duration(milliseconds: 500);

  // ============= Public Getters =============

  /// Stream of gaze data
  Stream<GazeData> get gazeStream => _gazeController.stream;

  /// Whether the service is ready
  bool get isInitialized => _isInitialized;

  /// Whether currently tracking
  bool get isTracking => _isTracking;

  /// Whether face is currently detected
  bool get faceDetected => _faceDetected;

  /// Camera controller for preview
  CameraController? get cameraController => _tracker?.cameraController;

  /// Whether model has been calibrated/trained
  bool get isCalibrated => _predictor?.isCalibrated ?? false;

  /// Training loss (lower = better)
  double get trainingLoss => _predictor?.trainingLoss ?? double.infinity;

  /// Number of training samples collected
  int get trainingSampleCount => _predictor?.trainingSampleCount ?? 0;

  /// Legacy calibration property
  GazeCalibration get calibration =>
      _predictor?.calibration ?? GazeCalibration();
  set calibration(GazeCalibration value) {
    // No longer used
  }

  // ============= Initialization =============

  /// Initialize the gaze service
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('GazeService: Initializing...');

    _tracker = GazeTracker();
    _predictor = GazePredictor();

    await _tracker!.initialize();
    await _predictor!.initialize();

    _faceTimeoutTimer = Timer.periodic(_faceTimeoutDuration, (_) {
      if (_lastFaceTime != null) {
        final elapsed = DateTime.now().difference(_lastFaceTime!);
        if (elapsed > _faceTimeoutDuration && _faceDetected) {
          _onFaceLost();
        }
      }
    });

    _isInitialized = true;
    debugPrint('GazeService: Initialized with real-time trainable model');
  }

  // ============= Tracking Control =============

  /// Start tracking gaze
  Future<void> startTracking() async {
    if (!_isInitialized) {
      throw Exception('GazeService not initialized');
    }
    if (_isTracking) return;

    await _tracker!.startTracking();
    _trackingSubscription = _tracker!.landmarksStream.listen(
      _onLandmarksDetected,
      onError: (error) {
        if (error == 'no_face') _onFaceLost();
      },
    );

    _isTracking = true;
    debugPrint('GazeService: Started tracking');
  }

  /// Stop tracking gaze
  Future<void> stopTracking() async {
    if (!_isTracking) return;

    await _trackingSubscription?.cancel();
    _trackingSubscription = null;
    await _tracker?.stopTracking();

    _isTracking = false;
    debugPrint('GazeService: Stopped tracking');
  }

  // ============= Calibration API =============

  /// Start calibration (clears previous data)
  void startCalibration() {
    _predictor?.startCalibration();
    debugPrint('GazeService: Calibration started');
  }

  /// Add a calibration sample
  void addCalibrationSample(EyeLandmarks landmarks, Offset targetPosition) {
    _predictor?.addCalibrationSample(landmarks, targetPosition);
  }

  /// Finish calibration and train the model
  void finishCalibration() {
    _predictor?.finishCalibration();
    debugPrint('GazeService: Calibration finished, model trained');
    debugPrint(
        'GazeService: Training loss = ${trainingLoss.toStringAsFixed(6)}');
  }

  /// Get raw prediction for current landmarks
  Future<Offset> getRawPrediction(EyeLandmarks landmarks) async {
    if (_predictor != null) {
      return _predictor!.predictRaw(landmarks);
    }
    return const Offset(0.5, 0.5);
  }

  /// Legacy calibrate method
  void calibrate(List<Offset> predictions, List<Offset> targets) {
    debugPrint(
        'GazeService: Legacy calibrate() called - use new calibration API');
  }

  // ============= Private Methods =============

  void _onLandmarksDetected(EyeLandmarks landmarks) async {
    _faceDetected = true;
    _lastFaceTime = DateTime.now();

    try {
      final gazePosition = await _predictor!.predict(landmarks);

      _gazeController.add(GazeData(
        position: gazePosition,
        landmarks: landmarks,
        timestamp: DateTime.now(),
        faceDetected: true,
      ));
    } catch (e) {
      debugPrint('GazeService: Prediction error: $e');
    }
  }

  void _onFaceLost() {
    if (_faceDetected) {
      _faceDetected = false;
      debugPrint('GazeService: Face lost');

      _gazeController.add(GazeData(
        position: const Offset(0.5, 0.5),
        timestamp: DateTime.now(),
        faceDetected: false,
      ));
    }
  }

  // ============= Reset for New Test =============

  /// Reset calibration for a new test session
  /// This clears all trained model data so the next test starts fresh
  void resetForNewTest() {
    debugPrint('GazeService: Resetting for new test...');
    _predictor?.startCalibration(); // This resets the model
    _faceDetected = false;
    _lastFaceTime = null;
    debugPrint('GazeService: Reset complete - ready for new calibration');
  }

  // ============= Cleanup =============

  Future<void> dispose() async {
    _faceTimeoutTimer?.cancel();
    await _trackingSubscription?.cancel();
    await _gazeController.close();
    await _tracker?.dispose();
    _predictor?.dispose();
    _isInitialized = false;
    _isTracking = false;
    _faceDetected = false;
    debugPrint('GazeService: Disposed');
  }
}

/// Global singleton
GazeService? _globalGazeService;

GazeService get gazeService {
  _globalGazeService ??= GazeService();
  return _globalGazeService!;
}

Future<void> disposeGlobalGazeService() async {
  await _globalGazeService?.dispose();
  _globalGazeService = null;
}
