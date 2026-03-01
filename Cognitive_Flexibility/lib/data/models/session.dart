enum SessionStatus {
  inProgress,
  completed,
  aborted;

  String toJson() {
    switch (this) {
      case SessionStatus.inProgress:
        return 'in_progress';
      case SessionStatus.completed:
        return 'completed';
      case SessionStatus.aborted:
        return 'aborted';
    }
  }

  static SessionStatus fromJson(String? value) {
    switch (value) {
      case 'completed':
        return SessionStatus.completed;
      case 'aborted':
        return SessionStatus.aborted;
      default:
        return SessionStatus.inProgress;
    }
  }
}

class AssessmentSession {
  final String id;
  final String childId;
  final String sessionType; // 'ai_doctor_bot', 'frog_jump', 'color_shape'
  final String? ageGroup;
  final SessionStatus status;
  final String? clinicianNote;
  final DateTime startTime;
  final DateTime? endTime;
  final Map<String, dynamic>? metrics;
  final Map<String, dynamic>? gameResults;
  final Map<String, dynamic>? questionnaireResults;
  final Map<String, dynamic>? reflectionResults;
  final double? riskScore;
  final String? riskLevel; // 'low', 'moderate', 'high'
  final DateTime createdAt;

  AssessmentSession({
    required this.id,
    required this.childId,
    required this.sessionType,
    this.ageGroup,
    this.status = SessionStatus.inProgress,
    this.clinicianNote,
    required this.startTime,
    this.endTime,
    this.metrics,
    this.gameResults,
    this.questionnaireResults,
    this.reflectionResults,
    this.riskScore,
    this.riskLevel,
    required this.createdAt,
  });

  bool get isAborted => status == SessionStatus.aborted;
  bool get isCompleted => status == SessionStatus.completed;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'session_type': sessionType,
      'age_group': ageGroup,
      'status': status.toJson(),
      'clinician_note': clinicianNote,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
      'metrics': metrics,
      'game_results': gameResults,
      'questionnaire_results': questionnaireResults,
      'reflection_results': reflectionResults,
      'risk_score': riskScore,
      'risk_level': riskLevel,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory AssessmentSession.fromJson(Map<String, dynamic> json) {
    return AssessmentSession(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      sessionType: json['session_type'] as String,
      ageGroup: json['age_group'] as String?,
      status: SessionStatus.fromJson(json['status'] as String?),
      clinicianNote: json['clinician_note'] as String?,
      startTime: DateTime.fromMillisecondsSinceEpoch(json['start_time'] as int),
      endTime: json['end_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['end_time'] as int)
          : null,
      metrics: json['metrics'] as Map<String, dynamic>?,
      gameResults: json['game_results'] as Map<String, dynamic>?,
      questionnaireResults: json['questionnaire_results'] as Map<String, dynamic>?,
      reflectionResults: json['reflection_results'] as Map<String, dynamic>?,
      riskScore: json['risk_score'] != null ? (json['risk_score'] as num).toDouble() : null,
      riskLevel: json['risk_level'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
    );
  }
}

