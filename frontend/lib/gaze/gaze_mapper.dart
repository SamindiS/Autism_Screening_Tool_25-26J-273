/// =============================================================================
/// Gaze Mapper - Coordinate System Conversion
/// =============================================================================
///
/// Maps normalized gaze coordinates (0-1) to screen/game world coordinates.
/// Handles:
/// - Portrait orientation
/// - Camera preview letterboxing/pillarboxing
/// - Calibration offset and scale
/// - Safe area padding
/// =============================================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/components.dart' as flame;
import 'gaze_point.dart';

/// Calibration parameters for gaze mapping
class GazeCalibrationParams {
  /// Offset in normalized coordinates (0-1)
  final Offset offset;

  /// Scale factor (default 1.0 = no scaling)
  final double scale;

  /// Rotation in radians (default 0.0 = no rotation)
  final double rotation;

  const GazeCalibrationParams({
    this.offset = Offset.zero,
    this.scale = 1.0,
    this.rotation = 0.0,
  });
}

/// Maps normalized gaze coordinates to screen/game coordinates
class GazeMapper {
  /// Screen size
  Size _screenSize = Size.zero;

  /// Safe area padding (pixels)
  double _padding = 20.0;

  /// Calibration parameters
  GazeCalibrationParams _calibration = const GazeCalibrationParams();

  /// Camera preview size (if different from screen)
  Size? _cameraPreviewSize;

  /// Camera preview offset (if letterboxed/pillarboxed)
  Offset? _cameraPreviewOffset;

  /// Update screen size
  void updateScreenSize(Size size) {
    _screenSize = size;
  }

  /// Update safe area padding
  void setPadding(double padding) {
    _padding = padding;
  }

  /// Update calibration parameters
  void setCalibration(GazeCalibrationParams calibration) {
    _calibration = calibration;
  }

  /// Set camera preview bounds (for letterboxing/pillarboxing)
  void setCameraPreviewBounds({
    required Size previewSize,
    required Offset previewOffset,
  }) {
    _cameraPreviewSize = previewSize;
    _cameraPreviewOffset = previewOffset;
  }

  /// Map normalized gaze point to screen coordinates (Offset)
  Offset mapToScreen(GazePoint gaze) {
    // Start with normalized coordinates
    double x = gaze.xNorm;
    double y = gaze.yNorm;

    // Apply calibration offset
    x += _calibration.offset.dx;
    y += _calibration.offset.dy;

    // Apply calibration scale
    x *= _calibration.scale;
    y *= _calibration.scale;

    // Apply rotation (if any)
    if (_calibration.rotation != 0.0) {
      final cosR = cos(_calibration.rotation);
      final sinR = sin(_calibration.rotation);
      final centerX = 0.5;
      final centerY = 0.5;
      final dx = x - centerX;
      final dy = y - centerY;
      x = centerX + dx * cosR - dy * sinR;
      y = centerY + dx * sinR + dy * cosR;
    }

    // Clamp to 0-1
    x = x.clamp(0.0, 1.0);
    y = y.clamp(0.0, 1.0);

    // Convert to screen pixels
    double screenX = x * _screenSize.width;
    double screenY = y * _screenSize.height;

    // Apply camera preview offset if set
    if (_cameraPreviewOffset != null) {
      screenX += _cameraPreviewOffset!.dx;
      screenY += _cameraPreviewOffset!.dy;
    }

    // Apply safe area padding
    screenX = screenX.clamp(_padding, _screenSize.width - _padding);
    screenY = screenY.clamp(_padding, _screenSize.height - _padding);

    return Offset(screenX, screenY);
  }

  /// Map normalized gaze point to Flame Vector2 (game world)
  flame.Vector2 mapToGameWorld(GazePoint gaze) {
    final offset = mapToScreen(gaze);
    return flame.Vector2(offset.dx, offset.dy);
  }

  /// Get safe area bounds (for keeping objects inside)
  Rect getSafeArea() {
    return Rect.fromLTWH(
      _padding,
      _padding,
      _screenSize.width - 2 * _padding,
      _screenSize.height - 2 * _padding,
    );
  }
}
