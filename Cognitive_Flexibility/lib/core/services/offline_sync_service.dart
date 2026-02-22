import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'api_service.dart';

class OfflineSyncService {
  static Database? _db;
  static const String _queueTable = 'sync_queue';

  static Future<void> init() async {
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

  // Enqueue when offline
  static Future<void> enqueueRequest({
    required String endpoint,
    required String method, // POST or PUT only
    required Map<String, dynamic> payload,
  }) async {
    if (_db == null) await init();
    await _db!.insert(_queueTable, {
      'endpoint': endpoint,
      'method': method.toUpperCase(),
      'payload': jsonEncode(payload),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Start background sync loop (non-blocking!)
  static void startSyncLoop() {
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

  static Future<void> _processQueue() async {
    if (_db == null) return;
    final rows = await _db!.query(_queueTable, orderBy: 'timestamp ASC');
    if (rows.isEmpty) return;

    final baseUrl = await ApiService.getBackendUrl();

    for (final row in rows) {
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
        }

        if (response != null &&
            response.statusCode >= 200 &&
            response.statusCode < 300) {
          await _db!
              .delete(_queueTable, where: 'id = ?', whereArgs: [row['id']]);
        } else {
          // Stop on server error (e.g. 400, 500) – will retry later
          break;
        }
      } catch (e) {
        // Network error or timeout → stop this round, retry in 30s
        break;
      }
    }
  }

  // Optional: show badge count
  static Future<int> getPendingCount() async {
    if (_db == null) await init();
    final result =
        await _db!.rawQuery('SELECT COUNT(*) as count FROM $_queueTable');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
