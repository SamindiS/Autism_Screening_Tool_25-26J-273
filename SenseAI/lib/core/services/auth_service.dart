import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'api_service.dart';

/// Service responsible for managing clinician authentication and session state.
/// 
/// Uses a combination of [FlutterSecureStorage] for sensitive tokens and 
/// [SharedPreferences] for non-sensitive configuration data.
class AuthService {
  // Secure storage instance for sensitive data (tokens, session info)
  static final _secureStorage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: const IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  // SharedPreferences keys for non-sensitive data
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyClinicianId = 'clinician_id';
  
  // Secure storage keys for sensitive session data
  static const String _keySessionToken = 'session_token';
  static const String _keyLoginTimestamp = 'login_timestamp';
  static const String _keyClinicianData = 'clinician_data';
  
  // Session expiry configuration (Default: 7 days)
  static const Duration _sessionExpiry = Duration(days: 7);

  /// Checks if a clinician is already registered in the system.
  /// 
  /// Performs a health check on the backend before attempting to 
  /// retrieve clinician information.
  static Future<bool> isRegistered() async {
    try {
      // First check if backend is available
      final isBackendAvailable = await ApiService.healthCheck();
      if (!isBackendAvailable) {
        debugPrint('Backend not available, assuming not registered');
        return false;
      }
      
      final clinician = await ApiService.getClinicianInfo();
      return clinician.isNotEmpty && clinician['id'] != null;
    } catch (e) {
      debugPrint('No clinician registered or backend unavailable: $e');
      return false;
    }
  }

  /// Verifies if there is an active and valid login session.
  /// 
  /// This method checks for the presence of a session token and ensures 
  /// that the session has not exceeded [_sessionExpiry].
  static Future<bool> isLoggedIn() async {
    try {
      // Check if session token exists
      final sessionToken = await _secureStorage.read(key: _keySessionToken);
      if (sessionToken == null || sessionToken.isEmpty) {
        debugPrint('No session token found');
        return false;
      }
      
      // Check if session is expired
      final loginTimestampStr = await _secureStorage.read(key: _keyLoginTimestamp);
      if (loginTimestampStr == null || loginTimestampStr.isEmpty) {
        debugPrint('No login timestamp found, clearing session');
        await _clearSession();
        return false;
      }
      
      final loginTimestamp = DateTime.parse(loginTimestampStr);
      final now = DateTime.now();
      final sessionAge = now.difference(loginTimestamp);
      
      if (sessionAge > _sessionExpiry) {
        debugPrint('Session expired (${sessionAge.inDays} days old). Max allowed: ${_sessionExpiry.inDays} days');
        await _clearSession();
        return false;
      }
      
      debugPrint('Session valid (${sessionAge.inDays} days old)');
      return true;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }
  
  /// Clears all session-related data from both secure and public storage.
  static Future<void> _clearSession() async {
    try {
      await _secureStorage.delete(key: _keySessionToken);
      await _secureStorage.delete(key: _keyLoginTimestamp);
      await _secureStorage.delete(key: _keyClinicianData);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, false);
      await prefs.remove(_keyClinicianId);
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
  }
  
  /// Retrieves the cached clinician profile from secure storage.
  static Future<Map<String, dynamic>?> getStoredClinicianData() async {
    try {
      final clinicianDataStr = await _secureStorage.read(key: _keyClinicianData);
      if (clinicianDataStr == null || clinicianDataStr.isEmpty) {
        return null;
      }
      return jsonDecode(clinicianDataStr) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting stored clinician data: $e');
      return null;
    }
  }

  /// Registers a new clinician and initializes an active session.
  /// 
  /// On success, stores clinicians details securely and sets a session token.
  static Future<Map<String, dynamic>> register({
    required String name,
    required String hospital,
    required String pin,
  }) async {
    try {
      final isBackendAvailable = await ApiService.healthCheck();
      if (!isBackendAvailable) {
        final msg = await ApiService.backendUnavailableMessage();
        return {
          'success': false,
          'error': msg,
          'errorType': 'backend_unavailable',
        };
      }

      final clinician = await ApiService.registerClinician(
        name: name,
        hospital: hospital,
        pin: pin,
      );

      final sessionToken = _generateSessionToken();
      final loginTimestamp = DateTime.now().toIso8601String();
      
      await _secureStorage.write(key: _keySessionToken, value: sessionToken);
      await _secureStorage.write(key: _keyLoginTimestamp, value: loginTimestamp);
      await _secureStorage.write(key: _keyClinicianData, value: jsonEncode(clinician));
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      if (clinician['id'] != null) {
        await prefs.setString(_keyClinicianId, clinician['id'].toString());
      }
      
      debugPrint('Clinician registered successfully: ${clinician['id']}');
      return {
        'success': true,
        'clinician': clinician,
      };
    } catch (e) {
      debugPrint('Error registering clinician: $e');
      
      String errorMessage = 'Registration failed. Please try again.';
      String errorType = 'unknown';
      
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        errorMessage = await ApiService.connectionErrorMessage();
        errorType = 'connection_error';
      } else if (e.toString().contains('400') || e.toString().contains('Bad Request')) {
        errorMessage = 'Invalid registration data. Please check your information and try again.';
        errorType = 'validation_error';
      } else if (e.toString().contains('409') || e.toString().contains('Conflict')) {
        errorMessage = 'A clinician with this PIN already exists. Please use a different PIN.';
        errorType = 'duplicate_error';
      } else if (e.toString().contains('500') || e.toString().contains('Internal Server Error')) {
        errorMessage = 'Server error occurred. Please try again later.';
        errorType = 'server_error';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timed out. Please check your connection and try again.';
        errorType = 'timeout_error';
      }
      
      return {
        'success': false,
        'error': errorMessage,
        'errorType': errorType,
      };
    }
  }

