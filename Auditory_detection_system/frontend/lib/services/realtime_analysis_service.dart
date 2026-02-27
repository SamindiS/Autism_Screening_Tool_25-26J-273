/// Real-time video and audio stream analysis service
/// 
/// Processes continuous streams to detect auditory stimuli and behavioral responses
/// Updates RTN metrics in real-time without UI dependencies

import 'dart:async';
import 'video_analysis_service.dart';

class RealtimeAnalysisService {
  final VideoAnalysisService _analysisService = VideoAnalysisService();
  
  // Stream controllers for real-time updates
  final _rtnStatusController = StreamController<RTNStatus>.broadcast();
  final _reactionTimeController = StreamController<double>.broadcast();
  final _behaviorsController = StreamController<List<DetectedBehavior>>.broadcast();
  final _confidenceController = StreamController<int>.broadcast();
  final _metricsController = StreamController<RTNMetrics>.broadcast();

  // Internal state
  bool _isProcessing = false;
  Timer? _processingTimer;
  final List<VideoFrame> _frameBuffer = [];
  final List<AudioEvent> _audioEvents = [];
  double _currentTime = 0.0;
  
  // Analysis window
  static const double analysisWindowSeconds = 5.0;
  static const double frameInterval = 1.0 / 30.0; // 30 FPS

  /// Streams for real-time updates
  Stream<RTNStatus> get rtnStatusStream => _rtnStatusController.stream;
  Stream<double> get reactionTimeStream => _reactionTimeController.stream;
  Stream<List<DetectedBehavior>> get behaviorsStream => _behaviorsController.stream;
  Stream<int> get confidenceStream => _confidenceController.stream;
  Stream<RTNMetrics> get metricsStream => _metricsController.stream;

  /// Start processing video and audio streams
  void startProcessing({
    required Stream<VideoFrame> videoStream,
    required Stream<AudioEvent> audioStream,
  }) {
    if (_isProcessing) {
      stopProcessing();
    }

    _isProcessing = true;
    _currentTime = 0.0;
    _frameBuffer.clear();
    _audioEvents.clear();

    // Subscribe to video stream
    videoStream.listen(
      (frame) => _processVideoFrame(frame),
      onError: (error) => _handleError('Video stream error: $error'),
      onDone: () => stopProcessing(),
    );

    // Subscribe to audio stream
    audioStream.listen(
      (audioEvent) => _processAudioEvent(audioEvent),
      onError: (error) => _handleError('Audio stream error: $error'),
    );

    // Start continuous analysis timer
    _processingTimer = Timer.periodic(
      const Duration(milliseconds: 100), // Update every 100ms
      (_) => _performContinuousAnalysis(),
    );
  }

  /// Process incoming video frame
  void _processVideoFrame(VideoFrame frame) {
    _frameBuffer.add(frame);
    _currentTime = frame.timestamp;

    // Maintain buffer size (keep last 5 seconds)
    final cutoffTime = _currentTime - analysisWindowSeconds;
    _frameBuffer.removeWhere((f) => f.timestamp < cutoffTime);
  }

  /// Process incoming audio event (name calling detection)
  void _processAudioEvent(AudioEvent event) {
    if (event.type == AudioEventType.nameCall) {
      _audioEvents.add(event);
      
      // Immediately trigger analysis for this stimulus
      _analyzeStimulusResponse(event.timestamp);
    }
  }

  /// Analyze response to a specific auditory stimulus
  Future<void> _analyzeStimulusResponse(double stimulusTime) async {
    // Get frames after stimulus
    final postStimulusFrames = _frameBuffer.where((frame) {
      return frame.timestamp >= stimulusTime && 
             frame.timestamp <= stimulusTime + analysisWindowSeconds;
    }).toList();

    if (postStimulusFrames.isEmpty) {
      return;
    }

    // Detect behaviors
    final behaviors = _detectBehaviorsInFrames(postStimulusFrames);
    
    // Calculate reaction time
    final reactionTime = _calculateReactionTime(
      stimulusTime: stimulusTime,
      behaviors: behaviors,
    );

    // Classify response
    final rtnStatus = _classifyResponse(
      reactionTime: reactionTime,
      behaviors: behaviors,
    );

    // Calculate confidence
    final confidence = _calculateConfidence(
      behaviors: behaviors,
      reactionTime: reactionTime,
      rtnStatus: rtnStatus,
    );

    // Emit real-time updates
    _rtnStatusController.add(rtnStatus);
    _reactionTimeController.add(reactionTime);
    _behaviorsController.add(behaviors);
    _confidenceController.add(confidence);

    // Emit complete metrics
    final metrics = RTNMetrics(
      rtnStatus: rtnStatus,
      reactionTime: reactionTime,
      detectedBehaviors: behaviors,
      confidenceScore: confidence,
      stimulusTime: stimulusTime,
      analysisTime: DateTime.now(),
    );
    _metricsController.add(metrics);
  }

