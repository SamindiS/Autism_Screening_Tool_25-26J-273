/// =============================================================================
/// Butterfly Component - Animated Butterfly Sprite
/// =============================================================================
///
/// Flame component representing the butterfly that follows gaze targets
/// with smooth easing and wander behavior when gaze is lost.
/// =============================================================================

import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ButterflyComponent extends PositionComponent with HasGameReference {

  // Movement
  Vector2? _target;
  bool _wanderMode = false;
  Vector2 _wanderTarget = Vector2.zero();
  TimerComponent? _wanderTimer;

  // Smoothing (low-pass filter)
  Vector2 _smoothedTarget = Vector2.zero();
  static const double _smoothingFactor = 0.15; // Lower = smoother

  // Animation
  double _angle = 0.0;
  double _scale = 1.0;
  TimerComponent? _flapTimer;
  int _flapFrame = 0;
  double _time = 0.0;

  // Speed
  static const double _maxSpeed = 200.0; // pixels per second
  static const double _wanderSpeed = 50.0;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Set initial size
    size = Vector2(60, 60);

    // Set initial position (center)
    position = Vector2(
      game.size.x / 2,
      game.size.y / 2,
    );

    _smoothedTarget = position.clone();

    // Start flap animation
    _flapTimer = TimerComponent(
      period: 0.1,
      repeat: true,
      onTick: () {
        _flapFrame = (_flapFrame + 1) % 4;
      },
    );
    add(_flapTimer!);

    // Start wander timer
    _wanderTimer = TimerComponent(
      period: 2.0,
      repeat: true,
      onTick: _updateWanderTarget,
    );
    add(_wanderTimer!);
  }

  /// Set target position (from gaze)
  void setTarget(Vector2 target) {
    _target = target;
    _wanderMode = false;
  }

  /// Enable/disable wander mode
  void setWanderMode(bool enabled) {
    _wanderMode = enabled;
    if (enabled && _wanderTarget == Vector2.zero()) {
      _updateWanderTarget();
    }
  }

  void _updateWanderTarget() {
    if (!_wanderMode) return;

    final random = math.Random();
    final padding = 20.0;
    _wanderTarget = Vector2(
      padding + random.nextDouble() * (game.size.x - 2 * padding),
      padding + random.nextDouble() * (game.size.y - 2 * padding),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    Vector2 desiredTarget;

    if (_wanderMode) {
      desiredTarget = _wanderTarget;
    } else if (_target != null) {
      desiredTarget = _target!;
    } else {
      return; // No target
    }

    // Apply low-pass filter for smooth movement
    _smoothedTarget = _smoothedTarget + (desiredTarget - _smoothedTarget) * _smoothingFactor;

    // Calculate direction and distance
    final direction = _smoothedTarget - position;
    final distance = direction.length;

    if (distance > 1.0) {
      // Normalize direction
      final normalized = direction.normalized();

      // Calculate speed based on distance (easing)
      final speed = _wanderMode
          ? _wanderSpeed
          : (_maxSpeed * (1.0 - math.exp(-distance / 100.0))).clamp(0.0, _maxSpeed);

      // Move towards target
      position += normalized * speed * dt;

      // Update angle (face direction of movement)
      _angle = math.atan2(direction.y, direction.x);

      // Gentle scale animation (breathing effect)
      _scale = 1.0 + 0.1 * math.sin(_time * 3.0);
    }

    // Keep within bounds
    final padding = 20.0;
    position.x = position.x.clamp(padding, game.size.x - padding).toDouble();
    position.y = position.y.clamp(padding, game.size.y - padding).toDouble();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Save canvas state
    canvas.save();

    // Move to center of component
    canvas.translate(size.x / 2, size.y / 2);

    // Rotate to face movement direction
    canvas.rotate(_angle);

    // Scale for animation
    canvas.scale(_scale);

    // Draw butterfly (simple colored shape for now)
    final paint = Paint()
      ..color = _getButterflyColor()
      ..style = PaintingStyle.fill;

    // Draw butterfly body (ellipse)
    final bodyRect = Rect.fromCenter(
      center: Offset.zero,
      width: 8,
      height: 20,
    );
    canvas.drawOval(bodyRect, paint);

    // Draw wings (two circles)
    final wingPaint = Paint()
      ..color = _getWingColor()
      ..style = PaintingStyle.fill;

    // Left wing
    canvas.drawCircle(
      Offset(-15, -5),
      18,
      wingPaint,
    );

    // Right wing
    canvas.drawCircle(
      Offset(15, -5),
      18,
      wingPaint,
    );

    // Wing details (smaller circles)
    final detailPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(-15, -5), 10, detailPaint);
    canvas.drawCircle(Offset(15, -5), 10, detailPaint);

    canvas.restore();
  }

  Color _getButterflyColor() {
    // Color changes based on flap frame
    final colors = [
      const Color(0xFFFF6B9D), // Pink
      const Color(0xFFC44569), // Dark pink
      const Color(0xFFFF6B9D), // Pink
      const Color(0xFFFFC93C), // Yellow
    ];
    return colors[_flapFrame % colors.length];
  }

  Color _getWingColor() {
    // Gradient-like effect
    final colors = [
      const Color(0xFFFF6B9D), // Pink
      const Color(0xFFFFC93C), // Yellow
      const Color(0xFF4ECDC4), // Teal
      const Color(0xFF95E1D3), // Light teal
    ];
    return colors[_flapFrame % colors.length];
  }
}
