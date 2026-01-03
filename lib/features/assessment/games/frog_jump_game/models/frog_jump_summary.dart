import 'dart:math' as math;
import 'game_trial.dart';

/// Summary of Frog Jump (Go/No-Go) game for ASD ML detection
/// 
/// Key ASD Markers:
/// - Commission errors (false positives): Responding when shouldn't (inhibitory failure)
/// - No-Go accuracy: Ability to inhibit responses
/// - RT variability: Inconsistent attention pattern
/// 
/// Scientific Basis: Go/No-Go paradigm measures inhibitory control,
/// which is often impaired in children with ASD
class FrogJumpSummary {
  final int totalTrials;
  final int practiceTrials;
  final int mainTrials;
  final int completionTimeSec;
  
  // Trial counts by type
  final int goTrials;        // Happy frog trials (should tap)
  final int nogoTrials;      // Sleepy turtle trials (should NOT tap)
  
  // Accuracy metrics
  final double goAccuracy;       // % correct on Go trials
  final double nogoAccuracy;     // % correct on No-Go trials (INHIBITORY CONTROL)
  final double overallAccuracy;
  
  // Error types (KEY ASD MARKERS)
  final int commissionErrors;      // False positives - tapped on No-Go (MOST IMPORTANT)
  final int omissionErrors;        // Misses - didn't tap on Go
  final double commissionErrorRate; // commission_errors / nogo_trials * 100
  final double omissionErrorRate;   // omission_errors / go_trials * 100
  
  // Reaction times (only for correct Go responses)
  final double avgRtGoMs;          // Average RT on correct Go trials
  final double rtVariability;      // Standard deviation of RT (HIGH in ASD)
  final double fastestRtMs;        // Minimum RT
  final double slowestRtMs;        // Maximum RT
  final double rtRange;            // slowest - fastest
  
  // Advanced metrics
  final int longestCorrectStreak;
  final int longestErrorStreak;
  final int totalErrorStreak;      // Total consecutive errors
  final double inhibitionFailureRate; // Same as commission error rate
  
  // Anticipatory responses (RT < 200ms - impulsive)
  final int anticipatoryResponses;
  final double anticipatoryRate;
  
  // Late responses (RT > 2000ms - attention lapses)
  final int lateResponses;
  final double lateResponseRate;

  FrogJumpSummary({
    required this.totalTrials,
    required this.practiceTrials,
    required this.mainTrials,
    required this.completionTimeSec,
    required this.goTrials,
    required this.nogoTrials,
    required this.goAccuracy,
    required this.nogoAccuracy,
    required this.overallAccuracy,
    required this.commissionErrors,
    required this.omissionErrors,
    required this.commissionErrorRate,
    required this.omissionErrorRate,
    required this.avgRtGoMs,
    required this.rtVariability,
    required this.fastestRtMs,
    required this.slowestRtMs,
    required this.rtRange,
    required this.longestCorrectStreak,
    required this.longestErrorStreak,
    required this.totalErrorStreak,
    required this.inhibitionFailureRate,
    required this.anticipatoryResponses,
    required this.anticipatoryRate,
    required this.lateResponses,
    required this.lateResponseRate,
  });

