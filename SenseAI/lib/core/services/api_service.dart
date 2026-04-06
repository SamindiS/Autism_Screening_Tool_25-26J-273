// api_service.dart - Backend API Integration Service
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/child.dart';

/// Service responsible for all backend API communications.
/// 
/// Handles authentication, child management, session tracking, and 
/// assessment trial data synchronization.
class ApiService {
  // Default URLs for different platforms
  static const String _defaultEmulatorUrl =
      'http://10.0.2.2:3000'; // Android emulator
  static const String _defaultSimulatorUrl =
      'http://localhost:3000'; // iOS simulator
  static const String _defaultRealDeviceUrl =
      'https://autism-screening-tool-25-26-j-273.vercel.app';
  //'http://192.168.48.180:3000'; // Real device (updated to user IP)

  // SharedPreferences key for storing backend URL
  static const String _backendUrlKey = 'backend_url';

  /// Set when health check fails with 401 and Vercel auth page (Deployment Protection).
  static String? lastHealthCheckFailureHint;

  /// Gets the base URL for API calls.
  /// 
  /// Checks [SharedPreferences] first for a user-defined URL, 
  /// then falls back to platform-specific defaults.
  static Future<String> get baseUrl async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(_backendUrlKey);

    if (savedUrl != null && savedUrl.isNotEmpty) {
      return savedUrl;
    }

