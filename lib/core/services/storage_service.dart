import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';

class StorageService {
  // Now using API service - local database kept for backward compatibility if needed
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'senseai.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Keep tables for potential local caching/offline support
    await db.execute('''
      CREATE TABLE IF NOT EXISTS children (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        date_of_birth INTEGER NOT NULL,
        gender TEXT NOT NULL,
        language TEXT NOT NULL,
        age REAL NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sessions (
        id TEXT PRIMARY KEY,
        child_id TEXT NOT NULL,
        session_type TEXT NOT NULL,
        age_group TEXT,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        metrics TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (child_id) REFERENCES children (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS trials (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        trial_number INTEGER NOT NULL,
        stimulus TEXT,
        response TEXT,
        reaction_time INTEGER,
        correct INTEGER,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (session_id) REFERENCES sessions (id)
      )
    ''');
  }

  // Child operations - Now using API Service
  static Future<void> saveChild({
    String? id, // Optional - backend generates UUID
    required String name,
    required DateTime dateOfBirth,
    required String gender,
    required String language,
    required double age,
    String? hospitalId,
  }) async {
    // Call API service instead of local database
    // Backend generates the ID, so we ignore the id parameter
    await ApiService.createChild(
      name: name,
      dateOfBirth: dateOfBirth,
      gender: gender,
      language: language,
      hospitalId: hospitalId,
    );
  }

  static Future<List<Map<String, dynamic>>> getAllChildren() async {
    // Call API service
    final children = await ApiService.getAllChildren();
    // Convert backend format to app format
    return children.map((child) => {
      'id': child['id'],
      'name': child['name'],
      'date_of_birth': child['date_of_birth'],
      'gender': child['gender'],
      'language': child['language'],
      'age': child['age'],
      'created_at': child['created_at'],
      'hospital_id': child['hospital_id'],
    }).toList();
  }

  static Future<Map<String, dynamic>?> getChild(String id) async {
    try {
      final child = await ApiService.getChild(id);
      return {
        'id': child['id'],
        'name': child['name'],
        'date_of_birth': child['date_of_birth'],
        'gender': child['gender'],
        'language': child['language'],
        'age': child['age'],
        'created_at': child['created_at'],
        'hospital_id': child['hospital_id'],
      };
    } catch (e) {
      return null;
    }
  }

  static Future<void> deleteChild(String id) async {
    // Call API service - cascading delete handled by backend
    await ApiService.deleteChild(id);
  }

  // Session operations - Now using API Service
  static Future<void> saveSession({
    required String id,
    required String childId,
    required String sessionType,
    String? ageGroup,
    required DateTime startTime,
    DateTime? endTime,
    Map<String, dynamic>? metrics,
    Map<String, dynamic>? gameResults,
    Map<String, dynamic>? questionnaireResults,
    Map<String, dynamic>? reflectionResults,
    double? riskScore,
    String? riskLevel,
  }) async {
    // Call API service
    await ApiService.createSession(
      childId: childId,
      sessionType: sessionType,
      ageGroup: ageGroup,
      startTime: startTime,
      endTime: endTime,
      metrics: metrics,
      gameResults: gameResults,
      questionnaireResults: questionnaireResults,
      reflectionResults: reflectionResults,
      riskScore: riskScore,
      riskLevel: riskLevel,
    );
  }

  static Future<List<Map<String, dynamic>>> getAllSessions() async {
    // Call API service
    final sessions = await ApiService.getAllSessions();
    // Convert backend format to app format
    return sessions.map((session) => {
      'id': session['id'],
      'child_id': session['child_id'],
      'session_type': session['session_type'],
      'age_group': session['age_group'],
      'start_time': session['start_time'],
      'end_time': session['end_time'],
      'metrics': session['metrics'],
      'game_results': session['game_results'],
      'questionnaire_results': session['questionnaire_results'],
      'reflection_results': session['reflection_results'],
      'risk_score': session['risk_score'],
      'risk_level': session['risk_level'],
      'created_at': session['created_at'],
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> getSessionsByChild(String childId) async {
    // Call API service
    final sessions = await ApiService.getSessionsByChild(childId);
    // Convert backend format to app format
    return sessions.map((session) => {
      'id': session['id'],
      'child_id': session['child_id'],
      'session_type': session['session_type'],
      'age_group': session['age_group'],
      'start_time': session['start_time'],
      'end_time': session['end_time'],
      'metrics': session['metrics'],
      'game_results': session['game_results'],
      'questionnaire_results': session['questionnaire_results'],
      'reflection_results': session['reflection_results'],
      'risk_score': session['risk_score'],
      'risk_level': session['risk_level'],
      'created_at': session['created_at'],
    }).toList();
  }

  static Future<void> updateSession({
    required String id,
    DateTime? endTime,
    Map<String, dynamic>? metrics,
    Map<String, dynamic>? gameResults,
    Map<String, dynamic>? questionnaireResults,
    Map<String, dynamic>? reflectionResults,
    double? riskScore,
    String? riskLevel,
  }) async {
    // Call API service
    await ApiService.updateSession(
      id: id,
      endTime: endTime,
      metrics: metrics,
      gameResults: gameResults,
      questionnaireResults: questionnaireResults,
      reflectionResults: reflectionResults,
      riskScore: riskScore,
      riskLevel: riskLevel,
    );
  }

  // Trial operations - Now using API Service
  static Future<void> saveTrial({
    required String id,
    required String sessionId,
    required int trialNumber,
    String? stimulus,
    String? rule,
    String? response,
    int? reactionTime,
    bool? correct,
    required DateTime timestamp,
    bool? isPostSwitch,
    bool? isPerseverativeError,
    Map<String, dynamic>? additionalData,
  }) async {
    // Call API service
    await ApiService.createTrial(
      sessionId: sessionId,
      trialNumber: trialNumber,
      stimulus: stimulus,
      rule: rule,
      response: response,
      correct: correct ?? false,
      reactionTime: reactionTime,
      timestamp: timestamp,
      isPostSwitch: isPostSwitch,
      isPerseverativeError: isPerseverativeError,
      additionalData: additionalData,
    );
  }

  /// Save multiple trials at once (batch)
  static Future<void> saveTrialsBatch({
    required List<Map<String, dynamic>> trials,
  }) async {
    // Convert app format to API format
    final apiTrials = trials.map((trial) => {
      'session_id': trial['session_id'],
      'trial_number': trial['trial_number'],
      'stimulus': trial['stimulus'],
      'rule': trial['rule'],
      'response': trial['response'],
      'correct': trial['correct'] is bool ? trial['correct'] : (trial['correct'] == 1),
      'reaction_time': trial['reaction_time'],
      'timestamp': trial['timestamp'] is DateTime
          ? (trial['timestamp'] as DateTime).millisecondsSinceEpoch
          : trial['timestamp'],
      'is_post_switch': trial['is_post_switch'],
      'is_perseverative_error': trial['is_perseverative_error'],
      'additional_data': trial['additional_data'],
    }).toList();

    await ApiService.createTrialsBatch(trials: apiTrials);
  }

  static Future<List<Map<String, dynamic>>> getTrialsBySession(String sessionId) async {
    // Call API service
    final trials = await ApiService.getTrialsBySession(sessionId);
    // Convert backend format to app format
    return trials.map((trial) => {
      'id': trial['id'],
      'session_id': trial['session_id'],
      'trial_number': trial['trial_number'],
      'stimulus': trial['stimulus'],
      'rule': trial['rule'],
      'response': trial['response'],
      'correct': trial['correct'] is bool ? (trial['correct'] ? 1 : 0) : trial['correct'],
      'reaction_time': trial['reaction_time'],
      'timestamp': trial['timestamp'],
      'is_post_switch': trial['is_post_switch'],
      'is_perseverative_error': trial['is_perseverative_error'],
      'additional_data': trial['additional_data'],
    }).toList();
  }
}

