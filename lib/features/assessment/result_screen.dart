import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../data/models/child.dart';
import '../../data/models/game_results.dart';

class ResultScreen extends StatefulWidget {
  final Child child;
  final String sessionId;
  final GameResults? gameResults;
  final Map<String, dynamic>? questionnaireResults;
  final Map<String, dynamic>? reflectionData;
  final double? riskScore;
  final String? riskLevel;

  const ResultScreen({
    Key? key,
    required this.child,
    required this.sessionId,
    this.gameResults,
    this.questionnaireResults,
    this.reflectionData,
    this.riskScore,
    this.riskLevel,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// For control group children, always show low risk / no ASD concern
  /// This is because they've been pre-screened as typically developing
  String get _effectiveRiskLevel {
    if (widget.child.isControlGroup) {
      return 'control_low'; // Special level for control group
    }
    return widget.riskLevel ?? 'not_assessed';
  }

  Color _getRiskColor() {
    switch (_effectiveRiskLevel) {
      case 'control_low':
        return const Color(0xFF10B981); // Emerald green for control
      case 'low':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getRiskLabel() {
    if (widget.child.isControlGroup) {
      return 'No ASD Concern';
    }
    switch (widget.riskLevel) {
      case 'low':
        return 'Low Risk';
      case 'moderate':
        return 'Moderate Risk';
      case 'high':
        return 'High Risk';
      default:
        return 'Not Assessed';
    }
  }

  IconData _getRiskIcon() {
    if (widget.child.isControlGroup) {
      return Icons.verified; // Checkmark with shield for control
    }
    switch (widget.riskLevel) {
      case 'low':
        return Icons.check_circle;
      case 'moderate':
        return Icons.warning;
      case 'high':
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }

  Color get _primaryColor => widget.child.isAsdGroup 
      ? const Color(0xFF6366F1) 
      : const Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Results'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Child Info Card
                    _buildChildInfoCard(),
                    const SizedBox(height: 24),
                    // Study Group Badge
                    _buildStudyGroupBadge(),
                    const SizedBox(height: 24),
                    // Risk Level Card
                    _buildRiskCard(),
                    const SizedBox(height: 24),
                    // Questionnaire Results (for ages 2-3.5)
                    if (widget.questionnaireResults != null) _buildQuestionnaireCard(),
                    const SizedBox(height: 24),
                    // Game Metrics (for ages 3.5-6)
                    if (widget.gameResults != null) _buildGameMetricsCard(),
                    const SizedBox(height: 24),
                    // Reflection Metrics
                    if (widget.reflectionData != null) _buildReflectionCard(),
                    const SizedBox(height: 24),
                    // Recommendations
                    _buildRecommendationsCard(),
                    const SizedBox(height: 32),
                    // Action Buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 3.14 / 2,
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _primaryColor.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.child.isAsdGroup ? Icons.medical_services : Icons.school,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.child.childCode,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (widget.child.name != widget.child.childCode)
                  Text(
                    widget.child.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '${widget.child.ageInMonths} months | ${widget.child.gender}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyGroupBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            widget.child.isAsdGroup ? Icons.medical_services : Icons.school,
            color: _primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Study Group: ${widget.child.groupDisplayName}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                if (widget.child.isAsdGroup && widget.child.asdLevel != null)
                  Text(
                    'ASD ${widget.child.asdLevelDisplayName}',
                    style: TextStyle(
                      fontSize: 13,
                      color: _primaryColor.withOpacity(0.8),
                    ),
                  ),
                Text(
                  'Source: ${widget.child.diagnosisSource}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard() {
    final riskColor = _getRiskColor();
    final isControl = widget.child.isControlGroup;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: riskColor.withOpacity(0.3), width: 3),
        boxShadow: [
          BoxShadow(
            color: riskColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _getRiskIcon(),
            size: 64,
            color: riskColor,
          ),
          const SizedBox(height: 16),
          Text(
            _getRiskLabel(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: riskColor,
            ),
          ),
          const SizedBox(height: 8),
          if (isControl)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Control Group - Typically Developing',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: riskColor,
                ),
              ),
            )
          else if (widget.riskScore != null)
            Text(
              'Risk Score: ${widget.riskScore!.toStringAsFixed(2)} / 5.0',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 12),
          // Pilot study data collection note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.science, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Data collected for pilot study research',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameMetricsCard() {
    if (widget.gameResults == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
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
              Icon(Icons.games, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              const Text(
                'DCCS Game Performance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMetricRow('Accuracy', '${widget.gameResults!.accuracy.toStringAsFixed(1)}%', Colors.green),
          const SizedBox(height: 12),
          _buildMetricRow('Correct Trials', '${widget.gameResults!.correctTrials}/${widget.gameResults!.totalTrials}', Colors.blue),
          const SizedBox(height: 12),
          _buildMetricRow('Avg Reaction Time', '${(widget.gameResults!.averageReactionTime / 1000).toStringAsFixed(2)}s', Colors.purple),
          if (widget.gameResults!.switchCost != null) ...[
            const SizedBox(height: 12),
            _buildMetricRow('Switch Cost', '${widget.gameResults!.switchCost}ms', Colors.orange),
          ],
          if (widget.gameResults!.perseverativeErrors != null) ...[
            const SizedBox(height: 12),
            _buildMetricRow('Perseverative Errors', widget.gameResults!.perseverativeErrors.toString(), Colors.red),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionnaireCard() {
    if (widget.questionnaireResults == null) return const SizedBox.shrink();

    final data = widget.questionnaireResults!;
    final categoryScores = data['category_scores'] as Map<String, dynamic>? ?? {};
    final maxScore = 10 * 5; // 10 questions, max 5 points each

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
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
              Icon(Icons.quiz, color: Colors.green.shade700),
              const SizedBox(width: 12),
              const Text(
                'Parent Questionnaire Results',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMetricRow('Total Score', '${data['total_score']}/$maxScore', Colors.green),
          const SizedBox(height: 12),
          _buildMetricRow('Percentage Score', '${(data['percentage_score'] as num?)?.toStringAsFixed(1) ?? '0'}%', Colors.blue),
          const SizedBox(height: 12),
          _buildMetricRow('Risk Score', '${(data['risk_score'] as num?)?.toStringAsFixed(1) ?? '0'}', Colors.orange),
          if (categoryScores.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text(
              'Category Scores:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            ...categoryScores.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildMetricRow(
                    entry.key,
                    '${(entry.value as num).toStringAsFixed(1)}%',
                    Colors.teal,
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildReflectionCard() {
    if (widget.reflectionData == null) return const SizedBox.shrink();

    final data = widget.reflectionData!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
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
              Icon(Icons.psychology, color: Colors.purple.shade700),
              const SizedBox(width: 12),
              const Text(
                'Behavioral Observations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (data['attention_level'] != null)
            _buildMetricRow('Attention Level', '${data['attention_level']}/5', Colors.blue),
          if (data['engagement_level'] != null) ...[
            const SizedBox(height: 12),
            _buildMetricRow('Engagement Level', '${data['engagement_level']}/5', Colors.green),
          ],
          if (data['frustration_tolerance'] != null) ...[
            const SizedBox(height: 12),
            _buildMetricRow('Frustration Tolerance', '${data['frustration_tolerance']}/5', Colors.orange),
          ],
          if (data['instruction_following'] != null) ...[
            const SizedBox(height: 12),
            _buildMetricRow('Instruction Following', '${data['instruction_following']}/5', Colors.teal),
          ],
          if (data['overall_behavior'] != null) ...[
            const SizedBox(height: 12),
            _buildMetricRow('Overall Behavior', '${data['overall_behavior']}/5', Colors.purple),
          ],
          if (data['average_reflection_score'] != null) ...[
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 12),
            _buildMetricRow('Average Reflection Score', '${(data['average_reflection_score'] as num).toStringAsFixed(2)}/5', Colors.indigo, isBold: true),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsCard() {
    String recommendation;
    Color recColor;

    if (widget.child.isControlGroup) {
      // Control group specific recommendation
      recommendation = 'This child is part of the Control Group (typically developing). '
          'The assessment data will be used as baseline comparison for the pilot study. '
          'No concerns identified based on parent screening.';
      recColor = const Color(0xFF10B981);
    } else {
      // ASD group recommendations based on risk level
      switch (widget.riskLevel) {
        case 'low':
          recommendation = 'ASD Group child showing good performance. Continue monitoring and '
              'document any changes in behavior patterns.';
          recColor = Colors.green;
          break;
        case 'moderate':
          recommendation = 'ASD Group child shows some areas requiring attention. Review specific '
              'metrics with clinical team and consider targeted interventions.';
          recColor = Colors.orange;
          break;
        case 'high':
          recommendation = 'ASD Group child shows significant indicators consistent with diagnosis. '
              'Data supports existing clinical assessment. Continue comprehensive support.';
          recColor = Colors.red;
          break;
        default:
          recommendation = 'Assessment completed for ASD Group child. Review results with clinical team.';
          recColor = Colors.grey;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: recColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: recColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: recColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.child.isControlGroup ? 'Control Group Note' : 'Clinical Note',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: recColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Export PDF
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF Export - Coming Soon')),
              );
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.dashboard),
            label: const Text('Back to Dashboard'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryColor,
              side: BorderSide(color: _primaryColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
