import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyPin = 'clinician_pin';
  static const String _keyName = 'clinician_name';
  static const String _keyHospital = 'clinician_hospital';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // Check if user is registered
  static Future<bool> isRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyPin);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Register new clinician
  static Future<bool> register({
    required String name,
    required String hospital,
    required String pin,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyName, name);
      await prefs.setString(_keyHospital, hospital);
      await prefs.setString(_keyPin, pin);
      await prefs.setBool(_keyIsLoggedIn, true);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Login with PIN
  static Future<bool> login(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPin = prefs.getString(_keyPin);
      
      if (savedPin == pin) {
        await prefs.setBool(_keyIsLoggedIn, true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get clinician info
  static Future<Map<String, String?>> getClinicianInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyName),
      'hospital': prefs.getString(_keyHospital),
    };
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}

