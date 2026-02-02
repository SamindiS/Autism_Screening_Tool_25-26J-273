class GameResults {
  final String gameType;
  final int totalTrials;
  final int correctTrials;
  final double accuracy;
  final int averageReactionTime;
  final int? switchCost;
  final int? perseverativeErrors;
  final int completionTime;
  final List<TrialData> trials;
  final Map<String, dynamic>? additionalMetrics;
  final Map<String, dynamic>? mlFeatures; // ML features for ASD detection
  final double? riskScore; // ML-based risk score (0-100)
  final String? riskLevel; // ML-based risk level ('low', 'moderate', 'high')
  final Map<String, dynamic>? mlPrediction; // Full ML prediction result

  GameResults({
    required this.gameType,
    required this.totalTrials,
    required this.correctTrials,
    required this.accuracy,
    required this.averageReactionTime,
    this.switchCost,
    this.perseverativeErrors,
    required this.completionTime,
    required this.trials,
    this.additionalMetrics,
    this.mlFeatures,
    this.riskScore,
    this.riskLevel,
    this.mlPrediction,
  });

  Map<String, dynamic> toJson() {
    return {
      'game_type': gameType,
      'total_trials': totalTrials,
      'correct_trials': correctTrials,
      'accuracy': accuracy,
      'average_reaction_time': averageReactionTime,
      'switch_cost': switchCost,
      'perseverative_errors': perseverativeErrors,
      'completion_time': completionTime,
      'trials': trials.map((t) => t.toJson()).toList(),
      'additional_metrics': additionalMetrics,
      'ml_features': mlFeatures,
      'risk_score': riskScore,
      'risk_level': riskLevel,
      'ml_prediction': mlPrediction,
    };
  }

  factory GameResults.fromJson(Map<String, dynamic> json) {
    return GameResults(
      gameType: json['game_type'] as String,
      totalTrials: json['total_trials'] as int,
      correctTrials: json['correct_trials'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      averageReactionTime: json['average_reaction_time'] as int,
      switchCost: json['switch_cost'] as int?,
      perseverativeErrors: json['perseverative_errors'] as int?,
      completionTime: json['completion_time'] as int,
      trials: (json['trials'] as List<dynamic>?)
              ?.map((t) => TrialData.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      additionalMetrics: json['additional_metrics'] as Map<String, dynamic>?,
      mlFeatures: json['ml_features'] as Map<String, dynamic>?,
      riskScore: (json['risk_score'] as num?)?.toDouble(),
      riskLevel: json['risk_level'] as String?,
      mlPrediction: json['ml_prediction'] as Map<String, dynamic>?,
    );
  }
  
  /// Create a copy with updated ML prediction data
  GameResults copyWith({
    String? gameType,
    int? totalTrials,
    int? correctTrials,
    double? accuracy,
    int? averageReactionTime,
    int? switchCost,
    int? perseverativeErrors,
    int? completionTime,
    List<TrialData>? trials,
    Map<String, dynamic>? additionalMetrics,
    Map<String, dynamic>? mlFeatures,
    double? riskScore,
    String? riskLevel,
    Map<String, dynamic>? mlPrediction,
  }) {
    return GameResults(
      gameType: gameType ?? this.gameType,
      totalTrials: totalTrials ?? this.totalTrials,
      correctTrials: correctTrials ?? this.correctTrials,
      accuracy: accuracy ?? this.accuracy,
      averageReactionTime: averageReactionTime ?? this.averageReactionTime,
      switchCost: switchCost ?? this.switchCost,
      perseverativeErrors: perseverativeErrors ?? this.perseverativeErrors,
      completionTime: completionTime ?? this.completionTime,
      trials: trials ?? this.trials,
      additionalMetrics: additionalMetrics ?? this.additionalMetrics,
      mlFeatures: mlFeatures ?? this.mlFeatures,
      riskScore: riskScore ?? this.riskScore,
      riskLevel: riskLevel ?? this.riskLevel,
      mlPrediction: mlPrediction ?? this.mlPrediction,
    );
  }
}

class TrialData {
  final int trialNumber;
  final String? stimulus;
  final String? rule;
  final String? response;
  final bool correct;
  final int reactionTime;
  final DateTime timestamp;
  final bool? isPostSwitch;
  final bool? isPerseverativeError;
  final Map<String, dynamic>? additionalData;

  TrialData({
    required this.trialNumber,
    this.stimulus,
    this.rule,
    this.response,
    required this.correct,
    required this.reactionTime,
    required this.timestamp,
    this.isPostSwitch,
    this.isPerseverativeError,
    this.additionalData,
  });

  Map<String, dynamic> toJson() {
    return {
      'trial_number': trialNumber,
      'stimulus': stimulus,
      'rule': rule,
      'response': response,
      'correct': correct ? 1 : 0,
      'reaction_time': reactionTime,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'is_post_switch': isPostSwitch,
      'is_perseverative_error': isPerseverativeError,
      'additional_data': additionalData,
    };
  }

  factory TrialData.fromJson(Map<String, dynamic> json) {
    return TrialData(
      trialNumber: json['trial_number'] as int,
      stimulus: json['stimulus'] as String?,
      rule: json['rule'] as String?,
      response: json['response'] as String?,
      correct: (json['correct'] as int? ?? 0) == 1,
      reactionTime: json['reaction_time'] as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      isPostSwitch: json['is_post_switch'] as bool?,
      isPerseverativeError: json['is_perseverative_error'] as bool?,
      additionalData: json['additional_data'] as Map<String, dynamic>?,
    );
  }
}
