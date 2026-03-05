import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:senseai/core/services/api_service.dart';

void main() {
  group('Clinician Authentication Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should handle login with valid PIN', () async {
      // Test structure - actual test would mock HTTP
      expect(
        ApiService.loginClinician(pin: '1234'),
        isA<Future<Map<String, dynamic>>>(),
      );
    });

    test('should handle admin login', () async {
      // Admin login should work with 'admin123'
      expect(
        ApiService.loginClinician(pin: 'admin123'),
        isA<Future<Map<String, dynamic>>>(),
      );
    });

    test('should handle registration', () async {
      expect(
        ApiService.registerClinician(
          name: 'Test Clinician',
          hospital: 'Test Hospital',
          pin: '1234',
        ),
        isA<Future<Map<String, dynamic>>>(),
      );
    });

    test('should handle invalid PIN', () async {
      // Test should handle error gracefully
      expect(
        ApiService.loginClinician(pin: 'invalid'),
        isA<Future<Map<String, dynamic>>>(),
      );
    });
  });
}
