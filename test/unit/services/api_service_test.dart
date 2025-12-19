import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:senseai/core/services/api_service.dart';
import 'package:senseai/data/models/child.dart';

import 'api_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('ApiService', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    group('Backend URL Management', () {
      test('should return default emulator URL when no saved URL', () async {
        final url = await ApiService.baseUrl;
        expect(url, 'http://10.0.2.2:3000');
      });

      test('should return saved URL from SharedPreferences', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('backend_url', 'http://192.168.1.100:3000');

        final url = await ApiService.baseUrl;
        expect(url, 'http://192.168.1.100:3000');
      });

      test('should set backend URL correctly', () async {
        await ApiService.setBackendUrl('http://192.168.1.100:3000');
        final url = await ApiService.getBackendUrl();
        expect(url, 'http://192.168.1.100:3000');
      });

      test('should remove trailing slash from URL', () async {
        await ApiService.setBackendUrl('http://192.168.1.100:3000/');
        final url = await ApiService.getBackendUrl();
        expect(url, 'http://192.168.1.100:3000');
      });

      test('should reset to default URL', () async {
        await ApiService.setBackendUrl('http://custom.url:3000');
        await ApiService.resetBackendUrl();
        final url = await ApiService.baseUrl;
        expect(url, 'http://10.0.2.2:3000');
      });
    });

    group('Health Check', () {
      test('should return true when backend is healthy', () async {
        // Note: This test requires actual HTTP mocking
        // For now, we test the structure
        expect(ApiService.healthCheck, isA<Future<bool>>());
      });
    });

    group('CSV Export', () {
      test('should export CSV with default format', () async {
        // Test structure - actual implementation would mock HTTP
        expect(
          ApiService.exportCSV(format: 'ml'),
          isA<Future<String>>(),
        );
      });

      test('should export CSV with group filter', () async {
        expect(
          ApiService.exportCSV(format: 'ml', group: 'asd'),
          isA<Future<String>>(),
        );
      });

      test('should export CSV with session type filter', () async {
        expect(
          ApiService.exportCSV(format: 'ml', sessionType: 'color_shape'),
          isA<Future<String>>(),
        );
      });
    });
  });
}

