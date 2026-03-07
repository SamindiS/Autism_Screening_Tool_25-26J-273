import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../gaze/gaze_service.dart';
import '../theme.dart';
import '../widgets/animated_butterfly.dart';
import 'bubbles_screen.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/language_selector.dart';


class ButterflyScreen extends StatefulWidget {
  final String testId;
  const ButterflyScreen({required this.testId, super.key});

  @override
  State<ButterflyScreen> createState() => _ButterflyScreenState();
}

class _ButterflyScreenState extends State<ButterflyScreen> {
  bool _showInstructions = true;
  final List<Map<String, dynamic>> events = [];
  Timer? _tickTimer;
  final int durationSec = 15;
  late DateTime _startTime;
  int _remainingSeconds = 15;
  bool _gameFinished = false;

  StreamSubscription<GazeData>? _gazeSubscription;
  Offset? _currentGaze;
  bool _gazeTrackingActive = false;
  String _debugStatus = 'Initializing...';
  Timer? _gazeHealthCheckTimer;

  GazeData? _latestGazeData;
  DateTime? _lastGazeUpdate;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = durationSec;
  }

  void _startGame() async {
    setState(() {
      _showInstructions = false;
    });

    await _initGazeTracking();
    await Future.delayed(const Duration(milliseconds: 300));

    _startTime = DateTime.now();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), _tick);

    debugPrint('Butterfly game: Started at ${DateTime.now()}');
    debugPrint('Butterfly game: Gaze tracking - isTracking: ${gazeService.isTracking}, faceDetected: ${gazeService.faceDetected}');
  }

  Future<void> _initGazeTracking() async {
    try {
      setState(() => _debugStatus = 'Checking gaze service...');

      await _gazeSubscription?.cancel();
      _gazeSubscription = null;

      if (!gazeService.isInitialized) {
        setState(() => _debugStatus = 'Initializing gaze service...');
        await gazeService.initialize();
        await Future.delayed(const Duration(milliseconds: 300));
      }

      if (gazeService.isTracking) {
        setState(() => _debugStatus = 'Restarting gaze tracking...');
        await gazeService.stopTracking();
        await Future.delayed(const Duration(milliseconds: 200));
      }

      setState(() => _debugStatus = 'Starting gaze tracking...');
      await gazeService.startTracking();
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _debugStatus = 'Subscribing to gaze stream...');

      _gazeSubscription = gazeService.gazeStream.listen(
        (gazeData) {
          if (mounted && !_gameFinished) {
            _latestGazeData = gazeData;
            _lastGazeUpdate = DateTime.now();

            setState(() {
              _gazeTrackingActive = gazeData.faceDetected;
              if (gazeData.faceDetected && gazeData.position != null) {
                _currentGaze = gazeData.position;
                _debugStatus =
                    'Gaze: (${gazeData.position.dx.toStringAsFixed(2)}, ${gazeData.position.dy.toStringAsFixed(2)})';
              } else {
                _currentGaze = null;
                _debugStatus = 'No face detected';
              }
            });
          }
        },
        onError: (error) {
          debugPrint('Gaze stream error: $error');
          if (mounted && !_gameFinished) {
            setState(() {
              _debugStatus = 'Gaze stream error: $error';
              _gazeTrackingActive = false;
              _currentGaze = null;
            });
          }
        },
        cancelOnError: false,
      );

      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _gazeTrackingActive = gazeService.faceDetected;
        if (gazeService.isTracking) {
          _debugStatus = 'Gaze tracking active!';
        } else {
          _debugStatus = 'Warning: Tracking not active';
        }
      });

      debugPrint('Butterfly game: Gaze tracking initialized - isTracking: ${gazeService.isTracking}, faceDetected: ${gazeService.faceDetected}');

      _gazeHealthCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (_gameFinished) {
          timer.cancel();
          return;
        }

        if (!gazeService.isTracking && mounted) {
          debugPrint('Butterfly game: Gaze tracking stopped unexpectedly, restarting...');
          _initGazeTracking();
        }
      });
    } catch (e, stackTrace) {
      debugPrint('Gaze tracking error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _debugStatus = 'Gaze error: $e';
          _gazeTrackingActive = false;
          _currentGaze = null;
        });
      }
    }
  }

  void _tick(Timer t) {
    if (_gameFinished) {
      t.cancel();
      return;
    }

    final elapsed = DateTime.now().difference(_startTime).inSeconds;
    final remaining = durationSec - elapsed;

    if (remaining <= 0) {
      _finish();
    } else {
      setState(() {
        _remainingSeconds = remaining;
      });
    }
  }

  void _handleSample(double gxPx, double gyPx, double txNorm, double tyNorm) {
    if (_gameFinished) return;

    final box = context.findRenderObject() as RenderBox?;
    final w = box?.size.width ?? 1.0;
    final h = box?.size.height ?? 1.0;

    double gazeX, gazeY;
    bool isRealGaze = false;

    final now = DateTime.now();
    final isRecentGaze = _lastGazeUpdate != null &&
                         now.difference(_lastGazeUpdate!).inMilliseconds < 300;

    final latestGaze = _latestGazeData;
    final latestGazePos = latestGaze?.position ?? _currentGaze;

    if (latestGazePos != null &&
        latestGaze?.faceDetected == true &&
        isRecentGaze &&
        gazeService.isTracking) {
      gazeX = latestGazePos.dx.clamp(0.0, 1.0);
      gazeY = latestGazePos.dy.clamp(0.0, 1.0);
      isRealGaze = true;
    } else {
      gazeX = (gxPx / w).clamp(0.0, 1.0);
      gazeY = (gyPx / h).clamp(0.0, 1.0);
      isRealGaze = false;
    }

    final e = {
      'timestamp': DateTime.now().millisecondsSinceEpoch / 1000.0,
      'x': gazeX,
      'y': gazeY,
      'target_x': txNorm,
      'target_y': tyNorm,
      'game': 'butterfly',
      'real_gaze': isRealGaze,
      'face_detected': latestGaze?.faceDetected ?? gazeService.faceDetected,
      'tracking_active': gazeService.isTracking,
    };
    events.add(e);
    if (events.length > 400) events.removeAt(0);
  }

  void _finish() async {
    if (_gameFinished) return;
    _gameFinished = true;

    _tickTimer?.cancel();
    _gazeHealthCheckTimer?.cancel();
    _gazeSubscription?.cancel();

    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => BubblesScreen(testId: widget.testId, score: 0.0)));

    try {
      final res = await http
          .post(
            Uri.parse('$API_BASE/upload_gaze'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'test_id': widget.testId, 'events': events}),
          )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        debugPrint('Butterfly game: Data uploaded successfully');
      }
    } catch (e) {
      debugPrint('Butterfly game: Upload failed (offline mode): $e');
    }
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _gazeSubscription?.cancel();
    super.dispose();
  }

  Widget _buildInstructionScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF5F5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🦋', style: TextStyle(fontSize: 40)),
                    SizedBox(width: 16),
                    Text('🌸', style: TextStyle(fontSize: 40)),
                    SizedBox(width: 16),
                    Text('🦋', style: TextStyle(fontSize: 40)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)?.butterflyGame ?? 'Butterfly Game',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FFF0),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '🌿 ${AppLocalizations.of(context)?.howToPlayGame ?? "How to Play"}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInstructionItem('🦋', AppLocalizations.of(context)?.watchButterfly ?? 'Watch the butterfly',
                          AppLocalizations.of(context)?.butterflyFlyAround ?? 'A colorful butterfly will fly around'),
                      const SizedBox(height: 16),
                      _buildInstructionItem('👀', AppLocalizations.of(context)?.followEyes ?? 'Follow with your eyes',
                          AppLocalizations.of(context)?.tryLookWhere ?? 'Try to look at where it goes'),
                      const SizedBox(height: 16),
                      _buildInstructionItem('🌸', AppLocalizations.of(context)?.visitFlowers ?? 'Visit the flowers',
                          AppLocalizations.of(context)?.butterflyLovesFlowers ?? 'The butterfly loves flowers!'),
                      const SizedBox(height: 16),
                      _buildInstructionItem(
                          '⏱️', AppLocalizations.of(context)?.fifteenSeconds ?? '15 seconds', AppLocalizations.of(context)?.gameLasts15 ?? 'The game lasts 15 seconds'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.startGameBtn ?? 'Start Game',
                      style:
                          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  Widget _buildInstructionItem(String emoji, String title, String description) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50))),
              Text(description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showInstructions) {
      return _buildInstructionScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.butterflyGame ?? 'Follow the Butterfly'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const LanguageSelector(),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _gazeTrackingActive ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _gazeTrackingActive ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _gazeTrackingActive ? 'Tracking' : 'No Face',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8F5E9),
                  Color(0xFFC8E6C9),
                  Color(0xFFA5D6A7),
                ],
              ),
            ),
          ),
          AnimatedButterfly(onSample: _handleSample),
          Positioned(
            left: 16,
            right: 16,
            bottom: 80,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value:
                      (1.0 - (_remainingSeconds / durationSec)).clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withOpacity(0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_remainingSeconds}s remaining',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _debugStatus,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: ElevatedButton(
              onPressed: _finish,
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }
}
