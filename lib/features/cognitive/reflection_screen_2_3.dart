import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/child.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/logger_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/language_selector.dart';
import '../assessment/result_screen.dart';

class ClinicianReflectionScreen2_3 extends StatefulWidget {
  final Child child;
  final String sessionId;
  final Map<String, dynamic> questionnaireResults;

  const ClinicianReflectionScreen2_3({
    Key? key,
    required this.child,
    required this.sessionId,
    required this.questionnaireResults,
  }) : super(key: key);

  @override
  State<ClinicianReflectionScreen2_3> createState() => _ClinicianReflectionScreen2_3State();
}

class _ClinicianReflectionScreen2_3State extends State<ClinicianReflectionScreen2_3> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // Manual Task Observations
  int? _task1Attention; // "Point to object" task
  int? _task2Flexibility; // "Follow simple instruction" task
  int? _task3Social; // "Imitate action" task
  int? _task4Communication; // "Respond to name" task
  int? _task5Engagement; // "Play with toy" task

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate all fields
    if (_task1Attention == null ||
        _task2Flexibility == null ||
        _task3Social == null ||
        _task4Communication == null ||
        _task5Engagement == null ||
        _cognitiveFlexibility == null ||
        _attentionLevel == null ||
        _frustrationTolerance == null ||
        _perseverationBehavior == null ||
        _overallBehavior == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all observations'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Calculate task scores
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

      final avgTaskScore = taskScores.values.reduce((a, b) => a + b) / taskScores.length;
      final avgBehavioralScore = behavioralScores.values.reduce((a, b) => a + b) / behavioralScores.length;
      final avgReflectionScore = (avgTaskScore + avgBehavioralScore) / 2;

      // Combine questionnaire (50%) + manual tasks (30%) + behavioral observations (20%)
      final questionnaireScore = (widget.questionnaireResults['percentage_score'] as num).toDouble() / 100.0 * 5.0;
      final taskScore = avgTaskScore;
      final behavioralScore = avgBehavioralScore;
      
      final enhancedRiskScore = (questionnaireScore * 0.5) + (taskScore * 0.3) + (behavioralScore * 0.2);
      
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
        'manual_task_scores': taskScores,
        'behavioral_observation_scores': behavioralScores,
        'average_task_score': avgTaskScore,
        'average_behavioral_score': avgBehavioralScore,
        'average_reflection_score': avgReflectionScore,
        'questionnaire_score': questionnaireScore,
        'enhanced_risk_score': enhancedRiskScore,
        'risk_level': riskLevel,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Update session with reflection data
      try {
        await StorageService.updateSession(
          id: widget.sessionId,
          reflectionResults: reflectionData,
          riskScore: enhancedRiskScore,
          riskLevel: riskLevel.toLowerCase(),
        );
      } catch (e) {
        debugPrint('Error updating session: $e');
        // Try to create session if it doesn't exist
        try {
          final sessionData = await StorageService.saveSession(
            childId: widget.child.id,
            sessionType: 'ai_doctor_bot',
            ageGroup: '2-3.5',
            startTime: DateTime.now().subtract(const Duration(minutes: 10)),
            endTime: DateTime.now(),
            questionnaireResults: widget.questionnaireResults,
            reflectionResults: reflectionData,
            riskScore: enhancedRiskScore,
            riskLevel: riskLevel.toLowerCase(),
          );
          
          if (sessionData != null && sessionData['id'] != null) {
            // Use the new session ID
            final newSessionId = sessionData['id'] as String;
            debugPrint('Created new session: $newSessionId');
          }
        } catch (createError) {
          debugPrint('Error creating session: $createError');
          throw Exception('Failed to save reflection data: $createError');
        }
      }

      // Log to console
      LoggerService.logSession({
        'event': 'CLINICAL_REFLECTION_2_3_COMPLETED',
        'child_id': widget.child.id,
        'session_id': widget.sessionId,
        'questionnaire_results': widget.questionnaireResults,
        'reflection_data': reflectionData,
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
              questionnaireResults: widget.questionnaireResults,
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
        title: Text(AppLocalizations.of(context)?.clinicianReflection2_3 ?? 'Clinical Reflection (Ages 2-3.5)'),
        backgroundColor: Colors.blue,
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
              Colors.blue.shade50,
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
                  const SizedBox(height: 24),
                  // Instructions
                  _buildInstructionsCard(),
                  const SizedBox(height: 24),
                  // Important Note
                  _buildImportantNoteCard(),
                  const SizedBox(height: 24),
                  // Manual Tasks Section
                  _buildSectionTitle('Manual Cognitive Flexibility Tasks', Icons.task),
                  const SizedBox(height: 16),
                  ..._manualTasks.map((task) => _buildTaskCard(task)),
                  const SizedBox(height: 24),
                  // Behavioral Observations Section
                  _buildSectionTitle('Behavioral Observations', Icons.psychology),
                  const SizedBox(height: 16),
                  ..._behavioralObservations.map((obs) => _buildBehavioralCard(obs)),
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
          colors: [Colors.blue.shade600, Colors.blue.shade400],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.assignment,
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
                  'Manual Task Assessment',
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
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manual Task Instructions',
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The parent has completed the questionnaire. Now, please perform these manual cognitive flexibility tasks with the child (WITHOUT tablet) and observe their behavior. Focus on rule-switching and cognitive flexibility abilities.',
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNoteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important: Manual Assessment Only',
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This child (ages 2-3.5) did NOT play tablet games. Please use physical objects (blocks, toys, etc.) to assess cognitive flexibility and rule-switching. Observe how the child adapts when rules change.',
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 28),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final taskId = task['id'] as String;
    int? selectedValue;

    switch (taskId) {
      case 'task1':
        selectedValue = _task1Attention;
        break;
      case 'task2':
        selectedValue = _task2Flexibility;
        break;
      case 'task3':
        selectedValue = _task3Social;
        break;
      case 'task4':
        selectedValue = _task4Communication;
        break;
      case 'task5':
        selectedValue = _task5Engagement;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
              Icon(task['icon'] as IconData, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task['title'] as String,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.play_circle_outline, size: 18, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Task to Perform:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  task['task'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                if (task['category'] != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Category: ${task['category']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            task['description'] as String,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),
          _buildLikertScale(taskId, selectedValue, 'task'),
        ],
      ),
    );
  }

  Widget _buildBehavioralCard(Map<String, dynamic> observation) {
    final obsId = observation['id'] as String;
    int? selectedValue;

    switch (obsId) {
      case 'rule_switching':
        selectedValue = _cognitiveFlexibility;
        break;
      case 'attention':
        selectedValue = _attentionLevel;
        break;
      case 'frustration':
        selectedValue = _frustrationTolerance;
        break;
      case 'perseveration':
        selectedValue = _perseverationBehavior;
        break;
      case 'overall':
        selectedValue = _overallBehavior;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
              Icon(observation['icon'] as IconData, color: Colors.purple.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  observation['label'] as String,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            observation['question'] as String,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),
          _buildLikertScale(obsId, selectedValue, 'behavior'),
        ],
      ),
    );
  }

  Widget _buildLikertScale(String id, int? selectedValue, String type) {
    final labels = type == 'task' ? _scaleLabels['task']! : _scaleLabels['behavior']!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        final value = index + 1;
        final isSelected = selectedValue == value;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                switch (id) {
                  case 'task1':
                    _task1Attention = value;
                    break;
                  case 'task2':
                    _task2Flexibility = value;
                    break;
                  case 'task3':
                    _task3Social = value;
                    break;
                  case 'task4':
                    _task4Communication = value;
                    break;
                  case 'task5':
                    _task5Engagement = value;
                    break;
                  case 'rule_switching':
                    _cognitiveFlexibility = value;
                    break;
                  case 'attention':
                    _attentionLevel = value;
                    break;
                  case 'frustration':
                    _frustrationTolerance = value;
                    break;
                  case 'perseveration':
                    _perseverationBehavior = value;
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
                    ? (type == 'task' ? Colors.blue.shade100 : Colors.purple.shade100)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? (type == 'task' ? Colors.blue : Colors.purple)
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
                          ? (type == 'task' ? Colors.blue.shade900 : Colors.purple.shade900)
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
                          ? (type == 'task' ? Colors.blue.shade900 : Colors.purple.shade900)
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
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _loading ? null : _submitReflection,
        style: ElevatedButton.styleFrom(
          primary: Colors.blue,
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

