import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/models/child.dart';
import 'api_service.dart';
import 'offline_sync_service.dart';

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
      version: 6, // v6: session status, clinician_note, expanded local session columns
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS children (
        id TEXT PRIMARY KEY,
        child_code TEXT NOT NULL,
        name TEXT NOT NULL,
        date_of_birth INTEGER NOT NULL,
        age_in_months INTEGER NOT NULL,
        gender TEXT NOT NULL,
        language TEXT NOT NULL,
        age REAL NOT NULL,
        hospital_id TEXT,
        study_group TEXT NOT NULL DEFAULT 'typically_developing',
        asd_level TEXT,
        diagnosis_source TEXT NOT NULL DEFAULT 'Unknown',
        clinician_id TEXT,
        clinician_name TEXT,
        diagnosis_type TEXT NOT NULL DEFAULT 'new',
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sessions (
        id TEXT PRIMARY KEY,
        child_id TEXT NOT NULL,
        session_type TEXT NOT NULL,
        age_group TEXT,
        status TEXT NOT NULL DEFAULT 'in_progress',
        clinician_note TEXT,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        metrics TEXT,
        game_results TEXT,
        questionnaire_results TEXT,
        reflection_results TEXT,
        risk_score REAL,
        risk_level TEXT,
        created_at INTEGER NOT NULL
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
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE children ADD COLUMN hospital_id TEXT');
    }
    if (oldVersion < 3) {
      // Add new study-specific columns for child profile
      await db.execute('ALTER TABLE children ADD COLUMN child_code TEXT');
      await db.execute('ALTER TABLE children ADD COLUMN age_in_months INTEGER');
      await db.execute('ALTER TABLE children ADD COLUMN study_group TEXT DEFAULT \'typically_developing\'');
      await db.execute('ALTER TABLE children ADD COLUMN asd_level TEXT');
      await db.execute('ALTER TABLE children ADD COLUMN diagnosis_source TEXT DEFAULT \'Unknown\'');
      
      // Update existing records to have child_code = name if null
      await db.execute('UPDATE children SET child_code = name WHERE child_code IS NULL');
      
      // Calculate age_in_months for existing records
      final children = await db.query('children');
      for (final child in children) {
        final dob = child['date_of_birth'] as int?;
        if (dob != null) {
          final dobDate = DateTime.fromMillisecondsSinceEpoch(dob);
          final ageInMonths = _calculateAgeInMonthsFromDate(dobDate);
          await db.update(
            'children',
            {'age_in_months': ageInMonths},
            where: 'id = ?',
            whereArgs: [child['id']],
          );
        }
      }
    }
    if (oldVersion < 4) {
      // Add clinician_id and clinician_name columns for ASD group tracking
      await db.execute('ALTER TABLE children ADD COLUMN clinician_id TEXT');
      await db.execute('ALTER TABLE children ADD COLUMN clinician_name TEXT');
    }
    if (oldVersion < 5) {
      await db.execute(
          'ALTER TABLE children ADD COLUMN diagnosis_type TEXT DEFAULT \'new\'');
    }
    if (oldVersion < 6) {
      await db.execute(
          "ALTER TABLE sessions ADD COLUMN status TEXT NOT NULL DEFAULT 'in_progress'");
      await db.execute(
          'ALTER TABLE sessions ADD COLUMN clinician_note TEXT');
      await db.execute(
          'ALTER TABLE sessions ADD COLUMN game_results TEXT');
      await db.execute(
          'ALTER TABLE sessions ADD COLUMN questionnaire_results TEXT');
      await db.execute(
          'ALTER TABLE sessions ADD COLUMN reflection_results TEXT');
      await db.execute(
          'ALTER TABLE sessions ADD COLUMN risk_score REAL');
      await db.execute(
          'ALTER TABLE sessions ADD COLUMN risk_level TEXT');
      // Mark existing sessions with end_time as completed
      await db.execute(
          "UPDATE sessions SET status = 'completed' WHERE end_time IS NOT NULL");
    }
  }

  static int _calculateAgeInMonthsFromDate(DateTime dob) {
    final now = DateTime.now();
    int months = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (now.day < dob.day) months--;
    return months;
  }

  static String _offlineId(String prefix) =>
      '${prefix}_${DateTime.now().millisecondsSinceEpoch}';

  static double _calculateAge(DateTime dob) {
    final now = DateTime.now();
    return now.difference(dob).inDays / 365.25;
  }

  // ---------------- CHILDREN ----------------
  
  /// Save a new child profile with study-specific fields
  static Future<Map<String, dynamic>?> saveChild({
    String? id,
    required String childCode,
    required String name,
    required DateTime dateOfBirth,
    required int ageInMonths,
    required String gender,
    required String language,
    required double age,
    String? hospitalId,
    required ChildGroup group,
    AsdLevel? asdLevel,
    required String diagnosisSource,
    String? clinicianId,
    String? clinicianName,
    String diagnosisType = 'new',
  }) async {
    final payload = {
      'child_code': childCode,
      'name': name,
      'date_of_birth': dateOfBirth.millisecondsSinceEpoch,
      'age_in_months': ageInMonths,
      'gender': gender.toLowerCase(),
      'language': language,
      'hospital_id': hospitalId,
      'group': group.toJson(),
      'asd_level': asdLevel?.toJson(),
      'diagnosis_source': diagnosisSource,
      'clinician_id': clinicianId,
      'clinician_name': clinicianName,
      'diagnosis_type': diagnosisType,
    };

    try {
      final child = await ApiService.createChild(
        childCode: childCode,
        name: name,
        dateOfBirth: dateOfBirth,
        ageInMonths: ageInMonths,
        gender: gender,
        language: language,
        hospitalId: hospitalId,
        group: group,
        asdLevel: asdLevel,
        diagnosisSource: diagnosisSource,
        clinicianId: clinicianId,
        clinicianName: clinicianName,
      );
      await _upsertChildLocal({
        'id': child['id'],
        'child_code': child['child_code'] ?? childCode,
        'name': child['name'],
        'date_of_birth': child['date_of_birth'],
        'age_in_months': child['age_in_months'] ?? ageInMonths,
        'gender': child['gender'],
        'language': child['language'],
        'age': child['age'] ?? age,
        'hospital_id': child['hospital_id'],
        'study_group': child['group'] ?? group.toJson(),
        'asd_level': child['asd_level'] ?? asdLevel?.toJson(),
        'diagnosis_source': child['diagnosis_source'] ?? diagnosisSource,
        'clinician_id': child['clinician_id'] ?? clinicianId,
        'clinician_name': child['clinician_name'] ?? clinicianName,
        'diagnosis_type': child['diagnosis_type'] ?? diagnosisType,
        'created_at':
            child['created_at'] ?? DateTime.now().millisecondsSinceEpoch,
      });
      debugPrint('✅ Child saved to backend: ${child['id']}');
      return child;
    } catch (e) {
      debugPrint('❌ Error saving child to backend: $e');
      debugPrint('⚠️ Saving locally and queuing for sync...');
      final offlineId = id ?? _offlineId('child');
      final localChild = {
        'id': offlineId,
        'child_code': childCode,
        'name': name,
        'date_of_birth': dateOfBirth.millisecondsSinceEpoch,
        'age_in_months': ageInMonths,
        'gender': gender,
        'language': language,
        'age': age,
        'hospital_id': hospitalId,
        'study_group': group.toJson(),
        'asd_level': asdLevel?.toJson(),
        'diagnosis_source': diagnosisSource,
        'clinician_id': clinicianId,
        'clinician_name': clinicianName,
        'diagnosis_type': diagnosisType,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };
      await _upsertChildLocal(localChild);
      await OfflineSyncService.enqueueRequest(
        endpoint: '/api/children',
        method: 'POST',
        payload: payload,
      );
      return localChild;
    }
  }

  static Future<Map<String, dynamic>?> updateChild({
    required String id,
    required String childCode,
    required String name,
    required DateTime dateOfBirth,
    required int ageInMonths,
    required String gender,
    required String language,
    double? age,
    String? hospitalId,
    required ChildGroup group,
    AsdLevel? asdLevel,
    required String diagnosisSource,
    String? clinicianId,
    String? clinicianName,
    String diagnosisType = 'new',
  }) async {
    final payload = {
      'child_code': childCode,
      'name': name,
      'date_of_birth': dateOfBirth.millisecondsSinceEpoch,
      'age_in_months': ageInMonths,
      'gender': gender.toLowerCase(),
      'language': language,
      'hospital_id': hospitalId,
      'group': group.toJson(),
      'asd_level': asdLevel?.toJson(),
      'diagnosis_source': diagnosisSource,
      'clinician_id': clinicianId,
      'clinician_name': clinicianName,
      'diagnosis_type': diagnosisType,
    };

    try {
      final updated = await ApiService.updateChild(
        id: id,
        childCode: childCode,
        name: name,
        dateOfBirth: dateOfBirth,
        ageInMonths: ageInMonths,
        gender: gender,
        language: language,
        hospitalId: hospitalId,
        group: group,
        asdLevel: asdLevel,
        diagnosisSource: diagnosisSource,
        clinicianId: clinicianId,
        clinicianName: clinicianName,
      );
      await _upsertChildLocal({
        'id': updated['id'],
        'child_code': updated['child_code'] ?? childCode,
        'name': updated['name'],
        'date_of_birth': updated['date_of_birth'],
        'age_in_months': updated['age_in_months'] ?? ageInMonths,
        'gender': updated['gender'],
        'language': updated['language'],
        'age': updated['age'] ?? age ?? _calculateAge(dateOfBirth),
        'hospital_id': updated['hospital_id'],
        'study_group': updated['group'] ?? group.toJson(),
        'asd_level': updated['asd_level'] ?? asdLevel?.toJson(),
        'diagnosis_source': updated['diagnosis_source'] ?? diagnosisSource,
        'clinician_id': updated['clinician_id'] ?? clinicianId,
        'clinician_name': updated['clinician_name'] ?? clinicianName,
        'diagnosis_type':
            updated['diagnosis_type'] ?? diagnosisType,
        'created_at':
            updated['created_at'] ?? DateTime.now().millisecondsSinceEpoch,
      });
      return updated;
    } catch (_) {
      final localChild = {
        'id': id,
        'child_code': childCode,
        'name': name,
        'date_of_birth': dateOfBirth.millisecondsSinceEpoch,
        'age_in_months': ageInMonths,
        'gender': gender,
        'language': language,
        'age': age ?? _calculateAge(dateOfBirth),
        'hospital_id': hospitalId,
        'study_group': group.toJson(),
        'asd_level': asdLevel?.toJson(),
        'diagnosis_source': diagnosisSource,
        'clinician_id': clinicianId,
        'clinician_name': clinicianName,
        'diagnosis_type': diagnosisType,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };
      await _upsertChildLocal(localChild);
      await OfflineSyncService.enqueueRequest(
        endpoint: '/api/children/$id',
        method: 'PUT',
        payload: payload,
      );
      return localChild;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllChildren() async {
    // First, get local data immediately (for offline support)
    final localChildren = await _getChildrenLocal();
    
    // Try to sync with backend if online
    try {
      // Check if backend is available (with timeout)
      final isOnline = await ApiService.healthCheck()
          .timeout(const Duration(seconds: 3), onTimeout: () => false);
      
      if (isOnline) {
        final children = await ApiService.getAllChildren()
            .timeout(const Duration(seconds: 10));
        final formatted = children
            .map((child) => {
                  'id': child['id'],
                  'child_code': child['child_code'] ?? child['name'],
                  'name': child['name'],
                  'date_of_birth': child['date_of_birth'],
                  'age_in_months': child['age_in_months'],
                  'gender': child['gender'],
                  'language': child['language'],
                  'age': child['age'],
                  'hospital_id': child['hospital_id'],
                  'study_group': child['group'],
                  'asd_level': child['asd_level'],
                  'diagnosis_source': child['diagnosis_source'],
                  'diagnosis_type': child['diagnosis_type'] ?? 'new',
                  'created_at': child['created_at'],
                })
            .toList();
        // Merge with local data (local data takes priority for offline entries)
        await _mergeChildrenLocal(formatted, localChildren);
        // Return merged data
        return await _getChildrenLocal();
      } else {
        // Offline - return local data
        debugPrint('📱 Offline mode: Returning ${localChildren.length} local children');
        return localChildren;
      }
    } catch (e) {
      // Any error - return local data (offline mode)
      debugPrint('⚠️ Error fetching from backend: $e');
      debugPrint('📱 Returning ${localChildren.length} local children');
      return localChildren;
    }
  }

  /// Returns the next sequential child code for a given hospital prefix.
  ///
  /// Example: if existing codes are `LRH-001`, `LRH-002`, returns `LRH-003`.
  /// This is local/offline-safe and does not require backend connectivity.
  static Future<String> getNextChildCode({
    required String prefix,
    int digits = 3,
  }) async {
    final normalizedPrefix = prefix.trim().toUpperCase();
    if (normalizedPrefix.isEmpty) {
      return 'CH-${'1'.padLeft(digits, '0')}';
    }

    final db = await database;
    final rows = await db.query(
      'children',
      columns: ['child_code'],
      where: 'child_code LIKE ?',
      whereArgs: ['$normalizedPrefix-%'],
    );

    final pattern = RegExp(
      '^${RegExp.escape(normalizedPrefix)}-(\\d+)\$',
      caseSensitive: false,
    );

    var maxN = 0;
    for (final row in rows) {
      final code = row['child_code']?.toString();
      if (code == null) continue;
      final match = pattern.firstMatch(code.trim());
      if (match == null) continue;
      final n = int.tryParse(match.group(1) ?? '');
      if (n != null && n > maxN) maxN = n;
    }

    final next = (maxN + 1).toString().padLeft(digits, '0');
    return '$normalizedPrefix-$next';
  }

  static Future<Map<String, dynamic>?> getChild(String id) async {
    try {
      final child = await ApiService.getChild(id);
      final mapped = {
        'id': child['id'],
        'child_code': child['child_code'] ?? child['name'],
        'name': child['name'],
        'date_of_birth': child['date_of_birth'],
        'age_in_months': child['age_in_months'],
        'gender': child['gender'],
        'language': child['language'],
        'age': child['age'],
        'hospital_id': child['hospital_id'],
        'study_group': child['group'],
        'asd_level': child['asd_level'],
        'diagnosis_source': child['diagnosis_source'],
        'diagnosis_type': child['diagnosis_type'] ?? 'new',
        'created_at': child['created_at'],
      };
      await _upsertChildLocal(mapped);
      return mapped;
    } catch (_) {
      final db = await database;
      final rows = await db.query(
        'children',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return rows.first;
    }
  }

  static Future<void> deleteChild(String id) async {
    try {
      await ApiService.deleteChild(id);
    } catch (_) {
      await OfflineSyncService.enqueueRequest(
        endpoint: '/api/children/$id',
        method: 'DELETE',
        payload: const {},
      );
    } finally {
      final db = await database;
      await db.delete('children', where: 'id = ?', whereArgs: [id]);
    }
  }

  // ---------------- SESSIONS ----------------
  static Future<Map<String, dynamic>?> saveSession({
    String? id,
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
    // Normalize session type to match backend expectations
    String normalizedSessionType = sessionType
        .replaceAll('-', '_')  // Convert hyphens to underscores
        .replaceAll('dccs_', '')  // Remove dccs prefix if present
        .replaceAll('dccs-', '');  // Remove dccs prefix with hyphen
    
    // Map common variations to backend expected values
    final sessionTypeMap = {
      'color_shape': 'color_shape',
      'color-shape': 'color_shape',
      'dccs_color_shape': 'color_shape',
      'dccs-color-shape': 'color_shape',
      'frog_jump': 'frog_jump',
      'frog-jump': 'frog_jump',
      'ai_doctor_bot': 'ai_doctor_bot',
      'ai-doctor-bot': 'ai_doctor_bot',
      'manual_assessment': 'manual_assessment',
      'manual-assessment': 'manual_assessment',
    };
    
    normalizedSessionType = sessionTypeMap[normalizedSessionType] ?? normalizedSessionType;
    
    final payload = {
      'child_id': childId,
      'session_type': normalizedSessionType,
      'age_group': ageGroup,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
      'metrics': metrics,
      'game_results': gameResults,
      'questionnaire_results': questionnaireResults,
      'reflection_results': reflectionResults,
      'risk_score': riskScore,
      'risk_level': riskLevel,
    };

    final status = endTime != null ? 'completed' : 'in_progress';

    try {
      final session = await ApiService.createSession(
        childId: childId,
        sessionType: normalizedSessionType,
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
      await _upsertSessionLocal({
        'id': session['id'],
        'child_id': session['child_id'],
        'session_type': session['session_type'],
        'age_group': session['age_group'],
        'status': status,
        'start_time': session['start_time'],
        'end_time': session['end_time'],
        'metrics': jsonEncode(metrics ?? const {}),
        'game_results': gameResults != null ? jsonEncode(gameResults) : null,
        'questionnaire_results': questionnaireResults != null ? jsonEncode(questionnaireResults) : null,
        'reflection_results': reflectionResults != null ? jsonEncode(reflectionResults) : null,
        'risk_score': riskScore,
        'risk_level': riskLevel,
        'created_at': session['created_at'],
      });
      debugPrint('✅ Session saved to backend: ${session['id']}');
      return session;
    } catch (e) {
      debugPrint('❌ Error saving session to backend: $e');
      debugPrint('⚠️ Saving locally and queuing for sync...');
      final offlineId = id ?? _offlineId('session');
      final localSession = {
        'id': offlineId,
        'child_id': childId,
        'session_type': sessionType,
        'age_group': ageGroup,
        'status': status,
        'start_time': startTime.millisecondsSinceEpoch,
        'end_time': endTime?.millisecondsSinceEpoch,
        'metrics': jsonEncode(metrics ?? const {}),
        'game_results': gameResults != null ? jsonEncode(gameResults) : null,
        'questionnaire_results': questionnaireResults != null ? jsonEncode(questionnaireResults) : null,
        'reflection_results': reflectionResults != null ? jsonEncode(reflectionResults) : null,
        'risk_score': riskScore,
        'risk_level': riskLevel,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };
      await _upsertSessionLocal(localSession);
      await OfflineSyncService.enqueueRequest(
        endpoint: '/api/sessions',
        method: 'POST',
        payload: payload,
      );
      return localSession;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllSessions() async {
    try {
      final sessions = await ApiService.getAllSessions();
      final formatted = sessions
          .map((session) => {
                'id': session['id'],
                'child_id': session['child_id'],
                'session_type': session['session_type'],
                'age_group': session['age_group'],
                'status': session['end_time'] != null ? 'completed' : (session['status'] ?? 'in_progress'),
                'start_time': session['start_time'],
                'end_time': session['end_time'],
                'metrics': jsonEncode(session['metrics'] ?? const {}),
                'game_results': session['game_results'] != null ? jsonEncode(session['game_results']) : null,
                'questionnaire_results': session['questionnaire_results'] != null ? jsonEncode(session['questionnaire_results']) : null,
                'reflection_results': session['reflection_results'] != null ? jsonEncode(session['reflection_results']) : null,
                'risk_score': session['risk_score'],
                'risk_level': session['risk_level'],
                'created_at': session['created_at'],
              })
          .toList();
      await _replaceSessionsLocal(formatted);
      return formatted;
    } catch (_) {
      return await _getSessionsLocal();
    }
  }

  static Future<List<Map<String, dynamic>>> getSessionsByChild(
      String childId) async {
    // First, get local sessions (preserves offline data)
    final db = await database;
    final localRows = await db.query(
      'sessions',
      where: 'child_id = ?',
      whereArgs: [childId],
      orderBy: 'created_at DESC',
    );
    final localSessions = localRows.map((row) => row as Map<String, dynamic>).toList();
    
    // Try to sync with backend if online
    try {
      final isOnline = await ApiService.healthCheck()
          .timeout(const Duration(seconds: 3), onTimeout: () => false);
      
      if (isOnline) {
        final serverSessions = await ApiService.getSessionsByChild(childId)
            .timeout(const Duration(seconds: 10));
        
        final serverMap = <String, Map<String, dynamic>>{};
        for (final session in serverSessions) {
          final formatted = {
            'id': session['id'],
            'child_id': session['child_id'],
            'session_type': session['session_type'],
            'age_group': session['age_group'],
            'status': session['end_time'] != null ? 'completed' : (session['status'] ?? 'in_progress'),
            'start_time': session['start_time'],
            'end_time': session['end_time'],
            'metrics': jsonEncode(session['metrics'] ?? const {}),
            'game_results': session['game_results'] != null ? jsonEncode(session['game_results']) : null,
            'questionnaire_results': session['questionnaire_results'] != null ? jsonEncode(session['questionnaire_results']) : null,
            'reflection_results': session['reflection_results'] != null ? jsonEncode(session['reflection_results']) : null,
            'risk_score': session['risk_score'],
            'risk_level': session['risk_level'],
            'created_at': session['created_at'],
          };
          serverMap[session['id'] as String] = formatted;
        }
        
        // Merge: server data takes priority, but keep local-only sessions
        final mergedSessions = <String, Map<String, dynamic>>{};
        for (final local in localSessions) {
          final id = local['id'] as String;
          mergedSessions[id] = local;
        }
        for (final entry in serverMap.entries) {
          mergedSessions[entry.key] = entry.value;
        }
        
        // Update local DB with merged data (upsert)
        for (final session in mergedSessions.values) {
          await _upsertSessionLocal(session);
        }
        
        // Return merged list, sorted by created_at DESC
        final result = mergedSessions.values.toList();
        result.sort((a, b) {
          final aTime = a['created_at'] as int? ?? 0;
          final bTime = b['created_at'] as int? ?? 0;
          return bTime.compareTo(aTime);
        });
        
        return result;
      } else {
        // Offline - return local data
        debugPrint('📱 Offline mode: Returning ${localSessions.length} local sessions');
        return localSessions;
      }
    } catch (e) {
      // Any error - return local data
      debugPrint('⚠️ Error fetching sessions from backend: $e');
      debugPrint('📱 Returning ${localSessions.length} local sessions');
      return localSessions;
    }
  }

  static Future<void> updateSession({
    required String id,
    String? status,
    String? clinicianNote,
    DateTime? endTime,
    Map<String, dynamic>? metrics,
    Map<String, dynamic>? gameResults,
    Map<String, dynamic>? questionnaireResults,
    Map<String, dynamic>? reflectionResults,
    double? riskScore,
    String? riskLevel,
  }) async {
    final payload = <String, dynamic>{};
    if (endTime != null) payload['end_time'] = endTime.millisecondsSinceEpoch;
    if (metrics != null) payload['metrics'] = metrics;
    if (gameResults != null) payload['game_results'] = gameResults;
    if (questionnaireResults != null) {
      payload['questionnaire_results'] = questionnaireResults;
    }
    if (reflectionResults != null) {
      payload['reflection_results'] = reflectionResults;
    }
    if (riskScore != null) payload['risk_score'] = riskScore;
    if (riskLevel != null) payload['risk_level'] = riskLevel;

    try {
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
    } catch (_) {
      await OfflineSyncService.enqueueRequest(
        endpoint: '/api/sessions/$id',
        method: 'PUT',
        payload: payload,
      );
    } finally {
      final db = await database;
      final updateData = <String, dynamic>{};
      // Auto-derive status: completed when endTime provided, unless explicitly set
      if (status != null) {
        updateData['status'] = status;
      } else if (endTime != null) {
        updateData['status'] = 'completed';
      }
      if (clinicianNote != null) updateData['clinician_note'] = clinicianNote;
      if (endTime != null) updateData['end_time'] = endTime.millisecondsSinceEpoch;
      if (metrics != null) updateData['metrics'] = jsonEncode(metrics);
      if (gameResults != null) updateData['game_results'] = jsonEncode(gameResults);
      if (questionnaireResults != null) {
        updateData['questionnaire_results'] = jsonEncode(questionnaireResults);
      }
      if (reflectionResults != null) {
        updateData['reflection_results'] = jsonEncode(reflectionResults);
      }
      if (riskScore != null) updateData['risk_score'] = riskScore;
      if (riskLevel != null) updateData['risk_level'] = riskLevel;

      if (updateData.isNotEmpty) {
        await db.update(
          'sessions',
          updateData,
          where: 'id = ?',
          whereArgs: [id],
        );
        debugPrint('✅ Updated local session $id (status: ${updateData['status']})');
      }
    }
  }

  /// Mark a session as aborted, saving any partial metrics collected so far.
  static Future<void> abortSession({
    required String id,
    Map<String, dynamic>? partialMetrics,
    Map<String, dynamic>? partialGameResults,
  }) async {
    await updateSession(
      id: id,
      status: 'aborted',
      endTime: DateTime.now(),
      metrics: partialMetrics,
      gameResults: partialGameResults,
    );
    debugPrint('⚠️ Session $id marked as aborted');
  }

  // ---------------- TRIALS ----------------
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
    final payload = {
      'session_id': sessionId,
      'trial_number': trialNumber,
      'stimulus': stimulus,
      'rule': rule,
      'response': response,
      'reaction_time': reactionTime,
      'correct': correct ?? false,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'is_post_switch': isPostSwitch,
      'is_perseverative_error': isPerseverativeError,
      'additional_data': additionalData,
    };

    try {
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
      await _upsertTrialLocal({
        'id': id,
        'session_id': sessionId,
        'trial_number': trialNumber,
        'stimulus': stimulus,
        'response': response,
        'reaction_time': reactionTime,
        'correct': (correct ?? false) ? 1 : 0,
        'timestamp': timestamp.millisecondsSinceEpoch,
      });
    } catch (_) {
      final offlineId = id.isEmpty ? _offlineId('trial') : id;
      await OfflineSyncService.enqueueRequest(
        endpoint: '/api/trials',
        method: 'POST',
        payload: payload,
      );
      await _upsertTrialLocal({
        'id': offlineId,
        'session_id': sessionId,
        'trial_number': trialNumber,
        'stimulus': stimulus,
        'response': response,
        'reaction_time': reactionTime,
        'correct': (correct ?? false) ? 1 : 0,
        'timestamp': timestamp.millisecondsSinceEpoch,
      });
    }
  }

  static Future<void> saveTrialsBatch({
    required List<Map<String, dynamic>> trials,
  }) async {
    final apiTrials = trials
        .map((trial) => {
              'session_id': trial['session_id'],
              'trial_number': trial['trial_number'],
              'stimulus': trial['stimulus'],
              'rule': trial['rule'],
              'response': trial['response'],
              'correct': trial['correct'] is bool
                  ? trial['correct']
                  : trial['correct'] == 1,
              'reaction_time': trial['reaction_time'],
              'timestamp': trial['timestamp'] is DateTime
                  ? (trial['timestamp'] as DateTime).millisecondsSinceEpoch
                  : trial['timestamp'],
              'is_post_switch': trial['is_post_switch'],
              'is_perseverative_error': trial['is_perseverative_error'],
              'additional_data': trial['additional_data'],
            })
        .toList();

    try {
      await ApiService.createTrialsBatch(trials: apiTrials);
      for (final trial in trials) {
        await _upsertTrialLocal({
          'id': trial['id'],
          'session_id': trial['session_id'],
          'trial_number': trial['trial_number'],
          'stimulus': trial['stimulus'],
          'response': trial['response'],
          'reaction_time': trial['reaction_time'],
          'correct': trial['correct'] is bool
              ? (trial['correct'] as bool ? 1 : 0)
              : trial['correct'],
          'timestamp': trial['timestamp'] is DateTime
              ? (trial['timestamp'] as DateTime).millisecondsSinceEpoch
              : trial['timestamp'],
        });
      }
    } catch (_) {
      for (final payload in apiTrials) {
        await OfflineSyncService.enqueueRequest(
          endpoint: '/api/trials',
          method: 'POST',
          payload: payload,
        );
      }
      for (final trial in trials) {
        await _upsertTrialLocal({
          'id': trial['id'] ?? _offlineId('trial'),
          'session_id': trial['session_id'],
          'trial_number': trial['trial_number'],
          'stimulus': trial['stimulus'],
          'response': trial['response'],
          'reaction_time': trial['reaction_time'],
          'correct': trial['correct'] is bool
              ? (trial['correct'] as bool ? 1 : 0)
              : trial['correct'],
          'timestamp': trial['timestamp'] is DateTime
              ? (trial['timestamp'] as DateTime).millisecondsSinceEpoch
              : trial['timestamp'],
        });
      }
    }
  }

  static Future<List<Map<String, dynamic>>> getTrialsBySession(
      String sessionId) async {
    try {
      final trials = await ApiService.getTrialsBySession(sessionId);
      final formatted = trials
          .map((trial) => {
                'id': trial['id'],
                'session_id': trial['session_id'],
                'trial_number': trial['trial_number'],
                'stimulus': trial['stimulus'],
                'response': trial['response'],
                'reaction_time': trial['reaction_time'],
                'correct': trial['correct'] is bool
                    ? (trial['correct'] ? 1 : 0)
                    : trial['correct'],
                'timestamp': trial['timestamp'],
              })
          .toList();
      await _replaceTrialsLocal(sessionId, formatted);
      return formatted;
    } catch (_) {
      final db = await database;
      return await db.query(
        'trials',
        where: 'session_id = ?',
        whereArgs: [sessionId],
        orderBy: 'trial_number ASC',
      );
    }
  }

  // -------------- LOCAL HELPERS --------------
  static Future<void> _upsertChildLocal(Map<String, dynamic> child) async {
    final db = await database;
    await db.insert(
      'children',
      child,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  static Future<List<Map<String, dynamic>>> _getChildrenLocal() async {
    final db = await database;
    return await db.query('children', orderBy: 'created_at DESC');
  }

  /// Merge remote and local children, preserving offline entries
  /// Offline entries have IDs starting with 'child_' (from _offlineId)
  static Future<void> _mergeChildrenLocal(
      List<Map<String, dynamic>> remoteChildren,
      List<Map<String, dynamic>> localChildren) async {
    final db = await database;
    final batch = db.batch();
    
    // Identify offline entries (IDs starting with 'child_')
    final offlineChildren = localChildren.where((child) {
      final id = child['id'] as String;
      return id.startsWith('child_');
    }).toList();
    
    // First, update/insert all remote children
    for (final remoteChild in remoteChildren) {
      batch.insert('children', remoteChild,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    // Then, preserve offline entries (they won't conflict with remote IDs)
    for (final offlineChild in offlineChildren) {
      batch.insert('children', offlineChild,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    await batch.commit(noResult: true);
    debugPrint('✅ Merged ${remoteChildren.length} remote + ${offlineChildren.length} offline children');
  }

  static Future<void> _upsertSessionLocal(Map<String, dynamic> session) async {
    final db = await database;
    await db.insert(
      'sessions',
      session,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> _replaceSessionsLocal(
      List<Map<String, dynamic>> sessions) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('sessions');
    for (final session in sessions) {
      batch.insert('sessions', session,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<List<Map<String, dynamic>>> _getSessionsLocal() async {
    final db = await database;
    final rows = await db.query('sessions', orderBy: 'created_at DESC');
    return rows.map((row) {
      final m = Map<String, dynamic>.from(row);
      if (m['game_results'] is String) {
        m['game_results'] = jsonDecode(m['game_results'] as String);
      }
      if (m['questionnaire_results'] is String) {
        m['questionnaire_results'] = jsonDecode(m['questionnaire_results'] as String);
      }
      if (m['reflection_results'] is String) {
        m['reflection_results'] = jsonDecode(m['reflection_results'] as String);
      }
      return m;
    }).toList();
  }

  static Future<void> _upsertTrialLocal(Map<String, dynamic> trial) async {
    final db = await database;
    await db.insert(
      'trials',
      trial,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> _replaceTrialsLocal(
    String sessionId,
    List<Map<String, dynamic>> trials,
  ) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('trials', where: 'session_id = ?', whereArgs: [sessionId]);
    for (final trial in trials) {
      batch.insert('trials', trial,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
