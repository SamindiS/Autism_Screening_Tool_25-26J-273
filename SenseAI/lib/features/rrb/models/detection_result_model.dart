/// RRB Detection Result Model
class RrbDetectionResult {
  final String id;
  final String videoId;
  final bool detected;
  final String? primaryBehavior;
  final double? confidence;
  final List<RrbBehaviorDetection> behaviors;
  final RrbVideoMetadata metadata;
  final DateTime timestamp;

  RrbDetectionResult({
    required this.id,
    required this.videoId,
    required this.detected,
    this.primaryBehavior,
    this.confidence,
    required this.behaviors,
    required this.metadata,
    required this.timestamp,
  });

  factory RrbDetectionResult.fromJson(Map<String, dynamic> json) {
    var detection = json['detection'] ?? {};
    var metadata = json['metadata'] ?? {};

    return RrbDetectionResult(
      id: json['id'] ?? '',
      videoId: json['videoId'] ?? '',
      detected: detection['detected'] ?? false,
      primaryBehavior: detection['primary_behavior'],
      confidence: detection['confidence']?.toDouble(),
      behaviors: (detection['behaviors'] as List<dynamic>?)
              ?.map((b) => RrbBehaviorDetection.fromJson(b))
              .toList() ??
          [],
      metadata: RrbVideoMetadata.fromJson(metadata),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoId': videoId,
      'detection': {
        'detected': detected,
        'primary_behavior': primaryBehavior,
        'confidence': confidence,
        'behaviors': behaviors.map((b) => b.toJson()).toList(),
      },
      'metadata': metadata.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Behavior Detection Model
class RrbBehaviorDetection {
  final String behavior;
  final double confidence;
  final int occurrences;
  final double totalDuration;

  RrbBehaviorDetection({
    required this.behavior,
    required this.confidence,
    required this.occurrences,
    required this.totalDuration,
  });

  factory RrbBehaviorDetection.fromJson(Map<String, dynamic> json) {
    return RrbBehaviorDetection(
      behavior: json['behavior'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      occurrences: json['occurrences'] ?? 0,
      totalDuration: (json['total_duration'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'behavior': behavior,
      'confidence': confidence,
      'occurrences': occurrences,
      'total_duration': totalDuration,
    };
  }
}

/// Video Metadata Model
class RrbVideoMetadata {
  final double duration;
  final int fps;
  final int sequencesAnalyzed;

  RrbVideoMetadata({
    required this.duration,
    required this.fps,
    required this.sequencesAnalyzed,
  });

  factory RrbVideoMetadata.fromJson(Map<String, dynamic> json) {
    return RrbVideoMetadata(
      duration: (json['video_duration'] ?? 0.0).toDouble(),
      fps: json['video_fps'] ?? 30,
      sequencesAnalyzed: json['sequences_analyzed'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'video_duration': duration,
      'video_fps': fps,
      'sequences_analyzed': sequencesAnalyzed,
    };
  }
}

