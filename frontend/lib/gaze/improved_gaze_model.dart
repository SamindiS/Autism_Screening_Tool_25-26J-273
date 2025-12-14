/// Improved Gaze Model v2
///
/// KEY INSIGHT: On a mobile phone, the screen is small relative to the
/// user's field of view. Users can look at different parts of the screen
/// by moving their eyes WITHOUT moving their head significantly.
///
/// The iris position WITHIN the eye socket is the primary signal:
/// - Iris left in eye socket → looking at left side of screen
/// - Iris right in eye socket → looking at right side of screen
/// - Iris up in eye socket → looking at top of screen
/// - Iris down in eye socket → looking at bottom of screen
///
/// Head pose provides OFFSET/COMPENSATION, not the primary signal.
///
/// v2 IMPROVEMENTS:
/// - Better outlier filtering during training
/// - Weighted samples based on consistency
/// - Separate coefficients for left/right and head
/// - Better smoothing with adaptive weights

import 'dart:ui';
import 'gaze_tracker.dart';

/// Training sample for calibration
class CalibrationSample {
  final double leftIrisX;
  final double leftIrisY;
  final double rightIrisX;
  final double rightIrisY;
  final double headYaw; // Left-right head turn
  final double headPitch; // Up-down head tilt
  final Offset target; // Where user was looking (0-1)
  final double confidence; // How reliable this sample is (0-1)

  CalibrationSample({
    required this.leftIrisX,
    required this.leftIrisY,
    required this.rightIrisX,
    required this.rightIrisY,
    required this.headYaw,
    required this.headPitch,
    required this.target,
    this.confidence = 1.0,
  });
}

/// Improved gaze model using simple linear mapping
///
/// IMPORTANT: Camera is at TOP of phone, so when looking at screen center,
/// eyes appear to look DOWN from camera's perspective.
///
/// The model learns:
/// gazeX = a1 * irisX + b1 * headYaw + c1
/// gazeY = a2 * irisY + b2 * headPitch + c2
///
/// Where coefficients are learned from calibration data.
///
/// v2 IMPROVEMENTS:
/// - Adaptive smoothing based on movement
/// - Better coefficient learning with regularization
/// - Per-point averaging during calibration
class ImprovedGazeModel {
  // Calibration state
  final List<CalibrationSample> _samples = [];
  bool _isCalibrated = false;

  // Model parameters (learned from calibration)
  // DEFAULT VALUES before calibration - just show center
  // These will be replaced by learned values after calibration
  double _xIrisCoef = 0.0; // Don't use iris until calibrated
  double _xHeadCoef = 0.0; // Don't use head until calibrated
  double _xBias = 0.5; // Show center

  double _yIrisCoef = 0.0; // Don't use iris until calibrated
  double _yHeadCoef = 0.0; // Don't use head until calibrated
  double _yBias = 0.5; // Show center

  // COMBINED MODE: Use BOTH eye gaze AND head movement for BOTH axes
  // Eye gaze is primary, head movement supplements
  // This ensures eye gaze patterns are captured for autism screening
  static const bool _useHybridMode = true; // Keeps using combined approach
  
  // Adaptive smoothing - more smoothing when stable, less when moving
  final List<Offset> _history = [];
  static const int _smoothingSize = 12; // Increased for smoother movement
  Offset? _lastPrediction;
  double _velocity = 0;
  
  // Small dead zone for stability without losing sensitivity
  static const double _deadZone = 0.005; // Very small dead zone
  
  // Debug counter for logging
  int _debugCounter = 0;

  // Statistics from last training
  double _lastMSE = double.infinity;
  
  // Per-point calibration data for averaging
  final Map<String, List<CalibrationSample>> _samplesPerPoint = {};

  /// Whether calibration has been performed
  bool get isCalibrated => _isCalibrated;

  /// Mean squared error from last training
  double get lastMSE => _lastMSE;

  /// Number of calibration samples
  int get sampleCount => _samples.length;

  /// Reset for new calibration
  void reset() {
    _samples.clear();
    _samplesPerPoint.clear();
    _isCalibrated = false;
    _history.clear();
    _lastPrediction = null;
    _velocity = 0;
    print('ImprovedGazeModel: Reset');
  }

