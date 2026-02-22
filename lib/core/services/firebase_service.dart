// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/foundation.dart';

// class FirebaseService {
//   static final FirebaseDatabase _database = FirebaseDatabase.instance;
//   static DatabaseReference? _rootRef;

//   /// Initialize Firebase Database reference
//   static DatabaseReference get rootRef {
//     _rootRef ??= _database.ref();
//     return _rootRef!;
//   }

//   /// Get reference to a specific path
//   static DatabaseReference ref(String path) {
//     return rootRef.child(path);
//   }

//   /// Write data to Firebase
//   static Future<void> writeData(String path, Map<String, dynamic> data) async {
//     try {
//       await ref(path).set(data);
//       debugPrint('✅ Data written to Firebase: $path');
//     } catch (e) {
//       debugPrint('❌ Error writing to Firebase: $e');
//       rethrow;
//     }
//   }

//   /// Update data in Firebase
//   static Future<void> updateData(String path, Map<String, dynamic> data) async {
//     try {
//       await ref(path).update(data);
//       debugPrint('✅ Data updated in Firebase: $path');
//     } catch (e) {
//       debugPrint('❌ Error updating Firebase: $e');
//       rethrow;
//     }
//   }

//   /// Read data once from Firebase
//   static Future<Map<String, dynamic>?> readData(String path) async {
//     try {
//       final snapshot = await ref(path).get();
//       if (snapshot.exists) {
//         final data = Map<String, dynamic>.from(snapshot.value as Map);
//         debugPrint('✅ Data read from Firebase: $path');
//         return data;
//       }
//       debugPrint('⚠️ No data found at path: $path');
//       return null;
//     } catch (e) {
//       debugPrint('❌ Error reading from Firebase: $e');
//       rethrow;
//     }
//   }

//   /// Listen to real-time changes
//   static Stream<DatabaseEvent> listenToData(String path) {
//     return ref(path).onValue;
//   }

//   /// Delete data from Firebase
//   static Future<void> deleteData(String path) async {
//     try {
//       await ref(path).remove();
//       debugPrint('✅ Data deleted from Firebase: $path');
//     } catch (e) {
//       debugPrint('❌ Error deleting from Firebase: $e');
//       rethrow;
//     }
//   }

//   /// Push data (creates unique key)
//   static Future<String> pushData(String path, Map<String, dynamic> data) async {
//     try {
//       final ref = rootRef.child(path).push();
//       await ref.set(data);
//       debugPrint('✅ Data pushed to Firebase: ${ref.key}');
//       return ref.key!;
//     } catch (e) {
//       debugPrint('❌ Error pushing to Firebase: $e');
//       rethrow;
//     }
//   }

//   /// Save session to Firebase
//   static Future<String> saveSession({
//     required String childId,
//     required String sessionType,
//     required String ageGroup,
//     required DateTime startTime,
//     DateTime? endTime,
//     Map<String, dynamic>? gameResults,
//     Map<String, dynamic>? questionnaireResults,
//     double? riskScore,
//     String? riskLevel,
//   }) async {
//     final sessionData = {
//       'child_id': childId,
//       'session_type': sessionType,
//       'age_group': ageGroup,
//       'start_time': startTime.toIso8601String(),
//       if (endTime != null) 'end_time': endTime.toIso8601String(),
//       if (gameResults != null) 'game_results': gameResults,
//       if (questionnaireResults != null) 'questionnaire_results': questionnaireResults,
//       if (riskScore != null) 'risk_score': riskScore,
//       if (riskLevel != null) 'risk_level': riskLevel,
//       'created_at': DateTime.now().toIso8601String(),
//     };

//     final sessionId = await pushData('sessions', sessionData);
//     return sessionId;
//   }

//   /// Update session in Firebase
//   static Future<void> updateSession({
//     required String sessionId,
//     DateTime? endTime,
//     Map<String, dynamic>? gameResults,
//     Map<String, dynamic>? questionnaireResults,
//     double? riskScore,
//     String? riskLevel,
//   }) async {
//     final updates = <String, dynamic>{};
    
//     if (endTime != null) updates['end_time'] = endTime.toIso8601String();
//     if (gameResults != null) updates['game_results'] = gameResults;
//     if (questionnaireResults != null) updates['questionnaire_results'] = questionnaireResults;
//     if (riskScore != null) updates['risk_score'] = riskScore;
//     if (riskLevel != null) updates['risk_level'] = riskLevel;
//     updates['updated_at'] = DateTime.now().toIso8601String();

//     await updateData('sessions/$sessionId', updates);
//   }

//   /// Save trial to Firebase
//   static Future<void> saveTrial({
//     required String sessionId,
//     required int trialNumber,
//     required String stimulus,
//     String? rule,
//     required String response,
//     required int reactionTime,
//     required bool correct,
//     required DateTime timestamp,
//     bool? isPostSwitch,
//     bool? isPerseverativeError,
//   }) async {
//     final trialData = {
//       'session_id': sessionId,
//       'trial_number': trialNumber,
//       'stimulus': stimulus,
//       if (rule != null) 'rule': rule,
//       'response': response,
//       'reaction_time': reactionTime,
//       'correct': correct,
//       'timestamp': timestamp.toIso8601String(),
//       if (isPostSwitch != null) 'is_post_switch': isPostSwitch,
//       if (isPerseverativeError != null) 'is_perseverative_error': isPerseverativeError,
//     };

//     await pushData('trials', trialData);
//   }

//   /// Get all sessions for a child
//   static Stream<DatabaseEvent> getChildSessions(String childId) {
//     return rootRef
//         .child('sessions')
//         .orderByChild('child_id')
//         .equalTo(childId)
//         .onValue;
//   }

//   /// Get session by ID
//   static Future<Map<String, dynamic>?> getSession(String sessionId) async {
//     return await readData('sessions/$sessionId');
//   }
// }

