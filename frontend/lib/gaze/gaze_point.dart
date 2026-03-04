/// =============================================================================
/// Gaze Point Model - Normalized Gaze Coordinates
/// =============================================================================
///
/// Represents a single gaze sample with normalized coordinates (0-1),
/// timestamp, and confidence level.
///
/// Used for real-time gaze tracking in games and interactive applications.
/// =============================================================================

import 'package:flutter/material.dart';
import 'gaze_service.dart';

/// Normalized gaze point with confidence
class GazePoint {
  /// Normalized X coordinate (0.0 to 1.0, relative to screen/camera)
  final double xNorm;

  /// Normalized Y coordinate (0.0 to 1.0, relative to screen/camera)
  final double yNorm;

  /// Timestamp in milliseconds since epoch
  final int tsMs;

  /// Confidence level (0.0 to 1.0, where 1.0 = high confidence)
  final double confidence;

  const GazePoint({
    required this.xNorm,
    required this.yNorm,
    required this.tsMs,
    this.confidence = 1.0,
  });

  /// Create from Offset (normalized 0-1)
  factory GazePoint.fromOffset(Offset position, {double confidence = 1.0}) {
    return GazePoint(
      xNorm: position.dx.clamp(0.0, 1.0),
      yNorm: position.dy.clamp(0.0, 1.0),
      tsMs: DateTime.now().millisecondsSinceEpoch,
      confidence: confidence.clamp(0.0, 1.0),
    );
  }

  /// Create from GazeData (existing service)
  factory GazePoint.fromGazeData(GazeData gazeData) {
    // Use faceDetected to set confidence, but allow lower confidence values
    // This ensures we can track even when confidence is moderate
    final confidence = gazeData.faceDetected ? 1.0 : 0.0;
    
    return GazePoint(
      xNorm: gazeData.position.dx.clamp(0.0, 1.0),
      yNorm: gazeData.position.dy.clamp(0.0, 1.0),
      tsMs: gazeData.timestamp.millisecondsSinceEpoch,
      confidence: confidence,
    );
  }

  /// Check if gaze is valid (confidence above threshold)
  bool isValid({double threshold = 0.5}) => confidence >= threshold;

  /// Convert to JSON for logging
  Map<String, dynamic> toJson() => {
        'xNorm': xNorm,
        'yNorm': yNorm,
        'tsMs': tsMs,
        'confidence': confidence,
      };

  @override
  String toString() =>
      'GazePoint(x: ${xNorm.toStringAsFixed(3)}, y: ${yNorm.toStringAsFixed(3)}, conf: ${confidence.toStringAsFixed(2)})';
}
