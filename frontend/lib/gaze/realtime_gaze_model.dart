/// Real-time Trainable Gaze Model
///
/// This model is trained ON-DEVICE using calibration data from the user.
/// It learns the mapping: [iris position, head pose] → [screen gaze coordinates]
///
/// Architecture:
/// - Input: 8 features (iris X/Y for both eyes, head euler angles X/Y/Z, eye openness)
/// - Hidden: Simple linear regression with learned weights
/// - Output: 2 values (screen X, screen Y in 0-1 range)
///
/// Training happens during calibration when child looks at known screen positions.

import 'dart:math';
import 'dart:ui';

/// Feature vector for gaze prediction
class GazeFeatures {
  /// Left iris position relative to eye (0-1, where 0.5 = center)
  final double leftIrisX;
  final double leftIrisY;

  /// Right iris position relative to eye (0-1, where 0.5 = center)
  final double rightIrisX;
  final double rightIrisY;

  /// Head rotation angles (normalized to -1 to 1 range)
  final double headPitch; // Up/down (X)
  final double headYaw; // Left/right (Y)
  final double headRoll; // Tilt (Z)

  /// Average eye openness (0-1)
  final double eyeOpenness;

  GazeFeatures({
    required this.leftIrisX,
    required this.leftIrisY,
    required this.rightIrisX,
    required this.rightIrisY,
    required this.headPitch,
    required this.headYaw,
    required this.headRoll,
    required this.eyeOpenness,
  });

  /// Convert to feature array for model input
  List<double> toArray() {
    return [
      leftIrisX,
      leftIrisY,
      rightIrisX,
      rightIrisY,
      headPitch,
      headYaw,
      headRoll,
      eyeOpenness,
    ];
  }

  /// Create from raw sensor data
  factory GazeFeatures.fromRaw({
    Offset? leftIris,
    Offset? rightIris,
    double? headX,
    double? headY,
    double? headZ,
    double? leftEyeOpen,
    double? rightEyeOpen,
  }) {
    // Default to center if iris not detected
    final lIris = leftIris ?? const Offset(0.5, 0.5);
    final rIris = rightIris ?? const Offset(0.5, 0.5);

    // Normalize head angles from typical range (-30 to 30) to (-1 to 1)
    final normalizeAngle =
        (double? angle) => ((angle ?? 0.0) / 30.0).clamp(-1.0, 1.0);

    // Average eye openness
    final avgOpen = ((leftEyeOpen ?? 0.8) + (rightEyeOpen ?? 0.8)) / 2.0;

    return GazeFeatures(
      leftIrisX: lIris.dx,
      leftIrisY: lIris.dy,
      rightIrisX: rIris.dx,
      rightIrisY: rIris.dy,
      headPitch: normalizeAngle(headX),
      headYaw: normalizeAngle(headY),
      headRoll: normalizeAngle(headZ),
      eyeOpenness: avgOpen,
    );
  }

  @override
  String toString() {
    return 'GazeFeatures(iris=[L:(${leftIrisX.toStringAsFixed(2)},${leftIrisY.toStringAsFixed(2)}), '
        'R:(${rightIrisX.toStringAsFixed(2)},${rightIrisY.toStringAsFixed(2)})], '
        'head=[${headPitch.toStringAsFixed(2)},${headYaw.toStringAsFixed(2)},${headRoll.toStringAsFixed(2)}], '
        'open=${eyeOpenness.toStringAsFixed(2)})';
  }
}

/// Training sample: features + target gaze position
class TrainingSample {
  final GazeFeatures features;
  final Offset target; // Where on screen the user was actually looking (0-1)

  TrainingSample({required this.features, required this.target});
}

/// Real-time trainable gaze model using simple linear regression
///
/// Model: gaze = W * features + bias
/// Where W is a 2x8 weight matrix and bias is a 2D vector
class RealtimeGazeModel {
  // Model parameters (2 outputs x 8 inputs)
  List<List<double>> _weights = [];
  List<double> _bias = [0.5, 0.5]; // Start biased toward center

  // Training state
  bool _isTrained = false;
  int _trainingEpochs = 0;
  double _lastLoss = double.infinity;

  // Training hyperparameters
  static const double _learningRate = 0.1;
  static const int _maxEpochs = 100;
  static const double _convergenceThreshold = 0.001;

  // Smoothing
  final List<Offset> _predictionHistory = [];
  static const int _smoothingWindow = 3;

  /// Whether the model has been trained
  bool get isTrained => _isTrained;

  /// Number of training epochs completed
  int get trainingEpochs => _trainingEpochs;

  /// Last training loss
  double get lastLoss => _lastLoss;

  RealtimeGazeModel() {
    _initializeWeights();
  }

