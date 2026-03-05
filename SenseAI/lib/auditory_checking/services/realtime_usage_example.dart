/// Example: Real-time video and audio stream processing
/// 
/// Demonstrates how to use RealtimeAnalysisService for continuous analysis

import 'dart:async';
import 'realtime_analysis_service.dart';
import 'audio_detection_service.dart';
import 'video_analysis_service.dart';

class RealtimeProcessingExample {
  final RealtimeAnalysisService _analysisService = RealtimeAnalysisService();
  final AudioDetectionService _audioService = AudioDetectionService();

  /// Example: Process live video and audio streams
  Future<void> processLiveStreams({
    required Stream<VideoFrame> videoStream,
    required Stream<List<int>> audioStream,
    required String childName,
  }) async {
    // Detect name-calling in audio stream
    final audioEvents = _audioService.detectNameCalling(
      audioStream: audioStream,
      childName: childName,
    );

    // Start real-time analysis
    _analysisService.startProcessing(
      videoStream: videoStream,
      audioStream: audioEvents,
    );

    // Subscribe to real-time updates (no UI dependency)
    _subscribeToUpdates();
  }

  /// Subscribe to all real-time metric streams
  void _subscribeToUpdates() {
    // RTN Status updates
    _analysisService.rtnStatusStream.listen((status) {
      print('RTN Status Update: ${status.name}');
      // Send to backend, store in database, etc.
    });

    // Reaction time updates
    _analysisService.reactionTimeStream.listen((time) {
      print('Reaction Time Update: ${time.toStringAsFixed(2)}s');
      // Track latency metrics
    });

    // Detected behaviors updates
    _analysisService.behaviorsStream.listen((behaviors) {
      print('Behaviors Update: ${behaviors.length} behaviors detected');
      for (final behavior in behaviors) {
        print('  - ${behavior.type.name} at ${behavior.timestamp.toStringAsFixed(2)}s (${behavior.confidence}% confidence)');
      }
    });

    // Confidence score updates
    _analysisService.confidenceStream.listen((confidence) {
      print('Confidence Update: $confidence%');
    });

    // Complete metrics updates (all data together)
    _analysisService.metricsStream.listen((metrics) {
      print('\n=== Complete RTN Metrics ===');
      print('Status: ${metrics.rtnStatus.name}');
      print('Reaction Time: ${metrics.reactionTime.toStringAsFixed(2)}s');
      print('Confidence: ${metrics.confidenceScore}%');
      print('Behaviors: ${metrics.detectedBehaviors.length}');
      
      // Get objective observations
      final observations = metrics.getObjectiveObservations();
      print('\nObjective Observations:');
      for (final observation in observations) {
        print('  - $observation');
      }
      
      // Convert to JSON for storage/API
      final json = metrics.toJson();
      print('\nJSON Output: $json');
      
      // Store or transmit metrics (no UI interaction)
      _storeMetrics(metrics);
    });
  }

  /// Store metrics (database, API, file, etc.)
  void _storeMetrics(RTNMetrics metrics) {
    // Example: Store in database
    // await database.insert('rtn_metrics', metrics.toJson());
    
    // Example: Send to API
    // await http.post('/api/rtn-metrics', body: jsonEncode(metrics.toJson()));
    
    // Example: Write to file
    // await file.writeAsString(jsonEncode(metrics.toJson()));
    
    print('Metrics stored at ${metrics.analysisTime}');
  }

  /// Example: Process pre-recorded video with audio
  Future<void> processRecordedVideo({
    required List<VideoFrame> videoFrames,
    required List<AudioEvent> audioEvents,
  }) async {
    // Convert to streams
    final videoStream = Stream.fromIterable(videoFrames);
    final audioStream = Stream.fromIterable(audioEvents);

    // Process in real-time manner
    _analysisService.startProcessing(
      videoStream: videoStream,
      audioStream: audioStream,
    );

    // Wait for processing to complete
    await videoStream.drain();
    
    // Stop processing
    _analysisService.stopProcessing();
  }

  /// Example: Continuous monitoring with callbacks
  void setupContinuousMonitoring({
    required Function(RTNMetrics) onMetricsUpdate,
    required Function(String) onError,
  }) {
    _analysisService.metricsStream.listen(
      (metrics) => onMetricsUpdate(metrics),
      onError: (error) => onError(error.toString()),
    );
  }

  /// Cleanup
  void dispose() {
    _analysisService.dispose();
  }
}

/// Example: Generate mock video stream for testing
Stream<VideoFrame> generateMockVideoStream() async* {
  double timestamp = 0.0;
  const frameRate = 30.0;
  const duration = 30.0; // 30 seconds

  while (timestamp < duration) {
    yield VideoFrame(
      timestamp: timestamp,
      headPose: _simulateHeadPose(timestamp),
      eyeGazeDirection: _simulateEyeGaze(timestamp),
      facialLandmarks: _simulateFacialLandmarks(timestamp),
      bodyPose: _simulateBodyPose(timestamp),
    );

    timestamp += 1.0 / frameRate;
    await Future.delayed(Duration(milliseconds: (1000 / frameRate).round()));
  }
}

/// Example: Generate mock audio stream for testing
Stream<List<int>> generateMockAudioStream() async* {
  // Simulate audio chunks
  for (int i = 0; i < 300; i++) {
    yield List.generate(1600, (_) => 0); // 16kHz, 100ms chunks
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

// Mock data generators
double _simulateHeadPose(double time) {
  if (time >= 3.0 && time <= 3.5) return 45.0;
  return 0.0;
}

double _simulateEyeGaze(double time) {
  if (time >= 3.1 && time <= 3.6) return 0.8;
  return 0.2;
}

double _simulateFacialLandmarks(double time) {
  if (time >= 3.2 && time <= 3.7) return 0.6;
  return 0.1;
}

double _simulateBodyPose(double time) {
  if (time >= 3.3 && time <= 3.8) return 0.5;
  return 0.1;
}












































