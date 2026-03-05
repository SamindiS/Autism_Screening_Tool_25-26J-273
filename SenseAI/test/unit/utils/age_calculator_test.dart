import 'package:flutter_test/flutter_test.dart';
import 'package:senseai/core/utils/age_calculator.dart';

void main() {
  group('AgeCalculator', () {
    test('should calculate age group correctly for 2-3.5 years', () {
      final ageGroup = AgeCalculator.getAgeGroup(2.5);
      expect(ageGroup, '2-3.5');
    });

    test('should calculate age group correctly for 3.5-5.5 years', () {
      final ageGroup = AgeCalculator.getAgeGroup(4.5);
      expect(ageGroup, '3.5-5.5');
    });

    test('should calculate age group correctly for 5.5-6 years', () {
      final ageGroup = AgeCalculator.getAgeGroup(6.0);
      expect(ageGroup, '5.5-6');
    });

    test('should handle out of range ages', () {
      final ageGroup1 = AgeCalculator.getAgeGroup(1.5);
      expect(ageGroup1, 'out_of_range');

      final ageGroup2 = AgeCalculator.getAgeGroup(7.0);
      expect(ageGroup2, 'out_of_range');
    });

    test('should handle boundary ages', () {
      expect(AgeCalculator.getAgeGroup(2.0), '2-3.5');
      expect(AgeCalculator.getAgeGroup(3.5), '3.5-5.5');
      expect(AgeCalculator.getAgeGroup(5.5), '5.5-6');
      expect(AgeCalculator.getAgeGroup(6.0), '5.5-6');
      expect(AgeCalculator.getAgeGroup(6.1), 'out_of_range');
    });
  });
}

