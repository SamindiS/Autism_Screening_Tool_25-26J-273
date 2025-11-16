// api_service.dart - Backend API Integration Service
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // For Android Emulator: use 10.0.2.2
  // For iOS Simulator: use localhost
  // For real device: use your computer's IP address (e.g., 192.168.1.100)
  static const String baseUrl = 'http://10.0.2.2:3000';
  
  // Uncomment and set your computer's IP for real device testing:
  // static const String baseUrl = 'http://192.168.1.100:3000';
  
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // Helper method for error handling
  static void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      final errorBody = response.body;
      try {
        final errorJson = jsonDecode(errorBody);
        throw Exception(errorJson['error'] ?? 'Request failed');
      } catch (e) {
        throw Exception('Request failed: ${response.statusCode}');
      }
    }
  }

  // ==================== CHILDREN ====================

  /// Create a new child
  static Future<Map<String, dynamic>> createChild({
    required String name,
    required DateTime dateOfBirth,
    required String gender,
    required String language,
    String? hospitalId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/children'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'date_of_birth': dateOfBirth.millisecondsSinceEpoch,
          'gender': gender,
          'language': language,
          'hospital_id': hospitalId,
        }),
      );

      _handleError(response);

      final data = jsonDecode(response.body);
      return data['child'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error creating child: $e');
      rethrow;
    }
  }

  /// Get all children
  static Future<List<Map<String, dynamic>>> getAllChildren() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/children'),
        headers: headers,
      );

      _handleError(response);

      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['children'] ?? []);
    } catch (e) {
      debugPrint('Error getting children: $e');
      rethrow;
    }
  }

  /// Get child by ID
  static Future<Map<String, dynamic>> getChild(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/children/$id'),
        headers: headers,
      );

      _handleError(response);

      final data = jsonDecode(response.body);
      return data['child'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting child: $e');
      rethrow;
    }
  }

  /// Update child
  static Future<Map<String, dynamic>> updateChild({
    required String id,
    required String name,
    required DateTime dateOfBirth,
    required String gender,
    required String language,
    String? hospitalId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/children/$id'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'date_of_birth': dateOfBirth.millisecondsSinceEpoch,
          'gender': gender,
          'language': language,
          'hospital_id': hospitalId,
        }),
      );

      _handleError(response);

      final data = jsonDecode(response.body);
      return data['child'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error updating child: $e');
      rethrow;
    }
  }

  /// Delete child
  static Future<void> deleteChild(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/children/$id'),
        headers: headers,
      );

      _handleError(response);
    } catch (e) {
      debugPrint('Error deleting child: $e');
      rethrow;
    }
  }

  // ==================== SESSIONS ====================

  /// Create a new session
  static Future<Map<String, dynamic>> createSession({
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
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/sessions'),
        headers: headers,
        body: jsonEncode({
          'child_id': childId,
          'session_type': sessionType,
          'age_group': ageGroup,
          'start_time': startTime.millisecondsSinceEpoch,
          'end_time': endTime?.millisecondsSinceEpoch,
          'metrics': metrics,
          'game_results': gameResults,
          'questionnaire_results': questionnaireResults,
          'reflection_results': reflectionResults,
          'risk_score': riskScore,
          'risk_level': riskLevel,
        }),
      );

      _handleError(response);

      final data = jsonDecode(response.body);
      return data['session'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error creating session: $e');
      rethrow;
    }
  }

  /// Get all sessions
  static Future<List<Map<String, dynamic>>> getAllSessions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/sessions'),
        headers: headers,
      );

      _handleError(response);

      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['sessions'] ?? []);
    } catch (e) {
      debugPrint('Error getting sessions: $e');
      rethrow;
    }
  }

  /// Get session by ID
  static Future<Map<String, dynamic>> getSession(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/sessions/$id'),
        headers: headers,
      );

      _handleError(response);

      final data = jsonDecode(response.body);
      return data['session'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting session: $e');
      rethrow;
    }
  }

  /// Get sessions by child ID
  static Future<List<Map<String, dynamic>>> getSessionsByChild(String childId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/sessions/child/$childId'),
        headers: headers,
      );

      _handleError(response);

      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['sessions'] ?? []);
    } catch (e) {
      debugPrint('Error getting sessions by child: $e');
      rethrow;
    }
  }

  /// Update session
  static Future<Map<String, dynamic>> updateSession({
    required String id,
    DateTime? endTime,
    Map<String, dynamic>? metrics,
    Map<String, dynamic>? gameResults,
    Map<String, dynamic>? questionnaireResults,
    Map<String, dynamic>? reflectionResults,
    double? riskScore,
    String? riskLevel,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (endTime != null) body['end_time'] = endTime.millisecondsSinceEpoch;
      if (metrics != null) body['metrics'] = metrics;
      if (gameResults != null) body['game_results'] = gameResults;
      if (questionnaireResults != null) body['questionnaire_results'] = questionnaireResults;
      if (reflectionResults != null) body['reflection_results'] = reflectionResults;
      if (riskScore != null) body['risk_score'] = riskScore;
      if (riskLevel != null) body['risk_level'] = riskLevel;

      final response = await http.put(
        Uri.parse('$baseUrl/api/sessions/$id'),
        headers: headers,
        body: jsonEncode(body),
      );

      _handleError(response);

      final data = jsonDecode(response.body);
      return data['session'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error updating session: $e');
      rethrow;
    }
  }

  /// Delete session
  static Future<void> deleteSession(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/sessions/$id'),
        headers: headers,
      );

      _handleError(response);
    } catch (e) {
      debugPrint('Error deleting session: $e');
      rethrow;
    }
  }

  // ==================== TRIALS ====================

  /// Create a single trial
  static Future<Map<String, dynamic>> createTrial({
    required String sessionId,
    required int trialNumber,
    String? stimulus,
    String? rule,
    String? response,
    required bool correct,
    int? reactionTime,
    required DateTime timestamp,
    bool? isPostSwitch,
    bool? isPerseverativeError,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/trials'),
        headers: headers,
        body: jsonEncode({
          'session_id': sessionId,
          'trial_number': trialNumber,
          'stimulus': stimulus,
          'rule': rule,
          'response': response,
          'correct': correct,
          'reaction_time': reactionTime,
          'timestamp': timestamp.millisecondsSinceEpoch,
          'is_post_switch': isPostSwitch,
          'is_perseverative_error': isPerseverativeError,
          'additional_data': additionalData,
        }),
      );

      _handleError(response);

      final data = jsonDecode(response.body);
      return data['trial'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error creating trial: $e');
      rethrow;
    }
  }

  /// Create multiple trials (batch)
  static Future<List<Map<String, dynamic>>> createTrialsBatch({
    required List<Map<String, dynamic>> trials,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/trials/batch'),
        headers: headers,
        body: jsonEncode({
          'trials': trials.map((trial) => {
            ...trial,
            'timestamp': trial['timestamp'] is DateTime
                ? (trial['timestamp'] as DateTime).millisecondsSinceEpoch
                : trial['timestamp'],
          }).toList(),
        }),
      );

      _handleError(response);

      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['trials'] ?? []);
    } catch (e) {
      debugPrint('Error creating trials batch: $e');
      rethrow;
    }
  }

  /// Get trials by session ID
  static Future<List<Map<String, dynamic>>> getTrialsBySession(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/trials/session/$sessionId'),
        headers: headers,
      );

      _handleError(response);

      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['trials'] ?? []);
    } catch (e) {
      debugPrint('Error getting trials by session: $e');
      rethrow;
    }
  }

  /// Get trial by ID
  static Future<Map<String, dynamic>> getTrial(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/trials/$id'),
        headers: headers,
      );

      _handleError(response);

      final data = jsonDecode(response.body);
      return data['trial'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting trial: $e');
      rethrow;
    }
  }

  /// Delete trial
  static Future<void> deleteTrial(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/trials/$id'),
        headers: headers,
      );

      _handleError(response);
    } catch (e) {
      debugPrint('Error deleting trial: $e');
      rethrow;
    }
  }

  // ==================== HEALTH CHECK ====================

  /// Check if backend is available
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Health check failed: $e');
      return false;
    }
  }
}

