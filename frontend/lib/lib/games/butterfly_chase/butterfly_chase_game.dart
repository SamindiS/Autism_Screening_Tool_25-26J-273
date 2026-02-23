/// =============================================================================
/// Butterfly Chase Game - Real-Time Gaze-Controlled Game
/// =============================================================================
///
/// Flame game that uses real-time gaze tracking to control butterfly movement.
/// The butterfly continuously follows the user's gaze with smooth easing.
/// =============================================================================

import 'dart:async' as async show StreamSubscription, Timer;
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../gaze/gaze_point.dart';
import '../../gaze/gaze_mapper.dart';
import 'components/butterfly_component.dart';
import 'components/gaze_indicator_component.dart';

/// Result data for ML analysis
class ButterflyChaseResult {
  final int score;
  final int gazeValidMs;
  final double avgDistance;
  final List<Map<String, dynamic>> events;
  final Duration duration;

  ButterflyChaseResult({
    required this.score,
    required this.gazeValidMs,
    required this.avgDistance,
    required this.events,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        'score': score,
        'gazeValidMs': gazeValidMs,
        'avgDistance': avgDistance,
        'eventCount': events.length,
        'durationMs': duration.inMilliseconds,
        'events': events,
      };
}

/// Main game class
class ButterflyChaseGame extends FlameGame with HasGameReference {
  // Gaze tracking
  async.StreamSubscription<GazePoint>? _gazeSubscription;
  GazeMapper? _gazeMapper;
  GazePoint? _latestGaze;
  DateTime? _lastGazeTime;
  bool _showGazeIndicator = false;

  // Game components
  ButterflyComponent? _butterfly;
  GazeIndicatorComponent? _gazeIndicator;

  // Game state
  DateTime? _startTime;
  bool _isRunning = false;
  bool _isFinished = false;

  // Data logging
  final List<Map<String, dynamic>> _events = [];
  final List<double> _distances = [];
  int _gazeValidMs = 0;
  async.Timer? _loggingTimer; // dart:async Timer

  // Configuration
  static const double _confidenceThreshold = 0.3; // Lower threshold for more responsive tracking
  static const Duration _gazeTimeout = Duration(milliseconds: 1000); // Longer timeout
  static const Duration _loggingInterval = Duration(milliseconds: 200);

  /// Initialize game with gaze stream
  Future<void> initialize({
    required Stream<GazePoint> gazeStream,
    required Size screenSize,
    GazeCalibrationParams? calibration,
  }) async {
    // Setup gaze mapper
    _gazeMapper = GazeMapper();
    _gazeMapper!.updateScreenSize(screenSize);
    _gazeMapper!.setPadding(20.0);
    if (calibration != null) {
      _gazeMapper!.setCalibration(calibration);
    }

    // Subscribe to gaze stream - accept ALL gaze updates for real-time tracking
    _gazeSubscription = gazeStream.listen(
      (gaze) {
        // Always update latest gaze for display, even if low confidence
        // This ensures real-time feedback
        _latestGaze = gaze;
        _lastGazeTime = DateTime.now();
        
        // Log all gaze updates for debugging
        debugPrint('ButterflyChase: Gaze received - (${gaze.xNorm.toStringAsFixed(3)}, ${gaze.yNorm.toStringAsFixed(3)}) conf: ${gaze.confidence.toStringAsFixed(2)}');
        
        // Record event for all valid gaze (confidence > 0.3 for more lenient tracking)
        if (gaze.confidence > 0.3) {
          _recordGazeEvent(gaze);
        }
      },
      onError: (error) {
        debugPrint('Gaze stream error: $error');
        // On error, set gaze to null to trigger wander mode
        _latestGaze = null;
        _lastGazeTime = null;
      },
    );

    // Create butterfly component
    _butterfly = ButterflyComponent();
    add(_butterfly!);

    // Create gaze indicator (hidden by default)
    _gazeIndicator = GazeIndicatorComponent();
    add(_gazeIndicator!);

    // Start logging timer
    _loggingTimer = async.Timer.periodic(_loggingInterval, (_) => _logButterflyPosition());
  }

  /// Start the game
  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _isFinished = false;
    _startTime = DateTime.now();
    _events.clear();
    _distances.clear();
    _gazeValidMs = 0;
  }

