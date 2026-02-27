/// Backend AI system for child behavioral video analysis
/// 
/// This service handles:
/// - Audio trigger detection (name calling)
/// - Video frame analysis for behavioral responses
/// - Reaction time measurement
/// - Response classification
/// - Confidence score calculation

class VideoAnalysisService {
  // Configuration
  static const double immediateResponseThreshold = 0.5; // seconds
  static const double delayedResponseThreshold = 2.0; // seconds
  static const double partialResponseThreshold = 0.3; // minimum confidence for partial

  /// Main analysis function
  /// 
  /// [videoFrames] - List of video frames with timestamps
  /// [audioTriggers] - List of timestamps when name was called
  /// 
  /// Returns: AnalysisResult with RTN status, reaction time, behaviors, and confidence
  Future<AnalysisResult> analyzeResponse({
    required List<VideoFrame> videoFrames,
    required List<double> audioTriggers,
  }) async {
    if (audioTriggers.isEmpty) {
      return AnalysisResult(
        rtnStatus: RTNStatus.noResponse,
        reactionTime: 0.0,
        detectedBehaviors: [],
        confidenceScore: 0,
      );
    }

    // Process each audio trigger
    final List<TriggerAnalysis> triggerAnalyses = [];
    
    for (final triggerTime in audioTriggers) {
      final analysis = _analyzeTriggerResponse(
        videoFrames: videoFrames,
        triggerTime: triggerTime,
      );
      triggerAnalyses.add(analysis);
    }

    // Aggregate results from all triggers
    return _aggregateResults(triggerAnalyses);
  }

  /// Analyzes response to a single audio trigger
  AnalysisResult _analyzeTriggerResponse({
    required List<VideoFrame> videoFrames,
    required double triggerTime,
  }) {
    // Find frames after trigger
    final postTriggerFrames = videoFrames.where((frame) {
      return frame.timestamp >= triggerTime && 
             frame.timestamp <= triggerTime + 5.0; // Analyze 5 seconds after trigger
    }).toList();

    if (postTriggerFrames.isEmpty) {
      return AnalysisResult(
        rtnStatus: RTNStatus.noResponse,
        reactionTime: 0.0,
        detectedBehaviors: [],
        confidenceScore: 0,
      );
    }

    // Detect behaviors in post-trigger frames
    final detectedBehaviors = _detectBehaviors(postTriggerFrames);
    
    // Calculate reaction time
    final reactionTime = _calculateReactionTime(
      postTriggerFrames: postTriggerFrames,
      triggerTime: triggerTime,
      behaviors: detectedBehaviors,
    );

    // Classify response type
    final rtnStatus = _classifyResponse(
      reactionTime: reactionTime,
      behaviors: detectedBehaviors,
    );

    // Calculate confidence score
    final confidenceScore = _calculateConfidence(
      behaviors: detectedBehaviors,
      reactionTime: reactionTime,
      rtnStatus: rtnStatus,
    );

    return AnalysisResult(
      rtnStatus: rtnStatus,
      reactionTime: reactionTime,
      detectedBehaviors: detectedBehaviors,
      confidenceScore: confidenceScore,
    );
  }

  /// Detects behavioral responses in video frames
  List<DetectedBehavior> _detectBehaviors(List<VideoFrame> frames) {
    final List<DetectedBehavior> behaviors = [];

    for (int i = 0; i < frames.length; i++) {
      final frame = frames[i];
      final previousFrame = i > 0 ? frames[i - 1] : null;

      if (previousFrame == null) continue;

      // Detect head turning
      final headTurn = _detectHeadTurn(frame, previousFrame);
      if (headTurn.detected) {
        behaviors.add(DetectedBehavior(
          type: BehaviorType.headTurning,
          timestamp: frame.timestamp,
          confidence: headTurn.confidence,
        ));
      }

      // Detect eye gaze change
      final eyeGaze = _detectEyeGazeChange(frame, previousFrame);
      if (eyeGaze.detected) {
        behaviors.add(DetectedBehavior(
          type: BehaviorType.eyeGazeChange,
          timestamp: frame.timestamp,
          confidence: eyeGaze.confidence,
        ));
      }

      // Detect facial movement
      final facialMovement = _detectFacialMovement(frame, previousFrame);
      if (facialMovement.detected) {
        behaviors.add(DetectedBehavior(
          type: BehaviorType.facialMovement,
          timestamp: frame.timestamp,
          confidence: facialMovement.confidence,
        ));
      }

      // Detect body movement
      final bodyMovement = _detectBodyMovement(frame, previousFrame);
      if (bodyMovement.detected) {
        behaviors.add(DetectedBehavior(
          type: BehaviorType.bodyMovement,
          timestamp: frame.timestamp,
          confidence: bodyMovement.confidence,
        ));
      }
    }

    return behaviors;
  }

