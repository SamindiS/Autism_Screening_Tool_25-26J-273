/// Social vs Object Preference test screen.
/// Two AOIs: left = face (emoji), right = object (toy). Collects gaze and labels AOI.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../gaze/gaze_service.dart';
import '../services/social_object_api.dart';
import 'social_object_result_screen.dart';

class SocialObjectTestScreen extends StatefulWidget {
  /// Optional child id from main flow; can be null when opened from menu.
  final String? childId;

  const SocialObjectTestScreen({super.key, this.childId});

  @override
  State<SocialObjectTestScreen> createState() => _SocialObjectTestScreenState();
}

class _SocialObjectTestScreenState extends State<SocialObjectTestScreen>
    with TickerProviderStateMixin {
  final SocialObjectApi _api = SocialObjectApi();
  final List<Map<String, dynamic>> _events = [];
  static const int _testDurationSec = 25;
  static const int _countdownSec = 3;
  static const double _minIntervalSec = 1 / 30; // max 30 events/sec

  String? _sessionId;
  bool _countdownPhase = true;
  int _countdownValue = _countdownSec;
  int _remainingSec = _testDurationSec;
  bool _recording = false;
  bool _finished = false;
  Timer? _countdownTimer;
  Timer? _testTimer;
  Timer? _uploadTimer;
  Timer? _blinkTimer;
  StreamSubscription<GazeData>? _gazeSubscription;
  int _lastEventTimeMs = 0;
  Offset? _touchGaze; // normalized 0-1 when using touch fallback

  late AnimationController _blinkController;
  late AnimationController _pulseController;
  late AnimationController _toyRotateController;
  late AnimationController _toyBounceController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _toyRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _toyBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _blinkTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || _finished) return;
      _blinkController.forward(from: 0);
      _blinkController.reverse();
    });
    _startSession();
  }

  Future<void> _startSession() async {
    try {
      final res = await _api.startSession(childId: widget.childId);
      if (!mounted) return;
      setState(() => _sessionId = res['session_id'] as String?);
      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      setState(() => _sessionId = 'local_${DateTime.now().millisecondsSinceEpoch}');
      _startCountdown();
    }
  }

  void _startCountdown() {
    setState(() {
      _countdownPhase = true;
      _countdownValue = _countdownSec;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _countdownValue--;
        if (_countdownValue <= 0) {
          t.cancel();
          _countdownPhase = false;
          _startTest();
        }
      });
    });
  }

  void _startTest() {
    setState(() {
      _recording = true;
      _remainingSec = _testDurationSec;
    });
    _initGazeSource();
    _uploadTimer = Timer.periodic(const Duration(seconds: 1), (_) => _flushUpload());
    _testTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _finished) return;
      setState(() {
        _remainingSec--;
        if (_remainingSec <= 0) {
          t.cancel();
          _endTest();
        }
      });
    });
  }

  Future<void> _initGazeSource() async {
    try {
      if (!gazeService.isInitialized) await gazeService.initialize();
      if (!gazeService.isTracking) await gazeService.startTracking();
      _gazeSubscription = gazeService.gazeStream.listen((gazeData) {
        if (!mounted || _finished || !_recording) return;
        if (gazeData.faceDetected) _addGazePoint(gazeData.position.dx, gazeData.position.dy);
      });
    } catch (_) {
      // Use touch fallback only when no gaze stream
    }
  }

  /// Label AOI: center (20% x 20% center) first, then face (left half - padding), then object (right half - padding).
  String _labelAOI(double x, double y, Size size) {
    const double padPx = 10.0;
    final double w = size.width;
    final double h = size.height;
    if (w <= 0 || h <= 0) return 'none';
    final double nx = x.clamp(0.0, 1.0);
    final double ny = y.clamp(0.0, 1.0);
    final double px = nx * w;
    final double py = ny * h;

    double cx = w * 0.2 / 2;
    double cy = h * 0.2 / 2;
    final double centerLeft = w * 0.5 - cx;
    final double centerRight = w * 0.5 + cx;
    final double centerTop = h * 0.5 - cy;
    final double centerBottom = h * 0.5 + cy;
    if (px >= centerLeft && px <= centerRight && py >= centerTop && py <= centerBottom) {
      return 'center';
    }
    final double leftHalfRight = w * 0.5;
    if (px >= padPx && px <= leftHalfRight - padPx && py >= padPx && py <= h - padPx) {
      return 'face';
    }
    if (px >= leftHalfRight + padPx && px <= w - padPx && py >= padPx && py <= h - padPx) {
      return 'object';
    }
    return 'none';
  }

  void _addGazePoint(double x, double y) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastEventTimeMs > 0) {
      final dt = (now - _lastEventTimeMs) / 1000.0;
      if (dt < _minIntervalSec) return;
    }
    _lastEventTimeMs = now;
    final size = MediaQuery.sizeOf(context);
    final aoi = _labelAOI(x, y, size);
    _events.add({
      'timestamp_ms': now,
      'x': x.clamp(0.0, 1.0),
      'y': y.clamp(0.0, 1.0),
      'aoi': aoi,
    });
  }

  Future<void> _flushUpload() async {
    if (_sessionId == null || _events.isEmpty) return;
    final chunkSize = _events.length > 25 ? 25 : _events.length;
    final toSend = _events.take(chunkSize).toList();
    for (int i = 0; i < chunkSize; i++) _events.removeAt(0);
    try {
      await _api.uploadGazeEvents(_sessionId!, toSend);
    } catch (_) {
      _events.insertAll(0, toSend);
    }
  }

  Future<void> _endTest() async {
    if (_finished) return;
    _finished = true;
    _recording = false;
    _uploadTimer?.cancel();
    _testTimer?.cancel();
    _gazeSubscription?.cancel();
    await _flushUpload();
    if (_events.isNotEmpty && _sessionId != null) {
      try {
        await _api.uploadGazeEvents(_sessionId!, List.from(_events));
      } catch (_) {}
      _events.clear();
    }

    Map<String, dynamic> metrics = {};
    if (_sessionId != null) {
      try {
        metrics = await _api.finishSession(_sessionId!);
      } catch (_) {}
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SocialObjectResultScreen(
          sessionId: _sessionId ?? '',
          metrics: metrics,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _testTimer?.cancel();
    _uploadTimer?.cancel();
    _blinkTimer?.cancel();
    _gazeSubscription?.cancel();
    _blinkController.dispose();
    _pulseController.dispose();
    _toyRotateController.dispose();
    _toyBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _countdownPhase ? _buildCountdown() : _buildTest(),
      ),
    );
  }

  Widget _buildCountdown() {
    return Container(
      color: const Color(0xFFE8F5E9),
      child: Center(
        child: Text(
          _countdownValue > 0 ? '$_countdownValue' : 'Go!',
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D32),
          ),
        ),
      ),
    );
  }

  Widget _buildTest() {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onPanUpdate: (details) {
                  if (!_recording || _finished) return;
                  final box = context.findRenderObject() as RenderBox?;
                  if (box == null) return;
                  final local = box.globalToLocal(details.globalPosition);
                  final x = (local.dx / box.size.width).clamp(0.0, 1.0);
                  final y = (local.dy / box.size.height).clamp(0.0, 1.0);
                  setState(() => _touchGaze = Offset(x, y));
                  _addGazePoint(x, y);
                },
                child: _FaceAOIWidget(
                  blinkController: _blinkController,
                  pulseController: _pulseController,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onPanUpdate: (details) {
                  if (!_recording || _finished) return;
                  final box = context.findRenderObject() as RenderBox?;
                  if (box == null) return;
                  final local = box.globalToLocal(details.globalPosition);
                  final x = (local.dx / box.size.width).clamp(0.0, 1.0);
                  final y = (local.dy / box.size.height).clamp(0.0, 1.0);
                  setState(() => _touchGaze = Offset(x, y));
                  _addGazePoint(x, y);
                },
                child: _ObjectAOIWidget(
                  rotateController: _toyRotateController,
                  bounceController: _toyBounceController,
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            color: Colors.black26,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: 1.0 - (_remainingSec / _testDurationSec),
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                Text(
                  '$_remainingSec s',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FaceAOIWidget extends StatelessWidget {
  final AnimationController blinkController;
  final AnimationController pulseController;

  const _FaceAOIWidget({
    required this.blinkController,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF8E1),
      padding: const EdgeInsets.all(10),
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([blinkController, pulseController]),
          builder: (context, child) {
            double scale = 0.9 + 0.1 * (pulseController.value);
            final blinkOpacity = 1.0 - (blinkController.value * 0.7);
            return Opacity(
              opacity: blinkOpacity.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: scale,
                child: const Text('😊', style: TextStyle(fontSize: 120)),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ObjectAOIWidget extends StatelessWidget {
  final AnimationController rotateController;
  final AnimationController bounceController;

  const _ObjectAOIWidget({
    required this.rotateController,
    required this.bounceController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE3F2FD),
      padding: const EdgeInsets.all(10),
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([rotateController, bounceController]),
          builder: (context, child) {
            final bounce = 8.0 * (0.5 - (bounceController.value - 0.5).abs());
            return Transform.translate(
              offset: Offset(0, bounce),
              child: Transform.rotate(
                angle: rotateController.value * 2 * 3.14159,
                child: const Text('🚗', style: TextStyle(fontSize: 100)),
              ),
            );
          },
        ),
      ),
    );
  }
}
