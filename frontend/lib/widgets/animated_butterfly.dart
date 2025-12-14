/// =============================================================================
/// Animated Butterfly Widget - Smooth Pursuit Eye Tracking Test
/// =============================================================================
///
/// A colorful animated butterfly that moves across the screen in various
/// patterns to test the child's smooth pursuit eye tracking ability.
///
/// Movement Patterns:
/// - Horizontal sweep: Left-right scanning
/// - Vertical sweep: Up-down scanning
/// - Gentle circle: Circular/oval paths
/// - Flower hop: Discrete jumps to fixed positions
/// - Combined: Cycles through all patterns
///
/// The widget emits gaze samples via [onSample] callback containing:
/// - gx, gy: Current gaze position (from gaze service)
/// - tx, ty: Target/butterfly position
///
/// Test Duration: 15 seconds (configurable)
/// =============================================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Callback for gaze sampling with gaze and target positions
typedef SampleCallback = void Function(
    double gx, double gy, double tx, double ty);

/// Movement patterns for the butterfly
enum ButterflyPattern {
  /// Smooth horizontal sweep (left to right, right to left)
  horizontalSweep,

  /// Smooth vertical sweep (top to bottom, bottom to top)
  verticalSweep,

  /// Gentle circular/oval path
  gentleCircle,

  /// Random flower-hopping (jumps to discrete positions)
  flowerHop,

  /// Combined pattern that cycles through different movements
  combined,
}

class AnimatedButterfly extends StatefulWidget {
  final SampleCallback onSample;
  final Duration interval;
  final ButterflyPattern pattern;

  const AnimatedButterfly({
    required this.onSample,
    this.interval = const Duration(milliseconds: 80),
    this.pattern = ButterflyPattern.combined,
    super.key,
  });

  @override
  State<AnimatedButterfly> createState() => _AnimatedButterflyState();
}

