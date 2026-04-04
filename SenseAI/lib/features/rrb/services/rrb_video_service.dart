import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import '../config/rrb_config.dart';
import '../models/detection_result_model.dart';

/// RRB Video Service — uploads video bytes to the Flask ML service
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

  /// Send video bytes to ML service for RRB detection
  Future<Map<String, dynamic>> detectRRB(
    String videoPath,
    Uint8List videoBytes,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${RrbConfig.mlServiceUrl}${RrbConfig.detectRRBEndpoint}'),
      );

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

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return {
            'success': true,
            'result': RrbDetectionResult.fromJson(data),
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Detection failed',
          };
        }
      } else {
        Map<String, dynamic> error = {};
        try {
          error = jsonDecode(response.body);
        } catch (_) {}
        return {
          'success': false,
          'error': error['error'] ?? 'Server error (${response.statusCode})',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Detection error: ${e.toString()}'};
    }
  }
}