  /// Calculate summary from list of trials
  factory FrogJumpSummary.fromTrials({
    required List<FrogJumpTrial> trials,
    required int completionTimeSec,
  }) {
    // Filter out practice trials for main metrics
    final mainTrials = trials.where((t) => t.phase == 'main').toList();
    final practiceTrialsList = trials.where((t) => t.phase == 'practice').toList();
    
    // Separate Go and No-Go trials
    final goTrials = mainTrials.where((t) => t.isGoTrial).toList();
    final nogoTrials = mainTrials.where((t) => !t.isGoTrial).toList();
    
    // Calculate accuracy
    final correctGoTrials = goTrials.where((t) => t.correct).toList();
    final correctNogoTrials = nogoTrials.where((t) => t.correct).toList();
    
    final goAccuracy = goTrials.isNotEmpty 
        ? (correctGoTrials.length / goTrials.length) * 100 
        : 0.0;
    final nogoAccuracy = nogoTrials.isNotEmpty 
        ? (correctNogoTrials.length / nogoTrials.length) * 100 
        : 0.0;
    final overallAccuracy = mainTrials.isNotEmpty 
        ? (mainTrials.where((t) => t.correct).length / mainTrials.length) * 100 
        : 0.0;
    
    // Calculate errors
    final commissionErrors = nogoTrials.where((t) => t.isCommissionError).length;
    final omissionErrors = goTrials.where((t) => t.isOmissionError).length;
    
    final commissionErrorRate = nogoTrials.isNotEmpty 
        ? (commissionErrors / nogoTrials.length) * 100 
        : 0.0;
    final omissionErrorRate = goTrials.isNotEmpty 
        ? (omissionErrors / goTrials.length) * 100 
        : 0.0;
    
    // Calculate reaction times (only for correct Go responses)
    final correctGoRts = correctGoTrials.map((t) => t.reactionTimeMs).toList();
    
    double avgRtGoMs = 0.0;
    double rtVariability = 0.0;
    double fastestRtMs = 0.0;
    double slowestRtMs = 0.0;
    
    if (correctGoRts.isNotEmpty) {
      avgRtGoMs = correctGoRts.reduce((a, b) => a + b) / correctGoRts.length;
      fastestRtMs = correctGoRts.reduce(math.min).toDouble();
      slowestRtMs = correctGoRts.reduce(math.max).toDouble();
      
      // Calculate standard deviation
      final squaredDiffs = correctGoRts.map((rt) => math.pow(rt - avgRtGoMs, 2));
      final variance = squaredDiffs.reduce((a, b) => a + b) / correctGoRts.length;
      rtVariability = math.sqrt(variance);
    }
    
    // Calculate streaks
    int longestCorrectStreak = 0;
    int longestErrorStreak = 0;
    int currentCorrectStreak = 0;
    int currentErrorStreak = 0;
    int totalErrorStreak = 0;
    
    for (final trial in mainTrials) {
      if (trial.correct) {
        currentCorrectStreak++;
        if (currentErrorStreak > 0) {
          totalErrorStreak += currentErrorStreak;
        }
        currentErrorStreak = 0;
        if (currentCorrectStreak > longestCorrectStreak) {
          longestCorrectStreak = currentCorrectStreak;
        }
      } else {
        currentErrorStreak++;
        currentCorrectStreak = 0;
        if (currentErrorStreak > longestErrorStreak) {
          longestErrorStreak = currentErrorStreak;
        }
      }
    }
    if (currentErrorStreak > 0) {
      totalErrorStreak += currentErrorStreak;
    }
    
    // Calculate anticipatory responses (RT < 200ms)
    final anticipatoryResponses = correctGoRts.where((rt) => rt < 200).length;
    final anticipatoryRate = correctGoRts.isNotEmpty 
        ? (anticipatoryResponses / correctGoRts.length) * 100 
        : 0.0;
    
    // Calculate late responses (RT > 2000ms)
    final lateResponses = correctGoRts.where((rt) => rt > 2000).length;
    final lateResponseRate = correctGoRts.isNotEmpty 
        ? (lateResponses / correctGoRts.length) * 100 
        : 0.0;

    return FrogJumpSummary(
      totalTrials: trials.length,
      practiceTrials: practiceTrialsList.length,
      mainTrials: mainTrials.length,
      completionTimeSec: completionTimeSec,
      goTrials: goTrials.length,
      nogoTrials: nogoTrials.length,
      goAccuracy: goAccuracy,
      nogoAccuracy: nogoAccuracy,
      overallAccuracy: overallAccuracy,
      commissionErrors: commissionErrors,
      omissionErrors: omissionErrors,
      commissionErrorRate: commissionErrorRate,
      omissionErrorRate: omissionErrorRate,
      avgRtGoMs: avgRtGoMs,
      rtVariability: rtVariability,
      fastestRtMs: fastestRtMs,
      slowestRtMs: slowestRtMs,
      rtRange: slowestRtMs - fastestRtMs,
      longestCorrectStreak: longestCorrectStreak,
      longestErrorStreak: longestErrorStreak,
      totalErrorStreak: totalErrorStreak,
      inhibitionFailureRate: commissionErrorRate,
      anticipatoryResponses: anticipatoryResponses,
      anticipatoryRate: anticipatoryRate,
      lateResponses: lateResponses,
      lateResponseRate: lateResponseRate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_trials': totalTrials,
      'practice_trials': practiceTrials,
      'main_trials': mainTrials,
      'completion_time_sec': completionTimeSec,
      'go_trials': goTrials,
      'nogo_trials': nogoTrials,
      'go_accuracy': goAccuracy,
      'nogo_accuracy': nogoAccuracy,
      'overall_accuracy': overallAccuracy,
      'commission_errors': commissionErrors,
      'omission_errors': omissionErrors,
      'commission_error_rate': commissionErrorRate,
      'omission_error_rate': omissionErrorRate,
      'avg_rt_go_ms': avgRtGoMs,
      'rt_variability': rtVariability,
      'fastest_rt_ms': fastestRtMs,
      'slowest_rt_ms': slowestRtMs,
      'rt_range': rtRange,
      'longest_correct_streak': longestCorrectStreak,
      'longest_error_streak': longestErrorStreak,
      'total_error_streak': totalErrorStreak,
      'inhibition_failure_rate': inhibitionFailureRate,
      'anticipatory_responses': anticipatoryResponses,
      'anticipatory_rate': anticipatoryRate,
      'late_responses': lateResponses,
      'late_response_rate': lateResponseRate,
    };
  }