  /// Continuous analysis of current state
  void _performContinuousAnalysis() {
    if (!_isProcessing || _audioEvents.isEmpty) {
      return;
    }

    // Analyze most recent stimulus
    final latestStimulus = _audioEvents.last;
    final timeSinceStimulus = _currentTime - latestStimulus.timestamp;

    // Only analyze if within analysis window
    if (timeSinceStimulus <= analysisWindowSeconds) {
      _analyzeStimulusResponse(latestStimulus.timestamp);
    }
  }

  /// Detect behaviors in video frames
  List<DetectedBehavior> _detectBehaviorsInFrames(List<VideoFrame> frames) {
    final List<DetectedBehavior> behaviors = [];

    for (int i = 1; i < frames.length; i++) {
      final current = frames[i];
      final previous = frames[i - 1];

      // Head turning detection
      final headAngleChange = (current.headPose - previous.headPose).abs();
      if (headAngleChange > 15.0) {
        final confidence = (headAngleChange / 90.0 * 100).clamp(0, 100).toInt();
        behaviors.add(DetectedBehavior(
          type: BehaviorType.headTurning,
          timestamp: current.timestamp,
          confidence: confidence,
        ));
      }

      // Eye gaze change detection
      final gazeChange = (current.eyeGazeDirection - previous.eyeGazeDirection).abs();
      if (gazeChange > 0.3) {
        final confidence = (gazeChange * 100).clamp(0, 100).toInt();
        behaviors.add(DetectedBehavior(
          type: BehaviorType.eyeGazeChange,
          timestamp: current.timestamp,
          confidence: confidence,
        ));
      }

      // Facial movement detection
      final facialChange = (current.facialLandmarks - previous.facialLandmarks).abs();
      if (facialChange > 0.2) {
        final confidence = (facialChange * 100).clamp(0, 100).toInt();
        behaviors.add(DetectedBehavior(
          type: BehaviorType.facialMovement,
          timestamp: current.timestamp,
          confidence: confidence,
        ));
      }

      // Body movement detection
      final bodyChange = (current.bodyPose - previous.bodyPose).abs();
      if (bodyChange > 0.25) {
        final confidence = (bodyChange * 100).clamp(0, 100).toInt();
        behaviors.add(DetectedBehavior(
          type: BehaviorType.bodyMovement,
          timestamp: current.timestamp,
          confidence: confidence,
        ));
      }
    }

    return behaviors;
  }

  /// Calculate reaction time from stimulus to first behavior
  double _calculateReactionTime({
    required double stimulusTime,
    required List<DetectedBehavior> behaviors,
  }) {
    if (behaviors.isEmpty) {
      return 0.0;
    }

    final earliestBehavior = behaviors.reduce((a, b) {
      return a.timestamp < b.timestamp ? a : b;
    });

    return (earliestBehavior.timestamp - stimulusTime).clamp(0.0, 10.0);
  }

  /// Classify response type
  RTNStatus _classifyResponse({
    required double reactionTime,
    required List<DetectedBehavior> behaviors,
  }) {
    if (behaviors.isEmpty) {
      return RTNStatus.noResponse;
    }

    if (reactionTime <= 0.5) {
      return RTNStatus.immediateResponse;
    } else if (reactionTime <= 2.0) {
      return RTNStatus.delayedResponse;
    } else {
      final hasSignificantBehavior = behaviors.any((b) => b.confidence >= 30);
      return hasSignificantBehavior 
        ? RTNStatus.partialResponse 
        : RTNStatus.noResponse;
    }
  }

