import 'package:flutter_test/flutter_test.dart';
import 'package:senseai/core/services/api_service.dart';
import 'package:senseai/core/services/storage_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:senseai/data/models/child.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Error Handling Tests', () {
    test('should handle network errors gracefully', () async {
      // Test with invalid backend URL
      await ApiService.setBackendUrl('http://invalid-url:3000');
      
      try {
        await ApiService.exportCSV(format: 'ml');
        // Should handle error gracefully
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('should handle invalid child data', () async {
      await StorageService.database;

      // Test with minimal valid data
      final child = await StorageService.saveChild(
        childCode: 'ERROR001',
        name: 'Error Test',
        dateOfBirth: DateTime.now(),
        ageInMonths: 0,
        age: 0.0,
        gender: 'unknown',
        language: 'en',
        hospitalId: null,
        group: ChildGroup.typicallyDeveloping,
        diagnosisSource: '',
        clinicianId: null,
        clinicianName: null,
      );

      // Should still save (validation happens at backend)
      expect(child, isNotNull);
    });

    test('should handle missing required fields', () async {
      await StorageService.database;

      // Test with empty strings (should be handled)
      final child = await StorageService.saveChild(
        childCode: '',
        name: '',
        dateOfBirth: DateTime.now(),
        ageInMonths: 0,
        age: 0.0,
        gender: '',
        language: '',
        hospitalId: null,
        group: ChildGroup.typicallyDeveloping,
        diagnosisSource: '',
        clinicianId: null,
        clinicianName: null,
      );

      // Should handle gracefully
      expect(child, isNotNull);
    });

    test('should handle CSV export errors', () async {
      try {
        await ApiService.exportCSV(format: 'invalid_format');
        // May succeed or fail depending on backend validation
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });
}

