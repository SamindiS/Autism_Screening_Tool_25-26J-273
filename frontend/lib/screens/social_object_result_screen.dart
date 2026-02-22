/// Result screen for Social vs Object Preference test.
/// Displays metrics and provides PDF report generation.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';

class SocialObjectResultScreen extends StatelessWidget {
  final String sessionId;
  final Map<String, dynamic> metrics;

  const SocialObjectResultScreen({
    super.key,
    required this.sessionId,
    required this.metrics,
  });

  static String _fmt(dynamic v) {
    if (v == null) return '—';
    if (v is num) return v is int ? '$v' : (v as double).toStringAsFixed(2);
    return '$v';
  }

  @override
  Widget build(BuildContext context) {
    final faceRatio = (metrics['face_time_ratio'] as num?)?.toDouble();
    final objectRatio = (metrics['object_time_ratio'] as num?)?.toDouble();
    final centerRatio = (metrics['center_time_ratio'] as num?)?.toDouble();
    final firstFixation = metrics['first_fixation'] as String?;
    final switchCount = metrics['switch_count'];
    final meanFaceMs = (metrics['mean_fix_dur_face_ms'] as num?)?.toDouble();
    final meanObjectMs = (metrics['mean_fix_dur_object_ms'] as num?)?.toDouble();
    final centerWarning = metrics['center_bias_warning'] == true;
    final durationMs = metrics['duration_ms'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social vs Object – Results'),
        backgroundColor: const Color(0xFF4ECDC4),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle, size: 64, color: Color(0xFF2E7D32)),
              const SizedBox(height: 16),
              const Text(
                'Social Attention Task Complete',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _MetricCard(
                title: 'Face attention',
                value: faceRatio != null ? '${(faceRatio * 100).toStringAsFixed(1)}%' : _fmt(metrics['face_time_ratio']),
              ),
              _MetricCard(
                title: 'Object attention',
                value: objectRatio != null ? '${(objectRatio * 100).toStringAsFixed(1)}%' : _fmt(metrics['object_time_ratio']),
              ),
              _MetricCard(
                title: 'Center attention',
                value: centerRatio != null ? '${(centerRatio * 100).toStringAsFixed(1)}%' : _fmt(metrics['center_time_ratio']),
              ),
              _MetricCard(title: 'First look', value: _fmt(firstFixation)),
              _MetricCard(title: 'Switches (face ↔ object)', value: _fmt(switchCount)),
              _MetricCard(
                title: 'Mean fixation – face',
                value: meanFaceMs != null ? '${meanFaceMs.toStringAsFixed(0)} ms' : _fmt(metrics['mean_fix_dur_face_ms']),
              ),
              _MetricCard(
                title: 'Mean fixation – object',
                value: meanObjectMs != null ? '${meanObjectMs.toStringAsFixed(0)} ms' : _fmt(metrics['mean_fix_dur_object_ms']),
              ),
              if (durationMs != null)
                _MetricCard(
                  title: 'Duration',
                  value: '${(durationMs / 1000).toStringAsFixed(1)} s',
                ),
              if (centerWarning) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: const Text(
                    'High center gaze bias observed; interpret results cautiously.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _generatePdfReport(context),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generate PDF Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E86AB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Back to Home'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generatePdfReport(BuildContext context) async {
    final url = Uri.parse('$apiBaseUrl/social_object/report/$sessionId/download');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open report. Try again or save from browser.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const _MetricCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF2C3E50),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E86AB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
