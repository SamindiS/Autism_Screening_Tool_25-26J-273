import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:senseai/core/services/offline_sync_service.dart';
import 'package:senseai/core/services/storage_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('OfflineSyncService', () {
    setUp(() async {
      await OfflineSyncService.init();
    });

    test('should initialize offline sync service', () async {
      expect(OfflineSyncService.init(), completes);
    });

    test('should enqueue request when offline', () async {
      await OfflineSyncService.enqueueRequest(
        endpoint: '/api/children',
        method: 'POST',
        payload: {
          'name': 'Test Child',
          'age': 5,
        },
      );

      // Verify request is queued
      final pendingCount = await OfflineSyncService.getPendingCount();
      expect(pendingCount, greaterThan(0));
    });

    test('should track pending sync count', () async {
      // Enqueue multiple requests
      await OfflineSyncService.enqueueRequest(
        endpoint: '/api/children',
        method: 'POST',
        payload: {'test': 'data1'},
      );

      await OfflineSyncService.enqueueRequest(
        endpoint: '/api/sessions',
        method: 'POST',
        payload: {'test': 'data2'},
      );

      final count = await OfflineSyncService.getPendingCount();
      expect(count, greaterThanOrEqualTo(2));
    });
  });
}

