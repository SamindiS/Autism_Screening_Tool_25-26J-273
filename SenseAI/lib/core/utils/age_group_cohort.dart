/// Study cohort labels stored on sessions (`age_group`) and used in exports.
///
/// Boundaries match [AgeCalculator.getAgeGroup]: 2–<3.5, 3.5–<5.5, 5.5–<6.9 years.
class AgeGroupCohort {
  static const String band24 = '2-3.4';
  static const String band354 = '3.5-5.4';
  static const String band569 = '5.5-6.9';

  /// Maps legacy UI/session strings to the canonical cohort keys above.
  static String? normalize(String? raw) {
    if (raw == null) return null;
    final v = raw.trim();
    if (v.isEmpty) return null;

    const map = {
      // Canonical
      '2-3.4': band24,
      '3.5-5.4': band354,
      '5.5-6.9': band569,
      // Legacy study labels (same month cutoffs)
      '2-3.5': band24,
      '3.5-5.5': band354,
      // Informal band used in older builds
      '5-6': band569,
    };

    return map[v] ?? v;
  }
}