  /// Stop the game and return results
  ButterflyChaseResult finish() {
    if (_isFinished) {
      return ButterflyChaseResult(
        score: 0,
        gazeValidMs: _gazeValidMs,
        avgDistance: _distances.isEmpty ? 0.0 : _distances.reduce((a, b) => a + b) / _distances.length,
        events: List.from(_events),
        duration: Duration.zero,
      );
    }

    _isRunning = false;
    _isFinished = true;
    _loggingTimer?.cancel();

    final duration = _startTime != null
        ? DateTime.now().difference(_startTime!)
        : Duration.zero;

    final avgDistance = _distances.isEmpty
        ? 0.0
        : _distances.reduce((a, b) => a + b) / _distances.length;

    return ButterflyChaseResult(
      score: _calculateScore(),
      gazeValidMs: _gazeValidMs,
      avgDistance: avgDistance,
      events: List.from(_events),
      duration: duration,
    );
  }

  /// Toggle gaze indicator visibility
  void toggleGazeIndicator() {
    _showGazeIndicator = !_showGazeIndicator;
    if (_gazeIndicator != null) {
      _gazeIndicator!.isVisible = _showGazeIndicator;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isRunning || _butterfly == null || _gazeMapper == null) return;

    // Check if gaze is valid and recent
    final now = DateTime.now();
    final isGazeRecent = _latestGaze != null &&
        _lastGazeTime != null &&
        now.difference(_lastGazeTime!) < _gazeTimeout;
    
    // Accept gaze if it's recent AND has reasonable confidence
    // Lower threshold allows more responsive tracking
    final isGazeValid = isGazeRecent &&
        _latestGaze!.confidence >= _confidenceThreshold;

    if (isGazeValid && _latestGaze != null) {
      // Always use latest gaze position, even if near center (0.5, 0.5)
      // This allows real-time tracking even when looking at center
      final target = _gazeMapper!.mapToGameWorld(_latestGaze!);
      _butterfly!.setTarget(target);

      // Update gaze indicator
      if (_gazeIndicator != null && _showGazeIndicator) {
        _gazeIndicator!.setPosition(target);
        _gazeIndicator!.isVisible = true;
      }

      // Track valid gaze time
      _gazeValidMs += (dt * 1000).round();
      
      // Calculate distance for metrics
      final distance = _butterfly!.position.distanceTo(target);
      _distances.add(distance);
      if (_distances.length > 1000) _distances.removeAt(0);
    } else {
      // Gaze lost or invalid - wander mode
      _butterfly!.setWanderMode(true);

      // Hide gaze indicator
      if (_gazeIndicator != null) {
        _gazeIndicator!.isVisible = false;
      }
    }
  }

  void _recordGazeEvent(GazePoint gaze) {
    if (!_isRunning) return;

    _events.add({
      'timestamp': gaze.tsMs / 1000.0,
      'xNorm': gaze.xNorm,
      'yNorm': gaze.yNorm,
      'confidence': gaze.confidence,
      'type': 'gaze_sample',
    });

    // Limit events to prevent memory issues
    if (_events.length > 2000) {
      _events.removeAt(0);
    }
  }

  void _logButterflyPosition() {
    if (!_isRunning || _butterfly == null) return;

    final target = _latestGaze != null && _latestGaze!.isValid()
        ? _gazeMapper!.mapToGameWorld(_latestGaze!)
        : null;

    _events.add({
      'timestamp': DateTime.now().millisecondsSinceEpoch / 1000.0,
      'butterflyX': _butterfly!.position.x,
      'butterflyY': _butterfly!.position.y,
      'targetX': target?.x,
      'targetY': target?.y,
      'type': 'butterfly_position',
    });

    if (_events.length > 2000) {
      _events.removeAt(0);
    }
  }

  int _calculateScore() {
    // Score based on engagement and accuracy
    final engagementScore = (_gazeValidMs / 1000).round() * 10;
    final accuracyScore = _distances.isEmpty
        ? 0
        : (1000 / (1 + _distances.reduce((a, b) => a + b) / _distances.length)).round();
    return engagementScore + accuracyScore;
  }

  @override
  void onRemove() {
    _gazeSubscription?.cancel();
    _loggingTimer?.cancel();
    super.onRemove();
  }
}