class _AnimatedButterflyState extends State<AnimatedButterfly>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctr;
  Timer? _timer;
  double t = 0.0;
  final rng = Random();

  // For flower-hop pattern
  int _currentFlower = 0;
  double _hopProgress = 0.0;
  Offset _lastPosition = const Offset(0.5, 0.5);
  Offset _targetPosition = const Offset(0.5, 0.5);

  // Flower positions (targets the butterfly visits)
  final List<Offset> _flowers = const [
    Offset(0.2, 0.3), // Top-left flower
    Offset(0.8, 0.25), // Top-right flower
    Offset(0.5, 0.5), // Center flower
    Offset(0.15, 0.7), // Bottom-left flower
    Offset(0.85, 0.75), // Bottom-right flower
    Offset(0.5, 0.2), // Top-center flower
    Offset(0.5, 0.8), // Bottom-center flower
  ];

  // Current phase for combined pattern
  int _phase = 0;
  double _phaseTime = 0;
  static const double _phaseDuration = 4.0; // 4 seconds per phase

  @override
  void initState() {
    super.initState();
    _ctr =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
    _timer = Timer.periodic(widget.interval, (_) => _sample());
    _targetPosition = _flowers[0];
  }

  void _sample() {
    if (!mounted) return;

    final dt = widget.interval.inMilliseconds / 1000.0;
    t += dt;
    _phaseTime += dt;

    // Calculate position based on pattern
    Offset normalizedPos;

    switch (widget.pattern) {
      case ButterflyPattern.horizontalSweep:
        normalizedPos = _horizontalSweep(t);
        break;
      case ButterflyPattern.verticalSweep:
        normalizedPos = _verticalSweep(t);
        break;
      case ButterflyPattern.gentleCircle:
        normalizedPos = _gentleCircle(t);
        break;
      case ButterflyPattern.flowerHop:
        normalizedPos = _flowerHop(dt);
        break;
      case ButterflyPattern.combined:
        normalizedPos = _combinedPattern(t, dt);
        break;
    }

    setState(() {
      _lastPosition = normalizedPos;
    });

    // Report sample
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = context.findRenderObject() as RenderBox?;
      if (box == null) return;
      final w = box.size.width;
      final h = box.size.height;
      final txPx = normalizedPos.dx * w;
      final tyPx = normalizedPos.dy * h;
      // Simulated gaze with small random offset (for testing without real gaze)
      final gx = (txPx + (rng.nextDouble() - 0.5) * 40).clamp(0.0, w);
      final gy = (tyPx + (rng.nextDouble() - 0.5) * 40).clamp(0.0, h);
      widget.onSample(gx, gy, normalizedPos.dx, normalizedPos.dy);
    });
  }

  /// Smooth horizontal sweep - good for testing horizontal eye tracking
  Offset _horizontalSweep(double time) {
    // Slow sinusoidal sweep, 6 seconds per full cycle
    final x = 0.5 + 0.35 * sin(time * 0.5);
    const y = 0.45; // Fixed vertical position
    return Offset(x.clamp(0.1, 0.9), y);
  }

  /// Smooth vertical sweep - good for testing vertical eye tracking
  Offset _verticalSweep(double time) {
    const x = 0.5; // Fixed horizontal position
    final y = 0.5 + 0.3 * sin(time * 0.5);
    return Offset(x, y.clamp(0.15, 0.85));
  }

  /// Gentle circular/oval path - smooth pursuit test
  Offset _gentleCircle(double time) {
    // Slow elliptical path, ~8 seconds per revolution
    final x = 0.5 + 0.25 * cos(time * 0.4);
    final y = 0.5 + 0.2 * sin(time * 0.4);
    return Offset(x.clamp(0.1, 0.9), y.clamp(0.15, 0.85));
  }

  /// Flower hopping - tests saccades (quick eye jumps)
  Offset _flowerHop(double dt) {
    _hopProgress += dt * 0.5; // Adjust speed: smaller = slower hops

    if (_hopProgress >= 1.0) {
      // Move to next flower
      _hopProgress = 0.0;
      _lastPosition = _targetPosition;
      _currentFlower = (_currentFlower + 1) % _flowers.length;
      _targetPosition = _flowers[_currentFlower];
    }

    // Smooth interpolation between flowers
    final eased = _easeInOutCubic(_hopProgress);
    return Offset(
      _lastPosition.dx + (_targetPosition.dx - _lastPosition.dx) * eased,
      _lastPosition.dy + (_targetPosition.dy - _lastPosition.dy) * eased,
    );
  }

  /// Combined pattern - cycles through different movements
  Offset _combinedPattern(double time, double dt) {
    // Change phase every _phaseDuration seconds
    if (_phaseTime >= _phaseDuration) {
      _phaseTime = 0;
      _phase = (_phase + 1) % 4;
    }

    switch (_phase) {
      case 0:
        return _horizontalSweep(time);
      case 1:
        return _flowerHop(dt);
      case 2:
        return _verticalSweep(time);
      case 3:
        return _gentleCircle(time);
      default:
        return _horizontalSweep(time);
    }
  }

  /// Easing function for smooth transitions
  double _easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      final px = _lastPosition.dx * w;
      final py = _lastPosition.dy * h;

      // Gentle wing flap animation
      final wingAngle = sin(t * 8) * 0.15;

      // Soft clinical colors for flowers
      const flowerColors = [
        Color(0xFFF7CAC9), // Soft coral
        Color(0xFFFFDAB9), // Soft peach
        Color(0xFFB8A9C9), // Soft lavender
        Color(0xFF98D8C8), // Soft mint
        Color(0xFFDCD0FF), // Soft lilac
        Color(0xFFA0E7E5), // Soft aqua
        Color(0xFF87CEEB), // Soft sky blue
      ];

      return Stack(children: [
        // Background with soft green gradient - matching bubble game style
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE8F5E9), // Light green (starts higher)
                Color(0xFFC8E6C9), // Soft mint green
                Color(0xFFA5D6A7), // Gentle green
              ],
            ),
          ),
        ),

        // Draw flowers as targets (visual interest for children)
        for (int i = 0; i < _flowers.length; i++)
          Positioned(
            left: _flowers[i].dx * w - 20,
            top: _flowers[i].dy * h - 20,
            child: _buildFlower(
              flowerColors[i % flowerColors.length],
              // Highlight the current target flower
              i == _currentFlower &&
                  widget.pattern == ButterflyPattern.flowerHop,
            ),
          ),

        // Trail effect (fading dots showing butterfly path)
        for (int i = 0; i < 5; i++)
          Positioned(
            left: (px - i * 8 * cos(t * 2)) - 4,
            top: (py - i * 4 * sin(t * 2)) - 4,
            child: Opacity(
              opacity: (1 - i * 0.2).clamp(0.0, 1.0),
              child: Container(
                width: 8 - i * 1.0,
                height: 8 - i * 1.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFB8A9C9).withOpacity(0.5 - i * 0.1),
                ),
              ),
            ),
          ),

        // Butterfly with shadow
        Positioned(
          left: px - 30,
          top: py - 28,
          child: Stack(
            children: [
              // Shadow
              Positioned(
                left: 4,
                top: 4,
                child: Transform.rotate(
                  angle: wingAngle,
                  child: Text(
                    '🦋',
                    style: TextStyle(
                      fontSize: 52,
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
              // Main butterfly
              Transform.rotate(
                angle: wingAngle,
                child: const Text(
                  '🦋',
                  style: TextStyle(fontSize: 52),
                ),
              ),
            ],
          ),
        ),

        // Sparkle effects around butterfly
        for (int i = 0; i < 3; i++)
          Positioned(
            left: px + cos(t * 3 + i * 2) * 30 - 6,
            top: py + sin(t * 3 + i * 2) * 25 - 6,
            child: Opacity(
              opacity: (0.5 + 0.5 * sin(t * 5 + i)).clamp(0.0, 1.0),
              child: const Text('✨', style: TextStyle(fontSize: 12)),
            ),
          ),

        // Instructions at top
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '👀 Follow the butterfly with your eyes!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ]);
    });
  }

  /// Build a flower with optional highlight for current target
  Widget _buildFlower(Color color, bool isTarget) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(isTarget ? 0.8 : 0.3),
        boxShadow: isTarget
            ? [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          '🌸',
          style: TextStyle(
            fontSize: isTarget ? 28 : 24,
          ),
        ),
      ),
    );
  }
}
