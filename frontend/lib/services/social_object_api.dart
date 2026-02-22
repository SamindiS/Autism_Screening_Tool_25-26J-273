/// Social vs Object Preference test - API service.
/// Handles session start, chunked gaze upload, and finish (metrics).

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class SocialObjectApi {
  SocialObjectApi({String? baseUrl}) : _baseUrl = baseUrl ?? apiBaseUrl;

  final String _baseUrl;

  String get _prefix => '$_baseUrl/social_object';

  /// Start a new session. Returns session_id.
  /// [childId] optional; [sessionId] optional (server generates if not provided).
  Future<Map<String, dynamic>> startSession({
    String? childId,
    String? sessionId,
  }) async {
    final body = <String, dynamic>{};
    if (childId != null) body['child_id'] = childId;
    if (sessionId != null) body['session_id'] = sessionId;

    final res = await http
        .post(
          Uri.parse('$_prefix/start'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('startSession failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Upload a chunk of gaze events.
  /// Events: [{ timestamp_ms, x, y, aoi }, ...]
  Future<Map<String, dynamic>> uploadGazeEvents(
    String sessionId,
    List<Map<String, dynamic>> events,
  ) async {
    final res = await http
        .post(
          Uri.parse('$_prefix/upload_gaze'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'session_id': sessionId, 'events': events}),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('uploadGazeEvents failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Finish session and get computed metrics.
  Future<Map<String, dynamic>> finishSession(String sessionId) async {
    final res = await http
        .post(
          Uri.parse('$_prefix/finish'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'session_id': sessionId}),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('finishSession failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
