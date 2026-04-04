import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../services/rrb_video_service.dart';
import 'rrb_results_screen.dart';

/// RRB Video Recording Screen — professional with Record & Upload options
class RrbVideoRecordingScreen extends StatefulWidget {
  const RrbVideoRecordingScreen({super.key});

  @override
  State<RrbVideoRecordingScreen> createState() =>
      _RrbVideoRecordingScreenState();
}

enum _VideoMode { none, recording }

class _RrbVideoRecordingScreenState extends State<RrbVideoRecordingScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _cameraReady = false;
  String? _videoPath;
  XFile? _videoFile;
  _VideoMode _mode = _VideoMode.none;
  Duration _recordDuration = Duration.zero;
  // ignore: unused_field
  dynamic _timer;

  final RrbVideoService _videoService = RrbVideoService();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) _initializeCamera();
  }

  void _showMessage(String message, {Color color = Colors.blue}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating));
  }

  // ── Camera Init ──────────────────────────────────────────────────────────────
  Future<void> _initializeCamera() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    if (cameraStatus.isDenied || micStatus.isDenied) {
      _showMessage('Camera & microphone permissions are required.',
          color: Colors.red);
      return;
    }
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      _showMessage('No camera available on this device.', color: Colors.red);
      return;
    }
    _cameraController = CameraController(_cameras![0], ResolutionPreset.high,
        enableAudio: true);
    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _cameraReady = true;
          _mode = _VideoMode.recording;
        });
      }
    } catch (e) {
      _showMessage('Failed to initialize camera: $e', color: Colors.red);
    }
  }

  // ── Record ───────────────────────────────────────────────────────────────────
  Future<void> _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordDuration = Duration.zero;
      });
      _startTimer();
      _showMessage('Recording started — tap Stop when done.',
          color: Colors.green);
    } catch (e) {
      _showMessage('Failed to start recording: $e', color: Colors.red);
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null || !_cameraController!.value.isRecordingVideo)
      return;
    _stopTimer();
    try {
      final video = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _videoPath = video.path;
        _videoFile = video;
      });
      _showMessage('Recording saved. Ready to process.', color: Colors.blue);
      _showProcessDialog();
    } catch (e) {
      _showMessage('Failed to stop recording: $e', color: Colors.red);
    }
  }

  void _startTimer() {
    _timer = Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted && _isRecording)
        setState(() => _recordDuration += const Duration(seconds: 1));
    });
  }

  void _stopTimer() {
    (_timer as dynamic)?.cancel();
    _timer = null;
  }

  // ── Upload from gallery / file system (Android + Web) ────────────────────────
  Future<void> _uploadVideo() async {
    try {
      if (kIsWeb) {
        // Web: use ImagePicker which delegates to browser file picker
        final picker = ImagePicker();
        final XFile? video = await picker.pickVideo(
            source: ImageSource.gallery,
            maxDuration: const Duration(minutes: 5));
        if (video != null) {
          setState(() {
            _videoFile = video;
            _videoPath = video.name.isNotEmpty ? video.name : 'video.mp4';
          });
          _showMessage('Video selected: ${_videoPath!}', color: Colors.green);
          _showProcessDialog();
        }
      } else {
        // Android/Desktop: use file_picker for full file system access
        final result = await FilePicker.platform
            .pickFiles(type: FileType.video, allowMultiple: false);
        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          setState(() {
            _videoPath = file.path ?? file.name;
            _videoFile = XFile(_videoPath!);
          });
          _showMessage('Video selected: ${file.name}', color: Colors.green);
          _showProcessDialog();
        }
      }
    } catch (e) {
      _showMessage('Failed to pick video: $e', color: Colors.red);
    }
  }

  // ── Web: capture via camera ──────────────────────────────────────────────────
  Future<void> _captureVideoWeb() async {
    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
          source: ImageSource.camera, maxDuration: const Duration(minutes: 5));
      if (video != null) {
        setState(() {
          _videoFile = video;
          _videoPath = video.name.isNotEmpty ? video.name : 'video.mp4';
        });
        _showMessage('Video captured. Ready to process.', color: Colors.green);
        _showProcessDialog();
      }
    } catch (e) {
      _showMessage('Failed to capture video: $e', color: Colors.red);
    }
  }

  // ── Process Dialog ───────────────────────────────────────────────────────────
  void _showProcessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.check_circle, color: Color(0xFF059669)),
          SizedBox(width: 8),
          Text('Video Ready'),
        ]),
        content: const Text(
            'Your video has been loaded successfully. Would you like to send it for RRB analysis now?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _videoPath = null;
                _videoFile = null;
              });
            },
            child: const Text('Discard'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _processVideo();
            },
            icon: const Icon(Icons.analytics_outlined),
            label: const Text('Analyze Now'),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  // ── Process / Send to ML ─────────────────────────────────────────────────────
  Future<void> _processVideo() async {
    if (_videoPath == null) return;
    setState(() => _isProcessing = true);
    try {
      final videoBytes = kIsWeb
          ? await _videoFile!.readAsBytes()
          : await File(_videoPath!).readAsBytes();
      final result = await _videoService.detectRRB(_videoPath!, videoBytes);
      if (!mounted) return;
      if (result['success'] == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) =>
                  RrbResultsScreen(detectionResult: result['result'])),
        );
      } else {
        _showMessage(result['error'] ?? 'Detection failed', color: Colors.red);
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      _showMessage('Error: $e', color: Colors.red);
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _cameraController?.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isProcessing) return _buildProcessingScreen();
    if (kIsWeb) return _buildWebScreen();
    if (_mode == _VideoMode.recording) return _buildCameraScreen();
    return _buildSelectionScreen();
  }

  // ── Processing Screen ─────────────────────────────────────────────────────────
  Widget _buildProcessingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)]),
              borderRadius: BorderRadius.circular(100),
            ),
            child:
                const Icon(Icons.psychology_alt, color: Colors.white, size: 52),
          ),
          const SizedBox(height: 30),
          const Text('Analyzing Video',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F))),
          const SizedBox(height: 8),
          const Text('AI is detecting Restrictive & Repetitive Behaviors...',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center),
          const SizedBox(height: 32),
          const CircularProgressIndicator(color: Color(0xFF0284C7)),
          const SizedBox(height: 16),
          const Text('This may take a few moments',
              style: TextStyle(color: Colors.grey)),
        ]),
      ),
    );
  }

  // ── Web Screen ────────────────────────────────────────────────────────────────
  Widget _buildWebScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: _buildAppBar('Clinical Video Input'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _buildInfoBanner(),
          const SizedBox(height: 24),
          const Text('Choose an Option',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F))),
          const SizedBox(height: 14),
          _buildOptionCard(
            icon: Icons.videocam_rounded,
            color: const Color(0xFF0284C7),
            title: 'Record via Camera',
            subtitle:
                'Use your device camera to record a new clinical observation session.',
            onTap: _captureVideoWeb,
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            icon: Icons.upload_file_rounded,
            color: const Color(0xFF7C3AED),
            title: 'Upload Existing Video',
            subtitle:
                'Select a previously recorded video from your device or file system.',
            onTap: _uploadVideo,
          ),
          const SizedBox(height: 20),
          _buildTipsBanner(),
        ]),
      ),
    );
  }

  // ── Selection Screen (Android — before camera opens) ─────────────────────────
  Widget _buildSelectionScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: _buildAppBar('Clinical Video Input'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _buildInfoBanner(),
          const SizedBox(height: 24),
          const Text('Choose an Option',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F))),
          const SizedBox(height: 14),
          _buildOptionCard(
            icon: Icons.videocam_rounded,
            color: const Color(0xFF0284C7),
            title: 'Record a New Video',
            subtitle:
                'Open the camera to record a live clinical observation of the child.',
            onTap: () {
              if (_cameraReady) {
                setState(() => _mode = _VideoMode.recording);
              } else {
                _initializeCamera();
              }
            },
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            icon: Icons.upload_file_rounded,
            color: const Color(0xFF7C3AED),
            title: 'Upload Existing Video',
            subtitle:
                'Select a previously recorded video from your gallery or device storage.',
            onTap: _uploadVideo,
          ),
          const SizedBox(height: 20),
          _buildTipsBanner(),
        ]),
      ),
    );
  }

  // ── Camera Screen (Android — live recording) ──────────────────────────────────
  Widget _buildCameraScreen() {
    final isInit =
        _cameraController != null && _cameraController!.value.isInitialized;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: _isRecording
            ? Row(children: [
                const Icon(Icons.fiber_manual_record,
                    color: Colors.red, size: 14),
                const SizedBox(width: 6),
                Text(_formatDuration(_recordDuration),
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ])
            : const Text('Record Video'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Switch to Upload',
            onPressed: () => setState(() => _mode = _VideoMode.none),
          ),
        ],
      ),
      body: isInit
          ? Column(children: [
              Expanded(child: CameraPreview(_cameraController!)),
              Container(
                color: const Color(0xFF111827),
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(children: [
                  if (!_isRecording)
                    const Text(
                        'Position the child clearly in frame, then tap Record',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                        textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    GestureDetector(
                      onTap: _isRecording ? _stopRecording : _startRecording,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording
                              ? Colors.red
                              : const Color(0xFF0284C7),
                          boxShadow: [
                            BoxShadow(
                                color: (_isRecording
                                        ? Colors.red
                                        : const Color(0xFF0284C7))
                                    .withValues(alpha: 0.4),
                                blurRadius: 16,
                                spreadRadius: 2)
                          ],
                        ),
                        child: Icon(
                            _isRecording
                                ? Icons.stop_rounded
                                : Icons.fiber_manual_record,
                            color: Colors.white,
                            size: 36),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Text(
                      _isRecording
                          ? 'Tap to Stop Recording'
                          : 'Tap to Start Recording',
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 12)),
                ]),
              ),
            ])
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  // ── Shared Widgets ────────────────────────────────────────────────────────────
  AppBar _buildAppBar(String title) {
    return AppBar(
      title: Text(title),
      backgroundColor: const Color(0xFF0369A1),
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(children: [
        Icon(Icons.psychology_alt, color: Colors.white, size: 40),
        SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Clinical Video Analysis',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            SizedBox(height: 4),
            Text(
                'Provide a clear video of the child to enable AI-powered RRB detection. Ensure good lighting and an unobstructed view.',
                style: TextStyle(
                    color: Colors.white70, fontSize: 12, height: 1.4)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildOptionCard(
      {required IconData icon,
      required Color color,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
      shadowColor: color.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)]),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A5F))),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6B7280), height: 1.4)),
                ])),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
          ]),
        ),
      ),
    );
  }

  Widget _buildTipsBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7DD3FC)),
      ),
      child:
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.tips_and_updates_rounded,
              color: Color(0xFF0284C7), size: 18),
          SizedBox(width: 6),
          Text('Recording Tips',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0369A1),
                  fontSize: 13)),
        ]),
        SizedBox(height: 8),
        Text(
          '• Duration: 10 seconds to 5 minutes\n'
          '• Ensure the child is clearly visible with good lighting\n'
          '• Keep the camera steady; avoid shaky movements\n'
          '• Capture the child\'s full upper body when possible\n'
          '• Record in a calm, natural environment for best results',
          style:
              TextStyle(fontSize: 12.5, height: 1.5, color: Color(0xFF075985)),
        ),
      ]),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
