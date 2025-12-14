/// Data Collection Screen
///
/// Purpose: Collect training data for the gaze prediction model
///
/// How it works:
/// 1. Shows a camera preview with face detection overlay
/// 2. Displays target dots at known screen positions
/// 3. When user presses "Capture", saves eye landmarks + dot position
/// 4. Exports collected data as JSON for training

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'gaze_tracker.dart';

/// Training sample: eye landmarks + target screen position
class TrainingSample {
  final EyeLandmarks landmarks;
  final double targetX; // Normalized 0-1
  final double targetY; // Normalized 0-1

  TrainingSample({
    required this.landmarks,
    required this.targetX,
    required this.targetY,
  });

  Map<String, dynamic> toJson() => {
        'landmarks': landmarks.toJson(),
        'modelInput': landmarks.toModelInput(),
        'targetX': targetX,
        'targetY': targetY,
      };
}

class DataCollectionScreen extends StatefulWidget {
  const DataCollectionScreen({super.key});

  @override
  State<DataCollectionScreen> createState() => _DataCollectionScreenState();
}

class _DataCollectionScreenState extends State<DataCollectionScreen> {
  final GazeTracker _gazeTracker = GazeTracker();
  bool _isInitialized = false;
  String _status = 'Initializing camera...';

  // Current target dot position (normalized 0-1)
  int _currentDotIndex = 0;

  // Grid of target positions for data collection
  // 9-point calibration grid covering the screen
  final List<Offset> _targetPositions = [
    const Offset(0.1, 0.1), // Top-left
    const Offset(0.5, 0.1), // Top-center
    const Offset(0.9, 0.1), // Top-right
    const Offset(0.1, 0.5), // Middle-left
    const Offset(0.5, 0.5), // Center
    const Offset(0.9, 0.5), // Middle-right
    const Offset(0.1, 0.9), // Bottom-left
    const Offset(0.5, 0.9), // Bottom-center
    const Offset(0.9, 0.9), // Bottom-right
  ];

  // Collected samples
  final List<TrainingSample> _samples = [];

  // Latest landmarks from tracker
  EyeLandmarks? _latestLandmarks;

  // Samples per position
  int _samplesPerPosition = 5;
  int _currentPositionSamples = 0;

  @override
  void initState() {
    super.initState();
    _initializeTracker();
  }

  Future<void> _initializeTracker() async {
    try {
      await _gazeTracker.initialize();

      // Listen to landmarks stream
      _gazeTracker.landmarksStream.listen((landmarks) {
        setState(() {
          _latestLandmarks = landmarks;
        });
      });

      await _gazeTracker.startTracking();

      setState(() {
        _isInitialized = true;
        _status = 'Look at the dot and tap "Capture"';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  @override
  void dispose() {
    _gazeTracker.dispose();
    super.dispose();
  }

  /// Capture current eye landmarks with target position
  void _captureSample() {
    if (_latestLandmarks == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No face detected! Look at the camera.')),
      );
      return;
    }

    final target = _targetPositions[_currentDotIndex];
    final sample = TrainingSample(
      landmarks: _latestLandmarks!,
      targetX: target.dx,
      targetY: target.dy,
    );

    _samples.add(sample);
    _currentPositionSamples++;

    setState(() {
      _status =
          'Captured! (${_samples.length} total, $_currentPositionSamples/$_samplesPerPosition for this dot)';
    });

    // Auto-advance to next dot after enough samples
    if (_currentPositionSamples >= _samplesPerPosition) {
      _nextDot();
    }
  }

  /// Move to next target dot
  void _nextDot() {
    setState(() {
      _currentDotIndex = (_currentDotIndex + 1) % _targetPositions.length;
      _currentPositionSamples = 0;

      if (_currentDotIndex == 0 && _samples.isNotEmpty) {
        _status =
            'Full round complete! ${_samples.length} samples collected. Continue or save.';
      } else {
        _status =
            'Dot ${_currentDotIndex + 1}/${_targetPositions.length} - Look and capture';
      }
    });
  }

  /// Save collected data to file
  Future<void> _saveData() async {
    if (_samples.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No samples to save!')),
      );
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/gaze_training_$timestamp.json');

      final data = {
        'version': '1.0',
        'collectedAt': DateTime.now().toIso8601String(),
        'totalSamples': _samples.length,
        'samples': _samples.map((s) => s.toJson()).toList(),
      };

      await file.writeAsString(jsonEncode(data));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Saved ${_samples.length} samples to ${file.path}')),
        );
      }

      setState(() {
        _status = 'Data saved! Path: ${file.path}';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    }
  }

  /// Clear all collected samples
  void _clearData() {
    setState(() {
      _samples.clear();
      _currentDotIndex = 0;
      _currentPositionSamples = 0;
      _status = 'Data cleared. Start collecting again.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gaze Data Collection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveData,
            tooltip: 'Save data',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearData,
            tooltip: 'Clear data',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          if (_isInitialized && _gazeTracker.cameraController != null)
            Positioned.fill(
              child: CameraPreview(
                  cameraController: _gazeTracker.cameraController!),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Target dot overlay
          if (_isInitialized) _buildTargetDot(),

          // Face detection indicator
          if (_latestLandmarks != null) _buildLandmarksOverlay(),

          // Status bar at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _status,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _captureSample,
                        icon: const Icon(Icons.camera),
                        label: const Text('Capture'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _nextDot,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Next Dot'),
                      ),
                      Text(
                        '${_samples.length} samples',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the target dot at current position
  Widget _buildTargetDot() {
    final screenSize = MediaQuery.of(context).size;
    final target = _targetPositions[_currentDotIndex];

    // Convert normalized position to screen coordinates
    // Account for safe areas and app bar
    final safeArea = MediaQuery.of(context).padding;
    final appBarHeight = AppBar().preferredSize.height;
    final availableHeight = screenSize.height -
        safeArea.top -
        appBarHeight -
        150; // 150 for bottom controls

    final dotX = target.dx * screenSize.width;
    final dotY = safeArea.top + appBarHeight + target.dy * availableHeight;

    return Positioned(
      left: dotX - 25,
      top: dotY - 25,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 15,
            height: 15,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  /// Build overlay showing detected eye landmarks
  Widget _buildLandmarksOverlay() {
    return Positioned(
      top: 100,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('👁 Face Detected',
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold)),
            Text(
              'L Eye: (${_latestLandmarks!.leftEyeCenter.dx.toStringAsFixed(2)}, ${_latestLandmarks!.leftEyeCenter.dy.toStringAsFixed(2)})',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'R Eye: (${_latestLandmarks!.rightEyeCenter.dx.toStringAsFixed(2)}, ${_latestLandmarks!.rightEyeCenter.dy.toStringAsFixed(2)})',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Head: X=${_latestLandmarks!.headEulerAngleX?.toStringAsFixed(1) ?? "?"}, Y=${_latestLandmarks!.headEulerAngleY?.toStringAsFixed(1) ?? "?"}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

/// Camera preview widget
class CameraPreview extends StatelessWidget {
  final CameraController cameraController;

  const CameraPreview({required this.cameraController, super.key});

  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Transform.scale(
      scaleX: -1, // Mirror the front camera
      child: CameraPreview2(controller: cameraController),
    );
  }
}

class CameraPreview2 extends StatelessWidget {
  final CameraController controller;

  const CameraPreview2({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return controller.buildPreview();
  }
}