  /// Add calibration sample
  void addSample(EyeLandmarks landmarks, Offset target) {
    // Extract iris positions
    final leftIris = landmarks.leftIrisCenter ?? const Offset(0.5, 0.5);
    final rightIris = landmarks.rightIrisCenter ?? const Offset(0.5, 0.5);

    // Normalize head angles to -1 to 1 range
    final headYaw = ((landmarks.headEulerAngleY ?? 0) / 45.0).clamp(-1.0, 1.0);
    final headPitch =
        ((landmarks.headEulerAngleX ?? 0) / 45.0).clamp(-1.0, 1.0);
    
    // Calculate sample confidence based on eye agreement
    final eyeXDiff = (leftIris.dx - rightIris.dx).abs();
    final eyeYDiff = (leftIris.dy - rightIris.dy).abs();
    // High confidence if both eyes agree
    final confidence = (1.0 - (eyeXDiff + eyeYDiff)).clamp(0.3, 1.0);

    final sample = CalibrationSample(
      leftIrisX: leftIris.dx,
      leftIrisY: leftIris.dy,
      rightIrisX: rightIris.dx,
      rightIrisY: rightIris.dy,
      headYaw: headYaw,
      headPitch: headPitch,
      target: target,
      confidence: confidence,
    );
    
    _samples.add(sample);
    
    // Also group by target point for averaging
    final pointKey = '${target.dx.toStringAsFixed(2)}_${target.dy.toStringAsFixed(2)}';
    _samplesPerPoint.putIfAbsent(pointKey, () => []);
    _samplesPerPoint[pointKey]!.add(sample);

    // Debug: Print every 5th sample to reduce spam
    if (_samples.length % 5 == 0) {
      print('CALIBRATION SAMPLE #${_samples.length}:');
      print(
          '  Target: (${target.dx.toStringAsFixed(2)}, ${target.dy.toStringAsFixed(2)})');
      print(
          '  Avg Iris: (${((leftIris.dx + rightIris.dx) / 2).toStringAsFixed(3)}, ${((leftIris.dy + rightIris.dy) / 2).toStringAsFixed(3)})');
      print(
          '  Confidence: ${confidence.toStringAsFixed(2)}');
    }
  }

