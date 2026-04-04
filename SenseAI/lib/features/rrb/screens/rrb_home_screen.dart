import 'package:flutter/material.dart';
import '../config/rrb_config.dart';
import 'rrb_video_recording_screen.dart';

/// RRB Home Screen — professional entry point for the RRB Detection module
class RrbHomeScreen extends StatelessWidget {
  const RrbHomeScreen({super.key});

  static const _behaviors = [
    {
      'label': 'Hand Flapping',
      'color': Color(0xFFE74C3C),
      'icon': Icons.back_hand
    },
    {
      'label': 'Head Banging',
      'color': Color(0xFFE67E22),
      'icon': Icons.crisis_alert
    },
    {'label': 'Head Nodding', 'color': Color(0xFFF39C12), 'icon': Icons.loop},
    {'label': 'Spinning', 'color': Color(0xFF9B59B6), 'icon': Icons.autorenew},
    {
      'label': 'Atypical Hand Movements',
      'color': Color(0xFF3498DB),
      'icon': Icons.gesture
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      body: CustomScrollView(
        slivers: [
          _buildHeroAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWhatIsRrbCard(),
                  const SizedBox(height: 16),
                  _buildDetectableBehaviorsCard(context),
                  const SizedBox(height: 16),
                  _buildHowItWorksCard(),
                  const SizedBox(height: 28),
                  _buildStartButton(context),
                  const SizedBox(height: 16),
                  _buildRequirementsNote(),
                  const SizedBox(height: 8),
                  _buildDisclaimerNote(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: const Color(0xFF0369A1),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0369A1), Color(0xFF0EA5E9), Color(0xFF38BDF8)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.psychology_alt,
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('RRB Detection',
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.3)),
                            Text('AI-Powered Clinical Observation Tool',
                                style: TextStyle(
                                    fontSize: 12.5, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text(
                      'Detect Restricted & Repetitive Behaviors in children aged 2–6 '
                      'through intelligent clinical video analysis.',
                      style: TextStyle(
                          fontSize: 13, color: Colors.white, height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWhatIsRrbCard() {
    return _SectionCard(
      icon: Icons.info_outline_rounded,
      iconColor: const Color(0xFF0284C7),
      title: 'What Are Restrictive & Repetitive Behaviors?',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restricted and Repetitive Behaviors (RRBs) are a core diagnostic feature of Autism Spectrum Disorder (ASD). '
            'They encompass stereotyped or repetitive motor movements, insistence on sameness, and restricted patterns of interest.',
            style: TextStyle(
                fontSize: 13.5, height: 1.55, color: Color(0xFF374151)),
          ),
          SizedBox(height: 10),
          Text(
            'Early and accurate detection of RRBs enables timely clinical intervention and supports individualized care planning for children at risk.',
            style: TextStyle(
                fontSize: 13.5, height: 1.55, color: Color(0xFF374151)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectableBehaviorsCard(BuildContext context) {
    return _SectionCard(
      icon: Icons.track_changes_rounded,
      iconColor: const Color(0xFF7C3AED),
      title: 'Behaviors This Tool Detects',
      child: Column(
        children: [
          ..._behaviors.map((b) => _BehaviorRow(
                label: b['label'] as String,
                color: b['color'] as Color,
                icon: b['icon'] as IconData,
                description: RrbConfig.behaviorDescriptions[b['label']] ?? '',
              )),
        ],
      ),
    );
  }

  Widget _buildHowItWorksCard() {
    return _SectionCard(
      icon: Icons.lightbulb_outline_rounded,
      iconColor: const Color(0xFF059669),
      title: 'How It Works',
      child: const Column(
        children: [
          _StepItem(
              step: '1',
              text:
                  'Record or upload a clinical observation video of the child (10 seconds – 5 minutes).'),
          _StepItem(
              step: '2',
              text:
                  'Our AI model analyzes motion patterns and body movements frame-by-frame.'),
          _StepItem(
              step: '3',
              text:
                  'Detected behaviors are reported with confidence scores and clinical descriptions.'),
          _StepItem(
              step: '4',
              text:
                  'Generate and download a professional PDF report for clinical records and referrals.'),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(18),
      shadowColor: const Color(0xFF0284C7).withValues(alpha: 0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RrbVideoRecordingScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_rounded, color: Colors.white, size: 32),
              SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start RRB Detection',
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text('Record or Upload a Clinical Video',
                      style: TextStyle(fontSize: 12.5, color: Colors.white70)),
                ],
              ),
              SizedBox(width: 12),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white70, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementsNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7DD3FC)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.checklist_rounded, color: Color(0xFF0284C7), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Video Requirements\n'
              '• Duration: 10 seconds to 5 minutes\n'
              '• Ensure good lighting and a clear, unobstructed view of the child\n'
              '• Confidence threshold: 70%  •  Min detection duration: 3 seconds',
              style: TextStyle(
                  fontSize: 12.5, height: 1.55, color: Color(0xFF075985)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'This tool is designed to support clinical observation only and does not provide a medical diagnosis. '
              'Results should always be interpreted by a qualified healthcare professional.',
              style: TextStyle(
                  fontSize: 11.5, height: 1.5, color: Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Section Card ──────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A5F))),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Behavior Row ───────────────────────────────────────────────────────────────
class _BehaviorRow extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final String description;

  const _BehaviorRow(
      {required this.label,
      required this.color,
      required this.icon,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: color)),
                const SizedBox(height: 2),
                Text(
                  description.split('.').first + '.',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280), height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step Item ─────────────────────────────────────────────────────────────────
class _StepItem extends StatelessWidget {
  final String step;
  final String text;

  const _StepItem({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)]),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(step,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13.5, color: Color(0xFF374151), height: 1.45)),
            ),
          ),
        ],
      ),
    );
  }
}
