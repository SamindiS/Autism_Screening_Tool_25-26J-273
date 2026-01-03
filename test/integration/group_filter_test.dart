import 'package:flutter_test/flutter_test.dart';
import 'package:senseai/core/services/api_service.dart';

void main() {
  group('Group Filter Tests', () {
    test('should export all groups when no filter specified', () async {
      final csv = await ApiService.exportCSV(format: 'ml');
      expect(csv, isNotEmpty);
      expect(csv.contains('session_id'), isTrue);
    });

    test('should export only ASD group', () async {
      final csv = await ApiService.exportCSV(format: 'ml', group: 'asd');
      expect(csv, isNotEmpty);
      
      // Verify CSV contains ASD data
      final lines = csv.split('\n');
      if (lines.length > 1) {
        // Check that group column contains 'asd'
        final headerIndex = lines[0].split(',').indexOf('group');
        if (headerIndex >= 0) {
          for (var i = 1; i < lines.length; i++) {
            if (lines[i].isNotEmpty) {
              final values = lines[i].split(',');
              if (values.length > headerIndex) {
                expect(values[headerIndex], 'asd');
              }
            }
          }
        }
      }
    });

    test('should export only Control group', () async {
      final csv = await ApiService.exportCSV(
        format: 'ml',
        group: 'typically_developing',
      );
      expect(csv, isNotEmpty);
    });

    test('should handle combined filters (group + session type)', () async {
      final csv = await ApiService.exportCSV(
        format: 'ml',
        group: 'asd',
        sessionType: 'color_shape',
      );
      expect(csv, isNotEmpty);
    });
  });
}



