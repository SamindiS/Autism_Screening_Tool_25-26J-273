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
}

