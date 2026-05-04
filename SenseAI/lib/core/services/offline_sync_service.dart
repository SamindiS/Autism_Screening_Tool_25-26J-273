import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'api_service.dart';

/// Service responsible for handling offline data synchronization.
/// 
/// This service uses a local SQLite database to queue API requests when the
/// device is offline, and periodically attempts to sync them with the backend
/// when an internet connection becomes available.
class OfflineSyncService {
  static Database? _db;
  static const String _queueTable = 'sync_queue';

  /// Initializes the local SQLite database for the sync queue.
  /// 
  /// This method creates the database file and the necessary table if they
  /// don't exist. It gracefully exits on web platforms where SQLite is not supported.
  static Future<void> init() async {
    if (kIsWeb) return; // sqflite is not supported on Web
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'senseai_offline.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_queueTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            endpoint TEXT NOT NULL,
            method TEXT NOT NULL,
            payload TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  /// Adds a new API request to the local sync queue.
  /// 
  /// The request will be stored locally and synced later when the network
  /// is reachable. Requires the target [endpoint], HTTP [method], and JSON [payload].
  static Future<void> enqueueRequest({
    required String endpoint,
    required String method, // POST, PUT, or DELETE
    required Map<String, dynamic> payload,
  }) async {
    if (kIsWeb) return; // sqflite is not supported on Web
    if (_db == null) await init();
    await _db!.insert(_queueTable, {
      'endpoint': endpoint,
      'method': method.toUpperCase(),
      'payload': jsonEncode(payload),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Starts a continuous, non-blocking loop to process the sync queue.
  /// 
  /// It checks the backend health every 30 seconds and processes queued
  /// requests if the backend is reachable.
  static void startSyncLoop() {
    if (kIsWeb) return; // sqflite is not supported on Web
    // Use Future.doWhile instead of while(true) to avoid blocking
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      final healthy = await ApiService.healthCheck();
      if (healthy) {
        await _processQueue();
      }
      return true; // keep looping forever
    });
  }

  /// Internal strategy to dispatch queued items to the server.
  /// 
  /// Iterates through the stored requests chronologically and sends them.
  /// Removes them from the queue upon successful transmission.
  static Future<void> _processQueue() async {
    if (_db == null) return;
    final rows = await _db!.query(_queueTable);
    if (rows.isEmpty) return;

    final baseUrl = await ApiService.getBackendUrl();

    int priorityFor(Map<String, Object?> row) {
      final endpoint = (row['endpoint'] as String?) ?? '';
      final method = ((row['method'] as String?) ?? '').toUpperCase();

      // Ensure sessions are created/updated before trials that reference them.
      // This prevents "Session not found" during offline sync.
      if (endpoint == '/api/sessions' && method == 'POST') return 0;
      if (endpoint.startsWith('/api/sessions/') && method == 'PUT') return 1;
      if (endpoint.startsWith('/api/trials') && (method == 'POST' || method == 'PUT')) return 2;
      return 3;
    }

    final sorted = [...rows];
    sorted.sort((a, b) {
      final pa = priorityFor(a);
      final pb = priorityFor(b);
      if (pa != pb) return pa.compareTo(pb);
      final ta = (a['timestamp'] as int?) ?? 0;
      final tb = (b['timestamp'] as int?) ?? 0;
      return ta.compareTo(tb);
    });

    for (final row in sorted) {
      try {
        final payload =
            jsonDecode(row['payload'] as String) as Map<String, dynamic>;
        final uri = Uri.parse('$baseUrl${row['endpoint']}');
        final method = row['method'] as String;

        http.Response? response;

        if (method == 'POST') {
          response = await http.post(uri,
              headers: ApiService.headers, body: jsonEncode(payload));
        } else if (method == 'PUT') {
          response = await http.put(uri,
              headers: ApiService.headers, body: jsonEncode(payload));
        } else if (method == 'DELETE') {
          response = await http.delete(uri, headers: ApiService.headers);
        }

        if (response != null &&
            response.statusCode >= 200 &&
            response.statusCode < 300) {
          await _db!
              .delete(_queueTable, where: 'id = ?', whereArgs: [row['id']]);
        } else {
          // If we somehow hit trials before a session exists, don't block the entire queue.
          // We'll retry later after session POST succeeds.
          if ((row['endpoint'] as String).startsWith('/api/trials') &&
              response != null &&
              response.statusCode == 404) {
            continue;
          }
          // Stop on server error (e.g. 400, 500) – will retry later
          break;
        }
      } catch (e) {
        // Network error or timeout → stop this round, retry in 30s
        break;
      }
    }
  }

  /// Gets the total number of items pending synchronization.
  /// 
  /// Returns 0 if using the Web platform or no items are pending.
  static Future<int> getPendingCount() async {
    if (kIsWeb) return 0; // sqflite is not supported on Web
    if (_db == null) await init();
    final result =
        await _db!.rawQuery('SELECT COUNT(*) as count FROM $_queueTable');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
