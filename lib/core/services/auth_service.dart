import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyClinicianId = 'clinician_id';

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

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
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

      // Save login state locally
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

      // Save login state locally
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

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyClinicianId);
  }
}

