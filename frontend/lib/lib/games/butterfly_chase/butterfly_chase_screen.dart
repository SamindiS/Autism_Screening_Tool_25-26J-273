/// =============================================================================
/// Butterfly Chase Screen - Real-Time Gaze-Controlled Game Screen
/// =============================================================================
///
/// Flutter screen wrapper for the ButterflyChaseGame.
/// Handles UI overlay, instructions, and integration with gaze service.
/// =============================================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:http/http.dart' as http;
import '../../gaze/gaze_point.dart';
import '../../gaze/gaze_mapper.dart';
import '../../gaze/gaze_service.dart';
import '../../gaze/gaze_stream_provider.dart';
import '../../main.dart' show API_BASE, BubblesScreen;
import 'butterfly_chase_game.dart';

class ButterflyChaseScreen extends StatefulWidget {
  final String testId;
  final GazeService? gazeService;
  final Stream<GazePoint>? gazeStream; // Optional direct stream

  const ButterflyChaseScreen({
    required this.testId,
    this.gazeService,
    this.gazeStream,
    super.key,
  });

  @override
  State<ButterflyChaseScreen> createState() => _ButterflyChaseScreenState();
}

class _ButterflyChaseScreenState extends State<ButterflyChaseScreen> {
  ButterflyChaseGame? _game;
  Stream<GazePoint>? _gazeStream;
  GazeStreamProvider? _gazeProvider;
  bool _showInstructions = true;
  bool _gameStarted = false;
  bool _gameFinished = false;
  int _remainingSeconds = 15;
  Timer? _countdownTimer;
  bool _showGazeDot = false;
  Size? _screenSize;
  GazePoint? _currentGazePoint;
  String _gazeStatus = 'Initializing...';

  @override
  void initState() {
    super.initState();
    // Don't access MediaQuery/Theme here - do it in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe to access MediaQuery here
    if (_screenSize == null) {
      _screenSize = MediaQuery.of(context).size;
      _initializeGame();
    }
  }

  Future<void> _initializeGame() async {
    // Ensure gaze service is initialized and tracking
    final service = widget.gazeService ?? gazeService;
    
    if (!service.isInitialized) {
      await service.initialize();
    }
    
    if (!service.isTracking) {
      await service.startTracking();
    }

    // Get gaze stream
    if (widget.gazeStream != null) {
      _gazeStream = widget.gazeStream;
    } else if (widget.gazeService != null) {
      _gazeProvider = GazeStreamProvider(widget.gazeService!);
      _gazeStream = _gazeProvider!.gazeStream;
    } else {
      // Use global gaze service
      _gazeProvider = GazeStreamProvider(gazeService);
      _gazeStream = _gazeProvider!.gazeStream;
    }

    // Listen to gaze stream for real-time display - show ALL updates
    _gazeStream?.listen(
      (gazePoint) {
        if (mounted) {
          setState(() {
            _currentGazePoint = gazePoint;
            // Always show the actual gaze position, even if low confidence
            // This provides real-time feedback
            if (gazePoint.confidence > 0.3) {
              _gazeStatus = 'Gaze: (${gazePoint.xNorm.toStringAsFixed(3)}, ${gazePoint.yNorm.toStringAsFixed(3)}) Conf: ${gazePoint.confidence.toStringAsFixed(2)}';
            } else if (gazePoint.confidence > 0.0) {
              _gazeStatus = 'Low confidence: (${gazePoint.xNorm.toStringAsFixed(3)}, ${gazePoint.yNorm.toStringAsFixed(3)}) Conf: ${gazePoint.confidence.toStringAsFixed(2)}';
            } else {
              _gazeStatus = 'No face detected';
            }
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _gazeStatus = 'Gaze error: $error';
            _currentGazePoint = null;
          });
        }
      },
    );

    // Create game
    _game = ButterflyChaseGame();

    // Initialize game with gaze stream
    if (_gazeStream != null && _screenSize != null) {
      await _game!.initialize(
        gazeStream: _gazeStream!,
        screenSize: _screenSize!,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _startGame() {
    if (_game == null || _gameStarted) return;

    setState(() {
      _showInstructions = false;
      _gameStarted = true;
      _remainingSeconds = 15;
    });

    _game!.start();

    // Start countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _finishGame();
      }
    });
  }

  void _finishGame() async {
    if (_gameFinished) return;
    _gameFinished = true;
    _countdownTimer?.cancel();

    final result = _game!.finish();

    // Upload data in background
    _uploadData(result);

    // Navigate to next screen (BubblesScreen)
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BubblesScreen(testId: widget.testId, score: 0.0),
        ),
      );
    }
  }

  Future<void> _uploadData(ButterflyChaseResult result) async {
    try {
      final res = await http.post(
        Uri.parse('$API_BASE/upload_gaze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'test_id': widget.testId,
          'events': result.events,
          'game': 'butterfly_chase',
          'result': result.toJson(),
        }),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        debugPrint('ButterflyChase: Data uploaded successfully');
      }
    } catch (e) {
      debugPrint('ButterflyChase: Upload failed (offline mode): $e');
    }
  }

  void _toggleGazeDot() {
    setState(() {
      _showGazeDot = !_showGazeDot;
    });
    _game?.toggleGazeIndicator();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _gazeProvider?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Safe to access Theme here
    final theme = Theme.of(context);

    if (_game == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Game
          if (_game != null)
            GameWidget<ButterflyChaseGame>.controlled(
              gameFactory: () => _game!,
            ),

          // Instructions overlay
          if (_showInstructions)
            _buildInstructionsOverlay(theme),

          // HUD overlay
          if (!_showInstructions)
            _buildHUDOverlay(theme),

          // Debug toggle button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: IconButton(
              icon: Icon(
                _showGazeDot ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: _toggleGazeDot,
              tooltip: 'Toggle gaze dot',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsOverlay(ThemeData theme) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                'Butterfly Chase',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Follow the butterfly with your eyes!\n'
                'Keep your gaze on the butterfly as it moves.\n'
                'The game will last 15 seconds.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Start Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHUDOverlay(ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Timer
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Time: $_remainingSeconds',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Real-time gaze position display - always show latest values
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: (_currentGazePoint != null && _currentGazePoint!.confidence > 0.3)
                    ? Colors.green.withOpacity(0.8)
                    : (_currentGazePoint != null && _currentGazePoint!.confidence > 0.0)
                        ? Colors.orange.withOpacity(0.8)
                        : Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _gazeStatus,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  if (_currentGazePoint != null) ...[
                    SizedBox(height: 4),
                    Text(
                      'X: ${_currentGazePoint!.xNorm.toStringAsFixed(3)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Y: ${_currentGazePoint!.yNorm.toStringAsFixed(3)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Conf: ${_currentGazePoint!.confidence.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontSize: 9,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Spacer(),
            // Gaze status
            if (_showGazeDot)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Gaze indicator: ON',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
