import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import '../config/app_config.dart';
import '../models/detection_result_model.dart';
import 'auth_service.dart';

/// Video Service for uploading and processing videos
class VideoService {
  final AuthService _authService = AuthService();

  /// Get MIME type from filename
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
        return MediaType('video', 'mp4'); // Default to mp4
    }
  }

  /// Upload video to backend
  Future<Map<String, dynamic>> uploadVideo(
    String videoPath,
    Uint8List videoBytes,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.uploadVideoEndpoint}'),
      );

      // Add video file using bytes (web-compatible)
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'videoId': data['videoId'] ?? data['id'],
          'message': 'Video uploaded successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message'] ?? 'Upload failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Upload error: ${e.toString()}'};
    }
  }

  /// Detect RRB in video
  Future<Map<String, dynamic>> detectRRB(
    String videoPath,
    Uint8List videoBytes,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.mlServiceUrl}${AppConfig.detectRRBEndpoint}'),
      );

      // Add video file using bytes (web-compatible)
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
          return {'success': true, 'result': DetectionResult.fromJson(data)};
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Detection failed',
          };
        }
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Detection failed',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Detection error: ${e.toString()}'};
    }
  }

  /// Get detection results
  Future<Map<String, dynamic>> getResults(String videoId) async {
    try {
      final headers = await _authService.getAuthHeaders();

      final response = await http.get(
        Uri.parse(
          '${AppConfig.apiBaseUrl}${AppConfig.getResultsEndpoint}/$videoId',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'result': DetectionResult.fromJson(data)};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'Failed to get results',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error: ${e.toString()}'};
    }
  }
}
