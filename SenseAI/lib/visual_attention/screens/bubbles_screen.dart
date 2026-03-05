import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../gaze/gaze_service.dart';
import '../theme.dart';
import '../widgets/interactive_bubbles.dart';
import 'results_screen.dart';

class BubblesScreen extends StatefulWidget {
  final String testId;
  final double? score;
  const BubblesScreen({required this.testId, this.score, super.key});

  @override
  State<BubblesScreen> createState() => _BubblesScreenState();
}

class _BubblesScreenState extends State<BubblesScreen> {
  bool _showInstructions = true;
  final List<Map<String, dynamic>> events = [];

  StreamSubscription<GazeData>? _gazeSubscription;
  Offset? _currentGaze;
  bool _gazeTrackingActive = false;
  bool _gameFinished = false;

  final int durationSec = 30;
  int _remainingSeconds = 30;
  late DateTime _startTime;
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = durationSec;
  }

  void _startGame() {
    setState(() {
      _showInstructions = false;
    });
    _startTime = DateTime.now();
    _initGazeTracking();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (t) {
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
    });
  }

  Future<void> _initGazeTracking() async {
    try {
      if (!gazeService.isInitialized) {
        await gazeService.initialize();
      }

      if (!gazeService.isTracking) {
        await gazeService.startTracking();
      }

      _gazeSubscription = gazeService.gazeStream.listen((gazeData) {
        if (mounted && !_gameFinished) {
          setState(() {
            _gazeTrackingActive = gazeData.faceDetected;
            if (gazeData.faceDetected) {
              _currentGaze = gazeData.position;
            } else {
              _currentGaze = null;
            }
          });

          if (gazeData.faceDetected) {
            _recordGazeEvent(gazeData);
          }
        }
      });

      setState(() {
        _gazeTrackingActive = gazeService.faceDetected;
      });
    } catch (e) {
      debugPrint('Gaze tracking error in bubbles: $e');
    }
  }

  void _recordGazeEvent(GazeData gazeData) {
    final e = {
      'timestamp': DateTime.now().millisecondsSinceEpoch / 1000.0,
      'x': gazeData.position.dx,
      'y': gazeData.position.dy,
      'real_gaze': true,
      'game': 'bubbles',
    };
    events.add(e);
    if (events.length > 800) events.removeAt(0);
  }

  void _onBubbleEvent(Map<String, dynamic> e) {
    if (_currentGaze != null) {
      e['gaze_x'] = _currentGaze!.dx;
      e['gaze_y'] = _currentGaze!.dy;
      e['real_gaze'] = true;
    }
    events.add(e);
    if (events.length > 800) events.removeAt(0);
  }

  void _finish() async {
    if (_gameFinished) return;
    _gameFinished = true;

    _tickTimer?.cancel();
    _gazeSubscription?.cancel();

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Analyzing gaze data...'),
            ],
          ),
        ),
      );
    }

    double score = 0.0;
    try {
      final res = await http
          .post(
            Uri.parse('$API_BASE/upload_gaze'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'test_id': widget.testId, 'events': events}),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        score = (data['score'] ?? 0.0).toDouble();
        debugPrint('Bubbles game: Data uploaded successfully, score: $score');
        debugPrint('Bubbles game: ${data['message'] ?? 'Analysis complete'}');
      }
    } catch (e) {
      debugPrint('Bubbles game: Upload failed (offline mode): $e');
    }

    if (mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ResultsScreen(testId: widget.testId, score: score)));
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
                    Text('🫧', style: TextStyle(fontSize: 36)),
                    SizedBox(width: 12),
                    Text('✨', style: TextStyle(fontSize: 40)),
                    SizedBox(width: 12),
                    Text('🫧', style: TextStyle(fontSize: 36)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bubble Pop Game',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: const Color(0xFF00ACC1).withOpacity(0.3)),
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
                      const Text(
                        '🎯 How to Play',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00838F),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInstructionItem('🫧', 'See the bubbles',
                          'Colorful bubbles will float on screen'),
                      const SizedBox(height: 16),
                      _buildInstructionItem('👆', 'Tap to pop!',
                          'Touch the bubbles to pop them!'),
                      const SizedBox(height: 16),
                      _buildInstructionItem(
                          '🎉', 'Have fun!', 'Pop as many bubbles as you can!'),
                      const SizedBox(height: 16),
                      _buildInstructionItem(
                          '⏱️', '30 seconds', 'The game lasts 30 seconds'),
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
                      backgroundColor: const Color(0xFF00ACC1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Start Game',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
        title: const Text('Pop the Bubbles'),
        actions: [
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
          InteractiveBubbles(
            onEvent: _onBubbleEvent,
            useCamera: true,
            modelEnabled: gazeService.isCalibrated,
          ),
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