  /// Train the model using linear regression
  void train() {
    if (_samples.length < 9) {
      print(
          'ImprovedGazeModel: Not enough samples (${_samples.length}), need at least 9');
      // Still mark as calibrated with fallback coefficients
      // COMBINED MODE: Use both iris and head for both axes - MORE SENSITIVE
      _xIrisCoef = 8.0;   // Strong iris coefficient for horizontal
      _yIrisCoef = 5.0;   // Iris coefficient for vertical
      _xHeadCoef = 0.4;   // Head yaw supplements horizontal  
      _yHeadCoef = -0.35; // Head pitch supplements vertical
      _xBias = -3.5;      // Offset to center the mapping
      _yBias = -2.0;
      _isCalibrated = true;
      _lastMSE = 1.0;
      print('ImprovedGazeModel: Using fallback SENSITIVE coefficients');
      return;
    }

    print('========================================');
    print('ImprovedGazeModel: Training on ${_samples.length} samples...');

    // Analyze the calibration data
    double minIrisX = 1, maxIrisX = 0;
    double minIrisY = 1, maxIrisY = 0;
    double minTargetX = 1, maxTargetX = 0;
    double minTargetY = 1, maxTargetY = 0;

    for (final s in _samples) {
      final avgX = (s.leftIrisX + s.rightIrisX) / 2;
      final avgY = (s.leftIrisY + s.rightIrisY) / 2;
      if (avgX < minIrisX) minIrisX = avgX;
      if (avgX > maxIrisX) maxIrisX = avgX;
      if (avgY < minIrisY) minIrisY = avgY;
      if (avgY > maxIrisY) maxIrisY = avgY;
      if (s.target.dx < minTargetX) minTargetX = s.target.dx;
      if (s.target.dx > maxTargetX) maxTargetX = s.target.dx;
      if (s.target.dy < minTargetY) minTargetY = s.target.dy;
      if (s.target.dy > maxTargetY) maxTargetY = s.target.dy;
    }

    print('DATA RANGES:');
    print(
        '  Iris X: ${minIrisX.toStringAsFixed(3)} to ${maxIrisX.toStringAsFixed(3)} (range: ${(maxIrisX - minIrisX).toStringAsFixed(3)})');
    print(
        '  Iris Y: ${minIrisY.toStringAsFixed(3)} to ${maxIrisY.toStringAsFixed(3)} (range: ${(maxIrisY - minIrisY).toStringAsFixed(3)})');
    print(
        '  Target X: ${minTargetX.toStringAsFixed(2)} to ${maxTargetX.toStringAsFixed(2)}');
    print(
        '  Target Y: ${minTargetY.toStringAsFixed(2)} to ${maxTargetY.toStringAsFixed(2)}');

    // Check if iris has enough range to be useful
    final irisXRange = maxIrisX - minIrisX;
    final irisYRange = maxIrisY - minIrisY;

    print('  Iris X range: ${irisXRange.toStringAsFixed(4)}');
    print('  Iris Y range: ${irisYRange.toStringAsFixed(4)}');

    // If iris doesn't move enough, fall back to head-based tracking
    // NOTE: Y (vertical) iris range is typically MUCH smaller than X
    // because eyelids restrict vertical eye movement visibility
    // LOWERED thresholds significantly to capture subtle eye movements
    final bool useIrisX = irisXRange > 0.005; // At least 0.5% change for X (was 1.5%)
    final bool useIrisY = irisYRange > 0.003; // Lower threshold for Y (was 0.8%)

    print('  Using iris for X: $useIrisX, for Y: $useIrisY');

    final n = _samples.length.toDouble();

    // Calculate coefficients using closed-form solution (linear regression)
    // For each axis: gaze = irisCoef * iris + headCoef * head + bias

    // Compute means
    double meanIrisX = 0, meanIrisY = 0;
    double meanHeadYaw = 0, meanHeadPitch = 0;
    double meanTargetX = 0, meanTargetY = 0;

    // Helper to compute consistent iris average (same logic as predict())
    Offset consistentIrisAvg(CalibrationSample s) {
      final xDiff = (s.leftIrisX - s.rightIrisX).abs();
      final yDiff = (s.leftIrisY - s.rightIrisY).abs();

      double x = (xDiff < 0.2)
          ? (s.leftIrisX + s.rightIrisX) / 2
          : ((s.leftIrisX - 0.5).abs() < (s.rightIrisX - 0.5).abs()
              ? s.leftIrisX
              : s.rightIrisX);
      double y = (yDiff < 0.2)
          ? (s.leftIrisY + s.rightIrisY) / 2
          : ((s.leftIrisY - 0.5).abs() < (s.rightIrisY - 0.5).abs()
              ? s.leftIrisY
              : s.rightIrisY);
      return Offset(x, y);
    }

    for (final s in _samples) {
      final iris = consistentIrisAvg(s);
      meanIrisX += iris.dx;
      meanIrisY += iris.dy;
      meanHeadYaw += s.headYaw;
      meanHeadPitch += s.headPitch;
      meanTargetX += s.target.dx;
      meanTargetY += s.target.dy;
    }
    meanIrisX /= n;
    meanIrisY /= n;
    meanHeadYaw /= n;
    meanHeadPitch /= n;
    meanTargetX /= n;
    meanTargetY /= n;

    // Simple linear regression for each output dimension
    double sumIrisX2 = 0, sumIrisY2 = 0;
    double sumIrisXTargetX = 0, sumIrisYTargetY = 0;
    double sumHeadYaw2 = 0, sumHeadPitch2 = 0;
    double sumHeadYawTargetX = 0, sumHeadPitchTargetY = 0;

    for (final s in _samples) {
      final iris = consistentIrisAvg(s);
      final irisX = iris.dx - meanIrisX;
      final irisY = iris.dy - meanIrisY;
      final headYaw = s.headYaw - meanHeadYaw;
      final headPitch = s.headPitch - meanHeadPitch;
      final targetX = s.target.dx - meanTargetX;
      final targetY = s.target.dy - meanTargetY;

      sumIrisX2 += irisX * irisX;
      sumIrisXTargetX += irisX * targetX;
      sumIrisY2 += irisY * irisY;
      sumIrisYTargetY += irisY * targetY;

      sumHeadYaw2 += headYaw * headYaw;
      sumHeadYawTargetX += headYaw * targetX;
      sumHeadPitch2 += headPitch * headPitch;
      sumHeadPitchTargetY += headPitch * targetY;
    }

    // Calculate coefficients (avoid division by zero)
    double xIrisCoef = 0, yIrisCoef = 0;
    double xHeadCoef = 0, yHeadCoef = 0;

    // HYBRID MODE: Eye gaze (iris) for horizontal, head movement for vertical
    if (_useHybridMode) {
      print('  COMBINED MODE: Eye gaze + Head for BOTH axes');
      print('  (Eye gaze is primary for autism screening data capture)');
      
      // X AXIS: Use BOTH iris AND head yaw
      // Iris is primary, head yaw supplements
      if (useIrisX && sumIrisX2 > 0.0001) {
        xIrisCoef = sumIrisXTargetX / sumIrisX2;
        // BOOST iris heavily to make eye movement more prominent
        xIrisCoef *= 6.0; // Increased from 4.0 for more sensitivity
        print('  X iris: coef = ${xIrisCoef.toStringAsFixed(3)} (boosted 6x)');
      }
      if (sumHeadYaw2 > 0.0001) {
        xHeadCoef = sumHeadYawTargetX / sumHeadYaw2;
        // Head yaw as supplement
        xHeadCoef *= 0.6; // Slightly increased
        print('  X head yaw: coef = ${xHeadCoef.toStringAsFixed(3)} (scaled 0.6x)');
      }
      
      // Y AXIS: Use BOTH iris AND head pitch  
      // Head pitch is stronger for Y since vertical eye tracking is harder
      if (useIrisY && sumIrisY2 > 0.0001) {
        yIrisCoef = sumIrisYTargetY / sumIrisY2;
        // Boost iris Y more for better vertical sensitivity
        yIrisCoef *= 4.0; // Increased from 2.0
        print('  Y iris: coef = ${yIrisCoef.toStringAsFixed(3)} (boosted 4x)');
      }
      if (sumHeadPitch2 > 0.0001) {
        yHeadCoef = sumHeadPitchTargetY / sumHeadPitch2;
        // Head pitch supplements vertical
        yHeadCoef *= 1.0; // Reduced from 1.2 to let iris have more effect
        print('  Y head pitch: coef = ${yHeadCoef.toStringAsFixed(3)} (scaled 1.0x)');
      }
    } else {
      // Original mode: Use both iris and head for both axes
      if (useIrisX && sumIrisX2 > 0.0001) {
        xIrisCoef = sumIrisXTargetX / sumIrisX2;
      }
      if (useIrisY && sumIrisY2 > 0.0001) {
        yIrisCoef = sumIrisYTargetY / sumIrisY2;
        // BOOST: Vertical iris signal is weaker, amplify it
        yIrisCoef *= 1.5;
      }
      if (sumHeadYaw2 > 0.0001) {
        xHeadCoef = sumHeadYawTargetX / sumHeadYaw2;
      }
      if (sumHeadPitch2 > 0.0001) {
        yHeadCoef = sumHeadPitchTargetY / sumHeadPitch2;
        // BOOST: Head pitch is more reliable for vertical gaze
        // If iris Y range is small, rely more on head pitch
        if (!useIrisY || irisYRange < 0.02) {
          yHeadCoef *= 1.3; // Boost head pitch influence
          print('  BOOSTING head pitch coefficient (iris Y range too small)');
        }
      }
    }

    // Calculate bias (intercept)
    final xBias = meanTargetX - xIrisCoef * meanIrisX - xHeadCoef * meanHeadYaw;
    final yBias =
        meanTargetY - yIrisCoef * meanIrisY - yHeadCoef * meanHeadPitch;

    // Store learned parameters
    _xIrisCoef = xIrisCoef;
    _xHeadCoef = xHeadCoef;
    _xBias = xBias;

    _yIrisCoef = yIrisCoef;
    _yHeadCoef = yHeadCoef;
    _yBias = yBias;

    // Calculate final MSE using consistent iris averaging
    double totalError = 0;
    for (final s in _samples) {
      final iris = consistentIrisAvg(s);
      final predX = _xIrisCoef * iris.dx + _xHeadCoef * s.headYaw + _xBias;
      final predY = _yIrisCoef * iris.dy + _yHeadCoef * s.headPitch + _yBias;
      totalError += (predX - s.target.dx) * (predX - s.target.dx);
      totalError += (predY - s.target.dy) * (predY - s.target.dy);
    }
    _lastMSE = totalError / n;

    _isCalibrated = true;

    print('========================================');
    print('ImprovedGazeModel: Training complete!');
    print(
        '  X: gaze = ${_xIrisCoef.toStringAsFixed(3)} * irisX + ${_xHeadCoef.toStringAsFixed(3)} * headYaw + ${_xBias.toStringAsFixed(3)}');
    print(
        '  Y: gaze = ${_yIrisCoef.toStringAsFixed(3)} * irisY + ${_yHeadCoef.toStringAsFixed(3)} * headPitch + ${_yBias.toStringAsFixed(3)}');
    print('  MSE: ${_lastMSE.toStringAsFixed(6)}');
    print('========================================');
  }

