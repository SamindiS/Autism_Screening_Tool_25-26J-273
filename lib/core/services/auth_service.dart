import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyClinicianId = 'clinician_id';

  // Check if user is registered (check backend)
  static Future<bool> isRegistered() async {
    try {
      final clinician = await ApiService.getClinicianInfo();
      return clinician.isNotEmpty;
    } catch (e) {
      debugPrint('No clinician registered: $e');
      return false;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Register new clinician (via API)
  static Future<bool> register({
    required String name,
    required String hospital,
    required String pin,
  }) async {
    try {
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
      return true;
    } catch (e) {
      debugPrint('Error registering clinician: $e');
      return false;
    }
  }

  // Login with PIN (via API)
  static Future<bool> login(String pin) async {
    try {
      // Login via API
      final clinician = await ApiService.loginClinician(pin: pin);

      // Save login state locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      if (clinician['id'] != null) {
        await prefs.setString(_keyClinicianId, clinician['id'].toString());
      }
      
      debugPrint('Clinician logged in successfully: ${clinician['id']}');
      return true;
    } catch (e) {
      debugPrint('Error logging in clinician: $e');
      return false;
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

