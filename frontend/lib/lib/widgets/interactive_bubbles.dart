/// =============================================================================
/// Interactive Bubbles Widget - Visual Attention Test
/// =============================================================================
///
/// Children pop bubbles by TAPPING them - easy and fun for ages 2-6!
/// The game tracks gaze in background for autism screening data collection.
///
/// Features:
/// - Touch/tap to pop bubbles (primary interaction)
/// - Gaze tracking in background for screening data
/// - Colorful floating bubbles with gentle animations
/// - Score tracking and encouraging feedback
/// - Big, easy-to-tap bubbles for little fingers
///
/// Clinical Metrics Collected:
/// - Time to first bubble pop
/// - Gaze-touch coordination
/// - Visual attention patterns
/// - Reaction time to new bubbles
///
/// Test Duration: 30 seconds (configurable)
/// =============================================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../gaze/gaze_service.dart';

/// Callback for bubble events (pop, spawn, gaze tracking)
typedef BubbleEventCallback = void Function(Map<String, dynamic> event);

/// Clinical soft colors for bubbles
class BubbleColors {
  static const List<Color> colors = [
    Color(0xFF87CEEB), // Soft sky blue
    Color(0xFF98D8C8), // Soft mint
    Color(0xFFB8A9C9), // Soft lavender
    Color(0xFFFFDAB9), // Soft peach
    Color(0xFFF7CAC9), // Soft coral
    Color(0xFF88D8D8), // Soft teal
    Color(0xFFDCD0FF), // Soft lilac
    Color(0xFFA0E7E5), // Soft aqua
  ];
}

/// Represents a single bubble
class Bubble {
  String id;
  Offset position; // Normalized 0-1
  double size;
  Color color;
  double wobblePhase;
  bool isBeingLookedAt;
  double gazeProgress; // 0-1, how long gaze has been on this bubble
  bool isPopping;

  // Floating animation properties
  double floatPhase; // Phase for sin/cos floating motion
  double floatSpeedX; // Individual speed for horizontal float
  double floatSpeedY; // Individual speed for vertical float
  double floatAmplitudeX; // How far to sway horizontally
  double floatAmplitudeY; // How far to bob vertically
  Offset basePosition; // Original spawn position to float around

  Bubble({
    required this.id,
    required this.position,
    required this.size,
    required this.color,
    this.wobblePhase = 0,
    this.isBeingLookedAt = false,
    this.gazeProgress = 0,
    this.isPopping = false,
    this.floatPhase = 0,
    this.floatSpeedX = 1.0,
    this.floatSpeedY = 1.5,
    this.floatAmplitudeX = 0.03,
    this.floatAmplitudeY = 0.02,
    Offset? basePosition,
  }) : basePosition = basePosition ?? position;
}

class InteractiveBubbles extends StatefulWidget {
  final BubbleEventCallback onEvent;
  final bool useCamera;
  final bool modelEnabled;

  const InteractiveBubbles({
    required this.onEvent,
    this.useCamera = false,
    this.modelEnabled = false,
    super.key,
  });

  @override
  State<InteractiveBubbles> createState() => _InteractiveBubblesState();
}