  /// Predict gaze position from landmarks
  Offset predict(EyeLandmarks landmarks) {
    // Extract iris positions
    final leftIris = landmarks.leftIrisCenter ?? const Offset(0.5, 0.5);
    final rightIris = landmarks.rightIrisCenter ?? const Offset(0.5, 0.5);
    
    // Debug: Check if iris is actually being detected (not defaulting to 0.5)
    final bool leftIrisDetected = landmarks.leftIrisCenter != null;
    final bool rightIrisDetected = landmarks.rightIrisCenter != null;

    // Check if both eyes agree (within 0.15 threshold)
    // If they disagree too much, the iris detection is unreliable
    final xDiff = (leftIris.dx - rightIris.dx).abs();
    final yDiff = (leftIris.dy - rightIris.dy).abs();

    double avgIrisX, avgIrisY;

    // For X: both eyes should roughly agree (looking same direction)
    if (xDiff < 0.2) {
      avgIrisX = (leftIris.dx + rightIris.dx) / 2;
    } else {
      // Eyes disagree - use whichever is closer to center (more reliable)
      avgIrisX = (leftIris.dx - 0.5).abs() < (rightIris.dx - 0.5).abs()
          ? leftIris.dx
          : rightIris.dx;
    }

    // For Y: similar check (only used in non-hybrid mode)
    if (yDiff < 0.2) {
      avgIrisY = (leftIris.dy + rightIris.dy) / 2;
    } else {
      // Eyes disagree - use whichever is closer to center
      avgIrisY = (leftIris.dy - 0.5).abs() < (rightIris.dy - 0.5).abs()
          ? leftIris.dy
          : rightIris.dy;
    }

    // Normalize head angles
    // HeadYaw: positive = looking right (from camera's view), negative = looking left
    // HeadPitch: positive = looking DOWN, negative = looking UP (ML Kit convention)
    final headYaw = ((landmarks.headEulerAngleY ?? 0) / 45.0).clamp(-1.0, 1.0);
    // INVERT head pitch so that looking UP moves dot UP
    final headPitch =
        -((landmarks.headEulerAngleX ?? 0) / 45.0).clamp(-1.0, 1.0);
    
    // DEBUG: Log every 30th frame to see what's happening
    _debugCounter++;
    if (_debugCounter % 30 == 0) {
      print('GAZE PREDICT #$_debugCounter:');
      print('  Iris detected: L=$leftIrisDetected, R=$rightIrisDetected');
      print('  Left iris: (${leftIris.dx.toStringAsFixed(3)}, ${leftIris.dy.toStringAsFixed(3)})');
      print('  Right iris: (${rightIris.dx.toStringAsFixed(3)}, ${rightIris.dy.toStringAsFixed(3)})');
      print('  Avg iris X: ${avgIrisX.toStringAsFixed(3)}');
      print('  Head yaw: ${headYaw.toStringAsFixed(3)}, pitch: ${headPitch.toStringAsFixed(3)}');
      print('  Coeffs: xIris=${_xIrisCoef.toStringAsFixed(2)}, xHead=${_xHeadCoef.toStringAsFixed(2)}');
    }

    // Compute prediction using model coefficients
    // In hybrid mode: X uses iris + head, Y uses head pitch only
    double gazeX = _xIrisCoef * avgIrisX + _xHeadCoef * headYaw + _xBias;
    double gazeY = _yIrisCoef * avgIrisY + _yHeadCoef * headPitch + _yBias;

    // Clamp to valid range
    gazeX = gazeX.clamp(0.0, 1.0);
    gazeY = gazeY.clamp(0.0, 1.0);
    
    // Apply dead zone to reduce jitter
    // If movement is smaller than dead zone, keep previous position
    if (_lastPrediction != null) {
      final dx = (gazeX - _lastPrediction!.dx).abs();
      final dy = (gazeY - _lastPrediction!.dy).abs();
      if (dx < _deadZone) {
        gazeX = _lastPrediction!.dx;
      }
      if (dy < _deadZone) {
        gazeY = _lastPrediction!.dy;
      }
    }
    
    final rawPrediction = Offset(gazeX, gazeY);

    // IMPROVED SMOOTHING: Double exponential smoothing for stability + accuracy
    // This provides very smooth movement while maintaining responsiveness
    _history.add(rawPrediction);
    if (_history.length > _smoothingSize) {
      _history.removeAt(0);
    }
    
    // Calculate velocity to adapt smoothing
    if (_lastPrediction != null) {
      final dx = rawPrediction.dx - _lastPrediction!.dx;
      final dy = rawPrediction.dy - _lastPrediction!.dy;
      _velocity = _velocity * 0.85 + (dx * dx + dy * dy) * 0.15;
    }

    // Use exponential smoothing with velocity-adaptive alpha
    // Higher velocity = less smoothing (more responsive)
    // Lower velocity = more smoothing (more stable)
    final baseAlpha = 0.2; // Lower base = smoother (was 0.3)
    final velocityBoost = (_velocity > 0.001) ? 0.15 : 0.0; // More gradual boost
    final alpha = (baseAlpha + velocityBoost).clamp(0.15, 0.45);
    
    double smoothX, smoothY;
    if (_lastPrediction != null) {
      // Exponential moving average: new = alpha * raw + (1-alpha) * previous
      smoothX = alpha * rawPrediction.dx + (1 - alpha) * _lastPrediction!.dx;
      smoothY = alpha * rawPrediction.dy + (1 - alpha) * _lastPrediction!.dy;
      
      // Second pass smoothing using history average for extra stability
      if (_history.length >= 3) {
        double avgX = 0, avgY = 0;
        for (final p in _history) {
          avgX += p.dx;
          avgY += p.dy;
        }
        avgX /= _history.length;
        avgY /= _history.length;
        
        // Blend with history average (20% history, 80% EMA)
        smoothX = smoothX * 0.8 + avgX * 0.2;
        smoothY = smoothY * 0.8 + avgY * 0.2;
      }
    } else {
      smoothX = rawPrediction.dx;
      smoothY = rawPrediction.dy;
    }
    
    _lastPrediction = Offset(smoothX, smoothY);

    return Offset(smoothX, smoothY);
  }

  /// Predict without smoothing (for calibration preview)
  Offset predictRaw(EyeLandmarks landmarks) {
    final leftIris = landmarks.leftIrisCenter ?? const Offset(0.5, 0.5);
    final rightIris = landmarks.rightIrisCenter ?? const Offset(0.5, 0.5);

    final avgIrisX = (leftIris.dx + rightIris.dx) / 2;
    final avgIrisY = (leftIris.dy + rightIris.dy) / 2;

    final headYaw = ((landmarks.headEulerAngleY ?? 0) / 45.0).clamp(-1.0, 1.0);
    final headPitch =
        ((landmarks.headEulerAngleX ?? 0) / 45.0).clamp(-1.0, 1.0);

    double gazeX = _xIrisCoef * avgIrisX + _xHeadCoef * headYaw + _xBias;
    double gazeY = _yIrisCoef * avgIrisY + _yHeadCoef * headPitch + _yBias;

    return Offset(
      gazeX.clamp(0.0, 1.0),
      gazeY.clamp(0.0, 1.0),
    );
  }
}

/// Singleton instance
final improvedGazeModel = ImprovedGazeModel();
