import 'package:flutter/material.dart';
import '../models/detection_result_model.dart';
import '../config/app_config.dart';

/// Results Screen - Display RRB detection results
class ResultsScreen extends StatelessWidget {
  final DetectionResult? detectionResult;

  const ResultsScreen({super.key, this.detectionResult});

  @override
  Widget build(BuildContext context) {
    if (detectionResult == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Results')),
        body: const Center(child: Text('No results available')),
      );
    }

    final result = detectionResult!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality coming soon'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Detection Status Card
            Card(
              color: result.detected ? Colors.orange[50] : Colors.green[50],
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      result.detected
                          ? Icons.warning_amber
                          : Icons.check_circle,
                      size: 64,
                      color: result.detected ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      result.detected ? 'RRB Detected' : 'No RRB Detected',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (result.primaryBehavior != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Primary Behavior: ${result.primaryBehavior}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                    if (result.confidence != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Confidence: ${(result.confidence! * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Detected Behaviors
            if (result.behaviors.isNotEmpty) ...[
              const Text(
                'Detected Behaviors',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...result.behaviors.map(
                (behavior) => _BehaviorCard(behavior: behavior),
              ),
              const SizedBox(height: 20),
            ],

            // Video Metadata
            const Text(
              'Video Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.timer,
                      label: 'Duration',
                      value: '${result.metadata.duration.toStringAsFixed(1)}s',
                    ),
                    const Divider(),
                    _InfoRow(
                      icon: Icons.video_settings,
                      label: 'FPS',
                      value: '${result.metadata.fps}',
                    ),
                    const Divider(),
                    _InfoRow(
                      icon: Icons.analytics,
                      label: 'Sequences Analyzed',
                      value: '${result.metadata.sequencesAnalyzed}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Actions
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/home', (route) => false);
              },
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BehaviorCard extends StatelessWidget {
  final BehaviorDetection behavior;

  const _BehaviorCard({required this.behavior});

  @override
  Widget build(BuildContext context) {
    final color = Color(
      AppConfig.categoryColors[behavior.behavior] ?? 0xFF2196F3,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    behavior.behavior,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${(behavior.confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: behavior.confidence,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Occurrences: ${behavior.occurrences}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Duration: ${behavior.totalDuration.toStringAsFixed(1)}s',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
