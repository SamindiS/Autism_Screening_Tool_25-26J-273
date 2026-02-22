import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/child.dart';
import '../../../../data/models/game_results.dart' show GameResults, TrialData;
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/age_calculator.dart';
import '../../../../core/services/ml_service.dart';
// App localizations not used in clinical DCCS game - uses hardcoded English
import 'package:senseai/core/providers/language_provider.dart';
import '../../../cognitive/reflection_screen.dart';
import 'models/game_trial.dart';
import 'models/shape_stimulus.dart';
import 'widgets/game_language_selector.dart';
import 'services/game_audio_service.dart';
import 'services/game_speech_service.dart';
import 'utils/dccs_translations.dart';

/// Clinical DCCS (Dimensional Change Card Sort) Game
/// Measures cognitive flexibility and rule-switching for ASD screening
class ColorShapeGameScreen extends StatefulWidget {
  final Child child;

  const ColorShapeGameScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ColorShapeGameScreen> createState() => _ColorShapeGameScreenState();
}

class _ColorShapeGameScreenState extends State<ColorShapeGameScreen>
    with TickerProviderStateMixin {
  
  // DCCS Configuration
  static const int _practiceTrials = 4;
  static const int _preSwitchTrials = 8;
  static const int _postSwitchTrials = 12;
  static const int _mixedTrials = 8;
  
  // Game state
  int _currentTrial = 0;
  int _totalTrials = 0;
  List<DccsTrial> _trials = [];
  ShapeStimulus? _currentStimulus;
  String _currentRule = 'color';
  String _previousRule = 'color';
  String _gamePhase = 'language';
  String _selectedLanguage = 'en';
  int _streak = 0;
  int _maxStreak = 0;
  DateTime? _trialStartTime;
  DateTime? _sessionStartTime;
  int _timeRemaining = 300;
  bool _isProcessing = false;
  bool _showFeedback = false;
  bool _lastCorrect = false;

  // Session
  String? _sessionId;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _totalTrials = _practiceTrials + _preSwitchTrials + _postSwitchTrials + _mixedTrials;
    _createSession();
  }

  Future<void> _initializeWithLanguage(String language) async {
    _selectedLanguage = language;
    await GameSpeechService.initialize(language: language);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final locale = Locale(language);
    if (languageProvider.locale != locale) {
      await languageProvider.setLocale(locale);
    }
  }

  Future<void> _createSession() async {
    try {
      final ageGroup = AgeCalculator.getAgeGroup(widget.child.age);
      final sessionData = await StorageService.saveSession(
        childId: widget.child.id,
        sessionType: 'color_shape',  // Use backend-expected format
        ageGroup: ageGroup,
        startTime: DateTime.now(),
      );
      _sessionId = sessionData?['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString();
    } catch (e) {
      debugPrint('Error creating session: $e');
      _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  void _startGame() {
    GameAudioService.startBackgroundMusic();
    setState(() {
      _gamePhase = 'practice';
      _currentTrial = 0;
      _trials = [];
      _currentRule = 'color';
      _previousRule = 'color';
      _streak = 0;
      _maxStreak = 0;
      _timeRemaining = 300;
      _sessionStartTime = DateTime.now();
    });
    _startTimer();
    // Announce practice phase
    GameSpeechService.speakPhaseStart('practice', _selectedLanguage);
    _nextTrial();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _timeRemaining--;
        if (_timeRemaining <= 0) {
          timer.cancel();
          _endGame();
        }
      });
    });
  }

  void _nextTrial() {
    _currentTrial++;
    
    if (_currentTrial > _totalTrials) {
      _endGame();
      return;
    }

    // Determine phase and rule
    _previousRule = _currentRule;
    final previousPhase = _gamePhase;
    
    if (_currentTrial <= _practiceTrials) {
      _gamePhase = 'practice';
      _currentRule = 'color';
    } else if (_currentTrial <= _practiceTrials + _preSwitchTrials) {
      _gamePhase = 'pre_switch';
      _currentRule = 'color';
    } else if (_currentTrial <= _practiceTrials + _preSwitchTrials + _postSwitchTrials) {
      _gamePhase = 'post_switch';
      _currentRule = 'shape';
    } else {
      _gamePhase = 'mixed';
      // Random rule in mixed phase
      _currentRule = math.Random().nextBool() ? 'color' : 'shape';
    }

    // Announce phase transition
    if (_gamePhase != previousPhase) {
      GameSpeechService.speakPhaseStart(_gamePhase, _selectedLanguage);
      GameAudioService.playRuleChangeSound();
    }
    // Also announce rule changes within mixed phase
    else if (_gamePhase == 'mixed' && _currentRule != _previousRule) {
      GameAudioService.playRuleChangeSound();
      GameSpeechService.speakRuleChange(_currentRule, _selectedLanguage);
    }

    // Generate random conflict stimulus
    final stimuli = ShapeStimulus.conflictStimuli;
    _currentStimulus = stimuli[math.Random().nextInt(stimuli.length)];
    _trialStartTime = DateTime.now();
    _isProcessing = false;
    _showFeedback = false;
    
    setState(() {});
  }

  void _handleChoice(String side) {
    if (_isProcessing || _currentStimulus == null || _trialStartTime == null) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final reactionTime = DateTime.now().difference(_trialStartTime!).inMilliseconds;
    final correctSide = _currentStimulus!.getCorrectSide(_currentRule);
    final isCorrect = side == correctSide;

    // Determine if switch trial (in mixed phase)
    bool isSwitchTrial = false;
    if (_gamePhase == 'mixed' && _trials.isNotEmpty) {
      final lastTrial = _trials.last;
      if (lastTrial.phase == 'mixed' && lastTrial.rule != _currentRule) {
        isSwitchTrial = true;
      }
    }

    // Detect perseverative error
    bool isPerseverativeError = false;
    if (!isCorrect) {
      // In post-switch phase or switch trial in mixed
      if (_gamePhase == 'post_switch' || isSwitchTrial) {
        // Check if child used the old rule
        final oldRule = _currentRule == 'color' ? 'shape' : 'color';
        final oldRuleCorrectSide = _currentStimulus!.getCorrectSide(oldRule);
        if (side == oldRuleCorrectSide) {
          isPerseverativeError = true;
        }
      }
    }

    // Record trial
    final trial = DccsTrial(
      trialNumber: _currentTrial,
      phase: _gamePhase,
      rule: _currentRule,
      stimulusColor: _currentStimulus!.color,
      stimulusShape: _currentStimulus!.shape,
      correctChoice: correctSide,
      childChoice: side,
      reactionTimeMs: reactionTime,
      correct: isCorrect,
      isSwitchTrial: isSwitchTrial,
      isPerseverativeError: isPerseverativeError,
      isPostSwitch: _gamePhase == 'post_switch',
      timestamp: DateTime.now(),
    );

    _trials.add(trial);

    // Update streak and provide feedback
    if (isCorrect) {
      _streak++;
      if (_streak > _maxStreak) _maxStreak = _streak;
      GameAudioService.playCorrectSound();
      GameSpeechService.speakFeedback(true, _selectedLanguage);
    } else {
      _streak = 0;
      GameAudioService.playWrongSound();
      GameSpeechService.speakFeedback(false, _selectedLanguage);
    }

    // Show feedback
    setState(() {
      _showFeedback = true;
      _lastCorrect = isCorrect;
    });

    // Move to next trial after delay
    Future.delayed(Duration(milliseconds: isCorrect ? 800 : 1200), () {
      if (!mounted) return;
      _nextTrial();
    });
  }

  void _endGame() {
    _timer?.cancel();
    GameAudioService.stopBackgroundMusic();
    GameSpeechService.speakGameComplete(_selectedLanguage);
    setState(() {
      _gamePhase = 'complete';
    });
    _saveResults();
  }

  DccsSummary _calculateSummary() {
    if (_trials.isEmpty) {
      return DccsSummary(
        totalTrials: 0,
        completionTimeSec: 0,
        accuracyPreColor: 0,
        accuracyPostShape: 0,
        accuracyMixed: 0,
        accuracyOverall: 0,
        avgReactionTimeMs: 0,
        avgRtPreSwitchMs: 0,
        avgRtPostSwitchMs: 0,
        avgRtPostCorrectMs: 0,
        switchCostMs: 0,
        perseverativeErrors: 0,
        perseverativeRatePost: 0,
        maxConsecutivePerseverations: 0,
        totalRuleSwitchErrors: 0,
        longestStreak: 0,
      );
    }

    // Filter trials by phase
    final preTrials = _trials.where((t) => t.phase == 'pre_switch').toList();
    final postTrials = _trials.where((t) => t.phase == 'post_switch').toList();
    final mixedTrials = _trials.where((t) => t.phase == 'mixed').toList();

    // Calculate accuracies
    double accuracy(List<DccsTrial> trials) {
      if (trials.isEmpty) return 0;
      return (trials.where((t) => t.correct).length / trials.length) * 100;
    }

    double meanRt(List<DccsTrial> trials) {
      if (trials.isEmpty) return 0;
      return trials.map((t) => t.reactionTimeMs).reduce((a, b) => a + b) / trials.length;
    }

    // Calculate switch cost
    final preRt = meanRt(preTrials);
    final postCorrect = postTrials.where((t) => t.correct).toList();
    final postRtCorrect = meanRt(postCorrect);
    final switchCost = postRtCorrect - preRt;

    // Count perseverative errors
    final perseverativeErrors = _trials.where((t) => t.isPerseverativeError).length;
    // postErrors variable reserved for future use
    final perseverativeRate = postTrials.isEmpty ? 0.0 :
        (perseverativeErrors / postTrials.length) * 100;

    // Count consecutive perseverations
    int maxConsec = 0;
    int currentConsec = 0;
    for (final trial in _trials) {
      if (trial.isPerseverativeError) {
        currentConsec++;
        if (currentConsec > maxConsec) maxConsec = currentConsec;
      } else {
        currentConsec = 0;
      }
    }

    // Total rule switch errors
    final ruleSwitchErrors = _trials.where((t) => !t.correct && (t.isPostSwitch || t.isSwitchTrial)).length;

    final completionTime = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!).inSeconds
        : 0;

    return DccsSummary(
      totalTrials: _trials.length,
      completionTimeSec: completionTime,
      accuracyPreColor: accuracy(preTrials),
      accuracyPostShape: accuracy(postTrials),
      accuracyMixed: accuracy(mixedTrials),
      accuracyOverall: accuracy(_trials),
      avgReactionTimeMs: meanRt(_trials),
      avgRtPreSwitchMs: preRt,
      avgRtPostSwitchMs: meanRt(postTrials),
      avgRtPostCorrectMs: postRtCorrect,
      switchCostMs: switchCost.isNaN ? 0 : switchCost,
      perseverativeErrors: perseverativeErrors,
      perseverativeRatePost: perseverativeRate.isNaN ? 0 : perseverativeRate,
      maxConsecutivePerseverations: maxConsec,
      totalRuleSwitchErrors: ruleSwitchErrors,
      longestStreak: _maxStreak,
    );
  }

  Future<void> _saveResults() async {
    try {
      final summary = _calculateSummary();
      final endTime = DateTime.now();

      // ✅ Get ML prediction from trained model
      MLPredictionResult? mlResult;
      try {
        if (summary.mlFeatures.isNotEmpty) {
          mlResult = await MLService.predict(
            mlFeatures: summary.mlFeatures,
            ageGroup: AgeCalculator.getAgeGroup(widget.child.age),
            sessionType: 'color_shape',
          );
          
          if (mlResult != null && mlResult.method == 'ml') {
            debugPrint('✅ ML Prediction: ${mlResult.riskLevel} (${mlResult.riskScore.toStringAsFixed(1)}%)');
          } else {
            debugPrint('⚠️  ML prediction unavailable, using rule-based');
          }
        } else {
          debugPrint('⚠️  No ML features available for prediction');
        }
      } catch (e) {
        debugPrint('⚠️  ML prediction error: $e - using rule-based');
        // Continue with rule-based (graceful fallback)
      }

      // Convert to GameResults for compatibility (use ML result if available)
      final gameResults = GameResults(
        gameType: 'dccs-color-shape',
        totalTrials: summary.totalTrials,
        correctTrials: _trials.where((t) => t.correct).length,
        accuracy: summary.accuracyOverall,
        averageReactionTime: summary.avgReactionTimeMs.round(),
        completionTime: summary.completionTimeSec,
        switchCost: summary.switchCostMs.round(),
        perseverativeErrors: summary.perseverativeErrors,
        trials: _trials.map((t) => TrialData(
          trialNumber: t.trialNumber,
          stimulus: '${t.stimulusColor} ${t.stimulusShape}',
          rule: t.rule,
          response: t.childChoice,
          correct: t.correct,
          reactionTime: t.reactionTimeMs,
          timestamp: t.timestamp,
          isPostSwitch: t.isPostSwitch,
          isPerseverativeError: t.isPerseverativeError,
        )).toList(),
        mlFeatures: summary.mlFeatures,
        // ✅ Add ML prediction data
        riskScore: mlResult?.riskScore,
        riskLevel: mlResult?.riskLevel,
        mlPrediction: mlResult != null ? {
          'isASD': mlResult.isASD,
          'asdProbability': mlResult.asdProbability,
          'controlProbability': mlResult.controlProbability,
          'confidence': mlResult.confidence,
          'riskLevel': mlResult.riskLevel,
          'riskScore': mlResult.riskScore,
          'method': mlResult.method,
        } : null,
      );

      if (_sessionId != null) {
        await StorageService.updateSession(
          id: _sessionId!,
          endTime: endTime,
          gameResults: gameResults.toJson(),
        );

        for (final trial in _trials) {
          await StorageService.saveTrial(
            id: '${_sessionId}_trial_${trial.trialNumber}',
            sessionId: _sessionId!,
            trialNumber: trial.trialNumber,
            stimulus: '${trial.stimulusColor} ${trial.stimulusShape}',
            response: trial.childChoice,
            reactionTime: trial.reactionTimeMs,
            correct: trial.correct,
            timestamp: trial.timestamp,
          );
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ClinicianReflectionScreen(
              child: widget.child,
              sessionId: _sessionId!,
              gameResults: gameResults,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving results: $e');
      if (mounted) {
        final summary = _calculateSummary();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ClinicianReflectionScreen(
              child: widget.child,
              sessionId: _sessionId ?? '',
              gameResults: GameResults(
                gameType: 'dccs-color-shape',
                totalTrials: summary.totalTrials,
                correctTrials: _trials.where((t) => t.correct).length,
                accuracy: summary.accuracyOverall,
                averageReactionTime: summary.avgReactionTimeMs.round(),
                completionTime: summary.completionTimeSec,
                switchCost: summary.switchCostMs.round(),
                perseverativeErrors: summary.perseverativeErrors,
                trials: [],
              ),
            ),
          ),
        );
      }
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}:${secs.toString().padLeft(2, '0')}';
  }

  /// Get translated text
  String _t(String key) => DccsTranslations.get(key, _selectedLanguage);

  @override
  void dispose() {
    _timer?.cancel();
    GameSpeechService.stop();
    GameAudioService.stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gamePhase == 'language') {
      return GameLanguageSelector(
        gameType: 'color-shape',
        onLanguageSelected: (language) async {
          await _initializeWithLanguage(language);
          setState(() {
            _gamePhase = 'instructions';
          });
        },
      );
    }

    if (_gamePhase == 'instructions') {
      return _buildInstructionsScreen();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE3F2FD), // Light blue clinical background
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Column(
                  children: [
                    _buildProgressBar(),
                    const SizedBox(height: 12),
                    _buildRuleBanner(),
                    const SizedBox(height: 16),
                    _buildTargetBoxes(),
                    const SizedBox(height: 24),
                    _buildStimulusCard(),
                    const SizedBox(height: 16),
                    if (_showFeedback) _buildFeedback(),
                    const Spacer(),
                    _buildPhaseIndicator(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE3F2FD),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // DCCS icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _t('game_title'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF90CAF9), width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _t('color_rule_instruction'),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _t('shape_rule_instruction'),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF1E88E5),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTargetPreview(Colors.red, true, _t('left')),
                            const SizedBox(width: 40),
                            _buildTargetPreview(Colors.blue, false, _t('right')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        GameSpeechService.speakInstructions(_selectedLanguage);
                      },
                      icon: const Icon(Icons.volume_up, size: 28),
                      label: Text(_t('listen')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA726),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF43A047),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(_t('start_game')),
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

  Widget _buildTargetPreview(Color color, bool isCircle, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(isCircle ? 25 : 8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            _t('dccs_game'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, size: 18, color: Color(0xFF1565C0)),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_timeRemaining),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
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
    final progress = _currentTrial / _totalTrials;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_t('trial_of')} $_currentTrial ${_t('of')} $_totalTrials',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _currentRule == 'color' ? Colors.red : Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleBanner() {
    final isColorRule = _currentRule == 'color';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isColorRule ? const Color(0xFFFFEBEE) : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isColorRule ? Colors.red : Colors.blue,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isColorRule ? Icons.palette : Icons.category,
            color: isColorRule ? Colors.red : Colors.blue,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            isColorRule ? _t('color_game') : _t('shape_game'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isColorRule ? Colors.red : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetBoxes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _handleChoice('left'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _t('left'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(35),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _t('red_circle'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => _handleChoice('right'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _t('right'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _t('blue_square'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStimulusCard() {
    if (_currentStimulus == null) {
      return const SizedBox(height: 120);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[300]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _t('tap_matching_box'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black45,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _currentStimulus!.colorValue,
              borderRadius: BorderRadius.circular(_currentStimulus!.borderRadius),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            DccsTranslations.getStimulusDescription(
              _currentStimulus!.color,
              _currentStimulus!.shape,
              _selectedLanguage,
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        color: _lastCorrect ? const Color(0xFF43A047) : const Color(0xFFE53935),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        _lastCorrect ? _t('correct') : _t('try_next'),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPhaseIndicator() {
    String phaseText;
    Color phaseColor;
    
    switch (_gamePhase) {
      case 'practice':
        phaseText = _t('practice_round');
        phaseColor = Colors.orange;
        break;
      case 'pre_switch':
        phaseText = _t('color_game_phase');
        phaseColor = Colors.red;
        break;
      case 'post_switch':
        phaseText = _t('shape_game_phase');
        phaseColor = Colors.blue;
        break;
      case 'mixed':
        phaseText = _t('mixed_phase');
        phaseColor = Colors.purple;
        break;
      default:
        phaseText = '';
        phaseColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: phaseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: phaseColor, width: 1),
      ),
      child: Text(
        phaseText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: phaseColor,
        ),
      ),
    );
  }
}
