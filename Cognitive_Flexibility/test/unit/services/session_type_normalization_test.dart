import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:senseai/core/services/storage_service.dart';
import 'package:senseai/data/models/child.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Session Type Normalization Tests', () {
    late Map<String, dynamic> testChild;

    setUp(() async {
      await StorageService.database;
      final child = await StorageService.saveChild(
        childCode: 'NORM001',
        name: 'Normalization Test',
        dateOfBirth: DateTime(2020, 1, 1),
        ageInMonths: 48,
        age: 4.0,
        gender: 'male',
        language: 'en',
        hospitalId: 'HOSP001',
        group: ChildGroup.typicallyDeveloping,
        diagnosisSource: 'Test Hospital',
        clinicianId: 'CLIN001',
        clinicianName: 'Test Clinician',
      );
      testChild = child!;
    });

    test('should normalize color-shape to color_shape', () async {
      final session = await StorageService.saveSession(
        childId: testChild['id'] as String,
        sessionType: 'color-shape', // With hyphen
        ageGroup: '5-6',
        startTime: DateTime.now(),
      );

      expect(session, isNotNull);
      expect(session!['session_type'], 'color_shape'); // Should be normalized
    });

    test('should normalize frog-jump to frog_jump', () async {
      final session = await StorageService.saveSession(
        childId: testChild['id'] as String,
        sessionType: 'frog-jump', // With hyphen
        ageGroup: '3.5-5.5',
        startTime: DateTime.now(),
      );

      expect(session, isNotNull);
      expect(session!['session_type'], 'frog_jump'); // Should be normalized
    });

    test('should normalize dccs-color-shape to color_shape', () async {
      final session = await StorageService.saveSession(
        childId: testChild['id'] as String,
        sessionType: 'dccs-color-shape', // With prefix and hyphen
        ageGroup: '5-6',
        startTime: DateTime.now(),
      );

      expect(session, isNotNull);
      expect(session!['session_type'], 'color_shape'); // Should be normalized
    });

    test('should keep already normalized types unchanged', () async {
      final session = await StorageService.saveSession(
        childId: testChild['id'] as String,
        sessionType: 'color_shape', // Already normalized
        ageGroup: '5-6',
        startTime: DateTime.now(),
      );

      expect(session, isNotNull);
      expect(session!['session_type'], 'color_shape');
    });
  });
}

