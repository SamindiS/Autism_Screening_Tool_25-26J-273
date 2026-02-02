import 'package:flutter_test/flutter_test.dart';
import 'package:senseai/core/services/api_service.dart';

void main() {
  group('CSV Export Flow Tests', () {
    test('should export all data in ML format', () async {
      final csv = await ApiService.exportCSV(format: 'ml');
      expect(csv, isNotEmpty);
      expect(csv.contains('session_id'), isTrue);
      expect(csv.contains('group'), isTrue);
    });

    test('should export ASD group only', () async {
      final csv = await ApiService.exportCSV(format: 'ml', group: 'asd');
      expect(csv, isNotEmpty);
      // Verify all rows are ASD group
      final lines = csv.split('\n');
      if (lines.length > 1) {
        // Skip header, check data rows
        for (var i = 1; i < lines.length; i++) {
          if (lines[i].isNotEmpty) {
            expect(lines[i].contains('asd'), isTrue);
          }
        }
      }
    });

    test('should export Control group only', () async {
      final csv = await ApiService.exportCSV(
        format: 'ml',
        group: 'typically_developing',
      );
      expect(csv, isNotEmpty);
    });

    test('should export with session type filter', () async {
      final csv = await ApiService.exportCSV(
        format: 'ml',
        sessionType: 'color_shape',
      );
      expect(csv, isNotEmpty);
    });

    test('should handle export errors gracefully', () async {
      // Test with invalid parameters
      try {
        await ApiService.exportCSV(format: 'invalid');
        fail('Should have thrown an error');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });
}




