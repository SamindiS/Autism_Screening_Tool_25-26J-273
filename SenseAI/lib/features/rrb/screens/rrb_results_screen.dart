import 'package:flutter/material.dart';
import '../models/detection_result_model.dart';
import '../config/rrb_config.dart';
import 'rrb_report_screen.dart';

/// RRB Results Screen — professional display with clinical descriptions & PDF report
class RrbResultsScreen extends StatelessWidget {
  final RrbDetectionResult? detectionResult;

  const RrbResultsScreen({super.key, this.detectionResult});

  @override
  Widget build(BuildContext context) {
    if (detectionResult == null) {
      return Scaffold(
        appBar: AppBar(
            title: const Text('Results'),
            backgroundColor: const Color(0xFF0284C7),
            foregroundColor: Colors.white),
        body: const Center(child: Text('No results available')),
      );
    }
    final result = detectionResult!;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: AppBar(
        title: const Text('Detection Results'),
        backgroundColor: const Color(0xFF0369A1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(result),
            const SizedBox(height: 18),
            if (result.behaviors.isNotEmpty) ...[
              _buildSectionHeader('Detected Behaviors',
                  Icons.track_changes_rounded, const Color(0xFF7C3AED)),
              const SizedBox(height: 12),
              ...result.behaviors.map((b) => _BehaviorCard(behavior: b)),
              const SizedBox(height: 18),
            ],
            _buildSectionHeader('Clinical Guidance',
                Icons.medical_information_rounded, const Color(0xFF059669)),
            const SizedBox(height: 12),
            _buildClinicalGuidanceCard(result),
            const SizedBox(height: 18),
            _buildSectionHeader('Video Analysis Summary',
                Icons.analytics_rounded, const Color(0xFF0284C7)),
            const SizedBox(height: 12),
            _buildVideoMetadataCard(result),
            const SizedBox(height: 18),
            _buildDisclaimerCard(),
            const SizedBox(height: 24),
            _buildGenerateReportButton(context, result),
            const SizedBox(height: 12),
            _buildBackButton(context),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(RrbDetectionResult result) {
    final detected = result.detected;
    final gradientColors = detected
        ? [const Color(0xFFEA580C), const Color(0xFFF97316)]
        : [const Color(0xFF059669), const Color(0xFF34D399)];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6))
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle),
          child: Icon(
              detected
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
              size: 52),
        ),
        const SizedBox(height: 16),
        Text(
          detected ? 'RRB Behaviors Detected' : 'No RRB Detected',
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        if (result.primaryBehavior != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20)),
            child: Text('Primary: ${result.primaryBehavior}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ),
        ],
        if (result.confidence != null) ...[
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Overall Confidence',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(width: 10),
            Text('${(result.confidence! * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
                value: result.confidence!,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation(Colors.white)),
          ),
        ],
      ]),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(children: [
      Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18)),
      const SizedBox(width: 10),
      Text(title,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    ]);
  }

  Widget _buildClinicalGuidanceCard(RrbDetectionResult result) {
    final instructions = result.behaviors.isNotEmpty
        ? RrbConfig.behaviorInstructions[result.primaryBehavior] ??
            RrbConfig.behaviorInstructions['Normal']!
        : RrbConfig.behaviorInstructions['Normal']!;

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.lightbulb_outline_rounded,
              color: Color(0xFF059669), size: 18),
          SizedBox(width: 8),
          Text('Recommended Actions',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF059669))),
        ]),
        const SizedBox(height: 10),
        Text(instructions,
            style: const TextStyle(
                fontSize: 13.5, height: 1.7, color: Color(0xFF374151))),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFED7AA))),
          child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Color(0xFFD97706), size: 16),
                SizedBox(width: 6),
                Expanded(
                    child: Text(
                        'These recommendations are intended to guide clinical decision-making. Always consult the child\'s multidisciplinary team before implementing any intervention.',
                        style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF92400E),
                            height: 1.5))),
              ]),
        ),
      ]),
    );
  }

  Widget _buildVideoMetadataCard(RrbDetectionResult result) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      padding: const EdgeInsets.all(18),
      child: Column(children: [
        _InfoRow(
            icon: Icons.timer_rounded,
            label: 'Video Duration',
            value: '${result.metadata.duration.toStringAsFixed(1)} sec'),
        const Divider(height: 20),
        _InfoRow(
            icon: Icons.speed_rounded,
            label: 'Frame Rate (FPS)',
            value: '${result.metadata.fps} fps'),
        const Divider(height: 20),
        _InfoRow(
            icon: Icons.analytics_rounded,
            label: 'Sequences Analyzed',
            value: '${result.metadata.sequencesAnalyzed}'),
        const Divider(height: 20),
        _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Analysis Date',
            value:
                '${result.timestamp.day}/${result.timestamp.month}/${result.timestamp.year}'),
      ]),
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF7DD3FC))),
      child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.shield_outlined, color: Color(0xFF0284C7), size: 18),
        SizedBox(width: 8),
        Expanded(
            child: Text(
          'These results are generated by an AI model for clinical observation support. '
          'They do not constitute a clinical diagnosis. All findings must be reviewed and '
          'interpreted by a qualified healthcare professional.',
          style: TextStyle(fontSize: 12, color: Color(0xFF075985), height: 1.5),
        )),
      ]),
    );
  }

  Widget _buildGenerateReportButton(
      BuildContext context, RrbDetectionResult result) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(16),
      shadowColor: const Color(0xFF059669).withValues(alpha: 0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => RrbReportScreen(detectionResult: result))),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF10B981)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight),
          ),
          child:
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Generate Clinical Report',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text('Download PDF with patient info & findings',
                  style: TextStyle(fontSize: 12, color: Colors.white70)),
            ]),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white70, size: 16),
          ]),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.home_rounded),
      label: const Text('Back to RRB Home'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF0284C7),
        side: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ── Behavior Card ─────────────────────────────────────────────────────────────
