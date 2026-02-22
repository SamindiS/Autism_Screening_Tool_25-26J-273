/// Trial data for Frog Jump (Go/No-Go) game
/// Captures all ASD-relevant metrics for ML training
/// 
/// Go trials: Happy Frog (child should tap)
/// No-Go trials: Sleepy Turtle (child should NOT tap)
class GameTrial {
  final int trialNumber;
  final String stimulus; // 'happy' or 'sleepy'
  final String response; // 'tap', 'no_tap', 'wrong_tap', 'miss'
  final bool correct;
  final int reactionTime;
  final DateTime timestamp;
  final String phase; // 'practice' or 'main'

  GameTrial({
    required this.trialNumber,
    required this.stimulus,
    required this.response,
    required this.correct,
    required this.reactionTime,
    required this.timestamp,
    required this.phase,
  });

  Map<String, dynamic> toJson() {
    return {
      'trial_number': trialNumber,
      'stimulus': stimulus,
      'response': response,
      'correct': correct,
      'reaction_time': reactionTime,
      'timestamp': timestamp.toIso8601String(),
      'phase': phase,
    };
  }
  
  factory GameTrial.fromJson(Map<String, dynamic> json) {
    return GameTrial(
      trialNumber: json['trial_number'] as int,
      stimulus: json['stimulus'] as String,
      response: json['response'] as String,
      correct: json['correct'] as bool,
      reactionTime: json['reaction_time'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      phase: json['phase'] as String,
    );
  }
}

/// Enhanced trial data for Frog Jump with ASD-relevant fields
/// Used for ML feature extraction
class FrogJumpTrial {
  final int trialNumber;
  final String phase; // 'practice' or 'main'
  final String stimulusType; // 'happy' (Go) or 'sleepy' (No-Go)
  final String response; // 'tap', 'no_tap', 'wrong_tap', 'miss'
  final int reactionTimeMs;
  final bool correct;
  final DateTime timestamp;
  
  // Computed properties for ML
  final bool isGoTrial; // Happy frog = should tap
  final bool isCommissionError; // Tapped on No-Go trial (inhibitory failure)
  final bool isOmissionError; // Didn't tap on Go trial
  final bool isAnticipatory; // RT < 200ms (impulsive)
  final bool isLateResponse; // RT > 2000ms (attention lapse)

  FrogJumpTrial({
    required this.trialNumber,
    required this.phase,
    required this.stimulusType,
    required this.response,
    required this.reactionTimeMs,
    required this.correct,
    required this.timestamp,
  }) : 
    isGoTrial = stimulusType == 'happy',
    isCommissionError = stimulusType == 'sleepy' && 
                        (response == 'tap' || response == 'wrong_tap'),
    isOmissionError = stimulusType == 'happy' && 
                      (response == 'miss' || response == 'no_tap'),
    isAnticipatory = reactionTimeMs < 200 && reactionTimeMs > 0,
    isLateResponse = reactionTimeMs > 2000;

  Map<String, dynamic> toJson() {
    return {
      'trial_number': trialNumber,
      'phase': phase,
      'stimulus_type': stimulusType,
      'response': response,
      'reaction_time_ms': reactionTimeMs,
      'correct': correct,
      'timestamp': timestamp.toIso8601String(),
      'is_go_trial': isGoTrial,
      'is_commission_error': isCommissionError,
      'is_omission_error': isOmissionError,
      'is_anticipatory': isAnticipatory,
      'is_late_response': isLateResponse,
    };
  }

  factory FrogJumpTrial.fromJson(Map<String, dynamic> json) {
    return FrogJumpTrial(
      trialNumber: json['trial_number'] as int,
      phase: json['phase'] as String,
      stimulusType: json['stimulus_type'] as String,
      response: json['response'] as String,
      reactionTimeMs: json['reaction_time_ms'] as int,
      correct: json['correct'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convert from basic GameTrial to FrogJumpTrial
  factory FrogJumpTrial.fromGameTrial(GameTrial trial) {
    return FrogJumpTrial(
      trialNumber: trial.trialNumber,
      phase: trial.phase,
      stimulusType: trial.stimulus,
      response: trial.response,
      reactionTimeMs: trial.reactionTime,
      correct: trial.correct,
      timestamp: trial.timestamp,
    );
  }
}
