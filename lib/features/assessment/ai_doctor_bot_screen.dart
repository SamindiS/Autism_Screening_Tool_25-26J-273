import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/child.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/logger_service.dart';
import '../../core/services/translation_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/language_selector.dart';
import '../settings/settings_screen.dart';
import '../cognitive/reflection_screen_2_3.dart';
import 'models/questionnaire_summary.dart';
import 'result_screen.dart';

class AIDoctorBotScreen extends StatefulWidget {
  final Child child;

  const AIDoctorBotScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AIDoctorBotScreen> createState() => _AIDoctorBotScreenState();
}

class _AIDoctorBotScreenState extends State<AIDoctorBotScreen>
    with TickerProviderStateMixin {
  int _currentQuestion = 0;
  final Map<int, int> _answers = {};
  late AnimationController _botController;
  late AnimationController _questionController;
  late Animation<double> _botScale;
  late Animation<double> _questionFade;
  String? _sessionId;
  DateTime? _startTime;

  List<Map<String, dynamic>> _getQuestions() {
    return TranslationHelper.getAIBotQuestions(widget.child.name, context);
  }
  
  // Legacy hardcoded questions - kept for reference but not used
  final List<Map<String, dynamic>> _questionsLegacy = [
    {
      'id': 1,
      'question': 'Does {childName} respond when you call their name?',
      'category': 'Social Responsiveness',
      'options': [
        {'text': 'Always responds immediately', 'value': 5},
        {'text': 'Usually responds', 'value': 4},
        {'text': 'Sometimes responds', 'value': 3},
        {'text': 'Rarely responds', 'value': 2},
        {'text': 'Never or almost never responds', 'value': 1},
      ],
    },
    {
      'id': 2,
      'question': 'How does {childName} react when their daily routine changes?',
      'category': 'Cognitive Flexibility',
      'options': [
        {'text': 'Adapts easily to changes', 'value': 5},
        {'text': 'Needs a little time but adapts', 'value': 4},
        {'text': 'Shows some distress, eventually adapts', 'value': 3},
        {'text': 'Gets very upset, takes long to adapt', 'value': 2},
        {'text': 'Cannot adapt, extreme distress', 'value': 1},
      ],
    },
    {
      'id': 3,
      'question': 'When playing with toys, does {childName} switch between different activities or toys?',
      'category': 'Cognitive Flexibility',
      'options': [
        {'text': 'Easily switches between toys/activities', 'value': 5},
        {'text': 'Switches with gentle prompting', 'value': 4},
        {'text': 'Switches but shows reluctance', 'value': 3},
        {'text': 'Very difficult to get them to switch', 'value': 2},
        {'text': 'Refuses to switch, fixates on one toy', 'value': 1},
      ],
    },
    {
      'id': 4,
      'question': 'How often does {childName} make eye contact when you talk to them?',
      'category': 'Social Communication',
      'options': [
        {'text': 'Always makes good eye contact', 'value': 5},
        {'text': 'Usually makes eye contact', 'value': 4},
        {'text': 'Sometimes makes eye contact', 'value': 3},
        {'text': 'Rarely makes eye contact', 'value': 2},
        {'text': 'Avoids eye contact completely', 'value': 1},
      ],
    },
    {
      'id': 5,
      'question': 'Does {childName} point to objects they want or find interesting?',
      'category': 'Joint Attention',
      'options': [
        {'text': 'Frequently points and shares interest', 'value': 5},
        {'text': 'Often points to things', 'value': 4},
        {'text': 'Occasionally points', 'value': 3},
        {'text': 'Rarely points', 'value': 2},
        {'text': 'Never or almost never points', 'value': 1},
      ],
    },
    {
      'id': 6,
      'question': 'How does {childName} react to unexpected sounds or sensory experiences?',
      'category': 'Sensory Processing',
      'options': [
        {'text': 'Reacts appropriately, recovers quickly', 'value': 5},
        {'text': 'Startles but calms down soon', 'value': 4},
        {'text': 'Gets upset, needs comfort', 'value': 3},
        {'text': 'Very distressed, takes long to calm', 'value': 2},
        {'text': 'Extreme distress or complete shutdown', 'value': 1},
      ],
    },
    {
      'id': 7,
      'question': 'Does {childName} imitate your actions or words?',
      'category': 'Social Learning',
      'options': [
        {'text': 'Frequently imitates spontaneously', 'value': 5},
        {'text': 'Often imitates when prompted', 'value': 4},
        {'text': 'Imitates some simple actions', 'value': 3},
        {'text': 'Rarely imitates', 'value': 2},
        {'text': 'Never or almost never imitates', 'value': 1},
      ],
    },
    {
      'id': 8,
      'question': 'How does {childName} play with other children?',
      'category': 'Social Interaction',
      'options': [
        {'text': 'Actively engages and shares', 'value': 5},
        {'text': 'Plays near others, some interaction', 'value': 4},
        {'text': 'Parallel play, minimal interaction', 'value': 3},
        {'text': 'Prefers solitary play, avoids others', 'value': 2},
        {'text': 'No interest in other children', 'value': 1},
      ],
    },
    {
      'id': 9,
      'question': 'Does {childName} show interest when you show them something?',
      'category': 'Joint Attention',
      'options': [
        {'text': 'Always looks and shows interest', 'value': 5},
        {'text': 'Usually looks when you point', 'value': 4},
        {'text': 'Sometimes follows your gaze/point', 'value': 3},
        {'text': 'Rarely follows your attention', 'value': 2},
        {'text': 'Never follows your gaze or point', 'value': 1},
      ],
    },
    {
      'id': 10,
      'question': 'How does {childName} express their needs or wants?',
      'category': 'Communication',
      'options': [
        {'text': 'Uses words and gestures clearly', 'value': 5},
        {'text': 'Uses gestures and some words', 'value': 4},
        {'text': 'Mostly gestures, few words', 'value': 3},
        {'text': 'Pulls you to objects, little gesture', 'value': 2},
        {'text': 'Cries or tantrums, no clear communication', 'value': 1},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _createSession();
    
    _botController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _questionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _botScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _botController, curve: Curves.elasticOut),
    );
    
    _questionFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _questionController, curve: Curves.easeIn),
    );
    
    _animateQuestion();
  }

  Future<void> _createSession() async {
    try {
      // Create session via API - backend will generate UUID
      final sessionData = await StorageService.saveSession(
        childId: widget.child.id,
        sessionType: 'ai_doctor_bot',
        ageGroup: '2-3.5',
        startTime: _startTime!,
      );
      
      // Get the session ID from the response
      if (sessionData != null && sessionData['id'] != null) {
        _sessionId = sessionData['id'] as String;
        debugPrint('Session created successfully: $_sessionId');
      } else {
        throw Exception('Session creation failed: No session ID returned');
      }
    } catch (e) {
      debugPrint('Error creating session: $e');
      // Show error but don't block - will try to create session later if needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Warning: Session creation failed. Error: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      // Generate fallback ID - will try to create session when completing
      _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  void _animateQuestion() {
    _botController.reset();
    _questionController.reset();
    _botController.forward();
    _questionController.forward();
  }

  void _handleAnswer(int questionId, int value) {
    setState(() {
      _answers[questionId] = value;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      // Check if this is the last question (0-indexed, so length - 1)
      final questions = _getQuestions();
      final isLastQuestion = _currentQuestion >= questions.length - 1;
      
      if (isLastQuestion) {
        // This is the last question, complete the assessment
        _completeAssessment();
      } else {
        // Move to next question
        setState(() {
          _currentQuestion++;
        });
        _animateQuestion();
      }
    });
  }

  Future<void> _completeAssessment() async {
    if (!mounted) return;
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final questions = _getQuestions();
      final endTime = DateTime.now();
      final completionTimeSec = _startTime != null 
          ? endTime.difference(_startTime!).inSeconds 
          : 0;
      
      // Generate comprehensive ML summary using QuestionnaireSummary
      final summary = QuestionnaireSummary.fromResponses(
        responses: _answers,
        questions: questions,
        completionTimeSec: completionTimeSec,
      );
      
      // Use ML-enhanced risk level
      final riskScore = summary.riskScore;
      final riskLevel = summary.riskLevel;

      // Convert _answers Map<int, int> to Map<String, int> for JSON encoding
      final responsesMap = <String, int>{};
      _answers.forEach((key, value) {
        responsesMap[key.toString()] = value;
      });

      // Build results with ML features
      final results = {
        'id': _sessionId,
        'child_id': widget.child.id,
        'child_name': widget.child.name,
        'child_age': widget.child.age is double ? widget.child.age : (widget.child.age as num).toDouble(),
        'child_gender': widget.child.gender,
        'session_date': DateTime.now().toIso8601String(),
        'assessment_type': 'ai_bot_questionnaire',
        'responses': responsesMap,
        'total_score': summary.totalScore,
        'percentage_score': summary.percentageScore,
        'risk_score': riskScore,
        'risk_level': riskLevel,
        'category_scores': summary.categoryScores.map((k, v) => MapEntry(k, v.percentage)),
        'completion_time': DateTime.now().millisecondsSinceEpoch,
        'completion_time_sec': completionTimeSec,
        // ML Features for ASD detection
        'ml_features': summary.mlFeatures,
        // M-CHAT-R/F style critical items
        'critical_items_failed': summary.criticalItemsFailed,
        'critical_items_fail_rate': summary.criticalItemsFailRate,
        'failed_items_total': summary.failedItemsTotal,
        'failed_items_rate': summary.failedItemsRate,
        // Domain-specific scores
        'domain_scores': {
          'social_responsiveness': summary.socialResponsivenessScore,
          'cognitive_flexibility': summary.cognitiveFlexibilityScore,
          'joint_attention': summary.jointAttentionScore,
          'social_communication': summary.socialCommunicationScore,
          'sensory_processing': summary.sensoryProcessingScore,
          'communication': summary.communicationScore,
        },
        // Interpretation
        'interpretation': summary.interpretation,
        // Full summary for detailed analysis
        'summary': summary.toJson(),
      };

      // Update or create session with questionnaire results
      if (_sessionId != null && !_sessionId!.contains('fallback')) {
        try {
          await StorageService.updateSession(
            id: _sessionId!,
            endTime: DateTime.now(),
            questionnaireResults: results,
            riskScore: riskScore,
            riskLevel: riskLevel.toLowerCase(),
          );
        } catch (e) {
          debugPrint('Error updating session, creating new one: $e');
          // Session might not exist, create a new one
          final sessionData = await StorageService.saveSession(
            childId: widget.child.id,
            sessionType: 'ai_doctor_bot',
            ageGroup: '2-3.5',
            startTime: _startTime!,
            endTime: DateTime.now(),
            questionnaireResults: results,
            riskScore: riskScore,
            riskLevel: riskLevel.toLowerCase(),
          );
          
          if (sessionData != null && sessionData['id'] != null) {
            _sessionId = sessionData['id'] as String;
            debugPrint('Created new session: $_sessionId');
          } else {
            throw Exception('Failed to create session');
          }
        }
      } else {
        // Create new session if we don't have a valid one
        final sessionData = await StorageService.saveSession(
          childId: widget.child.id,
          sessionType: 'ai_doctor_bot',
          ageGroup: '2-3.5',
          startTime: _startTime!,
          endTime: DateTime.now(),
          questionnaireResults: results,
          riskScore: riskScore,
          riskLevel: riskLevel.toLowerCase(),
        );
        
        if (sessionData != null && sessionData['id'] != null) {
          _sessionId = sessionData['id'] as String;
          debugPrint('Created session: $_sessionId');
        } else {
          throw Exception('Failed to create session');
        }
      }

      // Log to console
      LoggerService.logSession({
        'event': 'AI_BOT_QUESTIONNAIRE_COMPLETED',
        'child_id': widget.child.id,
        'session_id': _sessionId,
        'questionnaire_results': results,
      });

      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();
        
        // Navigate to Clinical Reflection for 2-3.5 age group
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ClinicianReflectionScreen2_3(
              child: widget.child,
              sessionId: _sessionId!,
              questionnaireResults: results,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog if still open
        Navigator.of(context).pop();
        
        // Show error and allow retry
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing assessment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _goBack() {
    if (_currentQuestion > 0) {
      setState(() {
        _currentQuestion--;
      });
      _animateQuestion();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _botController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questions = _getQuestions();
    final progress = ((_currentQuestion + 1) / questions.length) * 100;
    final question = questions[_currentQuestion];
    final questionText = (question['question'] as String).replaceAll(
      '{childName}',
      widget.child.name,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF667eea),
              const Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(progress),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Bot Avatar
                      _buildBotAvatar(),
                      const SizedBox(height: 30),
                      // Question Card
                      _buildQuestionCard(question, questionText),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _goBack,
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        final questions = _getQuestions();
                        return Text(
                          '${l10n.question} ${_currentQuestion + 1} ${l10n.ofText} ${questions.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  tooltip: 'Settings',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const LanguageSelector(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBotAvatar() {
    return AnimatedBuilder(
      animation: _botScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _botScale.value,
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '🤖',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'AI Doctor Bot',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667eea),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, String questionText) {
    final options = question['options'] as List<Map<String, dynamic>>;
    final selectedValue = _answers[question['id']];

    return AnimatedBuilder(
      animation: _questionFade,
      builder: (context, child) {
        return Opacity(
          opacity: _questionFade.value,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category
                Text(
                  question['category'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF667eea),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 15),
                // Question
                Text(
                  questionText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 25),
                // Options
                ...options.map((option) => _buildOptionButton(
                      question['id'] as int,
                      option,
                      selectedValue == option['value'],
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(int questionId, Map<String, dynamic> option, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleAnswer(questionId, option['value'] as int),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFe8eaf6) : const Color(0xFFf8f9fa),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? const Color(0xFF667eea) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFF667eea) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF667eea) : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    option['text'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? const Color(0xFF333333) : const Color(0xFF555555),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

