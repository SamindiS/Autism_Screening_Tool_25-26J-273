import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'api_service.dart';

class AuthService {
  // Secure storage for sensitive data (tokens, session info)
  static final _secureStorage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: const IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  // SharedPreferences for non-sensitive data (backward compatibility)
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyClinicianId = 'clinician_id';
  
  // Secure storage keys
  static const String _keySessionToken = 'session_token';
  static const String _keyLoginTimestamp = 'login_timestamp';
  static const String _keyClinicianData = 'clinician_data';
  
  // Session expiry: 7 days (configurable)
  static const Duration _sessionExpiry = Duration(days: 7);

  // Check if user is registered (check backend)
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

  // Check if user is logged in (with session expiry check)
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
  
  // Clear session data (secure storage)
  static Future<void> _clearSession() async {
    try {
      await _secureStorage.delete(key: _keySessionToken);
      await _secureStorage.delete(key: _keyLoginTimestamp);
      await _secureStorage.delete(key: _keyClinicianData);
      
      // Also clear SharedPreferences for backward compatibility
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, false);
      await prefs.remove(_keyClinicianId);
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
  }
  
  // Get stored clinician data
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

  // Register new clinician (via API)
  static Future<Map<String, dynamic>> register({
    required String name,
    required String hospital,
    required String pin,
  }) async {
    try {
      // First check if backend is available
      final isBackendAvailable = await ApiService.healthCheck();
      if (!isBackendAvailable) {
        return {
          'success': false,
          'error': 'Backend server is not available. Please ensure the backend server is running on port 3000.',
          'errorType': 'backend_unavailable',
        };
      }

      // Register via API
      final clinician = await ApiService.registerClinician(
        name: name,
        hospital: hospital,
        pin: pin,
      );

      // Generate session token (simple UUID-like string)
      final sessionToken = _generateSessionToken();
      final loginTimestamp = DateTime.now().toIso8601String();
      
      // Save to secure storage (encrypted)
      await _secureStorage.write(key: _keySessionToken, value: sessionToken);
      await _secureStorage.write(key: _keyLoginTimestamp, value: loginTimestamp);
      await _secureStorage.write(key: _keyClinicianData, value: jsonEncode(clinician));
      
      // Also save to SharedPreferences for backward compatibility
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      if (clinician['id'] != null) {
        await prefs.setString(_keyClinicianId, clinician['id'].toString());
      }
      
      debugPrint('Clinician registered successfully: ${clinician['id']}');
      debugPrint('Session token saved. Session expires in ${_sessionExpiry.inDays} days');
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
        errorMessage = 'Cannot connect to server. Please check:\n'
            '1. Backend server is running on port 3000\n'
            '2. You are connected to the correct network\n'
            '3. For emulator: Use http://10.0.2.2:3000\n'
            '4. For real device: Use your computer IP (e.g., http://192.168.1.100:3000)';
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

  // Login with PIN (via API)
  static Future<Map<String, dynamic>> login(String pin) async {
    try {
      // First check if backend is available
      final isBackendAvailable = await ApiService.healthCheck();
      if (!isBackendAvailable) {
        return {
          'success': false,
          'error': 'Backend server is not available. Please ensure the backend server is running on port 3000.',
          'errorType': 'backend_unavailable',
        };
      }

      // Login via API
      final clinician = await ApiService.loginClinician(pin: pin);

      // Generate session token (simple UUID-like string)
      final sessionToken = _generateSessionToken();
      final loginTimestamp = DateTime.now().toIso8601String();
      
      // Save to secure storage (encrypted)
      await _secureStorage.write(key: _keySessionToken, value: sessionToken);
      await _secureStorage.write(key: _keyLoginTimestamp, value: loginTimestamp);
      await _secureStorage.write(key: _keyClinicianData, value: jsonEncode(clinician));
      
      // Also save to SharedPreferences for backward compatibility
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      if (clinician['id'] != null) {
        await prefs.setString(_keyClinicianId, clinician['id'].toString());
      }
      
      debugPrint('Clinician logged in successfully: ${clinician['id']}');
      debugPrint('Session token saved. Session expires in ${_sessionExpiry.inDays} days');
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
        errorMessage = 'Cannot connect to server. Please check:\n'
            '1. Backend server is running on port 3000\n'
            '2. You are connected to the correct network\n'
            '3. For emulator: Use http://10.0.2.2:3000\n'
            '4. For real device: Use your computer IP (e.g., http://192.168.1.100:3000)';
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

  // Get clinician info (from API)
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

  // Logout (clears all session data)
  static Future<void> logout() async {
    debugPrint('Logging out...');
    await _clearSession();
    debugPrint('Logout complete. All session data cleared.');
  }
  
  // Generate a simple session token (UUID-like)
  static String _generateSessionToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + (timestamp % 1000)).toString();
    return 'session_${timestamp}_${random.substring(random.length - 6)}';
  }
  
  // Get remaining session time
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