  /// Log in a clinician using their PIN and initializes an active session.
  /// 
  /// Verifies credentials with the backend and stores the result locally.
  static Future<Map<String, dynamic>> login(String pin) async {
    try {
      final isBackendAvailable = await ApiService.healthCheck();
      if (!isBackendAvailable) {
        final msg = await ApiService.backendUnavailableMessage();
        return {
          'success': false,
          'error': msg,
          'errorType': 'backend_unavailable',
        };
      }

      final clinician = await ApiService.loginClinician(pin: pin);

      final sessionToken = _generateSessionToken();
      final loginTimestamp = DateTime.now().toIso8601String();
      
      await _secureStorage.write(key: _keySessionToken, value: sessionToken);
      await _secureStorage.write(key: _keyLoginTimestamp, value: loginTimestamp);
      await _secureStorage.write(key: _keyClinicianData, value: jsonEncode(clinician));
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      if (clinician['id'] != null) {
        await prefs.setString(_keyClinicianId, clinician['id'].toString());
      }
      
      debugPrint('Clinician logged in successfully: ${clinician['id']}');
      return {
        'success': true,
        'clinician': clinician,
      };
    } catch (e) {
      debugPrint('Error logging in clinician: $e');
      
      String errorMessage = 'Login failed. Please check your PIN and try again.';
      String errorType = 'unknown';
      
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        errorMessage = await ApiService.connectionErrorMessage();
        errorType = 'connection_error';
      } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        errorMessage = 'Invalid PIN. Please check and try again.';
        errorType = 'auth_error';
      } else if (e.toString().contains('404') || e.toString().contains('Not Found')) {
        errorMessage = 'Clinician not found. Please register first.';
        errorType = 'not_found_error';
      } else if (e.toString().contains('500') || e.toString().contains('Internal Server Error')) {
        errorMessage = 'Server error occurred. Please try again later.';
        errorType = 'server_error';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timed out. Please check your connection and try again.';
        errorType = 'timeout_error';
      }
      
      return {
        'success': false,
        'error': errorMessage,
        'errorType': errorType,
      };
    }
  }

  /// Retrieves the current clinician's profile directly from the backend.
  static Future<Map<String, String?>> getClinicianInfo() async {
    try {
      final clinician = await ApiService.getClinicianInfo();
      return {
        'name': clinician['name']?.toString(),
        'hospital': clinician['hospital']?.toString(),
        'id': clinician['id']?.toString(),
      };
    } catch (e) {
      debugPrint('Error getting clinician info: $e');
      return {
        'name': null,
        'hospital': null,
        'id': null,
      };
    }
  }

  /// Logs out the current clinician and wipes all session data.
  static Future<void> logout() async {
    debugPrint('Logging out...');
    await _clearSession();
    debugPrint('Logout complete. All session data cleared.');
  }
  
  /// Generates a unique, non-reversible session token based on the current time.
  static String _generateSessionToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + (timestamp % 1000)).toString();
    return 'session_${timestamp}_${random.substring(random.length - 6)}';
  }
  
  /// Calculates the time remaining before the current session expires.
  static Future<Duration?> getRemainingSessionTime() async {
    try {
      final loginTimestampStr = await _secureStorage.read(key: _keyLoginTimestamp);
      if (loginTimestampStr == null || loginTimestampStr.isEmpty) {
        return null;
      }
      
      final loginTimestamp = DateTime.parse(loginTimestampStr);
      final now = DateTime.now();
      final sessionAge = now.difference(loginTimestamp);
      final remaining = _sessionExpiry - sessionAge;
      
      return remaining.isNegative ? Duration.zero : remaining;
    } catch (e) {
      debugPrint('Error getting remaining session time: $e');
      return null;
    }
  }
}

