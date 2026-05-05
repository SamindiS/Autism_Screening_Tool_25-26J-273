import 'package:flutter_test/flutter_test.dart';
import 'package:senseai/core/utils/age_calculator.dart';

void main() {
  group('AgeCalculator', () {
    test('should calculate age group correctly for 2-3.4 years', () {
      final ageGroup = AgeCalculator.getAgeGroup(2.5);
      expect(ageGroup, '2-3.4');
    });

    test('should calculate age group correctly for 3.5-5.4 years', () {
      final ageGroup = AgeCalculator.getAgeGroup(4.5);
      expect(ageGroup, '3.5-5.4');
    });

    test('should calculate age group correctly for 5.5-6.9 years', () {
      final ageGroup = AgeCalculator.getAgeGroup(6.0);
      expect(ageGroup, '5.5-6.9');
    });

    test('should handle out of range ages', () {
      final ageGroup1 = AgeCalculator.getAgeGroup(1.5);
      expect(ageGroup1, 'out_of_range');

      final ageGroup2 = AgeCalculator.getAgeGroup(7.0);
      expect(ageGroup2, 'out_of_range');
    });

    test('should handle boundary ages', () {
      expect(AgeCalculator.getAgeGroup(2.0), '2-3.4');
      expect(AgeCalculator.getAgeGroup(3.5), '3.5-5.4');
      expect(AgeCalculator.getAgeGroup(5.5), '5.5-6.9');
      expect(AgeCalculator.getAgeGroup(6.0), '5.5-6.9');
      expect(AgeCalculator.getAgeGroup(6.1), 'out_of_range');
    });
  });
}