    // Return default based on platform
    // Default to real device URL for easier physical device testing
    return _defaultRealDeviceUrl;
  }

  /// Sets the backend URL and persists it in [SharedPreferences].
  /// 
  /// This is used primarily for configuring real devices to connect 
  /// to a local development server.
  static Future<void> setBackendUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    // Remove trailing slash if present
    final cleanUrl = url.trim().replaceAll(RegExp(r'/$'), '');
    await prefs.setString(_backendUrlKey, cleanUrl);
    debugPrint('Backend URL set to: $cleanUrl');
  }

  /// Retrieves the current effective backend URL.
  static Future<String> getBackendUrl() async {
    return await baseUrl;
  }

  /// Returns a user-facing connection error message appropriate for the current backend URL.
  static Future<String> connectionErrorMessage() async {
    final url = await baseUrl;
    final isVercel = url.contains('vercel.app');
    final isVercelProtection = lastHealthCheckFailureHint == 'vercel_protection';

    if (isVercelProtection && isVercel) {
      return 'Vercel Deployment Protection is blocking the app.\n\n'
          'In Vercel Dashboard:\n'
          '1. Open your project → Settings → Deployment Protection\n'
          '2. Set protection to "None" (or "Standard" so production is public)\n'
          '3. Redeploy if needed\n\n'
          'URL: $url';
    }

    final isCloud = url.startsWith('https://') && (url.contains('vercel.app') || url.contains('railway') || url.contains('heroku') || url.contains('render.com'));
    if (isCloud) {
      return 'Cannot reach backend. Please check:\n'
          '1. Your device has internet access\n'
          '2. Backend URL is correct\n'
          '3. Try again in a moment (server may be starting)\n'
          '4. URL: $url';
    }
    return 'Connection failed. Please check:\n'
        '1. Backend server is running on port 3000\n'
        '2. Your computer and tablet are on the same Wi-Fi\n'
        '3. Windows Firewall allows port 3000\n'
        '4. URL is correct: $url';
  }

  /// Returns a short "backend not available" message (for login/register).
  static Future<String> backendUnavailableMessage() async {
    final url = await baseUrl;
    final isVercel = url.contains('vercel.app');
    final isVercelProtection = lastHealthCheckFailureHint == 'vercel_protection';

    if (isVercelProtection && isVercel) {
      return 'Vercel Deployment Protection is on. In Vercel: Project → Settings → Deployment Protection → set to "None". URL: $url';
    }

    final isCloud = url.startsWith('https://') && (url.contains('vercel.app') || url.contains('railway') || url.contains('heroku') || url.contains('render.com'));
    if (isCloud) {
      return 'Backend is not reachable. Check internet connection and that the URL is correct: $url';
    }
    return 'Backend server is not available. Ensure the server is running on port 3000 and the URL is correct: $url';
  }

  /// Reset to default URL
  static Future<void> resetBackendUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_backendUrlKey);
  }

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  /// Centralized error handler for HTTP responses.
  /// 
  /// Throws an [Exception] if the status code indicates a failure (>= 400).
  /// Attempts to parse error details from the response body.
  static void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      final errorBody = response.body;
      try {
        final errorJson = jsonDecode(errorBody);
        final errorMessage = errorJson['error'] ?? 'Request failed';
        final details = errorJson['details'];
        throw Exception(
            details != null ? '$errorMessage: $details' : errorMessage);
      } catch (e) {
        if (e is Exception) {
          rethrow;
        }
        throw Exception(
            'Request failed: ${response.statusCode} - ${response.body}');
      }
    }
  }

  // ==================== CLINICIANS ====================

  /// Registers a new clinician or updates an existing profile.
  /// 
  /// Returns the registered clinician data as a [Map].
  static Future<Map<String, dynamic>> registerClinician({
    required String name,
    required String hospital,
    required String pin,
  }) async {
    try {
      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/api/clinicians/register'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'hospital': hospital,
          'pin': pin,
        }),
      );

      _handleError(response);

      final data = jsonDecode(response.body);
      return data['clinician'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error registering clinician: $e');
      rethrow;
    }
  }

  /// Authenticates a clinician using their unique PIN.
  /// 
  /// Returns the clinician profile on success.
  static Future<Map<String, dynamic>> loginClinician({
    required String pin,
  }) async {
    try {
      final url = await baseUrl;
      // Ensure PIN is trimmed and normalized
      final normalizedPin = pin.trim();
      debugPrint('🔐 Attempting login to: $url/api/clinicians/login');
      debugPrint('📌 PIN length: ${normalizedPin.length}');
      debugPrint(
          '📌 PIN value (first 2): ${normalizedPin.isNotEmpty ? '${normalizedPin.substring(0, normalizedPin.length > 2 ? 2 : normalizedPin.length)}***' : 'empty'}');

      final requestBody = jsonEncode({'pin': normalizedPin});
      debugPrint(
          '📤 Request body: ${requestBody.replaceAll(normalizedPin, '***')}');

      final response = await http
          .post(
        Uri.parse('$url/api/clinicians/login'),
        headers: headers,
        body: jsonEncode({'pin': normalizedPin}), // Use normalized PIN
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏱️ Login request timeout after 10 seconds');
          throw TimeoutException('Login request timed out');
        },
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      _handleError(response);

      final data = jsonDecode(response.body);

      // Check for success flag first
      if (data.containsKey('success') && data['success'] == true) {
        // Backend returns 'user' for both admin and clinician, but also includes 'clinician' for compatibility
        // Try 'clinician' first (for backward compatibility), then 'user'
        if (data.containsKey('clinician')) {
          debugPrint('✅ Login successful - using clinician data');
          return data['clinician'] as Map<String, dynamic>;
        } else if (data.containsKey('user')) {
          debugPrint('✅ Login successful - using user data');
          return data['user'] as Map<String, dynamic>;
        } else {
          debugPrint('❌ Login response missing clinician/user data');
          throw Exception(
              'Invalid login response: missing clinician/user data');
        }
      } else {
        // Login failed
        final errorMsg = data['error'] ?? data['message'] ?? 'Login failed';
        debugPrint('❌ Login failed: $errorMsg');
        throw Exception(errorMsg);
      }
    } on TimeoutException {
      debugPrint('❌ Login timeout - check network connection');
      rethrow;
    } catch (e) {
      debugPrint('❌ Error logging in clinician: $e');
      debugPrint('   URL: ${await baseUrl}/api/clinicians/login');
      if (e.toString().contains('SocketException')) {
        debugPrint('   → Network error - cannot connect to server');
      } else if (e.toString().contains('Failed host lookup')) {
        debugPrint('   → Cannot resolve host - check IP address');
      } else if (e.toString().contains('Connection refused')) {
        debugPrint('   → Connection refused - check if backend is running');
      }
      rethrow;
    }
  }

  /// Get current clinician info
  /// Uses stored clinician ID from login, or falls back to /me endpoint
  static Future<Map<String, dynamic>> getClinicianInfo() async {
    try {
      // First try to get stored clinician ID from login
      final prefs = await SharedPreferences.getInstance();
      final storedClinicianId = prefs.getString('clinician_id');

      final url = await baseUrl;

      if (storedClinicianId != null && storedClinicianId.isNotEmpty) {
        // Use stored ID to get specific clinician (longer timeout for slow networks)
        debugPrint('📋 Getting clinician info by ID: $storedClinicianId');
        final response = await http
            .get(
              Uri.parse('$url/api/clinicians/$storedClinicianId'),
              headers: headers,
            )
            .timeout(const Duration(seconds: 20));

        _handleError(response);

        final data = jsonDecode(response.body);
        return data['clinician'] as Map<String, dynamic>;
      } else {
        // Fallback to /me endpoint (for backward compatibility)
        debugPrint('⚠️ No stored clinician ID, using /me endpoint');
        final response = await http
            .get(
              Uri.parse('$url/api/clinicians/me'),
              headers: headers,
            )
            .timeout(const Duration(seconds: 20));

        _handleError(response);

        final data = jsonDecode(response.body);
        return data['clinician'] as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('❌ Error getting clinician info: $e');
      rethrow;
    }
  }

  /// Update clinician
  static Future<Map<String, dynamic>> updateClinician({
    required String id,
    required String name,
    required String hospital,
    required String pin,
  }) async {
    try {
      final url = await baseUrl;
      final response = await http.put(
        Uri.parse('$url/api/clinicians/$id'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'hospital': hospital,
          'pin': pin,
        }),
      );

      _handleError(response);

      final data = jsonDecode(response.body);
      return data['clinician'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error updating clinician: $e');
      rethrow;
    }
  }

  /// Delete clinician
  static Future<void> deleteClinician(String id) async {
    try {
      final url = await baseUrl;
      final response = await http.delete(
        Uri.parse('$url/api/clinicians/$id'),
        headers: headers,
      );

      _handleError(response);
    } catch (e) {
      debugPrint('Error deleting clinician: $e');
      rethrow;
    }
  }

  // ==================== CHILDREN ====================

  /// Creates a new child profile in the backend database.
  /// 
  /// Captures clinical metadata including age, gender, and study group.
  static Future<Map<String, dynamic>> createChild({
    required String childCode,
    required String name,
    required DateTime dateOfBirth,
    required int ageInMonths,
    required String gender,
    required String language,
    String? hospitalId,
    required ChildGroup group,
    AsdLevel? asdLevel,
    required String diagnosisSource,
    String? clinicianId,
    String? clinicianName,
    String diagnosisType = 'new',
    String? createdByClinicianId,
  }) async {
    try {
      // Convert gender to lowercase to match backend validation
      final normalizedGender = gender.toLowerCase();

      final url = await baseUrl;
      debugPrint('🌐 Creating child via API: $url/api/children');
      final requestBody = {
        'child_code': childCode,
        'name': name,
        'date_of_birth': dateOfBirth.millisecondsSinceEpoch,
        'age_in_months': ageInMonths,
        'gender': normalizedGender,
        'language': language,
        'hospital_id': hospitalId,
        'group': group.toJson(),
        'asd_level': asdLevel?.toJson(),
        'diagnosis_source': diagnosisSource,
        'clinician_id': clinicianId,
        'clinician_name': clinicianName,
        'diagnosis_type': diagnosisType,
        if (createdByClinicianId != null && createdByClinicianId.isNotEmpty)
          'created_by_clinician_id': createdByClinicianId,
      };
      debugPrint('📤 Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$url/api/children'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      _handleError(response);

      final data = jsonDecode(response.body);
      debugPrint('✅ Child created successfully: ${data['child']?['id']}');
      return data['child'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Error creating child: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Get all children (backend returns all; prefer getChildrenByClinician when logged in)
  static Future<List<Map<String, dynamic>>> getAllChildren() async {
    try {
      final url = await baseUrl;
      final response = await http.get(
        Uri.parse('$url/api/children'),
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

  /// Get children for the logged-in clinician only (fixes dashboard counting other clinicians' children)
  static Future<List<Map<String, dynamic>>> getChildrenByClinician(
      String clinicianId) async {
    try {
      final url = await baseUrl;
      final response = await http.get(
        Uri.parse('$url/api/children/clinician/$clinicianId'),
        headers: headers,
      );

      _handleError(response);

      final data = jsonDecode(response.body);
      final list = List<Map<String, dynamic>>.from(data['children'] ?? []);
      debugPrint(
          '📋 Loaded ${list.length} children for clinician $clinicianId');
      return list;
    } catch (e) {
      debugPrint('Error getting children by clinician: $e');
      rethrow;
    }
  }

  /// Get child by ID
  static Future<Map<String, dynamic>> getChild(String id) async {
    try {
      final url = await baseUrl;
      final response = await http
          .get(
            Uri.parse('$url/api/children/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 5));

      _handleError(response);

      final data = jsonDecode(response.body);
      return data['child'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting child: $e');
      rethrow;
    }
  }

  /// Update child with study profile fields
  static Future<Map<String, dynamic>> updateChild({
    required String id,
    required String childCode,
    required String name,
    required DateTime dateOfBirth,
    required int ageInMonths,
    required String gender,
    required String language,
    String? hospitalId,
    required ChildGroup group,
    AsdLevel? asdLevel,
    required String diagnosisSource,
    String? clinicianId,
    String? clinicianName,
    String diagnosisType = 'new',
  }) async {
    try {
      // Convert gender to lowercase to match backend validation
      final normalizedGender = gender.toLowerCase();

      final url = await baseUrl;
      final response = await http.put(
        Uri.parse('$url/api/children/$id'),
        headers: headers,
        body: jsonEncode({
          'child_code': childCode,
          'name': name,
          'date_of_birth': dateOfBirth.millisecondsSinceEpoch,
          'age_in_months': ageInMonths,
          'gender': normalizedGender,
          'language': language,
          'hospital_id': hospitalId,
          'group': group.toJson(),
          'asd_level': asdLevel?.toJson(),
          'diagnosis_source': diagnosisSource,
          'clinician_id': clinicianId,
          'clinician_name': clinicianName,
          'diagnosis_type': diagnosisType,
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
      final url = await baseUrl;
      final response = await http
          .delete(
            Uri.parse('$url/api/children/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      _handleError(response);
    } catch (e) {
      debugPrint('Error deleting child: $e');
      rethrow;
    }
  }

  // ==================== SESSIONS ====================

  /// Initializes a new assessment session for a child.
  /// 
  /// Returns the newly created session object.
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
    String? createdByClinicianId,
  }) async {
    try {
      final url = await baseUrl;
      debugPrint('🌐 Creating session via API: $url/api/sessions');
      final requestBody = {
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
        if (createdByClinicianId != null && createdByClinicianId.isNotEmpty)
          'created_by_clinician_id': createdByClinicianId,
      };
      debugPrint('📤 Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('$url/api/sessions'),
            headers: headers,
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 5));

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      _handleError(response);

      final data = jsonDecode(response.body);
      debugPrint('✅ Session created successfully: ${data['session']?['id']}');
      return data['session'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Error creating session: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Get all sessions
  static Future<List<Map<String, dynamic>>> getAllSessions() async {
    try {
      final url = await baseUrl;
      final response = await http
          .get(
            Uri.parse('$url/api/sessions'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      _handleError(response);

      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['sessions'] ?? []);
    } catch (e) {
      debugPrint('Error getting sessions: $e');
      rethrow;
    }
  }

  /// Get sessions created by a clinician (fast for dashboards)
  static Future<List<Map<String, dynamic>>> getSessionsByClinician(
      String clinicianId) async {
    try {
      final url = await baseUrl;
      final response = await http
          .get(
            Uri.parse('$url/api/sessions/clinician/$clinicianId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      _handleError(response);

      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['sessions'] ?? []);
    } catch (e) {
      debugPrint('Error getting sessions by clinician: $e');
      rethrow;
    }
  }

  /// Get session by ID
  static Future<Map<String, dynamic>> getSession(String id) async {
    try {
      final url = await baseUrl;
      final response = await http.get(
        Uri.parse('$url/api/sessions/$id'),
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
  static Future<List<Map<String, dynamic>>> getSessionsByChild(
      String childId) async {
    try {
      final url = await baseUrl;
      final response = await http.get(
        Uri.parse('$url/api/sessions/child/$childId'),
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
      if (questionnaireResults != null) {
        body['questionnaire_results'] = questionnaireResults;
      }
      if (reflectionResults != null) {
        body['reflection_results'] = reflectionResults;
      }
      if (riskScore != null) body['risk_score'] = riskScore;
      if (riskLevel != null) body['risk_level'] = riskLevel;

      final url = await baseUrl;
      final response = await http.put(
        Uri.parse('$url/api/sessions/$id'),
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
      final url = await baseUrl;
      final response = await http.delete(
        Uri.parse('$url/api/sessions/$id'),
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
      final url = await baseUrl;
      final httpResponse = await http.post(
        Uri.parse('$url/api/trials'),
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

      _handleError(httpResponse);

      final data = jsonDecode(httpResponse.body);
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
      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/api/trials/batch'),
        headers: headers,
        body: jsonEncode({
          'trials': trials
              .map((trial) => {
                    ...trial,
                    'timestamp': trial['timestamp'] is DateTime
                        ? (trial['timestamp'] as DateTime)
                            .millisecondsSinceEpoch
                        : trial['timestamp'],
                  })
              .toList(),
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
  static Future<List<Map<String, dynamic>>> getTrialsBySession(
      String sessionId) async {
    try {
      final url = await baseUrl;
      final response = await http.get(
        Uri.parse('$url/api/trials/session/$sessionId'),
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
      final url = await baseUrl;
      final response = await http.get(
        Uri.parse('$url/api/trials/$id'),
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
      final url = await baseUrl;
      final response = await http.delete(
        Uri.parse('$url/api/trials/$id'),
        headers: headers,
      );

      _handleError(response);
    } catch (e) {
      debugPrint('Error deleting trial: $e');
      rethrow;
    }
  }

  // ==================== CSV EXPORT ====================

  /// Export data to CSV format
  ///
  /// Parameters:
  /// - format: 'ml' (for ML training) or 'raw' (raw data)
  /// - group: Optional filter by group ('asd' or 'typically_developing')
  /// - sessionType: Optional filter by session type
  /// - ageGroup: Optional filter by age group ('2-3.5', '3.5-5.5', '5.5-6.9')
  static Future<String> exportCSV({
    String format = 'ml',
    String? group,
    String? sessionType,
    String? ageGroup,
  }) async {
    try {
      final url = await baseUrl;
      final queryParams = <String, String>{
        'format': format,
      };

      if (group != null) {
        queryParams['group'] = group;
      }

      if (sessionType != null) {
        queryParams['sessionType'] = sessionType;
      }

      if (ageGroup != null) {
        queryParams['ageGroup'] = ageGroup;
      }

      final uri = Uri.parse('$url/api/export/csv')
          .replace(queryParameters: queryParams);
      debugPrint('📥 Exporting CSV: $uri');

      final response = await http.get(uri, headers: headers);

      _handleError(response);

      if (response.statusCode == 200) {
        debugPrint(
            '✅ CSV exported successfully (${response.body.length} bytes)');
        return response.body;
      } else {
        throw Exception('Failed to export CSV: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error exporting CSV: $e');
      rethrow;
    }
  }

  // ==================== HEALTH CHECK ====================

  /// Check if backend is available.
  /// For Vercel (and similar) deployments, tries /api/health then /health.
  static Future<bool> healthCheck() async {
    final url = await baseUrl;
    final isVercel = url.contains('vercel.app');
    final paths = isVercel ? ['/api/health', '/health'] : ['/health'];
    lastHealthCheckFailureHint = null;

    for (final path in paths) {
      try {
        final fullUrl = '$url$path';
        debugPrint('🔍 Health check: Testing connection to $fullUrl');
        final response = await http
            .get(
          Uri.parse(fullUrl),
          headers: headers,
        )
            .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('⏱️ Health check timeout after 10 seconds');
            throw TimeoutException('Health check timed out');
          },
        );

        final isHealthy = response.statusCode == 200;
        if (response.statusCode == 401 &&
            (response.body.contains('Authentication Required') ||
                response.body.contains('Vercel Authentication') ||
                response.body.contains('vercel.com/sso-api'))) {
          lastHealthCheckFailureHint = 'vercel_protection';
          debugPrint('   → Vercel Deployment Protection is enabled (401). Disable it in Vercel project Settings.');
        }
        debugPrint(
            '${isHealthy ? "✅" : "❌"} Health check response: ${response.statusCode} - ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');
        if (isHealthy) return true;
      } on TimeoutException {
        debugPrint('❌ Health check timeout for $url$path');
      } catch (e) {
        debugPrint('❌ Health check failed for $url$path: $e');
        if (e.toString().contains('Failed host lookup')) {
          debugPrint('   → Cannot resolve host - check URL and internet');
        } else if (e.toString().contains('Connection refused')) {
          debugPrint('   → Connection refused - check if backend is running');
        } else if (e.toString().contains('Network is unreachable')) {
          debugPrint('   → Network unreachable - check Wi-Fi/internet');
        }
      }
    }

    debugPrint('   URL attempted: $url (tried: ${paths.join(", ")})');
    return false;
  }
}