  /// Get ML features for ASD detection model
  /// These features are specifically chosen based on ASD research literature
  Map<String, dynamic> get mlFeatures => {
    // PRIMARY ASD MARKERS (Most important for detection)
    'nogo_accuracy': nogoAccuracy,                    // Inhibitory control
    'commission_error_rate': commissionErrorRate,     // GOLD STANDARD - inhibitory failure
    'commission_errors': commissionErrors,            // Raw count of inhibitory failures
    'rt_variability': rtVariability,                  // Attention consistency (HIGH in ASD)
    
    // SECONDARY MARKERS
    'go_accuracy': goAccuracy,                        // Basic response accuracy
    'omission_errors': omissionErrors,                // Missed responses
    'omission_error_rate': omissionErrorRate,
    'avg_rt_go_ms': avgRtGoMs,                        // Processing speed
    'inhibition_failure_rate': inhibitionFailureRate, // Same as commission rate
    
    // ATTENTION MARKERS
    'anticipatory_responses': anticipatoryResponses,  // Impulsive responses
    'anticipatory_rate': anticipatoryRate,
    'late_responses': lateResponses,                  // Attention lapses
    'late_response_rate': lateResponseRate,
    
    // BEHAVIORAL PATTERNS
    'longest_correct_streak': longestCorrectStreak,   // Sustained attention
    'longest_error_streak': longestErrorStreak,       // Perseveration indicator
    'total_error_streak': totalErrorStreak,
    
    // BASIC METRICS
    'overall_accuracy': overallAccuracy,
    'fastest_rt_ms': fastestRtMs,
    'slowest_rt_ms': slowestRtMs,
    'rt_range': rtRange,
    'completion_time_sec': completionTimeSec,
    'total_trials': mainTrials,
  };

  /// Calculate risk level based on inhibitory control markers
  String get riskLevel {
    // High risk indicators:
    // - Commission error rate > 40% (severe inhibitory control deficit)
    // - No-Go accuracy < 50%
    // - RT variability > 400ms (very inconsistent attention)
    if (commissionErrorRate > 40 || nogoAccuracy < 50 || rtVariability > 400) {
      return 'HIGH';
    }
    
    // Moderate risk indicators:
    // - Commission error rate > 25%
    // - No-Go accuracy < 70%
    // - RT variability > 250ms
    if (commissionErrorRate > 25 || nogoAccuracy < 70 || rtVariability > 250) {
      return 'MODERATE';
    }
    
    return 'LOW';
  }

  /// Get a descriptive interpretation of the results
  String get interpretation {
    final risk = riskLevel;
    
    if (risk == 'HIGH') {
      return 'Significant difficulty with inhibitory control. '
          'Child showed frequent commission errors ($commissionErrors) and '
          'inconsistent response times (SD: ${rtVariability.toStringAsFixed(0)}ms). '
          'Further clinical evaluation recommended.';
    } else if (risk == 'MODERATE') {
      return 'Some difficulty with inhibitory control observed. '
          'Commission error rate: ${commissionErrorRate.toStringAsFixed(1)}%. '
          'Monitor and consider follow-up assessment.';
    }
    
    return 'Good inhibitory control demonstrated. '
        'No-Go accuracy: ${nogoAccuracy.toStringAsFixed(1)}%. '
        'Response times were consistent.';
  }
}









