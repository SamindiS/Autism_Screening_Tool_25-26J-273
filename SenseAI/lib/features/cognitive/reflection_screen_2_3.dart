import 'package:flutter/material.dart';
import '../../data/models/child.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/logger_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/language_selector.dart';
import '../settings/settings_screen.dart';
import '../assessment/result_screen.dart';
import '../../core/services/ml_service.dart';

/// Specialized post-assessment reflection form for the 2-3.5 age bracket.
class ClinicianReflectionScreen23 extends StatefulWidget {
  final Child child;
  final String sessionId;
  final Map<String, dynamic> questionnaireResults;

  const ClinicianReflectionScreen23({
    Key? key,
    required this.child,
    required this.sessionId,
    required this.questionnaireResults,
  }) : super(key: key);

  @override
  State<ClinicianReflectionScreen23> createState() => _ClinicianReflectionScreen23State();
}

class _ClinicianReflectionScreen23State extends State<ClinicianReflectionScreen23> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // Manual Task Observations
  int? _task1Attention; 
  int? _task2Flexibility;
  int? _task3Social;
  int? _task4Communication;
  int? _task5Engagement;

  // Overall Behavioral Observations
  int? _cognitiveFlexibility;
  int? _attentionLevel;
  int? _frustrationTolerance;
  int? _perseverationBehavior;
  int? _overallBehavior;

  final List<Map<String, dynamic>> _manualTasks = [
    {
      'id': 'task1',
      'title': 'Rule Switching Task - Color/Shape',
      'description': 'Did the child switch between sorting by color and shape?',
      'label': 'Rule Switching Ability',
      'icon': Icons.swap_horiz,
      'task': 'Give child blocks of different colors and shapes. First ask to sort by COLOR, then switch to SHAPE. Observe if child can switch rules.',
      'category': 'Cognitive Flexibility',
    },
    {
      'id': 'task2',
      'title': 'Follow Changing Instructions',
      'description': 'Did the child adapt when instructions changed?',
      'label': 'Instruction Flexibility',
      'icon': Icons.change_circle,
      'task': 'Give child simple instructions that change (e.g., "Put the red block here" then "Now put the blue block there"). Observe adaptation.',
      'category': 'Cognitive Flexibility',
    },
    {
      'id': 'task3',
      'title': 'Inhibition Task - Go/No-Go',
      'description': 'Did the child inhibit responses when told not to?',
      'label': 'Response Inhibition',
      'icon': Icons.block,
      'task': 'Play a simple game: "When I say GO, clap. When I say STOP, don\'t clap." Observe if child can inhibit clapping on STOP.',
      'category': 'Inhibition Control',
    },
    {
      'id': 'task4',
      'title': 'Perseveration Observation',
      'description': 'Did the child get stuck on one activity or rule?',
      'label': 'Perseveration',
      'icon': Icons.repeat,
      'task': 'After switching rules, observe if child continues with old rule (perseveration) or adapts to new rule.',
      'category': 'Cognitive Flexibility',
    },
    {
      'id': 'task5',
      'title': 'Task Switching - Play Activities',
      'description': 'How well did the child switch between different play activities?',
      'label': 'Activity Switching',
      'icon': Icons.swap_vert,
      'task': 'Have child play with blocks, then ask to switch to drawing, then to toy. Observe ease of switching between activities.',
      'category': 'Cognitive Flexibility',
    },
  ];

  final List<Map<String, dynamic>> _behavioralObservations = [
    {
      'id': 'rule_switching',
      'question': 'How well did the child demonstrate cognitive flexibility during rule-switching tasks?',
      'label': 'Cognitive Flexibility',
      'icon': Icons.psychology,
      'category': 'Cognitive Flexibility',
    },
    {
      'id': 'attention',
      'question': 'How well did the child maintain attention during the manual tasks?',
      'label': 'Attention Level',
      'icon': Icons.visibility,
      'category': 'Attention',
    },
    {
      'id': 'frustration',
      'question': 'How did the child handle frustration when tasks became difficult or rules changed?',
      'label': 'Frustration Tolerance',
      'icon': Icons.mood,
      'category': 'Emotional Regulation',
    },
    {
      'id': 'perseveration',
      'question': 'Did you observe any repetitive behaviors or getting stuck on one activity?',
      'label': 'Perseveration Behavior',
      'icon': Icons.repeat,
      'category': 'Cognitive Flexibility',
    },
    {
      'id': 'overall',
      'question': 'Overall, how would you rate the child\'s cognitive flexibility and rule-switching abilities?',
      'label': 'Overall Cognitive Flexibility',
      'icon': Icons.star,
      'category': 'Overall Assessment',
    },
  ];

  final Map<String, List<String>> _scaleLabels = {
    'task': ['Not Observed', 'Poor', 'Fair', 'Good', 'Excellent'],
    'behavior': ['Very Poor', 'Poor', 'Average', 'Good', 'Excellent'],
  };

  Future<void> _submitReflection() async {
    if (!_formKey.currentState!.validate()) return;

    if (_task1Attention == null || _task2Flexibility == null || _task3Social == null ||
        _task4Communication == null || _task5Engagement == null || _cognitiveFlexibility == null ||
        _attentionLevel == null || _frustrationTolerance == null || 
        _perseverationBehavior == null || _overallBehavior == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all observations'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final taskScores = {
        'rule_switching_ability': _task1Attention!,
        'instruction_flexibility': _task2Flexibility!,
        'response_inhibition': _task3Social!,
        'perseveration_observation': _task4Communication!,
        'activity_switching': _task5Engagement!,
      };

      final behavioralScores = {
        'cognitive_flexibility': _cognitiveFlexibility!,
        'attention_level': _attentionLevel!,
        'frustration_tolerance': _frustrationTolerance!,
        'perseveration_behavior': _perseverationBehavior!,
        'overall_cognitive_flexibility': _overallBehavior!,
      };

      final double avgReflectionScore = (taskScores.values.reduce((a, b) => a + b) / 5 + 
                                  behavioralScores.values.reduce((a, b) => a + b) / 5) / 2;

      // Prepare ML Features
      String mlLang = 'en';
      final currentLocale = Localizations.localeOf(context).languageCode;
      if (currentLocale == 'si') mlLang = 'si';
      if (currentLocale == 'ta') mlLang = 'ta';

      final Map<String, dynamic> qResponses = widget.questionnaireResults['responses'] ?? {};
      
      final Map<String, dynamic> mlFeatures = {
        'age_months': widget.child.ageInMonths,
        'gender': widget.child.gender.toLowerCase() == 'male' ? 1 : 0,
        'language': mlLang == 'en' ? 0 : mlLang == 'si' ? 1 : 2,
        'q1_name_response': qResponses['1'] ?? widget.questionnaireResults['q1_name_response'] ?? 3,
        'q2_routine_change': qResponses['2'] ?? widget.questionnaireResults['q2_routine_change'] ?? 3,
        'q3_toy_switching': qResponses['3'] ?? widget.questionnaireResults['q3_toy_switching'] ?? 3,
        'q4_eye_contact': qResponses['4'] ?? widget.questionnaireResults['q4_eye_contact'] ?? 1,
        'q5_pointing': qResponses['5'] ?? widget.questionnaireResults['q5_pointing'] ?? 1,
        'q6_sensory_reaction': qResponses['6'] ?? widget.questionnaireResults['q6_sensory_reaction'] ?? 1,
        'q7_imitation': qResponses['7'] ?? widget.questionnaireResults['q7_imitation'] ?? 1,
        'q8_peer_play': qResponses['8'] ?? widget.questionnaireResults['q8_peer_play'] ?? 1,
        'q9_joint_attention': qResponses['9'] ?? widget.questionnaireResults['q9_joint_attention'] ?? 1,
        'q10_communication': qResponses['10'] ?? widget.questionnaireResults['q10_communication'] ?? 1,
        'total_q_score': widget.questionnaireResults['total_score'] ?? 10,
        'attention_level': _attentionLevel ?? 3,
        'engagement_level': _task5Engagement ?? 3,
        'frustration_tolerance': _frustrationTolerance ?? 3,
        'instruction_following': _task2Flexibility ?? 3,
        'cognitive_flexibility_obs': _cognitiveFlexibility ?? 3,
        'perseveration_behavior': _perseverationBehavior ?? 3,
        'rule_switching_ability': _task1Attention ?? 3,
        'response_inhibition': _task3Social ?? 3,
        'activity_switching': _task5Engagement ?? 3,
      };

      final mlResult = await MLService.predict(
        mlFeatures: mlFeatures,
        ageGroup: '2-3.5',
        sessionType: 'clinician_reflection',
      );

      double finalRiskScore;
      String finalRiskLevel;
      Map<String, dynamic> finalPredictionMetadata = {};

      final bool hasReliableMlResult =
          mlResult != null && mlResult.method.toLowerCase() != 'fallback';

      if (hasReliableMlResult) {
        finalRiskScore = mlResult.riskScore;
        finalRiskLevel = mlResult.riskLevel;
        finalPredictionMetadata = {
          'ml_method': mlResult.method,
          'asd_probability': mlResult.asdProbability,
          'control_probability': mlResult.controlProbability,
          'confidence': mlResult.confidence,
        };
      } else {
        // Fallback Logic (Mandatory Clinical Realignment)
        // Corrected Interpretation: Lower points = Higher Risk
        // avgTotalScore maps to the 1.0-5.0 Scale suggested by clinicians
        final qScore = (widget.questionnaireResults['total_score'] as num?)?.toDouble() ?? 50.0;
        final avgQuestionnaire = qScore / 10.0;
        final avgTotalScore = (avgQuestionnaire + avgReflectionScore) / 2.0;

        finalRiskScore = (1.0 - (avgTotalScore - 1.0) / 4.0) * 100.0; // Normalized 0-100 Risk Score
        
        if (avgTotalScore <= 2.0) {
          finalRiskLevel = 'high';
        } else if (avgTotalScore <= 3.0) {
          finalRiskLevel = 'moderate';
        } else if (avgTotalScore <= 4.0) {
          finalRiskLevel = 'low';
        } else {
          finalRiskLevel = 'no_risk';
        }
        
        finalPredictionMetadata = {
          'ml_method': 'rule_based_fallback',
          if (mlResult != null) 'backend_method': mlResult.method,
          'avg_performance_score': avgTotalScore,
        };
      }

      final reflectionData = {
        'session_id': widget.sessionId,
        'child_id': widget.child.id,
        'manual_task_scores': taskScores,
        'behavioral_observation_scores': behavioralScores,
        'average_reflection_score': avgReflectionScore,
        'overall_cognitive_risk_score': finalRiskScore,
        'risk_level': finalRiskLevel,
        'prediction_metadata': finalPredictionMetadata,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await StorageService.updateSession(
        id: widget.sessionId,
        endTime: DateTime.now(),
        reflectionResults: reflectionData,
        riskScore: finalRiskScore,
        riskLevel: finalRiskLevel.toLowerCase(),
      );

      LoggerService.logSession({
        'event': 'CLINICAL_REFLECTION_2_3_COMPLETED',
        'child_id': widget.child.id,
        'session_id': widget.sessionId,
        'risk_level': finalRiskLevel,
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              child: widget.child,
              sessionId: widget.sessionId,
              questionnaireResults: widget.questionnaireResults,
              reflectionData: reflectionData,
              riskScore: finalRiskScore,
              riskLevel: finalRiskLevel,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.clinicianReflection2_3 ?? 'Clinician Reflection'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const LanguageSelector(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.blue.shade50, Colors.white])),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 24),
                  _buildInstructionsCard(),
                  const SizedBox(height: 24),
                  _buildImportantNoteCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle(l10n?.translate('manual_tasks_section') ?? 'Manual Tasks', Icons.task),
                  const SizedBox(height: 16),
                  ..._manualTasks.map((task) => _buildTaskCard(task)),
                  const SizedBox(height: 24),
                  _buildSectionTitle(l10n?.behavioralObservations ?? 'Observations', Icons.psychology),
                  const SizedBox(height: 16),
                  ..._behavioralObservations.map((obs) => _buildBehavioralCard(obs)),
                  const SizedBox(height: 32),
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
        gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade400]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.child.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Age: ${widget.child.ageInMonths} months', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange.withOpacity(0.3))),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          const Expanded(child: Text('Please perform manual cognitive tasks and observe the child\'s behavior.')),
        ],
      ),
    );
  }

  Widget _buildImportantNoteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.withOpacity(0.3))),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Text('Important: This age group (2-3.5) uses manual tasks for assessment.')),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 28),
        const SizedBox(width: 12),
        Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
      ],
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final id = task['id'] as String;
    int? val;
    if (id == 'task1') val = _task1Attention;
    if (id == 'task2') val = _task2Flexibility;
    if (id == 'task3') val = _task3Social;
    if (id == 'task4') val = _task4Communication;
    if (id == 'task5') val = _task5Engagement;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(task['task'], style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            _buildLikertScale(id, val, 'task'),
          ],
        ),
      ),
    );
  }

  Widget _buildBehavioralCard(Map<String, dynamic> observation) {
    final id = observation['id'] as String;
    int? val;
    if (id == 'rule_switching') val = _cognitiveFlexibility;
    if (id == 'attention') val = _attentionLevel;
    if (id == 'frustration') val = _frustrationTolerance;
    if (id == 'perseveration') val = _perseverationBehavior;
    if (id == 'overall') val = _overallBehavior;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(observation['label'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(observation['question'], style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            _buildLikertScale(id, val, 'behavior'),
          ],
        ),
      ),
    );
  }

  Widget _buildLikertScale(String id, int? selectedValue, String type) {
    final l10n = AppLocalizations.of(context);
    final labels = _scaleLabels[type] ?? ['1', '2', '3', '4', '5'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        final value = index + 1;
        final isSelected = selectedValue == value;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              if (id == 'task1') _task1Attention = value;
              else if (id == 'task2') _task2Flexibility = value;
              else if (id == 'task3') _task3Social = value;
              else if (id == 'task4') _task4Communication = value;
              else if (id == 'task5') _task5Engagement = value;
              else if (id == 'rule_switching') _cognitiveFlexibility = value;
              else if (id == 'attention') _attentionLevel = value;
              else if (id == 'frustration') _frustrationTolerance = value;
              else if (id == 'perseveration') _perseverationBehavior = value;
              else if (id == 'overall') _overallBehavior = value;
            }),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300, width: isSelected ? 2 : 1),
              ),
              child: Column(
                children: [
                  Text('$value', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.blue.shade900)),
                  const SizedBox(height: 2),
                  Text(
                    l10n?.translate('scale${type.substring(0, 1).toUpperCase()}${type.substring(1)}${value}') ?? labels[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 8, color: isSelected ? Colors.white : Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _loading ? null : _submitReflection,
        child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('COMPLETE ASSESSMENT'),
      ),
    );
  }
}