class _InteractiveBubblesState extends State<InteractiveBubbles>
    with TickerProviderStateMixin {
  final rng = Random();
  List<Bubble> bubbles = [];

  // Gaze tracking
  StreamSubscription<GazeData>? _gazeSubscription;
  Offset? _currentGaze;
  Offset? _smoothedGaze; // Extra smoothed gaze for display
  final List<Offset> _gazeHistory = []; // History for averaging
  bool _gazeActive = false;

  // Smoothing parameters for bubble game (steadier dot)
  static const int _smoothingWindow = 8; // More samples = steadier
  static const double _smoothingAlpha = 0.15; // Lower = smoother (0.1-0.3)

  // Game state
  int _score = 0;
  String _feedback = 'Tap the bubbles! �🫧';

  // Animation
  late AnimationController _wobbleController;
  Timer? _gameTimer;
  Timer? _gazeCheckTimer;
  
  // No need for AudioCache - we'll use AssetSource directly

  // Game settings - BIGGER bubbles for kids!
  static const int maxBubbles = 6; // Fewer bubbles, less overwhelming
  static const double bubbleMinSize = 80; // Bigger for easy tapping
  static const double bubbleMaxSize = 120; // Even bigger!
  static const double gazeThreshold = 0.25; // For tracking only, not popping
  static const double gazeProgressPerTick =
      0.04; // Not used for popping anymore

  // Encouraging messages
  final List<String> _encouragements = [
    'Great job! 🌟',
    'You did it! ⭐',
    'Amazing! 🎉',
    'Wonderful! 🦋',
    'Super! 🎈',
    'Fantastic! ✨',
  ];

  @override
  void initState() {
    super.initState();

    // Wobble animation for bubbles
    _wobbleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Initialize bubbles
    _initBubbles();

    // Start gaze tracking
    _startGazeTracking();

    // Game update timer
    _gameTimer = Timer.periodic(const Duration(milliseconds: 50), _updateGame);

    // Gaze check timer for visual feedback
    _gazeCheckTimer =
        Timer.periodic(const Duration(milliseconds: 50), _checkGaze);
  }

  void _initBubbles() {
    bubbles = List.generate(maxBubbles, (i) => _createBubble(i));
  }

  Bubble _createBubble(int index) {
    final basePos = Offset(
      0.1 + rng.nextDouble() * 0.8, // Keep away from edges
      0.15 + rng.nextDouble() * 0.55, // Spread across screen
    );

    return Bubble(
      id: 'bubble_$index',
      position: basePos,
      basePosition: basePos,
      size: bubbleMinSize + rng.nextDouble() * (bubbleMaxSize - bubbleMinSize),
      color: BubbleColors.colors[index % BubbleColors.colors.length],
      wobblePhase: rng.nextDouble() * 2 * pi,
      floatPhase: rng.nextDouble() * 2 * pi, // Random starting phase
      floatSpeedX: 0.8 + rng.nextDouble() * 0.6, // Varying speeds
      floatSpeedY: 1.0 + rng.nextDouble() * 0.8,
      floatAmplitudeX: 0.02 + rng.nextDouble() * 0.03, // Varying amplitudes
      floatAmplitudeY: 0.015 + rng.nextDouble() * 0.025,
    );
  }

  /// Apply extra smoothing for steadier dot display
  Offset _smoothGaze(Offset newGaze) {
    // Add to history
    _gazeHistory.add(newGaze);

    // Keep only recent samples
    while (_gazeHistory.length > _smoothingWindow) {
      _gazeHistory.removeAt(0);
    }

    // If we have previous smoothed value, apply EMA
    if (_smoothedGaze != null) {
      // Moving average of history
      double avgX = 0, avgY = 0;
      for (final g in _gazeHistory) {
        avgX += g.dx;
        avgY += g.dy;
      }
      avgX /= _gazeHistory.length;
      avgY /= _gazeHistory.length;

      // EMA on top of moving average for extra smoothness
      final smoothedX =
          _smoothedGaze!.dx + _smoothingAlpha * (avgX - _smoothedGaze!.dx);
      final smoothedY =
          _smoothedGaze!.dy + _smoothingAlpha * (avgY - _smoothedGaze!.dy);

      return Offset(smoothedX, smoothedY);
    }

    return newGaze;
  }

  void _startGazeTracking() {
    if (gazeService.isInitialized && gazeService.isCalibrated) {
      _gazeSubscription = gazeService.gazeStream.listen((data) {
        if (mounted && data.faceDetected) {
          final smoothed = _smoothGaze(data.position);
          setState(() {
            _currentGaze = data.position; // Raw for bubble detection
            _smoothedGaze = smoothed; // Smoothed for display
            _gazeActive = true;
          });
        } else {
          setState(() {
            _gazeActive = false;
          });
        }
      });
    }
  }

  void _checkGaze(Timer timer) {
    if (!mounted || _currentGaze == null) return;

    // Track which bubble child is looking at (for data collection only)
    // NO automatic popping - kids tap to pop!
    for (final bubble in bubbles) {
      if (bubble.isPopping) continue;

      final distance = _getDistance(bubble.position, _currentGaze!);
      final adjustedThreshold = gazeThreshold * (bubble.size / 80);

      if (distance < adjustedThreshold) {
        // Child is looking at this bubble - track it
        if (!bubble.isBeingLookedAt) {
          bubble.isBeingLookedAt = true;
          bubble.gazeProgress = 0;

          // Record gaze event for screening data
          widget.onEvent({
            'timestamp': DateTime.now().millisecondsSinceEpoch / 1000.0,
            'event_type': 'gaze_on_bubble',
            'x': _currentGaze!.dx,
            'y': _currentGaze!.dy,
            'target_x': bubble.position.dx,
            'target_y': bubble.position.dy,
            'bubble_id': bubble.id,
            'game': 'bubbles',
          });
        }
        bubble.gazeProgress =
            min(1.0, bubble.gazeProgress + gazeProgressPerTick);
      } else {
        // Not looking at this bubble
        if (bubble.isBeingLookedAt) {
          // Record gaze leaving bubble
          widget.onEvent({
            'timestamp': DateTime.now().millisecondsSinceEpoch / 1000.0,
            'event_type': 'gaze_off_bubble',
            'x': _currentGaze!.dx,
            'y': _currentGaze!.dy,
            'bubble_id': bubble.id,
            'dwell_time': bubble.gazeProgress,
            'game': 'bubbles',
          });
        }
        bubble.isBeingLookedAt = false;
        bubble.gazeProgress =
            max(0, bubble.gazeProgress - gazeProgressPerTick * 2);
      }
    }

    if (mounted) setState(() {});
  }

  double _getDistance(Offset a, Offset b) {
    final dx = a.dx - b.dx;
    final dy = a.dy - b.dy;
    return sqrt(dx * dx + dy * dy);
  }

  void _updateGame(Timer timer) {
    if (!mounted) return;

    // Animate bubble floating
    setState(() {
      for (final bubble in bubbles) {
        if (bubble.isPopping) continue;

        // Increment phase for smooth continuous motion
        bubble.floatPhase += 0.03; // Slowed down for gentler movement
        bubble.wobblePhase += 0.03;

        // Calculate floating offset using sin/cos for smooth motion
        // Each bubble has its own speed and amplitude for variety
        // These oscillate around zero - no net movement in any direction
        final floatOffsetX = sin(bubble.floatPhase * bubble.floatSpeedX) *
            bubble.floatAmplitudeX;
        final floatOffsetY = sin(bubble.floatPhase * bubble.floatSpeedY) *
            bubble.floatAmplitudeY;

        // Add a gentle figure-8 pattern for more organic movement
        final figure8X = sin(bubble.floatPhase * 0.5) * 0.008;
        final figure8Y = cos(bubble.floatPhase * 0.5) *
            0.006; // cos for perpendicular motion

        // NO drift - bubbles stay in their base area
        // Just apply the oscillating float offsets
        bubble.position = Offset(
          (bubble.basePosition.dx + floatOffsetX + figure8X).clamp(0.05, 0.95),
          (bubble.basePosition.dy + floatOffsetY + figure8Y).clamp(0.1, 0.75),
        );
      }
    });
  }

  void _playPopSound() async {
    if (!mounted) return;
    
    // Create a new AudioPlayer instance for each pop to allow overlapping sounds
    final player = AudioPlayer();
    
    try {
      // Configure player for sound effects
      player.setPlayerMode(PlayerMode.lowLatency);
      player.setVolume(1.0);
      
      // AssetSource path should be relative to assets/ folder
      // File renamed to bubble_pop.mp3 (underscore instead of space)
      const soundPath = 'logo/bubble/bubble_pop.mp3';
      
      debugPrint('🔊 Attempting to play sound: $soundPath');
      
      // Play the sound
      await player.play(AssetSource(soundPath));
      
      debugPrint('✅ Bubble pop sound started playing');
      
      // Dispose the player after sound finishes (cleanup)
      player.onPlayerComplete.listen((_) {
        debugPrint('🔇 Sound finished, disposing player');
        player.dispose();
      });
      
      // Also set a timeout to dispose if sound doesn't complete (safety net)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          try {
            player.dispose();
          } catch (_) {}
        }
      });
      
    } catch (error) {
      debugPrint('❌ Error playing bubble pop sound: $error');
      debugPrint('   Error type: ${error.runtimeType}');
      
      // Try fallback path
      try {
        debugPrint('🔄 Trying fallback path...');
        player.setPlayerMode(PlayerMode.lowLatency);
        player.setVolume(1.0);
        await player.play(AssetSource('assets/logo/bubble/bubble_pop.mp3'));
        debugPrint('✅ Bubble pop sound played with fallback path');
        
        player.onPlayerComplete.listen((_) {
          player.dispose();
        });
      } catch (e) {
        debugPrint('❌ Fallback also failed: $e');
        player.dispose();
      }
    }
  }

  void _popBubble(Bubble bubble) {
    if (bubble.isPopping) return;

    bubble.isPopping = true;
    _score += 10; // Points for popping!

    // Play bubble pop sound
    _playPopSound();

    // Report pop event with gaze data
    final event = {
      'timestamp': DateTime.now().millisecondsSinceEpoch / 1000.0,
      'event_type': 'bubble_popped',
      'gaze_x': _currentGaze?.dx ?? -1,
      'gaze_y': _currentGaze?.dy ?? -1,
      'target_x': bubble.position.dx,
      'target_y': bubble.position.dy,
      'bubble_id': bubble.id,
      'pop_method': 'touch',
      'was_looking_at_bubble': bubble.isBeingLookedAt,
      'gaze_progress_at_pop': bubble.gazeProgress,
      'game': 'bubbles',
    };
    widget.onEvent(event);

    // Show encouragement
    setState(() {
      _feedback = _encouragements[rng.nextInt(_encouragements.length)];
    });

    // Respawn bubble after animation
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        final index = bubbles.indexOf(bubble);
        if (index >= 0) {
          setState(() {
            bubbles[index] = _createBubble(index);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _wobbleController.dispose();
    _gameTimer?.cancel();
    _gazeCheckTimer?.cancel();
    _gazeSubscription?.cancel();
    // AudioCache is static and doesn't need disposal
    // Individual AudioPlayer instances are disposed after each sound completes
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;

      return Stack(
        children: [
          // Background gradient - light and playful for kids
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE0F7FA), // Light cyan
                  Color(0xFFB2EBF2), // Soft teal
                  Color(0xFF80DEEA), // Gentle aqua
                ],
              ),
            ),
          ),

          // Score and feedback
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3E50).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '⭐ $_score',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Gaze indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _gazeActive
                        ? Colors.green.withOpacity(0.7)
                        : Colors.orange.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _gazeActive ? '👁️ Tracking' : '👀 Look at me!',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Feedback message
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _feedback,
                  key: ValueKey(_feedback),
                  style: const TextStyle(
                    color: Color(0xFF2C3E50),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Bubbles
          for (final bubble in bubbles) _buildBubble(bubble, w, h),

          // Gaze indicator hidden - gaze tracking happens in background
          // but we don't show the dot to avoid distracting the child
          // The data is still collected for autism screening

          // Instructions at bottom
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50).withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '� Tap the bubbles to pop them!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBubble(Bubble bubble, double w, double h) {
    if (bubble.isPopping) {
      // Pop animation
      return Positioned(
        left: bubble.position.dx * w - bubble.size / 2,
        top: bubble.position.dy * h - bubble.size / 2,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 0.0),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 1.0 + (1 - value) * 0.5,
              child: Opacity(
                opacity: value,
                child: Container(
                  width: bubble.size,
                  height: bubble.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bubble.color.withOpacity(0.3),
                  ),
                  child: const Center(
                    child: Text('✨', style: TextStyle(fontSize: 30)),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // Wobble offset
    final wobbleX = sin(bubble.wobblePhase) * 3;
    final wobbleY = cos(bubble.wobblePhase * 0.7) * 2;

    // Subtle breathing scale effect
    final breatheScale = 1.0 + sin(bubble.floatPhase * 0.8) * 0.03;

    // Check if child is looking at this bubble (for subtle visual feedback)
    final isLookedAt = bubble.isBeingLookedAt && bubble.gazeProgress > 0;

    return Positioned(
      left: bubble.position.dx * w - bubble.size / 2 + wobbleX,
      top: bubble.position.dy * h - bubble.size / 2 + wobbleY,
      child: GestureDetector(
        onTap: () => _popBubble(bubble),
        child: Transform.scale(
          scale: breatheScale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: bubble.size,
            height: bubble.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                colors: [
                  bubble.color.withOpacity(0.9),
                  bubble.color.withOpacity(0.6),
                  bubble.color.withOpacity(0.3),
                ],
              ),
              boxShadow: [
                // Normal shadow
                BoxShadow(
                  color: bubble.color.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
                // Subtle glow when child is looking at it (feedback only)
                if (isLookedAt)
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
              ],
            ),
            child: Stack(
              children: [
                // Highlight reflection
                Positioned(
                  top: bubble.size * 0.15,
                  left: bubble.size * 0.2,
                  child: Container(
                    width: bubble.size * 0.3,
                    height: bubble.size * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(bubble.size * 0.15),
                    ),
                  ),
                ),
                // "Tap me" hint for kids
                Center(
                  child: Text(
                    '🫧',
                    style: TextStyle(
                      fontSize: bubble.size * 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
