import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:senseai/core/services/storage_service.dart';
import 'package:senseai/core/services/offline_sync_service.dart';
import 'package:senseai/data/models/child.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Offline Functionality Tests', () {
    test('should save child locally when offline', () async {
      await StorageService.database;

      final child = await StorageService.saveChild(
        childCode: 'OFFLINE001',
        name: 'Offline Child',
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

      expect(child, isNotNull);
      expect(child!['child_code'], 'OFFLINE001');

      // Verify child is in local database
      final children = await StorageService.getAllChildren();
      expect(children.any((c) => c['child_code'] == 'OFFLINE001'), isTrue);
    });

    test('should save session locally when offline', () async {
      await StorageService.database;

      // Create child first
      final child = await StorageService.saveChild(
        childCode: 'OFFLINE002',
        name: 'Offline Child 2',
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

      // Create session
      final session = await StorageService.saveSession(
        childId: child!['id'] as String,
        sessionType: 'color_shape',
        ageGroup: '5-6',
        startTime: DateTime.now(),
      );

      expect(session, isNotNull);
      expect(session!['session_type'], 'color_shape');

      // Verify session is in local database
      final sessions = await StorageService.getAllSessions();
      expect(sessions.any((s) => s['id'] == session['id']), isTrue);
    });

    test('should queue sync requests when offline', () async {
      await OfflineSyncService.init();

      // Enqueue multiple requests
      await OfflineSyncService.enqueueRequest(
        endpoint: '/api/children',
        method: 'POST',
        payload: {'name': 'Test Child'},
      );

      await OfflineSyncService.enqueueRequest(
        endpoint: '/api/sessions',
        method: 'POST',
        payload: {'session_type': 'color_shape'},
      );

      final pendingCount = await OfflineSyncService.getPendingCount();
      expect(pendingCount, greaterThanOrEqualTo(2));
    });
  });
}

