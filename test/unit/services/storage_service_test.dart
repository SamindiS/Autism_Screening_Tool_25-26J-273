import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:senseai/core/services/storage_service.dart';
import 'package:senseai/data/models/child.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('StorageService', () {
    setUp(() async {
      // Clean up before each test
      await StorageService.database;
    });

    tearDown(() async {
      // Clean up after each test
      final db = await StorageService.database;
      await db.close();
      StorageService._database = null;
    });

    group('Child Management', () {
      test('should save child to local database', () async {
        final childData = await StorageService.saveChild(
          childCode: 'TEST001',
          name: 'Test Child',
          dateOfBirth: DateTime(2020, 1, 1),
          ageInMonths: 48,
          gender: 'male',
          language: 'en',
          hospitalId: 'HOSP001',
          group: ChildGroup.typicallyDeveloping,
          diagnosisSource: 'Test Hospital',
          clinicianId: 'CLIN001',
          clinicianName: 'Test Clinician',
        );

        expect(childData, isNotNull);
        expect(childData['child_code'], 'TEST001');
        expect(childData['name'], 'Test Child');
        expect(childData['age_in_months'], 48);
      });

      test('should retrieve all children from local database', () async {
        // Save a child first
        await StorageService.saveChild(
          childCode: 'TEST001',
          name: 'Test Child',
          dateOfBirth: DateTime(2020, 1, 1),
          ageInMonths: 48,
          gender: 'male',
          language: 'en',
          hospitalId: 'HOSP001',
          group: ChildGroup.typicallyDeveloping,
          diagnosisSource: 'Test Hospital',
          clinicianId: 'CLIN001',
          clinicianName: 'Test Clinician',
        );

        final children = await StorageService.getAllChildren();
        expect(children.length, greaterThan(0));
        expect(children.any((c) => c['child_code'] == 'TEST001'), isTrue);
      });

      test('should update child in local database', () async {
        // Save a child first
        final saved = await StorageService.saveChild(
          childCode: 'TEST001',
          name: 'Test Child',
          dateOfBirth: DateTime(2020, 1, 1),
          ageInMonths: 48,
          gender: 'male',
          language: 'en',
          hospitalId: 'HOSP001',
          group: ChildGroup.typicallyDeveloping,
          diagnosisSource: 'Test Hospital',
          clinicianId: 'CLIN001',
          clinicianName: 'Test Clinician',
        );

        final childId = saved['id'] as String;

        // Update the child
        final updated = await StorageService.updateChild(
          id: childId,
          childCode: 'TEST001',
          name: 'Updated Child',
          dateOfBirth: DateTime(2020, 1, 1),
          ageInMonths: 49,
          gender: 'male',
          language: 'en',
          hospitalId: 'HOSP001',
          group: ChildGroup.typicallyDeveloping,
          diagnosisSource: 'Test Hospital',
          clinicianId: 'CLIN001',
          clinicianName: 'Test Clinician',
        );

        expect(updated, isNotNull);
        expect(updated!['name'], 'Updated Child');
        expect(updated['age_in_months'], 49);
      });

      test('should delete child from local database', () async {
        // Save a child first
        final saved = await StorageService.saveChild(
          childCode: 'TEST001',
          name: 'Test Child',
          dateOfBirth: DateTime(2020, 1, 1),
          ageInMonths: 48,
          gender: 'male',
          language: 'en',
          hospitalId: 'HOSP001',
          group: ChildGroup.typicallyDeveloping,
          diagnosisSource: 'Test Hospital',
          clinicianId: 'CLIN001',
          clinicianName: 'Test Clinician',
        );

        final childId = saved['id'] as String;

        // Delete the child
        await StorageService.deleteChild(childId);

        // Verify deletion
        final children = await StorageService.getAllChildren();
        expect(children.any((c) => c['id'] == childId), isFalse);
      });
    });

    group('Session Management', () {
      test('should save session to local database', () async {
        // Save a child first
        final child = await StorageService.saveChild(
          childCode: 'TEST001',
          name: 'Test Child',
          dateOfBirth: DateTime(2020, 1, 1),
          ageInMonths: 48,
          gender: 'male',
          language: 'en',
          hospitalId: 'HOSP001',
          group: ChildGroup.typicallyDeveloping,
          diagnosisSource: 'Test Hospital',
          clinicianId: 'CLIN001',
          clinicianName: 'Test Clinician',
        );

        final childId = child['id'] as String;

        // Save a session
        final session = await StorageService.saveSession(
          childId: childId,
          sessionType: 'color_shape',
          ageGroup: '5-6',
          startTime: DateTime.now(),
        );

        expect(session, isNotNull);
        expect(session!['child_id'], childId);
        expect(session['session_type'], 'color_shape');
        expect(session['age_group'], '5-6');
      });

      test('should retrieve all sessions from local database', () async {
        // Save a child and session first
        final child = await StorageService.saveChild(
          childCode: 'TEST001',
          name: 'Test Child',
          dateOfBirth: DateTime(2020, 1, 1),
          ageInMonths: 48,
          gender: 'male',
          language: 'en',
          hospitalId: 'HOSP001',
          group: ChildGroup.typicallyDeveloping,
          diagnosisSource: 'Test Hospital',
          clinicianId: 'CLIN001',
          clinicianName: 'Test Clinician',
        );

        await StorageService.saveSession(
          childId: child['id'] as String,
          sessionType: 'color_shape',
          ageGroup: '5-6',
          startTime: DateTime.now(),
        );

        final sessions = await StorageService.getAllSessions();
        expect(sessions.length, greaterThan(0));
      });
    });

    group('Data Validation', () {
      test('should handle invalid child data gracefully', () async {
        // Test with missing required fields
        expect(
          () => StorageService.saveChild(
            childCode: '',
            name: '',
            dateOfBirth: DateTime.now(),
            ageInMonths: 0,
            gender: '',
            language: '',
            hospitalId: null,
            group: ChildGroup.typicallyDeveloping,
            diagnosisSource: '',
            clinicianId: null,
            clinicianName: null,
          ),
          returnsNormally,
        );
      });

      test('should normalize session types correctly', () async {
        final child = await StorageService.saveChild(
          childCode: 'TEST001',
          name: 'Test Child',
          dateOfBirth: DateTime(2020, 1, 1),
          ageInMonths: 48,
          gender: 'male',
          language: 'en',
          hospitalId: 'HOSP001',
          group: ChildGroup.typicallyDeveloping,
          diagnosisSource: 'Test Hospital',
          clinicianId: 'CLIN001',
          clinicianName: 'Test Clinician',
        );

        // Test session type normalization (color-shape -> color_shape)
        final session = await StorageService.saveSession(
          childId: child['id'] as String,
          sessionType: 'color-shape', // Should be normalized to color_shape
          ageGroup: '5-6',
          startTime: DateTime.now(),
        );

        expect(session, isNotNull);
        // The session type should be normalized
        expect(session!['session_type'], 'color_shape');
      });
    });
  });
}

