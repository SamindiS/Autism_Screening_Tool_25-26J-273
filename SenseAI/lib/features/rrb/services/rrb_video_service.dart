import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import '../config/rrb_config.dart';
import '../models/detection_result_model.dart';

/// RRB Video Service
///
/// Flow:
///   Flutter app  →  POST /api/videos/upload  →  RRB Node.js backend (Render)
///                                                       ↓
///                                             POST /api/v1/detect
///                                                       ↓
///                                             RRB ML service (Render)
///                                                       ↓
///                                             ML result wrapped in "detection" key
///                                                       ↓
///   Flutter app  ←  combined JSON response  ←  Node.js backend
///
/// Node.js backend response shape:
///   {
///     "success": true,
///     "video": { "filename": "...", "size": ..., ... },
///     "detection": {                         ← this is the FULL ML service response
///       "success": true,
///       "detection": { "detected": ..., "behaviors": [...], ... },
///       "metadata": { "video_duration": ..., ... }
///     }
///   }
///
/// We extract data['detection'] (the full ML response) and pass it directly
/// to RrbDetectionResult.fromJson(), which already reads ['detection'] and
/// ['metadata'] from the top level — so it parses correctly.
class RrbVideoService {
  /// Determine MIME type from filename extension
  MediaType _getMimeType(String filename) {
    final ext = path.extension(filename).toLowerCase();
    switch (ext) {
      case '.mp4':
        return MediaType('video', 'mp4');
      case '.avi':
        return MediaType('video', 'x-msvideo');
      case '.mov':
        return MediaType('video', 'quicktime');
      case '.mkv':
        return MediaType('video', 'x-matroska');
      default:
        return MediaType('video', 'mp4');
    }
  }

  /// Upload video to the RRB Node.js backend, which forwards it to the
  /// ML service and returns the detection result.
  Future<Map<String, dynamic>> detectRRB(
    String videoPath,
    Uint8List videoBytes,
  ) async {
    try {
      // ── Step 1: Build multipart request to Node.js backend ──────────
      final uploadUrl = Uri.parse(
        '${RrbConfig.rrbNodeBackendUrl}${RrbConfig.uploadVideoEndpoint}',
      );

      var request = http.MultipartRequest('POST', uploadUrl);

      final filename = path.basename(videoPath);
      final mimeType = _getMimeType(filename);

      request.files.add(
        http.MultipartFile.fromBytes(
          'video',
          videoBytes,
          filename: filename,
          contentType: mimeType,
        ),
      );

      // ── Step 2: Send and await response ─────────────────────────────
      // Large videos can take several minutes to process — use a long timeout
      final streamedResponse = await request.send().timeout(
            const Duration(minutes: 10),
            onTimeout: () => throw Exception(
              'Request timed out. The video may be too large or the server is slow. '
              'Please try a shorter video.',
            ),
          );
      final response = await http.Response.fromStream(streamedResponse);

      // ── Step 3: Parse response ───────────────────────────────────────
      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return {
          'success': false,
          'error': 'Invalid response from server (${response.statusCode})',
        };
      }

      if (response.statusCode == 200 && data['success'] == true) {
        // Node.js backend wraps the full ML response in data['detection'].
        // RrbDetectionResult.fromJson reads ['detection'] and ['metadata']
        // at the top level — which exist inside data['detection'] — so we
        // pass data['detection'] directly.
        final mlResponse = data['detection'] as Map<String, dynamic>?;

        if (mlResponse == null) {
          return {
            'success': false,
            'error': 'Missing detection data in server response',
          };
        }

        // Check that the ML service itself reported success
        if (mlResponse['success'] == false) {
          return {
            'success': false,
            'error': mlResponse['error'] ?? 'ML detection failed',
          };
        }

        return {
          'success': true,
          'result': RrbDetectionResult.fromJson(mlResponse),
        };
      } else {
        // Server returned an error status or success == false
        final errorMsg = data['error'] ??
            data['message'] ??
            'Upload/detection failed (${response.statusCode})';
        return {'success': false, 'error': errorMsg};
      }
    } on Exception catch (e) {
      return {'success': false, 'error': e.toString()};
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: $e'};
    }
  }
}