  /// Calculate confidence score
  int _calculateConfidence({
    required List<DetectedBehavior> behaviors,
    required double reactionTime,
    required RTNStatus rtnStatus,
  }) {
    if (behaviors.isEmpty) {
      return 0;
    }

    // Behavior quality score
    double behaviorScore = 0.0;
    for (final behavior in behaviors) {
      behaviorScore += behavior.confidence / 100.0;
    }
    behaviorScore = (behaviorScore / behaviors.length) * 50;

    // Reaction time score
    double timeScore = 0.0;
    if (reactionTime > 0 && reactionTime <= 0.5) {
      timeScore = 30.0;
    } else if (reactionTime <= 2.0) {
      timeScore = 20.0;
    } else {
      timeScore = 10.0;
    }

    // Status bonus
    double statusBonus = 0.0;
    switch (rtnStatus) {
      case RTNStatus.immediateResponse:
        statusBonus = 20.0;
        break;
      case RTNStatus.delayedResponse:
        statusBonus = 15.0;
        break;
      case RTNStatus.partialResponse:
        statusBonus = 10.0;
        break;
      case RTNStatus.noResponse:
        statusBonus = 0.0;
        break;
    }

    return (behaviorScore + timeScore + statusBonus).clamp(0, 100).toInt();
  }

  /// Stop processing streams
  void stopProcessing() {
    _isProcessing = false;
    _processingTimer?.cancel();
    _processingTimer = null;
  }

  /// Handle errors
  void _handleError(String error) {
    print('RealtimeAnalysisService Error: $error');
    // In production, emit error through error stream
  }

  /// Dispose resources
  void dispose() {
    stopProcessing();
    _rtnStatusController.close();
    _reactionTimeController.close();
    _behaviorsController.close();
    _confidenceController.close();
    _metricsController.close();
  }
}

// ============================================================================
// Data Models for Real-time Processing
// ============================================================================

/// Audio event from stream
class AudioEvent {
  final AudioEventType type;
  final double timestamp;
  final double confidence; // Detection confidence 0-1

  AudioEvent({
    required this.type,
    required this.timestamp,
    this.confidence = 1.0,
  });
}

/// Types of audio events
enum AudioEventType {
  nameCall,    // Child's name was called
  otherSound,  // Other audio detected
}

/// Complete RTN metrics snapshot
class RTNMetrics {
  final RTNStatus rtnStatus;
  final double reactionTime;
  final List<DetectedBehavior> detectedBehaviors;
  final int confidenceScore;
  final double stimulusTime;
  final DateTime analysisTime;

  RTNMetrics({
    required this.rtnStatus,
    required this.reactionTime,
    required this.detectedBehaviors,
    required this.confidenceScore,
    required this.stimulusTime,
    required this.analysisTime,
  });

  /// Convert to JSON for storage/transmission
  Map<String, dynamic> toJson() {
    return {
      'RTN_Status': rtnStatus.name,
      'Reaction_Time': reactionTime,
      'Detected_Behaviors': detectedBehaviors.map((b) => {
        'type': b.type.name,
        'timestamp': b.timestamp,
        'confidence': b.confidence,
      }).toList(),
      'Confidence_Score': confidenceScore,
      'Stimulus_Time': stimulusTime,
      'Analysis_Time': analysisTime.toIso8601String(),
    };
  }

  /// Get objective behavioral observations (no interpretation)
  List<String> getObjectiveObservations() {
    final observations = <String>[];

    if (detectedBehaviors.isEmpty) {
      observations.add('No observable behavioral changes detected within ${reactionTime.toStringAsFixed(2)} seconds after auditory stimulus.');
      return observations;
    }

    observations.add('First observable behavioral change detected ${reactionTime.toStringAsFixed(2)} seconds after auditory stimulus.');

    for (final behavior in detectedBehaviors) {
      switch (behavior.type) {
        case BehaviorType.headTurning:
          observations.add('Head orientation change observed at ${behavior.timestamp.toStringAsFixed(2)}s (confidence: ${behavior.confidence}%).');
          break;
        case BehaviorType.eyeGazeChange:
          observations.add('Eye gaze direction change observed at ${behavior.timestamp.toStringAsFixed(2)}s (confidence: ${behavior.confidence}%).');
          break;
        case BehaviorType.facialMovement:
          observations.add('Facial feature movement observed at ${behavior.timestamp.toStringAsFixed(2)}s (confidence: ${behavior.confidence}%).');
          break;
        case BehaviorType.bodyMovement:
          observations.add('Body position change observed at ${behavior.timestamp.toStringAsFixed(2)}s (confidence: ${behavior.confidence}%).');
          break;
      }
    }

    observations.add('Overall response classification: ${rtnStatus.name}.');
    observations.add('Analysis confidence: ${confidenceScore}%.');

    return observations;
  }
}












































