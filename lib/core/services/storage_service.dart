import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
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
    await db.execute('''
      CREATE TABLE children (
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
      CREATE TABLE sessions (
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
      CREATE TABLE trials (
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

  // Child operations
  static Future<void> saveChild({
    required String id,
    required String name,
    required DateTime dateOfBirth,
    required String gender,
    required String language,
    required double age,
  }) async {
    final db = await database;
    await db.insert('children', {
      'id': id,
      'name': name,
      'date_of_birth': dateOfBirth.millisecondsSinceEpoch,
      'gender': gender,
      'language': language,
      'age': age,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<List<Map<String, dynamic>>> getAllChildren() async {
    final db = await database;
    return await db.query('children', orderBy: 'created_at DESC');
  }

  static Future<Map<String, dynamic>?> getChild(String id) async {
    final db = await database;
    final results = await db.query(
      'children',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  static Future<void> deleteChild(String id) async {
    final db = await database;
    await db.delete('children', where: 'id = ?', whereArgs: [id]);
    // Also delete related sessions
    await db.delete('sessions', where: 'child_id = ?', whereArgs: [id]);
  }

  // Session operations
  static Future<void> saveSession({
    required String id,
    required String childId,
    required String sessionType,
    String? ageGroup,
    required DateTime startTime,
    DateTime? endTime,
    Map<String, dynamic>? metrics,
  }) async {
    final db = await database;
    await db.insert('sessions', {
      'id': id,
      'child_id': childId,
      'session_type': sessionType,
      'age_group': ageGroup,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
      'metrics': metrics != null ? jsonEncode(metrics) : null,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<List<Map<String, dynamic>>> getAllSessions() async {
    final db = await database;
    return await db.query('sessions', orderBy: 'created_at DESC');
  }

  static Future<List<Map<String, dynamic>>> getSessionsByChild(String childId) async {
    final db = await database;
    return await db.query(
      'sessions',
      where: 'child_id = ?',
      whereArgs: [childId],
      orderBy: 'created_at DESC',
    );
  }

  static Future<void> updateSession({
    required String id,
    DateTime? endTime,
    Map<String, dynamic>? metrics,
  }) async {
    final db = await database;
    final updates = <String, dynamic>{};
    if (endTime != null) {
      updates['end_time'] = endTime.millisecondsSinceEpoch;
    }
    if (metrics != null) {
      updates['metrics'] = jsonEncode(metrics);
    }
    if (updates.isNotEmpty) {
      await db.update('sessions', updates, where: 'id = ?', whereArgs: [id]);
    }
  }

  // Trial operations
  static Future<void> saveTrial({
    required String id,
    required String sessionId,
    required int trialNumber,
    String? stimulus,
    String? response,
    int? reactionTime,
    bool? correct,
    required DateTime timestamp,
  }) async {
    final db = await database;
    await db.insert('trials', {
      'id': id,
      'session_id': sessionId,
      'trial_number': trialNumber,
      'stimulus': stimulus,
      'response': response,
      'reaction_time': reactionTime,
      'correct': correct != null ? (correct ? 1 : 0) : null,
      'timestamp': timestamp.millisecondsSinceEpoch,
    });
  }

  static Future<List<Map<String, dynamic>>> getTrialsBySession(String sessionId) async {
    final db = await database;
    return await db.query(
      'trials',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'trial_number ASC',
    );
  }
}