  /// Detects head turning between frames
  DetectionResult _detectHeadTurn(VideoFrame current, VideoFrame previous) {
    // Simulate head pose analysis
    final headAngleChange = (current.headPose - previous.headPose).abs();
    final threshold = 15.0; // degrees
    
    if (headAngleChange > threshold) {
      final confidence = (headAngleChange / 90.0 * 100).clamp(0, 100).toInt();
      return DetectionResult(detected: true, confidence: confidence);
    }
    
    return DetectionResult(detected: false, confidence: 0);
  }

  /// Detects eye gaze change
  DetectionResult _detectEyeGazeChange(VideoFrame current, VideoFrame previous) {
    // Simulate eye tracking analysis
    final gazeDirectionChange = (current.eyeGazeDirection - previous.eyeGazeDirection).abs();
    final threshold = 0.3; // normalized value
    
    if (gazeDirectionChange > threshold) {
      final confidence = (gazeDirectionChange * 100).clamp(0, 100).toInt();
      return DetectionResult(detected: true, confidence: confidence);
    }
    
    return DetectionResult(detected: false, confidence: 0);
  }

  /// Detects facial movement/expression change
  DetectionResult _detectFacialMovement(VideoFrame current, VideoFrame previous) {
    // Simulate facial landmark analysis
    final facialChange = (current.facialLandmarks - previous.facialLandmarks).abs();
    final threshold = 0.2; // normalized value
    
    if (facialChange > threshold) {
      final confidence = (facialChange * 100).clamp(0, 100).toInt();
      return DetectionResult(detected: true, confidence: confidence);
    }
    
    return DetectionResult(detected: false, confidence: 0);
  }

  /// Detects body movement
  DetectionResult _detectBodyMovement(VideoFrame current, VideoFrame previous) {
    // Simulate body pose analysis
    final bodyPoseChange = (current.bodyPose - previous.bodyPose).abs();
    final threshold = 0.25; // normalized value
    
    if (bodyPoseChange > threshold) {
      final confidence = (bodyPoseChange * 100).clamp(0, 100).toInt();
      return DetectionResult(detected: true, confidence: confidence);
    }
    
    return DetectionResult(detected: false, confidence: 0);
  }

  /// Calculates reaction time from trigger to first detected behavior
  double _calculateReactionTime({
    required List<VideoFrame> postTriggerFrames,
    required double triggerTime,
    required List<DetectedBehavior> behaviors,
  }) {
    if (behaviors.isEmpty) {
      return 0.0;
    }

    // Find earliest behavior after trigger
    final earliestBehavior = behaviors.reduce((a, b) {
      return a.timestamp < b.timestamp ? a : b;
    });

    return (earliestBehavior.timestamp - triggerTime).clamp(0.0, 10.0);
  }

  /// Classifies response type based on reaction time and behaviors
  RTNStatus _classifyResponse({
    required double reactionTime,
    required List<DetectedBehavior> behaviors,
  }) {
    if (behaviors.isEmpty) {
      return RTNStatus.noResponse;
    }

    if (reactionTime <= immediateResponseThreshold) {
      return RTNStatus.immediateResponse;
    } else if (reactionTime <= delayedResponseThreshold) {
      return RTNStatus.delayedResponse;
    } else {
      // Check if there are any behaviors with sufficient confidence
      final hasSignificantBehavior = behaviors.any((b) => 
        b.confidence >= (partialResponseThreshold * 100).toInt()
      );
      
      return hasSignificantBehavior 
        ? RTNStatus.partialResponse 
        : RTNStatus.noResponse;
    }
  }

