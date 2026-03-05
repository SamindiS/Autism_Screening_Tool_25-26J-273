import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;
import '../../core/services/storage_service.dart';
import '../../core/services/logger_service.dart';
import '../../core/utils/age_calculator.dart';
import '../../widgets/language_selector.dart';
import '../../data/models/child.dart';
import '../../data/models/game_results.dart';
import '../settings/settings_screen.dart';
import '../cognitive/reflection_screen.dart';
import 'result_screen.dart';
import 'games/color_shape_game/color_shape_game_screen.dart';
import 'games/frog_jump_game/frog_jump_game_screen.dart';

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
  late final webview.WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _createSession();

    // Only initialize WebView for non-color-shape games
    if (widget.gameType != 'color-shape' && widget.gameType != 'color_shape') {
      _initializeWebView();
    }
  }

  void _initializeWebView() {
    _webViewController = webview.WebViewController()
      ..setJavaScriptMode(webview.JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (webview.JavaScriptMessage message) {
          _handleGameMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        webview.NavigationDelegate(
          onPageFinished: (String url) {
            setState(() => _webViewReady = true);
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
            'file:///android_asset/flutter_assets/assets/games/${widget.gameType}.html'),
      );
  }

  Future<void> _createSession() async {
    try {
      final ageGroup = AgeCalculator.getAgeGroup(widget.child.age);

      // Create session via API - backend will generate UUID
      final sessionData = await StorageService.saveSession(
        childId: widget.child.id,
        sessionType: widget.gameType,
        ageGroup: ageGroup,
        startTime: _startTime!,
      );

      // Get the session ID from the response
      if (sessionData != null && sessionData['id'] != null) {
        _sessionId = sessionData['id'] as String;
      } else {
        // Fallback: generate timestamp-based ID if API doesn't return one
        _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      }
    } catch (e) {
      debugPrint('Error creating session: $e');
      // Fallback: generate timestamp-based ID
      _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    }
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

    try {
      // Convert HTML game data format to our model format
      final htmlResults = data['results'] as Map<String, dynamic>;
      final results = _convertHtmlResultsToGameResults(htmlResults);
      final endTime = DateTime.now();

      // Ensure we have a valid session ID
      if (_sessionId == null) {
        debugPrint('Warning: Session ID is null, creating new session');
        // Create a new session if we don't have one
        final sessionData = await StorageService.saveSession(
          childId: widget.child.id,
          sessionType:
              widget.gameType == 'frog-jump' ? 'frog_jump' : 'color_shape',
          ageGroup: AgeCalculator.getAgeGroup(widget.child.age),
          startTime: _startTime ?? DateTime.now(),
        );

        if (sessionData != null && sessionData['id'] != null) {
          _sessionId = sessionData['id'] as String;
        } else {
          throw Exception('Failed to create session');
        }
      }

      // Save session with results
      try {
        await StorageService.updateSession(
          id: _sessionId!,
          endTime: endTime,
          gameResults: results.toJson(),
        );
      } catch (e) {
        debugPrint('Error updating session: $e');
        // Continue anyway - session might already be updated
      }

      // Save trials (non-blocking - continue even if some fail)
      for (final trial in results.trials) {
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
          // Continue with next trial
        }
      }

      // Log to console
      LoggerService.logSession({
        'event': 'GAME_COMPLETED',
        'child_id': widget.child.id,
        'session_id': _sessionId,
        'game_type': widget.gameType,
        'results': results.toJson(),
        'duration_ms':
            endTime.difference(_startTime ?? DateTime.now()).inMilliseconds,
      });

      // Route based on game type
      // Frog Jump (3.5-5.5) and Color-Shape (5.5-6.9) both go to Clinician Reflection
      if (mounted && _sessionId != null) {
        // Frog Jump game: ages 3.5-5.5 -> Clinician Reflection
        if (widget.gameType == 'frog-jump' || widget.gameType == 'frog_jump') {
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
        // Color-Shape game: ages 5.5-6.9 -> Clinician Reflection
        else if (widget.gameType == 'color-shape' ||
            widget.gameType == 'color_shape') {
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
        // Fallback: Navigate to Results screen
        else {
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
    } catch (e) {
      debugPrint('Error handling game completion: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving game results: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // Still try to navigate even if saving failed
        if (_sessionId != null) {
          final htmlResults = data['results'] as Map<String, dynamic>;
          final results = _convertHtmlResultsToGameResults(htmlResults);

          if (widget.gameType == 'frog-jump' ||
              widget.gameType == 'frog_jump' ||
              widget.gameType == 'color-shape' ||
              widget.gameType == 'color_shape') {
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
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Flutter games instead of WebView
    if (widget.gameType == 'color-shape' || widget.gameType == 'color_shape') {
      return ColorShapeGameScreen(
        key: ValueKey('color_shape_${widget.child.id}'),
        child: widget.child,
      );
    } else if (widget.gameType == 'frog-jump' ||
        widget.gameType == 'frog_jump') {
      return FrogJumpGameScreen(
        key: ValueKey('frog_jump_${widget.child.id}'),
        child: widget.child,
      );
    }

    // WebView for other games (fallback)
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
          webview.WebViewWidget(controller: _webViewController),
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
    final trials = (htmlData['trials'] as List<dynamic>?)?.map((t) {
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
        }).toList() ??
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
