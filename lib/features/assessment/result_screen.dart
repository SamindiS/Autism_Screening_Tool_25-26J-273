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

  Color _getRiskColor() {
    switch (widget.riskLevel) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Results'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
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
                    // Risk Level Card
                    if (widget.riskLevel != null) _buildRiskCard(),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.child_care, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.child.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Age: ${widget.child.age.toStringAsFixed(1)} years | ${widget.child.gender}',
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

  Widget _buildRiskCard() {
    final riskColor = _getRiskColor();
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
            widget.riskLevel == 'low'
                ? Icons.check_circle
                : widget.riskLevel == 'moderate'
                    ? Icons.warning
                    : Icons.error,
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
          if (widget.riskScore != null) ...[
            const SizedBox(height: 8),
            Text(
              'Risk Score: ${widget.riskScore!.toStringAsFixed(2)} / 5.0',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
                'Game Performance',
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
          _buildMetricRow('Attention Level', '${data['attention_level']}/5', Colors.blue),
          const SizedBox(height: 12),
          _buildMetricRow('Engagement Level', '${data['engagement_level']}/5', Colors.green),
          const SizedBox(height: 12),
          _buildMetricRow('Frustration Tolerance', '${data['frustration_tolerance']}/5', Colors.orange),
          const SizedBox(height: 12),
          _buildMetricRow('Instruction Following', '${data['instruction_following']}/5', Colors.teal),
          const SizedBox(height: 12),
          _buildMetricRow('Overall Behavior', '${data['overall_behavior']}/5', Colors.purple),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 12),
          _buildMetricRow('Average Reflection Score', '${(data['average_reflection_score'] as num).toStringAsFixed(2)}/5', Colors.indigo, isBold: true),
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

    switch (widget.riskLevel) {
      case 'low':
        recommendation = 'The child shows typical development patterns. Continue regular monitoring.';
        recColor = Colors.green;
        break;
      case 'moderate':
        recommendation = 'The child shows some areas of concern. Recommend further evaluation and monitoring.';
        recColor = Colors.orange;
        break;
      case 'high':
        recommendation = 'The child shows significant indicators. Recommend comprehensive evaluation by a specialist.';
        recColor = Colors.red;
        break;
      default:
        recommendation = 'Assessment completed. Review results with clinical team.';
        recColor = Colors.grey;
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
                  'Recommendation',
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
              backgroundColor: Colors.orange,
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
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange, width: 2),
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
