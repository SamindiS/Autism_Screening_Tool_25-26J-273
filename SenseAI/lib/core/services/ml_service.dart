import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// Service for interacting with the backend Machine Learning models.
/// 
/// This service sends extracted features to the backend and receives 
/// ASD risk predictions, confidence scores, and feature explanations.
class MLService {
  /// Predicts ASD risk using a trained ML model on the backend.
  /// 
  /// Requires extracted [mlFeatures], the child's [ageGroup], and the [sessionType].
  /// Returns an [MLPredictionResult] on success, or null if the ML service 
  /// is unavailable (permitting fallback to rule-based logic).
  static Future<MLPredictionResult?> predict({
    required Map<String, dynamic> mlFeatures,
    required String ageGroup,
    required String sessionType,
  }) async {
    try {
      final url = await ApiService.baseUrl;
      debugPrint('🌐 Calling ML prediction API: $url/api/ml/predict');
      debugPrint('📤 Features: ${mlFeatures.keys.length} features');
      
      final response = await http.post(
        Uri.parse('$url/api/ml/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mlFeatures': mlFeatures,
          'ageGroup': ageGroup,
          'sessionType': sessionType,
        }),
      ).timeout(const Duration(seconds: 5));

      debugPrint('📥 ML Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = MLPredictionResult.fromJson(data);
        
        debugPrint('✅ ML Prediction: ${result.isASD ? "ASD Risk" : "Control"}, '
            'Score: ${result.riskScore.toStringAsFixed(1)}, '
            'Method: ${result.method}');
        
        return result;
      } else {
        debugPrint('❌ ML prediction failed: ${response.statusCode} - ${response.body}');
        return null; // Fallback to rule-based
      }
    } catch (e) {
      debugPrint('❌ ML prediction error: $e');
      debugPrint('⚠️  Falling back to rule-based prediction');
      return null; // Fallback to rule-based
    }
  }

  /// Performs a health check to verify if the ML backend is reachable.
  static Future<bool> isAvailable() async {
    try {
      final url = await ApiService.baseUrl;
      final response = await http.get(
        Uri.parse('$url/api/ml/health'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Represents the output of an ML risk assessment.
/// 
/// Includes binary classification, probability scores, confidence levels, 
/// and a list of internal explanations for the prediction.
class MLPredictionResult {
  /// Whether the model predicts a risk of ASD.
  final bool isASD; 
  
  /// The calculated probability of the child having ASD (0.0 to 1.0).
  final double asdProbability;
  
  /// The calculated probability of the child being a control (0.0 to 1.0).
  final double controlProbability;
  
  /// General confidence metric for the prediction accuracy.
  final double confidence;
  
  /// categorical risk level (low, moderate, high).
  final String riskLevel; 
  
  /// Normalized risk score (usually 0 to 100).
  final double riskScore; 
  
  /// Identification of the method used (ml or fallback).
  final String method; 
  
  /// The age group model used for this prediction.
  final String? modelAgeGroup; 
  
  /// List of features and their contributions to this specific prediction.
  final List<MLExplanationItem> explanations;

  MLPredictionResult({
    required this.isASD,
    required this.asdProbability,
    required this.controlProbability,
    required this.confidence,
    required this.riskLevel,
    required this.riskScore,
    required this.method,
    required this.modelAgeGroup,
    required this.explanations,
  });

  /// Factory for creating a result from JSON backend responses.
  factory MLPredictionResult.fromJson(Map<String, dynamic> json) {
    final prediction = json['prediction'] as int? ?? 0;
    final probabilities = json['probability'] as List<dynamic>? ?? [0.5, 0.5];
    final explanationsJson = json['explanations'] as List<dynamic>? ?? const [];
    
    return MLPredictionResult(
      isASD: prediction == 1,
      asdProbability: (probabilities[1] as num).toDouble(),
      controlProbability: (probabilities[0] as num).toDouble(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      riskLevel: json['risk_level'] as String? ?? 'moderate',
      riskScore: (json['risk_score'] as num?)?.toDouble() ?? 50.0,
      method: json['method'] as String? ?? 'unknown',
      modelAgeGroup: json['model_age_group'] as String?,
      explanations: explanationsJson
          .whereType<Map<String, dynamic>>()
          .map(MLExplanationItem.fromJson)
          .toList(),
    );
  }

  /// Convenience getter for the risk level string in uppercase.
  String get riskLevelUpper => riskLevel.toUpperCase();
}

/// Details about a specific feature's contribution to an ML prediction.
class MLExplanationItem {
  /// The name of the feature (e.g., total_perseverative_errors).
  final String feature;
  
  /// The raw value of the feature for this session.
  final double value;
  
  /// The relative contribution of this feature to the final prediction.
  final double contribution;
  
  /// Whether this feature increases or decreases the calculated ASD risk.
  final String direction; // increases_risk | decreases_risk

  const MLExplanationItem({
    required this.feature,
    required this.value,
    required this.contribution,
    required this.direction,
  });

  /// Factory for creating an explanation item from JSON parts.
  factory MLExplanationItem.fromJson(Map<String, dynamic> json) {
    return MLExplanationItem(
      feature: json['feature'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      contribution: (json['contribution'] as num?)?.toDouble() ?? 0.0,
      direction: json['direction'] as String? ?? 'increases_risk',
    );
  }
}








