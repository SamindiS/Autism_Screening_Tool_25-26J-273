// ml_service.dart - ML Model Prediction Service
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// Service for making ML predictions using trained model
class MLService {
  /// Predict ASD risk using trained ML model
  /// 
  /// Returns ML prediction result with risk score and level
  /// Falls back to null if prediction fails (use rule-based instead)
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
      );

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

  /// Check if ML service is available
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

/// ML Prediction Result
class MLPredictionResult {
  final bool isASD; // prediction == 1
  final double asdProbability;
  final double controlProbability;
  final double confidence;
  final String riskLevel; // 'low', 'moderate', 'high'
  final double riskScore; // 0-100
  final String method; // 'ml' or 'fallback'
  final String? modelAgeGroup; // '2-3.5', '3.5-5.5', '5.5-6.9'
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

  /// Convert risk level to uppercase for compatibility
  String get riskLevelUpper => riskLevel.toUpperCase();
}

class MLExplanationItem {
  final String feature;
  final double value;
  final double contribution;
  final String direction; // increases_risk | decreases_risk

  const MLExplanationItem({
    required this.feature,
    required this.value,
    required this.contribution,
    required this.direction,
  });

  factory MLExplanationItem.fromJson(Map<String, dynamic> json) {
    return MLExplanationItem(
      feature: json['feature'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      contribution: (json['contribution'] as num?)?.toDouble() ?? 0.0,
      direction: json['direction'] as String? ?? 'increases_risk',
    );
  }
}








