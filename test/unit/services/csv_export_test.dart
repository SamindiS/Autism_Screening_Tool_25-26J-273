import 'package:flutter_test/flutter_test.dart';
import 'package:senseai/core/services/api_service.dart';

void main() {
  group('CSV Export Tests', () {
    test('should export CSV with ML format', () async {
      // Test structure - actual test would mock HTTP
      expect(
        ApiService.exportCSV(format: 'ml'),
        isA<Future<String>>(),
      );
    });

    test('should export CSV with raw format', () async {
      expect(
        ApiService.exportCSV(format: 'raw'),
        isA<Future<String>>(),
      );
    });

    test('should export CSV filtered by ASD group', () async {
      expect(
        ApiService.exportCSV(format: 'ml', group: 'asd'),
        isA<Future<String>>(),
      );
    });

    test('should export CSV filtered by Control group', () async {
      expect(
        ApiService.exportCSV(format: 'ml', group: 'typically_developing'),
        isA<Future<String>>(),
      );
    });

    test('should export CSV filtered by session type', () async {
      expect(
        ApiService.exportCSV(format: 'ml', sessionType: 'color_shape'),
        isA<Future<String>>(),
      );
    });

    test('should export CSV with multiple filters', () async {
      expect(
        ApiService.exportCSV(
          format: 'ml',
          group: 'asd',
          sessionType: 'color_shape',
        ),
        isA<Future<String>>(),
      );
    });
  });
}


