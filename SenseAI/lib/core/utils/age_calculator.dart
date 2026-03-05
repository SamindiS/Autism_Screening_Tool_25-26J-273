class AgeCalculator {
  /// Calculate precise age from date of birth
  static AgeResult calculate(DateTime dateOfBirth) {
    final now = DateTime.now();
    final difference = now.difference(dateOfBirth);

    final years = difference.inDays ~/ 365;
    final remainingDays = difference.inDays % 365;
    final months = remainingDays ~/ 30;
    final days = remainingDays % 30;

    final totalYears = difference.inDays / 365.25;
    final totalMonths = difference.inDays / 30.44;

    return AgeResult(
      years: years,
      months: months,
      days: days,
      totalYears: totalYears,
      totalMonths: totalMonths,
      dateOfBirth: dateOfBirth,
    );
  }

  /// Determine age group for routing
  static String getAgeGroup(double ageInYears) {
    if (ageInYears >= 2.0 && ageInYears < 3.5) {
      return '2-3.5';
    } else if (ageInYears >= 3.5 && ageInYears < 5.5) {
      return '3.5-5.5';
    } else if (ageInYears >= 5.5 && ageInYears <= 6.0) {
      return '5.5-6';
    }
    return 'out_of_range';
  }

  /// Get assessment type based on age
  static AssessmentType getAssessmentType(double ageInYears) {
    if (ageInYears >= 2.0 && ageInYears < 3.5) {
      return AssessmentType.aiDoctorBot;
    } else if (ageInYears >= 3.5 && ageInYears < 5.5) {
      return AssessmentType.frogJump;
    } else if (ageInYears >= 5.5 && ageInYears <= 6.0) {
      return AssessmentType.colorShape;
    }
    return AssessmentType.none;
  }

  /// Format age as string
  static String formatAge(AgeResult age) {
    return '${age.years} years ${age.months} months';
  }
}

class AgeResult {
  final int years;
  final int months;
  final int days;
  final double totalYears;
  final double totalMonths;
  final DateTime dateOfBirth;

  AgeResult({
    required this.years,
    required this.months,
    required this.days,
    required this.totalYears,
    required this.totalMonths,
    required this.dateOfBirth,
  });

  @override
  String toString() {
    return '${years}y ${months}m ${days}d (${totalYears.toStringAsFixed(2)} years)';
  }
}

enum AssessmentType {
  aiDoctorBot,
  frogJump,
  colorShape,
  none,
}

