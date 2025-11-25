import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/child.dart';
import '../../../../data/models/game_results.dart' show GameResults, TrialData;
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/age_calculator.dart';
import 'package:senseai/l10n/app_localizations.dart';
import 'package:senseai/core/providers/language_provider.dart';
import '../../../cognitive/reflection_screen.dart';
import 'models/game_trial.dart';
import 'models/flower_stimulus.dart';
import 'widgets/game_flower_widget.dart';
import 'widgets/game_wand_button.dart';
import 'widgets/game_rule_display.dart';
import 'widgets/game_language_selector.dart';
import 'services/game_audio_service.dart';
import 'services/game_speech_service.dart';

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
  // Game state - Very simplified for young autistic children
  int _currentTrial = 1;
  final int _maxTrials = 12; // Much simpler - only 12 trials
  final int _practiceTrials = 3; // Only 3 practice trials
  final List<int> _switchPoints = [5, 9]; // Only 2 rule switches
  int _score = 0;
  List<GameTrial> _trials = [];
  List<FlowerStimulus> _currentFlowers = [];
  String _currentRule = 'color';
  String _gamePhase =
      'language'; // 'language', 'instructions', 'practice', 'main', 'complete'
  String _selectedLanguage = 'en';
  int _streak = 0;
  int _maxStreak = 0;
  DateTime? _startTime;
  DateTime? _sessionStartTime;
  int _timeRemaining = 300; // 5 minutes
  bool _isProcessing = false;
  bool _isSwitching = false;

  // Session
  String? _sessionId;

  // UI state
  Timer? _timer;

  // Animations
  late AnimationController _notificationController;

  @override
  void initState() {
    super.initState();
    GameAudioService.startBackgroundMusic();
    // Reset all game state to ensure fresh start
    _currentTrial = 1;
    _score = 0;
    _trials = [];
    _currentFlowers = [];
    _currentRule = 'color';
    _gamePhase = 'language';
    _selectedLanguage = 'en';
    _streak = 0;
    _maxStreak = 0;
    _startTime = null;
    _sessionStartTime = null;
    _timeRemaining = 300;
    _isProcessing = false;
    _isSwitching = false;
    _sessionId = null;
    _timer?.cancel();
    _timer = null;

    _initializeServices();
    _createSession();
    _notificationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  Future<void> _initializeServices() async {
    // Will initialize with selected language after language selection
  }

  Future<void> _initializeWithLanguage(String language) async {
    _selectedLanguage = language;
    await GameSpeechService.initialize(language: language);
    // Update app language if needed
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
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
        sessionType: 'color-shape',
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
    debugPrint('🎮 Starting game...');
    setState(() {
      _gamePhase = 'practice';
      _currentTrial = 1;
      _score = 0;
      _trials = [];
      _currentRule = 'color';
      _streak = 0;
      _maxStreak = 0;
      _timeRemaining = 300;
      _isProcessing = false;
      _isSwitching = false;
      _sessionStartTime = DateTime.now();
      _startTime = null;
      _currentFlowers = [];
    });

    _startTimer();
    final localizations = AppLocalizations.of(context)!;
    _showNotification("${localizations.greatJob} 🌷", 'encouragement');
    // Speak instructions with a small delay for better UX
    Future.delayed(const Duration(milliseconds: 500), () {
      GameSpeechService.speakInstructions(_selectedLanguage);
    });
    _nextTrial();
    debugPrint('🎮 Game started, trial: $_currentTrial, phase: $_gamePhase');
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
    debugPrint(
        '🔄 Next trial: $_currentTrial/$_maxTrials, phase: $_gamePhase, isProcessing: $_isProcessing');

    if (_currentTrial > _maxTrials) {
      debugPrint('✅ Game complete! Ending game...');
      _endGame();
      return;
    }

    // Ensure we're not processing when starting a new trial
    if (_isProcessing) {
      debugPrint('⚠️ Warning: Still processing, but continuing anyway');
      setState(() {
        _isProcessing = false;
      });
    }

    // Handle phase transition
    if (_currentTrial == _practiceTrials + 1) {
      setState(() {
        _gamePhase = 'main';
      });
      _showNotification(
          "Great job! Now the real magic begins! ✨", 'encouragement');
    }

    // Handle rule switches
    if (_switchPoints.contains(_currentTrial)) {
      setState(() {
        _currentRule = _currentRule == 'color' ? 'shape' : 'color';
        _isSwitching = true;
      });
      GameAudioService.playRuleChangeSound();
      GameSpeechService.speakRuleChange(_currentRule, _selectedLanguage);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _isSwitching = false;
          });
        }
      });
    }

    // Generate flowers
    _currentFlowers = _generateFlowers();
    _startTime = DateTime.now();
    _isProcessing = false;
    debugPrint(
        '✅ Trial $_currentTrial ready: ${_currentFlowers.length} flowers, rule: $_currentRule');
  }

  List<FlowerStimulus> _generateFlowers() {
    final flowers = FlowerStimulus.allFlowers;
    final selected = <FlowerStimulus>[];
    final random = math.Random();

    while (selected.length < 2) {
      final flower = flowers[random.nextInt(flowers.length)];
      if (!selected.any((f) => f.emoji == flower.emoji)) {
        selected.add(flower);
      }
    }

    return selected;
  }

  void _handleResponse(String response) {
    debugPrint(
        '🎯 Response received: $response, currentRule: $_currentRule, isProcessing: $_isProcessing, phase: $_gamePhase');

    if (_isProcessing || _startTime == null || _currentFlowers.isEmpty) {
      debugPrint(
          '⚠️ Response blocked: isProcessing=$_isProcessing, startTime=$_startTime, flowers=${_currentFlowers.length}');
      return;
    }

    // Prevent multiple responses during processing
    if (_gamePhase == 'complete') {
      debugPrint('⚠️ Response blocked: game already complete');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final reactionTime =
          DateTime.now().difference(_startTime!).inMilliseconds;
      final isCorrect = response == _currentRule;
      final isPostSwitch = _switchPoints.contains(_currentTrial - 1);
      final isPerseverativeError = !isCorrect &&
          isPostSwitch &&
          _trials.isNotEmpty &&
          _trials.last.rule != _currentRule;

      final trial = GameTrial(
        trialNumber: _currentTrial,
        phase: _gamePhase,
        stimulus: _currentFlowers.map((f) => f.emoji).join(' '),
        rule: _currentRule,
        response: response,
        reactionTime: reactionTime,
        correct: isCorrect,
        isPostSwitch: isPostSwitch,
        isPerseverativeError: isPerseverativeError,
        timestamp: DateTime.now(),
      );

      setState(() {
        _trials.add(trial);
      });

      if (isCorrect) {
        setState(() {
          _score += 2;
          _streak++;
          if (_streak > _maxStreak) {
            _maxStreak = _streak;
          }
        });
        GameAudioService.playCorrectSound();
        final localizations = AppLocalizations.of(context)!;
        GameSpeechService.speakFeedback(true, _selectedLanguage);
        _showNotification(localizations.greatJob, 'success');

        if (_streak >= 5) {
          _showNotification('🔥 $_streak in a row! Amazing! 🔥', 'success');
        }
      } else {
        setState(() {
          _streak = 0;
        });
        GameAudioService.playWrongSound();
        final localizations = AppLocalizations.of(context)!;
        GameSpeechService.speakFeedback(false, _selectedLanguage);
        _showNotification(localizations.tryAgain, 'encouragement');
      }

      // Use a slightly longer delay to ensure notification is visible
      final delayMs = isCorrect ? 1000 : 1500;
      Future.delayed(Duration(milliseconds: delayMs), () {
        if (!mounted) {
          _isProcessing = false;
          return;
        }

        if (_gamePhase == 'complete') {
          setState(() {
            _isProcessing = false;
          });
          return;
        }

        // Clear any existing notifications
        ScaffoldMessenger.of(context).clearSnackBars();

        // Update state and move to next trial
        setState(() {
          _currentTrial++;
          _isProcessing = false; // Reset BEFORE calling _nextTrial
        });

        debugPrint('🔄 Moving to trial $_currentTrial, isProcessing: false');
        _nextTrial();
      });
    } catch (e) {
      debugPrint('Error handling response: $e');
      // Reset processing flag on error
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      } else {
        _isProcessing = false;
      }
    }
  }

  void _showNotification(String message, String type) {
    // Show notification using ScaffoldMessenger - shorter duration to not block game
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: type == 'success'
              ? const Color(0xFF06D6A0)
              : const Color(0xFFFF6B8B),
          duration: const Duration(milliseconds: 1500), // Shorter duration
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          dismissDirection:
              DismissDirection.none, // Prevent accidental dismissal
        ),
      );
    }
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _gamePhase = 'complete';
      _isProcessing = false; // Reset processing flag
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
    final correctTrials = _trials.where((t) => t.correct).toList();
    final accuracy =
        _trials.isEmpty ? 0.0 : (correctTrials.length / _trials.length) * 100;
    final avgReactionTime = _trials.isEmpty
        ? 0
        : (_trials.map((t) => t.reactionTime).reduce((a, b) => a + b) /
                _trials.length)
            .round();
    final completionTime = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!).inSeconds
        : 0;
    final switchCost = _calculateSwitchCost();
    final perseverativeErrors =
        _trials.where((t) => t.isPerseverativeError).length;

    return GameResults(
      gameType: 'color-shape',
      totalTrials: _trials.length,
      correctTrials: correctTrials.length,
      accuracy: accuracy,
      averageReactionTime: avgReactionTime,
      completionTime: completionTime,
      switchCost: switchCost,
      perseverativeErrors: perseverativeErrors,
      trials: _trials
          .map((t) => TrialData(
                trialNumber: t.trialNumber,
                stimulus: t.stimulus,
                rule: t.rule,
                response: t.response,
                correct: t.correct,
                reactionTime: t.reactionTime,
                timestamp: t.timestamp,
                isPostSwitch: t.isPostSwitch,
                isPerseverativeError: t.isPerseverativeError,
              ))
          .toList(),
    );
  }

  int _calculateSwitchCost() {
    if (_switchPoints.isEmpty) return 0;
    final switchPoint = _switchPoints[0];
    final preSwitch =
        _trials.where((t) => t.trialNumber <= switchPoint).toList();
    final postSwitch =
        _trials.where((t) => t.trialNumber > switchPoint).toList();

    if (preSwitch.isEmpty || postSwitch.isEmpty) return 0;

    final preAvg =
        preSwitch.map((t) => t.reactionTime).reduce((a, b) => a + b) /
            preSwitch.length;
    final postAvg =
        postSwitch.map((t) => t.reactionTime).reduce((a, b) => a + b) /
            postSwitch.length;

    return (postAvg - preAvg).round();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notificationController.dispose();
    GameSpeechService.stop();
    GameAudioService.stopBackgroundMusic();
    // Reset processing flag on dispose
    _isProcessing = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gamePhase == 'language') {
      return GameLanguageSelector(
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

    if (_gamePhase == 'story') {
      return _buildStoryScreen();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildProgressBar(),
                          const SizedBox(height: 8),
                          GameRuleDisplay(
                            rule: _currentRule,
                            isSwitching: _isSwitching,
                          ),
                          const SizedBox(height: 10),
                          _buildGardenArea(),
                          const SizedBox(height: 10),
                          _buildWandButtons(),
                          const SizedBox(height: 5),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
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
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🌺',
                    style: TextStyle(fontSize: 100),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    localizations.gameTitle,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          localizations.gameInstructionsSimple,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildInstructionButton(
                                localizations.colorButton, '🎨', Colors.pink),
                            const SizedBox(width: 20),
                            _buildInstructionButton(
                                localizations.shapeButton, '🔷', Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () {
                        GameSpeechService.speakInstructions(_selectedLanguage);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        '🔊 Listen',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06D6A0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'START',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildInstructionButton(String label, String emoji, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryScreen() {
    return _buildInstructionsScreen(); // Use same screen
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF667eea).withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(color: Colors.white30, width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            '🌷 Magic Garden',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFFE4A1), width: 2),
                ),
                child: Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Text(
                      '$_score',
                      style: const TextStyle(
                        color: Color(0xFFFF6B8B),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF88E2DC), width: 2),
                ),
                child: Row(
                  children: [
                    const Text('⏱️', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(_timeRemaining),
                      style: const TextStyle(
                        color: Color(0xFF4ECDC4),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (_streak > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        '$_streak',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentTrial / _maxTrials) * 100;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'GARDEN PROGRESS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B8B),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF88E2DC),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '${progress.round()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4ECDC4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 18,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFE4A1), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: MediaQuery.of(context).size.width * (progress / 100),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF6B8B),
                      Color(0xFF4ECDC4),
                      Color(0xFF06D6A0)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGardenArea() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 250,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE4A1), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentFlowers.isNotEmpty)
                  IgnorePointer(
                    child: GameFlowerWidget(
                      flower: _currentFlowers[0],
                      onTap: () {}, // Flowers are display-only, not interactive
                    ),
                  ),
                const SizedBox(width: 40),
                if (_currentFlowers.length > 1)
                  IgnorePointer(
                    child: GameFlowerWidget(
                      flower: _currentFlowers[1],
                      onTap: () {}, // Flowers are display-only, not interactive
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFA7BA), Color(0xFFFF6B8B)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🐰', style: TextStyle(fontSize: 40)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWandButtons() {
    final isActive = !_isProcessing &&
        _gamePhase != 'complete' &&
        _gamePhase != 'story' &&
        _currentFlowers.isNotEmpty &&
        _startTime != null;

    debugPrint(
        '🎯 Wand buttons - isActive: $isActive, isProcessing: $_isProcessing, phase: $_gamePhase, flowers: ${_currentFlowers.length}, startTime: $_startTime');

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          children: [
            Expanded(
              child: WandButton(
                type: 'color',
                onTap: () {
                  debugPrint(
                      '🎨 Color wand tapped - isProcessing: $_isProcessing');
                  if (!_isProcessing && _gamePhase != 'complete') {
                    _handleResponse('color');
                  }
                },
                isActive: isActive,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: WandButton(
                type: 'shape',
                onTap: () {
                  debugPrint(
                      '🔷 Shape wand tapped - isProcessing: $_isProcessing');
                  if (!_isProcessing && _gamePhase != 'complete') {
                    _handleResponse('shape');
                  }
                },
                isActive: isActive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
