class GameTrial {
  final int trialNumber;
  final String phase; // 'practice' or 'main'
  final String stimulus; // Flower emojis
  final String rule; // 'color' or 'shape'
  final String response; // 'color' or 'shape'
  final int reactionTime; // milliseconds
  final bool correct;
  final bool isPostSwitch;
  final bool isPerseverativeError;
  final DateTime timestamp;

  GameTrial({
    required this.trialNumber,
    required this.phase,
    required this.stimulus,
    required this.rule,
    required this.response,
    required this.reactionTime,
    required this.correct,
    required this.isPostSwitch,
    required this.isPerseverativeError,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'trial_number': trialNumber,
      'phase': phase,
      'stimulus': stimulus,
      'rule': rule,
      'response': response,
      'reaction_time': reactionTime,
      'correct': correct,
      'is_post_switch': isPostSwitch,
      'is_perseverative_error': isPerseverativeError,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}


