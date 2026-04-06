/// Utility class for calculating and formatting child ages precisely.
/// 
/// Provides standardized logic for computing age from a date of birth
/// and determining the appropriate clinical assessment pathway based on age.
class AgeCalculator {
  /// Calculates precise age components from a given [dateOfBirth].
  /// 
  /// Returns an [AgeResult] containing exact years, months, and days,
  /// as well as floating-point representations of total age.
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

  /// Determines the study-defined age group string for routing.
  /// 
  /// The clinical study categorizes children into distinct cohorts:
  /// '2-3.5', '3.5-5.5', and '5.5-6'. If [ageInYears] falls outside
  /// these ranges, it returns 'out_of_range'.
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

  /// Determines the specific clinical assessment type assigned to a child based on age.
  /// 
  /// - 2.0 to <3.5 years: [AssessmentType.aiDoctorBot]
  /// - 3.5 to <5.5 years: [AssessmentType.frogJump]
  /// - 5.5 to 6.0 years: [AssessmentType.colorShape]
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

  /// Formats an [AgeResult] into a human-readable string (e.g., "3 years 2 months").
  static String formatAge(AgeResult age) {
    return '${age.years} years ${age.months} months';
  }
}

/// Data class representing the precise calculated age of a child.
class AgeResult {
  /// The integer number of full years elapsed since birth.
  final int years;
  
  /// The integer number of full months elapsed since the last birthday.
  final int months;
  
  /// The integer number of days elapsed since the last full month.
  final int days;
  
  /// The fractional total years elapsed (accounting for leap years).
  final double totalYears;
  
  /// The fractional total months elapsed.
  final double totalMonths;
  
  /// The original date of birth used for this calculation.
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

/// Defines the different assessment pathways available in the app.
enum AssessmentType {
  /// Early childhood interaction and joint attention observation (2-3.5 yrs)
  aiDoctorBot,
  
  /// Response inhibition and working memory task (3.5-5.5 yrs)
  frogJump,
  
  /// Set-shifting and cognitive flexibility task (5.5-6 yrs)
  colorShape,
  
  /// Indicates an unsupported age or configuration error
  none,
}

