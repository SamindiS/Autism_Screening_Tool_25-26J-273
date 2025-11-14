import 'package:flutter/material.dart';
import '../../data/models/child.dart';
import '../../data/models/game_results.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/logger_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/language_selector.dart';
import '../assessment/result_screen.dart';

class ClinicianReflectionScreen extends StatefulWidget {
  final Child child;
  final String sessionId;
  final GameResults gameResults;

  const ClinicianReflectionScreen({
    Key? key,
    required this.child,
    required this.sessionId,
    required this.gameResults,
  }) : super(key: key);

  @override
  State<ClinicianReflectionScreen> createState() => _ClinicianReflectionScreenState();
}

class _ClinicianReflectionScreenState extends State<ClinicianReflectionScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _attentionLevel;
  int? _engagementLevel;
  int? _frustrationTolerance;
  int? _instructionFollowing;
  int? _overallBehavior;
  bool _loading = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'id': 'attention',
      'question': 'How well did the child maintain attention during the game?',
      'label': 'Attention Level',
      'icon': Icons.visibility,
    },
    {
      'id': 'engagement',
      'question': 'How engaged was the child with the game activities?',
      'label': 'Engagement Level',
      'icon': Icons.psychology,
    },
    {
      'id': 'frustration',
      'question': 'How did the child handle frustration or mistakes?',
      'label': 'Frustration Tolerance',
      'icon': Icons.mood,
    },
    {
      'id': 'instructions',
      'question': 'How well did the child follow game instructions?',
      'label': 'Following Instructions',
      'icon': Icons.hearing,
    },
    {
      'id': 'overall',
      'question': 'Overall, how would you rate the child\'s behavior during assessment?',
      'label': 'Overall Behavior',
      'icon': Icons.star,
    },
  ];

  final Map<String, List<String>> _scaleLabels = {
    'attention': ['Very Poor', 'Poor', 'Average', 'Good', 'Excellent'],
    'engagement': ['Not Engaged', 'Minimal', 'Moderate', 'Good', 'Very Engaged'],
    'frustration': ['Very Low', 'Low', 'Moderate', 'Good', 'Excellent'],
    'instructions': ['Very Poor', 'Poor', 'Average', 'Good', 'Excellent'],
    'overall': ['Concerning', 'Below Average', 'Average', 'Good', 'Excellent'],
  };

  Future<void> _submitReflection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_attentionLevel == null ||
        _engagementLevel == null ||
        _frustrationTolerance == null ||
        _instructionFollowing == null ||
        _overallBehavior == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Calculate enhanced risk score
      final reflectionScores = {
        'attention': _attentionLevel!,
        'engagement': _engagementLevel!,
        'frustration': _frustrationTolerance!,
        'instructions': _instructionFollowing!,
        'overall': _overallBehavior!,
      };

      final avgReflectionScore = reflectionScores.values.reduce((a, b) => a + b) / reflectionScores.length;
      
      // Combine game metrics (60%) with behavioral observations (40%)
      final gameScore = widget.gameResults.accuracy / 100.0 * 5.0; // Convert to 1-5 scale
      final enhancedRiskScore = (gameScore * 0.6) + (avgReflectionScore * 0.4);
      
      // Determine risk level
      String riskLevel;
      if (enhancedRiskScore <= 2.0) {
        riskLevel = 'high';
      } else if (enhancedRiskScore <= 3.5) {
        riskLevel = 'moderate';
      } else {
        riskLevel = 'low';
      }

      // Save reflection data
      final reflectionData = {
        'session_id': widget.sessionId,
        'child_id': widget.child.id,
        'attention_level': _attentionLevel,
        'engagement_level': _engagementLevel,
        'frustration_tolerance': _frustrationTolerance,
        'instruction_following': _instructionFollowing,
        'overall_behavior': _overallBehavior,
        'average_reflection_score': avgReflectionScore,
        'game_accuracy': widget.gameResults.accuracy,
        'enhanced_risk_score': enhancedRiskScore,
        'risk_level': riskLevel,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Update session with reflection data
      await StorageService.updateSession(
        id: widget.sessionId,
        metrics: {
          'game_results': widget.gameResults.toJson(),
          'reflection_results': reflectionData,
          'risk_score': enhancedRiskScore,
          'risk_level': riskLevel,
        },
      );

      // Log to console
      LoggerService.logSession({
        'event': 'CLINICAL_REFLECTION_COMPLETED',
        'child_id': widget.child.id,
        'session_id': widget.sessionId,
        'reflection_data': reflectionData,
        'game_results': widget.gameResults.toJson(),
        'enhanced_risk_score': enhancedRiskScore,
        'risk_level': riskLevel,
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              child: widget.child,
              sessionId: widget.sessionId,
              gameResults: widget.gameResults,
              reflectionData: reflectionData,
              riskScore: enhancedRiskScore,
              riskLevel: riskLevel,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.clinicianReflection ?? 'Clinician Reflection'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const LanguageSelector(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  _buildHeaderCard(),
                  const SizedBox(height: 32),
                  // Instructions
                  _buildInstructionsCard(),
                  const SizedBox(height: 24),
                  // Questions
                  ..._questions.map((q) => _buildQuestionCard(q)),
                  const SizedBox(height: 32),
                  // Submit Button
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.orange.shade400],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Behavioral Observation',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.child.name,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Please observe and rate the child\'s behavior during the game assessment. Your observations will help determine the child\'s autism risk level.',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    final questionId = question['id'] as String;
    final labels = _scaleLabels[questionId] ?? [];
    int? selectedValue;

    switch (questionId) {
      case 'attention':
        selectedValue = _attentionLevel;
        break;
      case 'engagement':
        selectedValue = _engagementLevel;
        break;
      case 'frustration':
        selectedValue = _frustrationTolerance;
        break;
      case 'instructions':
        selectedValue = _instructionFollowing;
        break;
      case 'overall':
        selectedValue = _overallBehavior;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(question['icon'] as IconData, color: Colors.orange.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question['label'] as String,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question['question'] as String,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),
          // Likert Scale (1-5)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final value = index + 1;
              final isSelected = selectedValue == value;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      switch (questionId) {
                        case 'attention':
                          _attentionLevel = value;
                          break;
                        case 'engagement':
                          _engagementLevel = value;
                          break;
                        case 'frustration':
                          _frustrationTolerance = value;
                          break;
                        case 'instructions':
                          _instructionFollowing = value;
                          break;
                        case 'overall':
                          _overallBehavior = value;
                          break;
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.orange.shade100
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.orange
                            : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          value.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.orange.shade900
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          labels[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? Colors.orange.shade900
                                : Colors.grey.shade600,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _loading ? null : _submitReflection,
        style: ElevatedButton.styleFrom(
          primary: Colors.orange,
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
        ),
        child: _loading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'COMPLETE ASSESSMENT',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }
}
