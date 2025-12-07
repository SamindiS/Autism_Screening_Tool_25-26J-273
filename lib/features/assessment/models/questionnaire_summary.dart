import 'dart:math' as math;

/// Summary of AI Doctor Bot Questionnaire for ASD ML detection (Age 2-3.5 years)
/// 
/// Based on M-CHAT-R/F (Modified Checklist for Autism in Toddlers) framework
/// with adaptations for Sri Lankan context
/// 
/// Key ASD Markers:
/// - Low scores on Social Responsiveness (name response)
/// - Low scores on Joint Attention (pointing, gaze following)
/// - Low scores on Social Communication (eye contact)
/// - Rigid response to routine changes (Cognitive Flexibility)
/// 
/// Scoring: Each question scored 1-5 (1=concerning, 5=typical)
/// Risk is INVERTED: Lower behavioral scores = Higher ASD risk
class QuestionnaireSummary {
  final int totalQuestions;
  final int completionTimeSec;
  
  // Raw scores
  final int totalScore;
  final int maxPossibleScore;
  final double percentageScore;
  
  // Category scores (each 0-100%)
  final Map<String, CategoryScore> categoryScores;
  
  // Individual question responses (1-5)
  final Map<int, int> responses;
  
  // Critical items (M-CHAT style) - questions that strongly indicate ASD risk
  final List<int> criticalItemsFailed;
  final int criticalItemsCount;
  final double criticalItemsFailRate;
  
  // Risk calculation
  final double riskScore; // 0-100 (higher = more risk)
  final String riskLevel; // LOW, MODERATE, HIGH
  
  // M-CHAT-R/F inspired metrics
  final int failedItemsTotal; // Items scored 1 or 2
  final double failedItemsRate;
  
  // Domain-specific scores for ML
  final double socialResponsivenessScore;
  final double cognitiveFlexibilityScore;
  final double jointAttentionScore;
  final double socialCommunicationScore;
  final double sensoryProcessingScore;
  final double communicationScore;

  QuestionnaireSummary({
    required this.totalQuestions,
    required this.completionTimeSec,
    required this.totalScore,
    required this.maxPossibleScore,
    required this.percentageScore,
    required this.categoryScores,
    required this.responses,
    required this.criticalItemsFailed,
    required this.criticalItemsCount,
    required this.criticalItemsFailRate,
    required this.riskScore,
    required this.riskLevel,
    required this.failedItemsTotal,
    required this.failedItemsRate,
    required this.socialResponsivenessScore,
    required this.cognitiveFlexibilityScore,
    required this.jointAttentionScore,
    required this.socialCommunicationScore,
    required this.sensoryProcessingScore,
    required this.communicationScore,
  });

