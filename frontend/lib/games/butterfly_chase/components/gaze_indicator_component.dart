/// =============================================================================
/// Gaze Indicator Component - Visual Debug Indicator
/// =============================================================================
///
/// Small translucent circle that shows where the gaze target is located.
/// Used for debugging and testing gaze tracking accuracy.
/// =============================================================================

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GazeIndicatorComponent extends PositionComponent {
  bool _visible = false;

  bool get isVisible => _visible;
  set isVisible(bool value) {
    _visible = value;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(20, 20);
    _visible = false;
  }

  /// Set position of gaze indicator
  void setPosition(Vector2 position) {
    this.position = position - size / 2;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (!_visible) return;

    // Draw translucent circle
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      paint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.blue.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      borderPaint,
    );
  }
}
