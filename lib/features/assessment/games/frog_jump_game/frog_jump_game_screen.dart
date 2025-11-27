import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/child.dart';
import '../../../../data/models/game_results.dart' show GameResults, TrialData;
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/age_calculator.dart';
import 'package:senseai/l10n/app_localizations.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../cognitive/reflection_screen.dart';
import 'models/game_trial.dart';
import 'models/frog_jump_summary.dart';
import 'models/stimulus.dart';
import 'widgets/game_character_widget.dart';
import 'widgets/game_feedback_widget.dart';
import 'services/game_audio_service.dart';
import 'services/game_speech_service.dart';
import '../color_shape_game/widgets/game_language_selector.dart';

class FrogJumpGameScreen extends StatefulWidget {
  final Child child;

  const FrogJumpGameScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<FrogJumpGameScreen> createState() => _FrogJumpGameScreenState();
}

class _FrogJumpGameScreenState extends State<FrogJumpGameScreen>
    with TickerProviderStateMixin {
  // Game state - Simplified for age 3.5-5.5
  int _currentTrial = 1;
  final int _maxTrials = 20;
  final int _practiceTrials = 4;
  int _score = 0;
  List<GameTrial> _trials = [];
  Stimulus? _currentStimulus;
  String _gamePhase = 'language_select'; // 'language_select', 'instructions', 'practice', 'main', 'complete'
  String _selectedLanguage = 'en';
  DateTime? _startTime;
  DateTime? _sessionStartTime;
  bool _isProcessing = false;
  bool _showFeedback = false;
  bool _feedbackIsCorrect = false;
  Timer? _responseTimeout;
  Timer? _feedbackTimer;

  // Session
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _createSession();
    
    // Set initial language from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      setState(() {
        _selectedLanguage = languageProvider.locale.languageCode;
      });
    });
  }

  Future<void> _initializeServices() async {
    await GameSpeechService.initialize();
    await GameAudioService.initialize();
    await GameAudioService.startBackgroundMusic();
  }

  Future<void> _createSession() async {
    try {
      final ageGroup = AgeCalculator.getAgeGroup(widget.child.age);
      final sessionData = await StorageService.saveSession(
        childId: widget.child.id,
        sessionType: 'frog-jump',
        ageGroup: ageGroup,
        startTime: DateTime.now(),
      );

      if (sessionData != null && sessionData['id'] != null) {
        _sessionId = sessionData['id'] as String;
      } else {
        _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      }
    } catch (e) {
      debugPrint('Error creating session: $e');
      _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  void _startGame() {
    setState(() {
      _gamePhase = 'practice';
      _currentTrial = 1;
      _score = 0;
      _trials = [];
      _currentStimulus = null;
      _isProcessing = false;
      _showFeedback = false;
      _sessionStartTime = DateTime.now();
    });

    final localizations = AppLocalizations.of(context)!;
    _showNotification(localizations.greatJob, true);
    GameSpeechService.speakInstructions(_selectedLanguage);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextTrial();
      }
    });
  }

  void _nextTrial() {
    if (_currentTrial > _maxTrials) {
      _endGame();
      return;
    }

    // Handle phase transition
    if (_currentTrial == _practiceTrials + 1) {
      setState(() {
        _gamePhase = 'main';
      });
      final localizations = AppLocalizations.of(context)!;
      _showNotification(localizations.greatJob, true);
    }

    // Cancel any existing timeout
    _responseTimeout?.cancel();
    _responseTimeout = null;

    // Reset processing state
    setState(() {
      _isProcessing = false;
      _showFeedback = false;
    });

    // Generate stimulus: 70% happy (Go), 30% sleepy (No-Go)
    final random = math.Random();
    final isHappy = random.nextDouble() < 0.7;
    
    // Update stimulus
    _currentStimulus = isHappy ? Stimulus.happyFrog : Stimulus.sleepyTurtle;
    _startTime = DateTime.now();
    
    // Trigger rebuild
    if (mounted) {
      setState(() {});
    }

    // Set timeout for response
    final timeoutDuration = isHappy ? 3000 : 2500; // Happy: 3s, Sleepy: 2.5s
    _responseTimeout = Timer(Duration(milliseconds: timeoutDuration), () {
      if (mounted && !_isProcessing && _currentStimulus != null) {
        _handleResponse('miss');
      }
    });

    // Speak stimulus instruction with delay to ensure widget is built
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _currentStimulus != null) {
        GameSpeechService.speakStimulus(_currentStimulus!.type, _selectedLanguage);
      }
    });
  }

  void _handleResponse(String response) {
    if (!mounted || _isProcessing || _currentStimulus == null || _startTime == null) {
      return;
    }

    _responseTimeout?.cancel();
    _responseTimeout = null;

    if (!mounted) return;
    
    setState(() {
      _isProcessing = true;
    });

    final reactionTime = DateTime.now().difference(_startTime!).inMilliseconds;
    final isCorrect = (_currentStimulus!.type == 'happy' && response == 'tap') ||
        (_currentStimulus!.type == 'sleepy' && (response == 'no_tap' || response == 'miss'));

    final trial = GameTrial(
      trialNumber: _currentTrial,
      phase: _gamePhase,
      stimulus: _currentStimulus!.type,
      response: response,
      reactionTime: reactionTime,
      correct: isCorrect,
      timestamp: DateTime.now(),
    );

    setState(() {
      _trials.add(trial);
      if (isCorrect) {
        _score++;
      }
    });

    // Show feedback
    setState(() {
      _showFeedback = true;
      _feedbackIsCorrect = isCorrect;
    });

    if (isCorrect) {
      GameAudioService.playCorrectSound();
      GameSpeechService.speakFeedback(true, _selectedLanguage);
    } else {
      GameAudioService.playWrongSound();
      GameSpeechService.speakFeedback(false, _selectedLanguage);
    }

    // Move to next trial after feedback
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && _gamePhase != 'complete') {
        setState(() {
          _currentTrial++;
          _showFeedback = false;
          _isProcessing = false;
        });
        _nextTrial();
      }
    });
  }

  void _showNotification(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  void _endGame() {
    _responseTimeout?.cancel();
    _feedbackTimer?.cancel();
    setState(() {
      _gamePhase = 'complete';
      _isProcessing = false;
      _showFeedback = false;
    });

    _saveResults();
  }

  Future<void> _saveResults() async {
    try {
      final results = _calculateResults();
      final endTime = DateTime.now();

      if (_sessionId != null) {
        await StorageService.updateSession(
          id: _sessionId!,
          endTime: endTime,
          gameResults: results.toJson(),
        );

        for (final trial in _trials) {
          try {
            await StorageService.saveTrial(
              id: '${_sessionId}_trial_${trial.trialNumber}',
              sessionId: _sessionId!,
              trialNumber: trial.trialNumber,
              stimulus: trial.stimulus,
              response: trial.response,
              reactionTime: trial.reactionTime,
              correct: trial.correct,
              timestamp: trial.timestamp,
            );
          } catch (e) {
            debugPrint('Error saving trial ${trial.trialNumber}: $e');
          }
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ClinicianReflectionScreen(
              child: widget.child,
              sessionId: _sessionId!,
              gameResults: results,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving results: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ClinicianReflectionScreen(
              child: widget.child,
              sessionId: _sessionId ?? '',
              gameResults: _calculateResults(),
            ),
          ),
        );
      }
    }
  }

  GameResults _calculateResults() {
    // Convert to FrogJumpTrial for enhanced analysis
    final frogJumpTrials = _trials.map((t) => FrogJumpTrial.fromGameTrial(t)).toList();
    
    // Calculate completion time
    final completionTimeSec = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!).inSeconds
        : 0;
    
    // Generate comprehensive ML summary
    final summary = FrogJumpSummary.fromTrials(
      trials: frogJumpTrials,
      completionTimeSec: completionTimeSec,
    );
    
    // Basic metrics for backward compatibility
    final correctTrials = _trials.where((t) => t.correct).toList();
    final totalTrials = _trials.length;
    final accuracy = totalTrials > 0 ? (correctTrials.length / totalTrials) * 100 : 0.0;

    final totalReactionTime =
        correctTrials.map((t) => t.reactionTime).fold(0, (sum, rt) => sum + rt);
    final avgReactionTime =
        correctTrials.isNotEmpty ? totalReactionTime ~/ correctTrials.length : 0;

    final completionTimeMs = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!).inMilliseconds
        : 0;

    return GameResults(
      gameType: 'frog-jump',
      totalTrials: totalTrials,
      correctTrials: correctTrials.length,
      accuracy: accuracy,
      averageReactionTime: avgReactionTime,
      completionTime: completionTimeMs,
      switchCost: null,
      // Store commission errors in perseverativeErrors field for compatibility
      perseverativeErrors: summary.commissionErrors,
      trials: _trials
          .map((t) => TrialData(
                trialNumber: t.trialNumber,
                stimulus: t.stimulus,
                rule: t.phase,
                response: t.response,
                reactionTime: t.reactionTime,
                correct: t.correct,
                timestamp: t.timestamp,
                isPostSwitch: null,
                isPerseverativeError: t.stimulus == 'sleepy' && 
                    (t.response == 'tap' || t.response == 'wrong_tap'),
              ))
          .toList(),
      // Include full ML features
      mlFeatures: summary.mlFeatures,
      // Include additional metrics
      additionalMetrics: {
        'summary': summary.toJson(),
        'risk_level': summary.riskLevel,
        'interpretation': summary.interpretation,
      },
    );
  }

  @override
  void dispose() {
    _responseTimeout?.cancel();
    _feedbackTimer?.cancel();
    GameSpeechService.stop();
    GameAudioService.stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gamePhase == 'language_select') {
      return _buildLanguageSelectionScreen();
    } else if (_gamePhase == 'instructions') {
      return _buildInstructionsScreen();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFE5EC), Color(0xFFFFC2D4), Color(0xFFFFB5C5)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildProgressBar(),
                          const SizedBox(height: 20),
                          _buildInstructionBox(),
                          const SizedBox(height: 30),
                          _buildCharacterArea(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_showFeedback)
                Center(
                  child: GameFeedbackWidget(
                    isCorrect: _feedbackIsCorrect,
                    onComplete: () {
                      setState(() {
                        _showFeedback = false;
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelectionScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFE5EC), Color(0xFFFFC2D4), Color(0xFFFFB5C5)],
          ),
        ),
        child: Center(
          child: GameLanguageSelector(
            onLanguageSelected: (languageCode) {
              setState(() {
                _selectedLanguage = languageCode;
                _gamePhase = 'instructions';
              });
              Provider.of<LanguageProvider>(context, listen: false)
                  .setLocale(Locale(languageCode));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsScreen() {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFE5EC), Color(0xFFFFC2D4), Color(0xFFFFB5C5)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🐸', style: TextStyle(fontSize: 120)),
                  const SizedBox(height: 20),
                  Text(
                    localizations.frogJumpGameTitle,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    localizations.frogJumpGameInstructions,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildExample(Stimulus.happyFrog, localizations.tapMe),
                      _buildExample(Stimulus.sleepyTurtle, localizations.dontTap),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      GameSpeechService.speakInstructions(_selectedLanguage);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔊', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Text(
                          'Hear Instructions',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B9D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Start Game',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('✨', style: TextStyle(fontSize: 24)),
                      ],
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

  Widget _buildExample(Stimulus stimulus, String label) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: stimulus.gradient,
            shape: BoxShape.circle,
            border: Border.all(color: stimulus.borderColor, width: 5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              stimulus.emoji,
              style: const TextStyle(fontSize: 70),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: stimulus.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 8),
                Text(
                  '$_score',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentTrial / _maxTrials) * 100;
    return Column(
      children: [
        Container(
          height: 25,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: MediaQuery.of(context).size.width * (progress / 100),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Round $_currentTrial of $_maxTrials',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionBox() {
    final localizations = AppLocalizations.of(context)!;
    String instruction;
    if (_currentStimulus == null) {
      instruction = localizations.getReady;
    } else if (_currentStimulus!.type == 'happy') {
      instruction = localizations.tapHappyFrog;
    } else {
      instruction = localizations.dontTapSleepyTurtle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: const Color(0xFFFF6B9D), width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        instruction,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF6B9D),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCharacterArea() {
    if (_currentStimulus == null) {
      return const SizedBox(height: 400);
    }

    // Use key to force widget recreation when stimulus changes
    return SizedBox(
      height: 400,
      child: Center(
        child: GameCharacterWidget(
          key: ValueKey('${_currentStimulus!.type}_$_currentTrial'),
          stimulus: _currentStimulus!,
          onTap: () {
            if (!_isProcessing && !_showFeedback && _currentStimulus != null) {
              if (_currentStimulus!.type == 'happy') {
                _handleResponse('tap');
              } else {
                _handleResponse('wrong_tap');
              }
            }
          },
          isActive: !_isProcessing && !_showFeedback,
        ),
      ),
    );
  }
}