  /// Calculate summary from questionnaire responses
  /// 
  /// [responses] - Map of question_id to response_value (1-5)
  /// [questions] - List of question definitions with 'id', 'category', etc.
  /// [completionTimeSec] - Time taken to complete questionnaire
  factory QuestionnaireSummary.fromResponses({
    required Map<int, int> responses,
    required List<Map<String, dynamic>> questions,
    required int completionTimeSec,
  }) {
    final totalQuestions = questions.length;
    final maxPossibleScore = totalQuestions * 5;
    
    // Calculate total score
    int totalScore = 0;
    responses.forEach((_, value) {
      totalScore += value;
    });
    
    final percentageScore = (totalScore / maxPossibleScore) * 100;
    
    // Calculate category scores
    final categoryData = <String, List<int>>{};
    for (final q in questions) {
      final questionId = q['id'] as int;
      final category = q['category'] as String;
      final response = responses[questionId] ?? 0;
      
      if (!categoryData.containsKey(category)) {
        categoryData[category] = [];
      }
      categoryData[category]!.add(response);
    }
    
    final categoryScores = <String, CategoryScore>{};
    categoryData.forEach((category, scores) {
      final total = scores.reduce((a, b) => a + b);
      final maxScore = scores.length * 5;
      final percentage = (total / maxScore) * 100;
      final avgScore = total / scores.length;
      
      categoryScores[category] = CategoryScore(
        category: category,
        totalScore: total,
        maxScore: maxScore,
        percentage: percentage,
        averageScore: avgScore,
        questionCount: scores.length,
        failedItems: scores.where((s) => s <= 2).length,
      );
    });
    
    // Critical items (based on M-CHAT-R/F critical items)
    // Questions 1, 4, 5, 7, 9 are most predictive of ASD
    // Q1: Name response, Q4: Eye contact, Q5: Pointing, Q7: Imitation, Q9: Joint attention
    final criticalItemIds = [1, 4, 5, 7, 9];
    final criticalItemsFailed = <int>[];
    
    for (final id in criticalItemIds) {
      if (responses.containsKey(id) && responses[id]! <= 2) {
        criticalItemsFailed.add(id);
      }
    }
    
    final criticalItemsCount = criticalItemIds.length;
    final criticalItemsFailRate = criticalItemsFailed.isEmpty 
        ? 0.0 
        : (criticalItemsFailed.length / criticalItemsCount) * 100;
    
    // Calculate failed items (responses 1 or 2)
    final failedItemsTotal = responses.values.where((v) => v <= 2).length;
    final failedItemsRate = (failedItemsTotal / totalQuestions) * 100;
    
    // Calculate risk score (inverted - lower behavioral score = higher risk)
    // Also weighted by critical items
    double riskScore = 100 - percentageScore;
    
    // Add weight for critical items failed
    riskScore += (criticalItemsFailRate * 0.3); // 30% weight for critical items
    riskScore = math.min(100, riskScore); // Cap at 100
    
    // Determine risk level (M-CHAT-R/F inspired thresholds)
    String riskLevel;
    if (criticalItemsFailed.length >= 2 || failedItemsTotal >= 4) {
      riskLevel = 'HIGH';
    } else if (criticalItemsFailed.length >= 1 || failedItemsTotal >= 2) {
      riskLevel = 'MODERATE';
    } else {
      riskLevel = 'LOW';
    }
    
    // Extract domain-specific scores for ML
    double getScore(String categoryName) {
      return categoryScores[categoryName]?.percentage ?? 50.0;
    }
    
    return QuestionnaireSummary(
      totalQuestions: totalQuestions,
      completionTimeSec: completionTimeSec,
      totalScore: totalScore,
      maxPossibleScore: maxPossibleScore,
      percentageScore: percentageScore,
      categoryScores: categoryScores,
      responses: responses,
      criticalItemsFailed: criticalItemsFailed,
      criticalItemsCount: criticalItemsCount,
      criticalItemsFailRate: criticalItemsFailRate,
      riskScore: riskScore,
      riskLevel: riskLevel,
      failedItemsTotal: failedItemsTotal,
      failedItemsRate: failedItemsRate,
      socialResponsivenessScore: getScore('Social Responsiveness'),
      cognitiveFlexibilityScore: getScore('Cognitive Flexibility'),
      jointAttentionScore: getScore('Joint Attention'),
      socialCommunicationScore: getScore('Social Communication'),
      sensoryProcessingScore: getScore('Sensory Processing'),
      communicationScore: getScore('Communication'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_questions': totalQuestions,
      'completion_time_sec': completionTimeSec,
      'total_score': totalScore,
      'max_possible_score': maxPossibleScore,
      'percentage_score': percentageScore,
      'category_scores': categoryScores.map((k, v) => MapEntry(k, v.toJson())),
      'responses': responses.map((k, v) => MapEntry(k.toString(), v)),
      'critical_items_failed': criticalItemsFailed,
      'critical_items_count': criticalItemsCount,
      'critical_items_fail_rate': criticalItemsFailRate,
      'risk_score': riskScore,
      'risk_level': riskLevel,
      'failed_items_total': failedItemsTotal,
      'failed_items_rate': failedItemsRate,
      'social_responsiveness_score': socialResponsivenessScore,
      'cognitive_flexibility_score': cognitiveFlexibilityScore,
      'joint_attention_score': jointAttentionScore,
      'social_communication_score': socialCommunicationScore,
      'sensory_processing_score': sensoryProcessingScore,
      'communication_score': communicationScore,
    };
  }

  /// Get ML features for ASD detection model
  /// These features are based on M-CHAT-R/F and validated ASD screening research
  Map<String, dynamic> get mlFeatures => {
    // PRIMARY ASD MARKERS (Critical Items - Most Predictive)
    'critical_items_failed': criticalItemsFailed.length,
    'critical_items_fail_rate': criticalItemsFailRate,
    
    // Q1: Name Response (Social Responsiveness)
    'q1_name_response': responses[1] ?? 0,
    // Q4: Eye Contact (Social Communication)
    'q4_eye_contact': responses[4] ?? 0,
    // Q5: Pointing (Joint Attention) - MOST CRITICAL
    'q5_pointing': responses[5] ?? 0,
    // Q7: Imitation (Social Learning)
    'q7_imitation': responses[7] ?? 0,
    // Q9: Joint Attention / Gaze Following
    'q9_joint_attention': responses[9] ?? 0,
    
    // DOMAIN SCORES (0-100, lower = more risk)
    'social_responsiveness_score': socialResponsivenessScore,
    'cognitive_flexibility_score': cognitiveFlexibilityScore, // KEY for CF component
    'joint_attention_score': jointAttentionScore,
    'social_communication_score': socialCommunicationScore,
    'sensory_processing_score': sensoryProcessingScore,
    'communication_score': communicationScore,
    
    // SECONDARY MARKERS
    'q2_routine_change': responses[2] ?? 0,    // Cognitive Flexibility
    'q3_toy_switching': responses[3] ?? 0,     // Cognitive Flexibility
    'q6_sensory_reaction': responses[6] ?? 0,  // Sensory Processing
    'q8_peer_play': responses[8] ?? 0,         // Social Interaction
    'q10_communication': responses[10] ?? 0,   // Communication
    
    // OVERALL METRICS
    'total_score': totalScore,
    'percentage_score': percentageScore,
    'failed_items_total': failedItemsTotal,
    'failed_items_rate': failedItemsRate,
    'risk_score': riskScore,
    
    // COMPLETION METRICS
    'completion_time_sec': completionTimeSec,
    'total_questions': totalQuestions,
  };

  /// Get a descriptive interpretation of the results
  String get interpretation {
    final buffer = StringBuffer();
    
    if (riskLevel == 'HIGH') {
      buffer.writeln('⚠️ HIGH RISK INDICATORS DETECTED');
      buffer.writeln('');
      buffer.writeln('Critical items failed: ${criticalItemsFailed.length}/$criticalItemsCount');
      buffer.writeln('Total items of concern: $failedItemsTotal/$totalQuestions');
      buffer.writeln('');
      buffer.writeln('Areas of concern:');
      
      categoryScores.forEach((category, score) {
        if (score.percentage < 50) {
          buffer.writeln('  • $category: ${score.percentage.toStringAsFixed(0)}%');
        }
      });
      
      buffer.writeln('');
      buffer.writeln('RECOMMENDATION: Clinical evaluation strongly recommended.');
    } else if (riskLevel == 'MODERATE') {
      buffer.writeln('⚡ MODERATE RISK INDICATORS');
      buffer.writeln('');
      buffer.writeln('Some areas may need attention:');
      
      categoryScores.forEach((category, score) {
        if (score.percentage < 60) {
          buffer.writeln('  • $category: ${score.percentage.toStringAsFixed(0)}%');
        }
      });
      
      buffer.writeln('');
      buffer.writeln('RECOMMENDATION: Monitor development and consider follow-up screening.');
    } else {
      buffer.writeln('✅ LOW RISK');
      buffer.writeln('');
      buffer.writeln('Child shows typical developmental patterns in most areas.');
      buffer.writeln('Overall score: ${percentageScore.toStringAsFixed(0)}%');
    }
    
    return buffer.toString();
  }

  /// Get individual question analysis for clinical review
  List<QuestionAnalysis> get questionAnalysis {
    return responses.entries.map((entry) {
      final questionId = entry.key;
      final response = entry.value;
      final isCritical = [1, 4, 5, 7, 9].contains(questionId);
      final isFailed = response <= 2;
      
      return QuestionAnalysis(
        questionId: questionId,
        response: response,
        isCritical: isCritical,
        isFailed: isFailed,
        riskContribution: isCritical && isFailed ? 'HIGH' : (isFailed ? 'MODERATE' : 'LOW'),
      );
    }).toList();
  }
}

/// Category-specific score breakdown
class CategoryScore {
  final String category;
  final int totalScore;
  final int maxScore;
  final double percentage;
  final double averageScore;
  final int questionCount;
  final int failedItems;

