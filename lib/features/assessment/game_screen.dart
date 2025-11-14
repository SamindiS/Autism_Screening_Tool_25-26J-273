import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;
import '../../core/services/storage_service.dart';
import '../../core/services/logger_service.dart';
import '../../core/utils/age_calculator.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/language_selector.dart';
import '../../data/models/child.dart';
import '../../data/models/game_results.dart';
import '../cognitive/reflection_screen.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final Child child;
  final String gameType; // 'frog-jump' or 'color-shape'

  const GameScreen({
    Key? key,
    required this.child,
    required this.gameType,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _gameCompleted = false;
  String? _sessionId;
  DateTime? _startTime;
  bool _webViewReady = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _createSession();
  }

  Future<void> _createSession() async {
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final ageGroup = AgeCalculator.getAgeGroup(widget.child.age);
    
    await StorageService.saveSession(
      id: _sessionId!,
      childId: widget.child.id,
      sessionType: widget.gameType,
      ageGroup: ageGroup,
      startTime: _startTime!,
    );
  }

  void _handleGameMessage(String message) {
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      
      if (data['type'] == 'game_complete') {
        _handleGameComplete(data);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error parsing game message: $e');
    }
  }

  Future<void> _handleGameComplete(Map<String, dynamic> data) async {
    if (_gameCompleted) return;
    _gameCompleted = true;

    // Convert HTML game data format to our model format
    final htmlResults = data['results'] as Map<String, dynamic>;
    final results = _convertHtmlResultsToGameResults(htmlResults);
    final endTime = DateTime.now();

    // Save session with results
    await StorageService.updateSession(
      id: _sessionId!,
      endTime: endTime,
      metrics: results.toJson(),
    );

    // Save trials
    for (final trial in results.trials) {
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
    }

    // Log to console
    LoggerService.logSession({
      'event': 'GAME_COMPLETED',
      'child_id': widget.child.id,
      'session_id': _sessionId,
      'game_type': widget.gameType,
      'results': results.toJson(),
      'duration_ms': endTime.difference(_startTime!).inMilliseconds,
    });

    // Route based on age
    if (mounted) {
      if (widget.child.age >= 3.0 && widget.child.age <= 6.0) {
        // Navigate to Clinician Reflection
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
      } else {
        // Navigate directly to Results
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              child: widget.child,
              sessionId: _sessionId!,
              gameResults: results,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getGameTitle()),
        backgroundColor: Colors.orange,
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
      body: Stack(
        children: [
          webview.WebView(
            initialUrl: 'file:///android_asset/flutter_assets/assets/games/${widget.gameType}.html',
            javascriptMode: webview.JavascriptMode.unrestricted,
            javascriptChannels: {
              webview.JavascriptChannel(
                name: 'Flutter',
                onMessageReceived: (webview.JavascriptMessage message) {
                  _handleGameMessage(message.message);
                },
              ),
            },
            onPageFinished: (String url) {
              setState(() => _webViewReady = true);
            },
          ),
          if (!_webViewReady || _gameCompleted)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  String _getGameTitle() {
    switch (widget.gameType) {
      case 'frog-jump':
        return 'Frog Jump Game';
      case 'color-shape':
        return 'Color-Shape Game';
      default:
        return 'Assessment Game';
    }
  }

  GameResults _convertHtmlResultsToGameResults(Map<String, dynamic> htmlData) {
    // Convert HTML game format to GameResults model
    final trials = (htmlData['trials'] as List<dynamic>?)
            ?.map((t) {
              final trialData = t as Map<String, dynamic>;
              return TrialData(
                trialNumber: trialData['trial_number'] as int,
                stimulus: trialData['stimulus'] as String?,
                rule: trialData['rule'] as String?,
                response: trialData['response'] as String?,
                correct: trialData['correct'] as bool,
                reactionTime: trialData['reaction_time'] as int,
                timestamp: DateTime.parse(trialData['timestamp'] as String),
                isPostSwitch: trialData['is_post_switch'] as bool?,
                isPerseverativeError: trialData['is_perseverative_error'] as bool?,
              );
            })
            .toList() ??
        [];

    return GameResults(
      gameType: htmlData['game_type'] as String? ?? widget.gameType,
      totalTrials: htmlData['total_trials'] as int? ?? trials.length,
      correctTrials: htmlData['correct_trials'] as int? ?? 
          trials.where((t) => t.correct).length,
      accuracy: (htmlData['accuracy'] as num?)?.toDouble() ?? 0.0,
      averageReactionTime: htmlData['average_reaction_time'] as int? ?? 0,
      switchCost: htmlData['switch_cost'] as int?,
      perseverativeErrors: htmlData['perseverative_errors'] as int?,
      completionTime: htmlData['completion_time'] as int? ?? 0,
      trials: trials,
    );
  }
}

