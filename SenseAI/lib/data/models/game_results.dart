/// Holds the consolidated results of a distinct clinical game or module.
/// 
/// Captures both high-level summaries (accuracy, speed, error rates) and
/// raw granular data ([TrialData]), which are essential for ML inference and 
/// behavioral analysis in ASD screening.
class GameResults {
  /// The type of game/module executed (e.g., 'frog_jump', 'color_shape').
  final String gameType;
  
  /// The total number of trials presented during the game.
  final int totalTrials;
  
  /// The total number of successfully completed trials.
  final int correctTrials;
  
  /// The percentage of correct trials (usually 0.0 to 1.0).
  final double accuracy;
  
  /// The mean reaction time across all trials (in milliseconds).
  final int averageReactionTime;
  
  /// The temporal cost associated with switching rules (applicable in set-shifting games).
  final int? switchCost;
  
  /// The count of perseverative errors (failing to switch rules when prompted).
  final int? perseverativeErrors;
  
  /// Total duration the child took to complete the module (in milliseconds).
  final int completionTime;
  
  /// A chronological list of granular data for each individual trial.
  final List<TrialData> trials;
  
  /// Flexible map for module-specific metrics not captured by standard fields.
  final Map<String, dynamic>? additionalMetrics;
  
  /// Abstract extracted features explicitly formatted for ML model inference.
  final Map<String, dynamic>? mlFeatures;
  
  /// The generated risk score from the ML model specifically for this game (if isolated).
  final double? riskScore;
  
  /// The categorical risk level assigned ('low', 'moderate', 'high').
  final String? riskLevel;
  
  /// The full structured JSON response from the underlying ML prediction service.
  final Map<String, dynamic>? mlPrediction;

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

  /// Serializes the game results to a JSON map for storage or network transport.
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

  /// Deserializes a JSON map into a [GameResults] instance.
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
  
  /// Creates a copy with updated (often ML prediction) data.
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

/// Represents the granular behavioral data captured during a single game trial.
/// 
/// Used to precisely monitor reaction times, correctness, and specifically
/// clinical indicators like perseverative errors across cognitive shifts.
class TrialData {
  /// The chronological index of the trial within the session.
  final int trialNumber;
  
  /// The visual or auditory prompt presented (e.g., 'red_circle').
  final String? stimulus;
  
  /// The active cognitive rule during the trial (e.g., 'match_by_color').
  final String? rule;
  
  /// The deliberate action or choice taken by the child.
  final String? response;
  
  /// Whether the child's response correctly aligned with the active rule.
  final bool correct;
  
  /// The time elapsed (in ms) between stimulus presentation and response.
  final int reactionTime;
  
  /// Exact timestamp of the interaction for time-series analysis.
  final DateTime timestamp;
  
  /// Indicates if this trial occurred immediately after a rule switch.
  final bool? isPostSwitch;
  
  /// Indicates if an error occurred due to stubbornly following a previous rule.
  final bool? isPerseverativeError;
  
  /// Extended arbitrary data specific to unique game types.
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

  /// Serializes the trial data into a JSON map.
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

  /// Deserializes a JSON map into [TrialData]. Note: SQLite stores booleans as 1/0.
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
