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

  group('Data Synchronization Tests', () {
    test('should sync local data when online', () async {
      // Initialize services
      await StorageService.database;
      await OfflineSyncService.init();

      // Create local data
      final child = await StorageService.saveChild(
        childCode: 'SYNC001',
        name: 'Sync Test Child',
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
      // In real test, would verify sync to backend
    });

    test('should queue requests when offline', () async {
      await OfflineSyncService.init();

      // Enqueue request (simulating offline)
      await OfflineSyncService.enqueueRequest(
        endpoint: '/api/children',
        method: 'POST',
        payload: {'test': 'data'},
      );

      final pendingCount = await OfflineSyncService.getPendingCount();
      expect(pendingCount, greaterThan(0));
    });
  });
}