  /// Initialize weights with sensible defaults
  void _initializeWeights() {
    // Weight matrix: 2 outputs (gazeX, gazeY) x 8 inputs
    // Initialize with small random values + reasonable defaults
    final random = Random(42);

    _weights = [
      // Weights for gazeX output
      [
        -0.5, // leftIrisX: iris right -> look left (inverted for front camera)
        0.0, // leftIrisY: minimal vertical effect on horizontal
        -0.5, // rightIrisX: same as left
        0.0, // rightIrisY: minimal
        0.0, // headPitch: minimal horizontal effect
        0.3, // headYaw: turn right -> look right
        0.0, // headRoll: minimal
        0.0, // eyeOpenness: minimal
      ],
      // Weights for gazeY output
      [
        0.0, // leftIrisX: minimal horizontal effect on vertical
        0.5, // leftIrisY: iris down -> look down
        0.0, // rightIrisX: minimal
        0.5, // rightIrisY: same as left
        -0.3, // headPitch: tilt up -> look up
        0.0, // headYaw: minimal vertical effect
        0.0, // headRoll: minimal
        0.0, // eyeOpenness: minimal
      ],
    ];

    // Add small random noise to break symmetry
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 8; j++) {
        _weights[i][j] += (random.nextDouble() - 0.5) * 0.1;
      }
    }
  }

  /// Train the model on calibration data
  ///
  /// This uses gradient descent to learn the mapping from features to gaze
  void train(List<TrainingSample> samples) {
    if (samples.isEmpty) {
      print('RealtimeGazeModel: No training samples provided');
      return;
    }

    print('RealtimeGazeModel: Training on ${samples.length} samples...');

    // Print sample data for debugging
    for (int i = 0; i < samples.length && i < 5; i++) {
      final s = samples[i];
      print(
          '  Sample $i: ${s.features} -> target(${s.target.dx.toStringAsFixed(2)}, ${s.target.dy.toStringAsFixed(2)})');
    }

    // Gradient descent training
    _trainingEpochs = 0;
    double prevLoss = double.infinity;

    for (int epoch = 0; epoch < _maxEpochs; epoch++) {
      double totalLoss = 0.0;

      // Accumulate gradients
      List<List<double>> gradW = List.generate(2, (_) => List.filled(8, 0.0));
      List<double> gradB = [0.0, 0.0];

      for (final sample in samples) {
        final features = sample.features.toArray();
        final target = [sample.target.dx, sample.target.dy];

        // Forward pass
        final prediction = _forward(features);

        // Compute error
        final errorX = prediction[0] - target[0];
        final errorY = prediction[1] - target[1];

        totalLoss += errorX * errorX + errorY * errorY;

        // Accumulate gradients (gradient of MSE loss)
        for (int j = 0; j < 8; j++) {
          gradW[0][j] += 2 * errorX * features[j];
          gradW[1][j] += 2 * errorY * features[j];
        }
        gradB[0] += 2 * errorX;
        gradB[1] += 2 * errorY;
      }

      // Average gradients
      final n = samples.length.toDouble();
      for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 8; j++) {
          gradW[i][j] /= n;
        }
        gradB[i] /= n;
      }

      // Update weights
      for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 8; j++) {
          _weights[i][j] -= _learningRate * gradW[i][j];
        }
        _bias[i] -= _learningRate * gradB[i];
      }

      // Average loss
      totalLoss /= n;
      _lastLoss = totalLoss;
      _trainingEpochs = epoch + 1;

      // Check convergence
      if ((prevLoss - totalLoss).abs() < _convergenceThreshold) {
        print(
            'RealtimeGazeModel: Converged at epoch $epoch with loss ${totalLoss.toStringAsFixed(6)}');
        break;
      }
      prevLoss = totalLoss;

      if (epoch % 20 == 0) {
        print(
            'RealtimeGazeModel: Epoch $epoch, loss=${totalLoss.toStringAsFixed(6)}');
      }
    }

    _isTrained = true;
    print(
        'RealtimeGazeModel: Training complete! Final loss: ${_lastLoss.toStringAsFixed(6)}');
    print('RealtimeGazeModel: Learned weights:');
    print(
        '  GazeX weights: ${_weights[0].map((w) => w.toStringAsFixed(3)).join(", ")}');
    print(
        '  GazeY weights: ${_weights[1].map((w) => w.toStringAsFixed(3)).join(", ")}');
    print('  Bias: ${_bias.map((b) => b.toStringAsFixed(3)).join(", ")}');
  }

  /// Forward pass: compute prediction from features
  List<double> _forward(List<double> features) {
    double gazeX = _bias[0];
    double gazeY = _bias[1];

    for (int j = 0; j < 8; j++) {
      gazeX += _weights[0][j] * features[j];
      gazeY += _weights[1][j] * features[j];
    }

    // Clamp to valid range
    return [gazeX.clamp(0.0, 1.0), gazeY.clamp(0.0, 1.0)];
  }

  /// Predict gaze position from features
  Offset predict(GazeFeatures features) {
    final featureArray = features.toArray();
    final prediction = _forward(featureArray);
    final raw = Offset(prediction[0], prediction[1]);

    // Apply smoothing
    return _smooth(raw);
  }

  /// Smooth predictions to reduce jitter
  Offset _smooth(Offset raw) {
    _predictionHistory.add(raw);

    while (_predictionHistory.length > _smoothingWindow) {
      _predictionHistory.removeAt(0);
    }

    // Weighted average (more recent = more weight)
    double sumX = 0, sumY = 0, sumWeight = 0;
    for (int i = 0; i < _predictionHistory.length; i++) {
      final weight = (i + 1).toDouble();
      sumX += _predictionHistory[i].dx * weight;
      sumY += _predictionHistory[i].dy * weight;
      sumWeight += weight;
    }

    return Offset(sumX / sumWeight, sumY / sumWeight);
  }

  /// Reset model to untrained state
  void reset() {
    _initializeWeights();
    _isTrained = false;
    _trainingEpochs = 0;
    _lastLoss = double.infinity;
    _predictionHistory.clear();
    print('RealtimeGazeModel: Reset to untrained state');
  }

  /// Export model weights for debugging/saving
  Map<String, dynamic> exportWeights() {
    return {
      'weights': _weights,
      'bias': _bias,
      'isTrained': _isTrained,
      'epochs': _trainingEpochs,
      'loss': _lastLoss,
    };
  }

  /// Import model weights
  void importWeights(Map<String, dynamic> data) {
    _weights = List<List<double>>.from(
      (data['weights'] as List).map((row) => List<double>.from(row)),
    );
    _bias = List<double>.from(data['bias']);
    _isTrained = data['isTrained'] ?? false;
    _trainingEpochs = data['epochs'] ?? 0;
    _lastLoss = data['loss'] ?? double.infinity;
  }
}