  /// Calculates confidence score based on multiple factors
  int _calculateConfidence({
    required List<DetectedBehavior> behaviors,
    required double reactionTime,
    required RTNStatus rtnStatus,
  }) {
    if (behaviors.isEmpty) {
      return 0;
    }

    // Base confidence from behavior count and quality
    double behaviorScore = 0.0;
    for (final behavior in behaviors) {
      behaviorScore += behavior.confidence / 100.0;
    }
    behaviorScore = (behaviorScore / behaviors.length) * 50; // Max 50 points

    // Reaction time score (faster = higher score)
    double timeScore = 0.0;
    if (reactionTime > 0 && reactionTime <= immediateResponseThreshold) {
      timeScore = 30.0; // Full points for immediate
    } else if (reactionTime <= delayedResponseThreshold) {
      timeScore = 20.0; // Partial points for delayed
    } else {
      timeScore = 10.0; // Minimal points for very delayed
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

    final totalScore = (behaviorScore + timeScore + statusBonus).clamp(0, 100);
    return totalScore.toInt();
  }

  /// Aggregates results from multiple trigger analyses
  AnalysisResult _aggregateResults(List<TriggerAnalysis> analyses) {
    if (analyses.isEmpty) {
      return AnalysisResult(
        rtnStatus: RTNStatus.noResponse,
        reactionTime: 0.0,
        detectedBehaviors: [],
        confidenceScore: 0,
      );
    }

    // Use the best response (highest confidence)
    analyses.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
    final bestResult = analyses.first;

    return AnalysisResult(
      rtnStatus: bestResult.rtnStatus,
      reactionTime: bestResult.reactionTime,
      detectedBehaviors: bestResult.detectedBehaviors,
      confidenceScore: bestResult.confidenceScore,
    );
  }
}

// ============================================================================
// Data Models
// ============================================================================

/// Video frame with analysis data
class VideoFrame {
  final double timestamp; // seconds from start
  final double headPose; // head angle in degrees
  final double eyeGazeDirection; // normalized 0-1
  final double facialLandmarks; // normalized facial change metric
  final double bodyPose; // normalized body pose change

  VideoFrame({
    required this.timestamp,
    required this.headPose,
    required this.eyeGazeDirection,
    required this.facialLandmarks,
    required this.bodyPose,
  });
}

/// Detected behavioral response
class DetectedBehavior {
  final BehaviorType type;
  final double timestamp;
  final int confidence; // 0-100

  DetectedBehavior({
    required this.type,
    required this.timestamp,
    required this.confidence,
  });
}

/// Types of detectable behaviors
enum BehaviorType {
  headTurning,
  eyeGazeChange,
  facialMovement,
  bodyMovement,
}

/// RTN Response Status
enum RTNStatus {
  immediateResponse,
  delayedResponse,
  partialResponse,
  noResponse,
}

/// Final analysis result
class AnalysisResult {
  final RTNStatus rtnStatus;
  final double reactionTime; // seconds
  final List<DetectedBehavior> detectedBehaviors;
  final int confidenceScore; // 0-100

  AnalysisResult({
    required this.rtnStatus,
    required this.reactionTime,
    required this.detectedBehaviors,
    required this.confidenceScore,
  });

  /// Converts to JSON for API response
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
    };
  }
}

/// Internal trigger analysis result
class TriggerAnalysis {
  final RTNStatus rtnStatus;
  final double reactionTime;
  final List<DetectedBehavior> detectedBehaviors;
  final int confidenceScore;

  TriggerAnalysis({
    required this.rtnStatus,
    required this.reactionTime,
    required this.detectedBehaviors,
    required this.confidenceScore,
  });
}

/// Detection result helper
class DetectionResult {
  final bool detected;
  final int confidence; // 0-100

  DetectionResult({
    required this.detected,
    required this.confidence,
  });
}












































