/// Tracks the lifecycle status of a clinical assessment session.
enum SessionStatus {
  /// The session is currently active or temporarily paused.
  inProgress,
  
  /// The session successfully concluded and data was captured.
  completed,
  
  /// The session was prematurely terminated due to technical issues or child non-compliance.
  aborted;

  /// Serializes the status to a SQLite/API compatible string.
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

  /// Deserializes a string into a [SessionStatus]. Defaults to [inProgress].
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

/// Core data model representing a single clinical assessment block.
/// 
/// An AssessmentSession binds a specific [childId] to an assessment module
/// (e.g., 'frog_jump', 'color_shape'). It tracks temporal data, status, clinician observations,
/// and aggregates various result components including raw game metrics, questionnaires,
/// and AI-generated risk evaluations.
class AssessmentSession {
  /// Unique identifier (UUID or backend-generated).
  final String id;
  
  /// The foreign key linking this session to a [Child] profile.
  final String childId;
  
  /// Identify the specific module run (e.g. 'ai_doctor_bot', 'frog_jump', 'color_shape').
  final String sessionType;
  
  /// Expected or targeted age cohort for the session (e.g., '2-3.5').
  final String? ageGroup;
  
  /// The current state of the session in its lifecycle.
  final SessionStatus status;
  
  /// Subjective observations entered down by the clinician managing the session.
  final String? clinicianNote;
  
  /// When the assessment officially started.
  final DateTime startTime;
  
  /// When the assessment concluded (used to calculate duration).
  final DateTime? endTime;
  
  /// General behavioral metrics recorded throughout the session.
  final Map<String, dynamic>? metrics;
  
  /// Raw granular data and summary statistics from interactive modules (maps to [GameResults]).
  final Map<String, dynamic>? gameResults;
  
  /// Answers to standard clinical questionnaires (e.g., M-CHAT-R).
  final Map<String, dynamic>? questionnaireResults;
  
  /// Clinician reflections or post-session standardized scoring.
  final Map<String, dynamic>? reflectionResults;
  
  /// Aggregate or isolated ML-generated risk score (0-100 scale).
  final double? riskScore;
  
  /// Interpretative risk category ('low', 'moderate', 'high').
  final String? riskLevel;
  
  /// Timestamp indicating when the local database originally logged the session creation.
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

  /// Quick check if the session was prematurely aborted.
  bool get isAborted => status == SessionStatus.aborted;
  
  /// Quick check if the session successfully concluded.
  bool get isCompleted => status == SessionStatus.completed;

  /// Serializes the session properties to a JSON map.
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

  /// Instantiates an [AssessmentSession] from a stored or fetched JSON map.
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

