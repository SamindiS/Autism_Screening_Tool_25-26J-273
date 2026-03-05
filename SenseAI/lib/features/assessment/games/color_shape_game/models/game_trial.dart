/// Trial data for clinical DCCS game
/// Captures all ASD-relevant metrics for ML training
class DccsTrial {
  final int trialNumber;
  final String phase; // 'practice', 'pre_switch', 'post_switch', 'mixed'
  final String rule; // 'color' or 'shape'
  final String stimulusColor; // 'red' or 'blue'
  final String stimulusShape; // 'circle' or 'square'
  final String correctChoice; // 'left' or 'right'
  final String childChoice; // 'left' or 'right'
  final int reactionTimeMs;
  final bool correct;
  final bool isSwitchTrial; // In mixed phase, did rule change from last trial?
  final bool isPerseverativeError; // Used old rule after switch
  final bool isPostSwitch; // Is this in post-switch phase?
  final DateTime timestamp;

  DccsTrial({
    required this.trialNumber,
    required this.phase,
    required this.rule,
    required this.stimulusColor,
    required this.stimulusShape,
    required this.correctChoice,
    required this.childChoice,
    required this.reactionTimeMs,
    required this.correct,
    required this.isSwitchTrial,
    required this.isPerseverativeError,
    required this.isPostSwitch,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'trial_number': trialNumber,
      'phase': phase,
      'rule': rule,
      'stimulus_color': stimulusColor,
      'stimulus_shape': stimulusShape,
      'correct_choice': correctChoice,
      'child_choice': childChoice,
      'reaction_time_ms': reactionTimeMs,
      'correct': correct,
      'is_switch_trial': isSwitchTrial,
      'is_perseverative_error': isPerseverativeError,
      'is_post_switch': isPostSwitch,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory DccsTrial.fromJson(Map<String, dynamic> json) {
    return DccsTrial(
      trialNumber: json['trial_number'] as int,
      phase: json['phase'] as String,
      rule: json['rule'] as String,
      stimulusColor: json['stimulus_color'] as String,
      stimulusShape: json['stimulus_shape'] as String,
      correctChoice: json['correct_choice'] as String,
      childChoice: json['child_choice'] as String,
      reactionTimeMs: json['reaction_time_ms'] as int,
      correct: json['correct'] as bool,
      isSwitchTrial: json['is_switch_trial'] as bool? ?? false,
      isPerseverativeError: json['is_perseverative_error'] as bool? ?? false,
      isPostSwitch: json['is_post_switch'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Summary of DCCS game results with all ML features for ASD detection
class DccsSummary {
  final int totalTrials;
  final int completionTimeSec;
  
  // Accuracy metrics
  final double accuracyPreColor;
  final double accuracyPostShape; // KEY ASD MARKER
  final double accuracyMixed;
  final double accuracyOverall;
  
  // Reaction times
  final double avgReactionTimeMs;
  final double avgRtPreSwitchMs;
  final double avgRtPostSwitchMs;
  final double avgRtPostCorrectMs;
  
  // Switch cost (KEY ASD MARKER)
  final double switchCostMs;
  
  // Perseverative errors (MOST IMPORTANT ASD MARKER)
  final int perseverativeErrors;
  final double perseverativeRatePost;
  final int maxConsecutivePerseverations;
  final int totalRuleSwitchErrors;
  
  // RT variability (standard deviation of correct-trial RTs)
  final double rtVariability;

  // Additional
  final int longestStreak;

  DccsSummary({
    required this.totalTrials,
    required this.completionTimeSec,
    required this.accuracyPreColor,
    required this.accuracyPostShape,
    required this.accuracyMixed,
    required this.accuracyOverall,
    required this.avgReactionTimeMs,
    required this.avgRtPreSwitchMs,
    required this.avgRtPostSwitchMs,
    required this.avgRtPostCorrectMs,
    required this.switchCostMs,
    required this.perseverativeErrors,
    required this.perseverativeRatePost,
    required this.maxConsecutivePerseverations,
    required this.totalRuleSwitchErrors,
    this.rtVariability = 0,
    required this.longestStreak,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_trials': totalTrials,
      'completion_time_sec': completionTimeSec,
      'accuracy_pre_color': accuracyPreColor,
      'accuracy_post_shape': accuracyPostShape,
      'accuracy_mixed': accuracyMixed,
      'accuracy_overall': accuracyOverall,
      'avg_reaction_time_ms': avgReactionTimeMs,
      'avg_rt_pre_switch_ms': avgRtPreSwitchMs,
      'avg_rt_post_switch_ms': avgRtPostSwitchMs,
      'avg_rt_post_correct_ms': avgRtPostCorrectMs,
      'switch_cost_ms': switchCostMs,
      'perseverative_errors': perseverativeErrors,
      'perseverative_rate_post': perseverativeRatePost,
      'max_consecutive_perseverations': maxConsecutivePerseverations,
      'total_rule_switch_errors': totalRuleSwitchErrors,
      'rt_variability': rtVariability,
      'longest_streak': longestStreak,
    };
  }

  /// Get ML features for ASD detection model
  Map<String, dynamic> get mlFeatures => {
    // PRIMARY ASD MARKERS
    'post_switch_accuracy': accuracyPostShape,
    'total_perseverative_errors': perseverativeErrors,
    'switch_cost_ms': switchCostMs,
    'perseverative_error_rate_post_switch': perseverativeRatePost,
    
    // SECONDARY MARKERS
    'avg_rt_pre_switch_ms': avgRtPreSwitchMs,
    'avg_rt_post_switch_correct_ms': avgRtPostCorrectMs,
    'number_of_consecutive_perseverations': maxConsecutivePerseverations,
    'total_rule_switch_errors': totalRuleSwitchErrors,
    
    // ADDITIONAL FEATURES
    'pre_switch_accuracy': accuracyPreColor,
    'mixed_block_accuracy': accuracyMixed,
    'longest_streak_correct': longestStreak,
    'avg_reaction_time_ms': avgReactionTimeMs,
    'rt_variability_ms': rtVariability,
  };

  /// Calculate risk level based on ASD markers
  String get riskLevel {
    if (accuracyPostShape < 60 || perseverativeErrors > 4) {
      return 'HIGH';
    } else if (accuracyPostShape < 75 || perseverativeErrors > 2) {
      return 'MODERATE';
    }
    return 'LOW';
  }
}