  CategoryScore({
    required this.category,
    required this.totalScore,
    required this.maxScore,
    required this.percentage,
    required this.averageScore,
    required this.questionCount,
    required this.failedItems,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'total_score': totalScore,
      'max_score': maxScore,
      'percentage': percentage,
      'average_score': averageScore,
      'question_count': questionCount,
      'failed_items': failedItems,
    };
  }
  
  /// Risk level for this category
  String get riskLevel {
    if (percentage < 40) return 'HIGH';
    if (percentage < 60) return 'MODERATE';
    return 'LOW';
  }
}

/// Individual question analysis
class QuestionAnalysis {
  final int questionId;
  final int response;
  final bool isCritical;
  final bool isFailed;
  final String riskContribution;

  QuestionAnalysis({
    required this.questionId,
    required this.response,
    required this.isCritical,
    required this.isFailed,
    required this.riskContribution,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'response': response,
      'is_critical': isCritical,
      'is_failed': isFailed,
      'risk_contribution': riskContribution,
    };
  }
}

/// M-CHAT-R/F Critical Item Descriptions
class MChatCriticalItems {
  static const Map<int, String> descriptions = {
    1: 'Name Response - Does the child respond when you call their name?',
    4: 'Eye Contact - Does the child make eye contact during interactions?',
    5: 'Pointing - Does the child point to show interest or share attention?',
    7: 'Imitation - Does the child imitate actions and sounds?',
    9: 'Joint Attention - Does the child follow your gaze and pointing?',
  };
  
  /// Get risk interpretation for critical item
  static String getRiskInterpretation(int questionId, int response) {
    if (response <= 2) {
      switch (questionId) {
        case 1:
          return 'Reduced response to name is a key early indicator of ASD';
        case 4:
          return 'Limited eye contact may indicate social communication difficulties';
        case 5:
          return 'Absence of pointing is one of the strongest predictors of ASD';
        case 7:
          return 'Limited imitation may affect social learning development';
        case 9:
          return 'Difficulty with joint attention is a core feature of ASD';
        default:
          return 'This response indicates a potential area of concern';
      }
    }
    return 'Response within typical range';
  }
}