class _BehaviorCard extends StatefulWidget {
  final RrbBehaviorDetection behavior;
  const _BehaviorCard({required this.behavior});

  @override
  State<_BehaviorCard> createState() => _BehaviorCardState();
}

class _BehaviorCardState extends State<_BehaviorCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final color =
        Color(RrbConfig.categoryColors[widget.behavior.behavior] ?? 0xFF2196F3);
    final description =
        RrbConfig.behaviorDescriptions[widget.behavior.behavior] ?? '';
    final instructions =
        RrbConfig.behaviorInstructions[widget.behavior.behavior] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Row(children: [
                  Container(
                      width: 14,
                      height: 14,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(widget.behavior.behavior,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A5F)))),
                  Text(
                      '${(widget.behavior.confidence * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  const SizedBox(width: 8),
                  Icon(
                      _expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: color),
                ]),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                      value: widget.behavior.confidence,
                      minHeight: 7,
                      backgroundColor: color.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(color)),
                ),
                const SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatChip(
                          icon: Icons.repeat_rounded,
                          label: '${widget.behavior.occurrences} occurrences',
                          color: color),
                      _StatChip(
                          icon: Icons.timer_rounded,
                          label:
                              '${widget.behavior.totalDuration.toStringAsFixed(1)}s total',
                          color: color),
                    ]),
              ]),
            ),
          ),
          // Expandable: description + instructions
          if (_expanded) ...[
            Divider(color: color.withValues(alpha: 0.2), height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.description_rounded, color: color, size: 16),
                      const SizedBox(width: 6),
                      Text('Clinical Description',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: color)),
                    ]),
                    const SizedBox(height: 6),
                    Text(description,
                        style: const TextStyle(
                            fontSize: 13,
                            height: 1.55,
                            color: Color(0xFF374151))),
                    const SizedBox(height: 14),
                    Row(children: [
                      Icon(Icons.assignment_turned_in_rounded,
                          color: color, size: 16),
                      const SizedBox(width: 6),
                      Text('Recommendations',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: color)),
                    ]),
                    const SizedBox(height: 6),
                    Text(instructions,
                        style: const TextStyle(
                            fontSize: 13,
                            height: 1.65,
                            color: Color(0xFF374151))),
                  ]),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: const Color(0xFF0284C7), size: 18)),
      const SizedBox(width: 12),
      Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)))),
      Text(value,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A5F))),
    ]);
  }
}
