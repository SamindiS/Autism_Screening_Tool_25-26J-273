/// Example usage of VideoAnalysisService
/// 
/// This demonstrates how to use the backend service for video analysis

import 'video_analysis_service.dart';

class VideoAnalysisServiceExample {
  final VideoAnalysisService _service = VideoAnalysisService();

  /// Example: Process a video with audio triggers
  Future<void> exampleAnalysis() async {
    // Simulate video frames (in real implementation, these come from video processing)
    final videoFrames = _generateMockVideoFrames();
    
    // Simulate audio triggers (when name was called)
    final audioTriggers = [2.5, 5.0, 8.0]; // Name called at 2.5s, 5.0s, 8.0s

    // Run analysis
    final result = await _service.analyzeResponse(
      videoFrames: videoFrames,
      audioTriggers: audioTriggers,
    );

    // Output results (backend only - no UI)
    print('Analysis Result:');
    print('RTN Status: ${result.rtnStatus.name}');
    print('Reaction Time: ${result.reactionTime.toStringAsFixed(2)} seconds');
    print('Detected Behaviors: ${result.detectedBehaviors.length}');
    print('Confidence Score: ${result.confidenceScore}%');
    
    // Convert to JSON for API response
    final jsonResult = result.toJson();
    print('JSON Output: $jsonResult');
  }

  /// Generate mock video frames for testing
  List<VideoFrame> _generateMockVideoFrames() {
    final List<VideoFrame> frames = [];
    final double frameRate = 30.0; // 30 FPS
    final double duration = 10.0; // 10 seconds
    
    for (double t = 0.0; t < duration; t += 1.0 / frameRate) {
      frames.add(VideoFrame(
        timestamp: t,
        headPose: _simulateHeadPose(t),
        eyeGazeDirection: _simulateEyeGaze(t),
        facialLandmarks: _simulateFacialLandmarks(t),
        bodyPose: _simulateBodyPose(t),
      ));
    }
    
    return frames;
  }

  // Mock data generators
  double _simulateHeadPose(double time) {
    // Simulate head turning at 3.0 seconds (response to trigger at 2.5s)
    if (time >= 3.0 && time <= 3.5) {
      return 45.0; // Head turned
    }
    return 0.0; // Neutral position
  }

  double _simulateEyeGaze(double time) {
    // Simulate eye movement at 3.1 seconds
    if (time >= 3.1 && time <= 3.6) {
      return 0.8; // Eye gaze changed
    }
    return 0.2; // Neutral gaze
  }

  double _simulateFacialLandmarks(double time) {
    // Simulate facial movement at 3.2 seconds
    if (time >= 3.2 && time <= 3.7) {
      return 0.6; // Facial expression changed
    }
    return 0.1; // Neutral expression
  }

  double _simulateBodyPose(double time) {
    // Simulate body movement at 3.3 seconds
    if (time >= 3.3 && time <= 3.8) {
      return 0.5; // Body moved
    }
    return 0.1; // Neutral pose
  }
}












































