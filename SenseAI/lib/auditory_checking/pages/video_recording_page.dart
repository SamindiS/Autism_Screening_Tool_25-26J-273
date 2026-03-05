import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Real-time recording with: framing guide overlay, countdown (min 30s), hint messages.
/// Returns recorded video file path to caller.
class VideoRecordingPage extends StatefulWidget {
  /// Minimum recording duration in seconds
  final int minDurationSeconds;

  const VideoRecordingPage({super.key, this.minDurationSeconds = 30});

  @override
  State<VideoRecordingPage> createState() => _VideoRecordingPageState();
}

class _VideoRecordingPageState extends State<VideoRecordingPage> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  String? _error;
  bool _isRecording = false;
  int _elapsedSeconds = 0;
  Timer? _timer;
  int _hintIndex = 0;
  static const _hints = [
    "Keep child's face in the frame",
    "Child's face not visible - adjust camera",
    "Audio too quiet - move closer",
    "Ensure good lighting",
    "Position face in the oval guide",
  ];

  @override
  void initState() {
    super.initState();
    _initCamera();
    _rotateHints();
  }

  void _rotateHints() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() => _hintIndex = (_hintIndex + 1) % _hints.length);
      _rotateHints();
    });
  }

  Future<void> _initCamera() async {
    try {
      final status = await Permission.camera.request();
      final mic = await Permission.microphone.request();
      if (!status.isGranted) {
        setState(() => _error = 'Camera permission denied');
        return;
      }
      if (!mic.isGranted) {
        setState(() => _error = 'Microphone permission denied');
        return;
      }
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _error = 'No camera found');
        return;
      }
      // Prefer back camera for recording child (parent holds phone)
      final camera = _cameras.length > 1 ? _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      ) : _cameras.first;
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isInitialized = true);
    } catch (e) {
      setState(() => _error = 'Camera error: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _elapsedSeconds = 0;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _elapsedSeconds++);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Start recording failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_isRecording) return;
    _timer?.cancel();
    _timer = null;
    try {
      final file = await _controller!.stopVideoRecording();
      final path = file.path;
      if (path.isNotEmpty && mounted) {
        Navigator.of(context).pop(path);
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stop recording failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isRecording = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Record video', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _error != null
          ? _buildError()
          : !_isInitialized
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _buildCameraWithOverlay(),
      bottomNavigationBar: _isInitialized && _error == null ? _buildControls() : null,
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white),
              label: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraWithOverlay() {
    final controller = _controller!;
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
        ),
        // Framing guide overlay (oval)
        CustomPaint(
          painter: FramingGuidePainter(),
          child: const SizedBox.expand(),
        ),
        // Top hint message
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _hints[_hintIndex],
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
        // Countdown / timer
        Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: _elapsedSeconds >= widget.minDurationSeconds
                    ? Colors.green.withOpacity(0.8)
                    : Colors.orange.withOpacity(0.8),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _isRecording
                    ? (_elapsedSeconds >= widget.minDurationSeconds
                        ? 'OK - you can stop ($_elapsedSeconds s)'
                        : 'Recording: $_elapsedSeconds s (min ${widget.minDurationSeconds}s)')
                    : 'Minimum ${widget.minDurationSeconds} seconds',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isRecording)
              ElevatedButton.icon(
                onPressed: _startRecording,
                icon: const Icon(Icons.fiber_manual_record, color: Colors.white),
                label: const Text('Start recording', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _elapsedSeconds >= widget.minDurationSeconds ? _stopRecording : null,
                icon: const Icon(Icons.stop, color: Colors.white),
                label: Text(
                  _elapsedSeconds >= widget.minDurationSeconds ? 'Stop & use video' : 'Record at least ${widget.minDurationSeconds}s',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _elapsedSeconds >= widget.minDurationSeconds ? Colors.green : Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Draws an oval framing guide in the center (face position).
class FramingGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const width = 220.0;
    const height = 280.0;
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawOval(rect, paint);
    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Position face here',
        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy + height / 2 + 12),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
