import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import '../config/backend_config.dart';

/// Simple Tap the Sound Game for Children
/// 
/// Game Rules:
/// - Play one animal sound
/// - Show 3 large animal pictures
/// - Child taps one picture
/// - No text, no instructions, only tap
/// - Measure: Correct/Incorrect, Reaction time, Attention level
class TapTheSoundPage extends StatefulWidget {
  final String? childName;
  final int? childAge;
  final String childId;

  const TapTheSoundPage({
    super.key,
    required this.childId,
    this.childName,
    this.childAge,
  });

  @override
  State<TapTheSoundPage> createState() => _TapTheSoundPageState();
}

class _TapTheSoundPageState extends State<TapTheSoundPage>
    with TickerProviderStateMixin {
  // ============================================================================
  // GAME CONFIGURATION - EASY TO CHANGE PHOTOS AND SOUNDS
  // ============================================================================
  // Add or modify animals here. Each animal needs:
  // - A unique key (name)
  // - An image path in assets folder
  // - A sound file path in assets folder
  // 
  // TO ADD YOUR ANIMALS:
  // 1. Put your image files in the assets/ folder (e.g., assets/lion.jpg)
  // 2. Put your sound files in the assets/ folder (e.g., assets/lion-roar.mp3)
  // 3. Add an entry below with the animal name, image path, and sound path
  // ============================================================================
  static const Map<String, Map<String, String>> gameItems = {
    'bird': {
      'image': 'bird.png.jpg',  // Actual filename in assets folder
      'sound': 'bird sound.mp3.wav',  // Actual filename in assets folder
    },
    'cat': {
      'image': 'cat.png.jpg',
      'sound': 'cat sound.mp3.wav',
    },
    'dog': {
      'image': 'dog.png.png',
      'sound': 'dog sound.mp3.wav',
    },
    'cow': {
      'image': 'cow.jpg',  // This one is correct
      'sound': 'cow sound.mp3.wav',
    },
    'rooster': {
      'image': 'rooster.png.jpg',
      'sound': 'rooster sound.mp3.mp3',
    },
  };

  // Feedback sounds (optional - add these files to assets folder)
  static const String happySoundPath = 'happy-success.mp3'; // Add your happy sound file
  static const String sadSoundPath = 'sad-incorrect.mp3';     // Optional: add sad sound file
  static const String titleSoundPath = 'tap the animal sound.mp3.mp3'; // Sound for "tap the animal sound"

  // Available animals (automatically generated from gameItems)
  static List<String> get _allAnimals => gameItems.keys.toList();

  // Game state
  bool _gameStarted = false; // Track if game has started
  String? _currentSoundType; // The animal sound playing
  List<String> _displayAnimals = []; // 3 random animals to show
  DateTime? _soundStartTime; // When sound started playing
  DateTime? _soundEndTime; // When sound finished playing
  bool _awaitingTap = false;
  int? _tappedIndex;
  bool _showFeedback = false;
  bool _isCorrect = false;
  String? _sessionId;
  bool _showNextButton = false; // Show next button after tap
  
  // Sound repeat settings (single play by default; counter kept for analytics/logs)
  int _soundRepeatCount = 0; // Track how many times sound has played
  static const int maxSoundRepeats = 3; // Not used for auto-repeat anymore
  
  // Age 5-6 Measurement Metrics
  DateTime? _firstTapTime; // First tap time (for hesitation tracking)
  List<int> _tapHistory = []; // Track all taps (for decision-making)
  bool _soundWasPlayingWhenTapped = false; // Attention span tracking
  int _totalTapsInRound = 0; // Count taps in current round
  Duration? _soundDuration; // Duration of the sound file
  
  // Audio players
  final AudioPlayer _audioPlayer = AudioPlayer(); // For animal sounds
  final AudioPlayer _feedbackPlayer = AudioPlayer(); // For happy/sad feedback sounds
  final AudioPlayer _titlePlayer = AudioPlayer(); // For title sound "tap the animal sound"
  bool _isPlayingSound = false;
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _feedbackController;
  late AnimationController _startButtonController;

  @override
  void initState() {
    super.initState();
    // Configure audio player for optimal playback with maximum volume
    _audioPlayer.setVolume(1.0); // Maximum volume (1.0 = 100%)
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer); // Use media player mode for better sound quality
    // Ensure volume is set to maximum
    _audioPlayer.setVolume(1.0); // Set again to ensure it's applied
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _startButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..value = 1.0; // Start visible
    
    _startGameSession();
    _playTitleSound(); // Play "tap the animal sound" when page loads
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    _pulseController.dispose();
    _feedbackController.dispose();
    _startButtonController.dispose();
    _audioPlayer.dispose();
    _feedbackPlayer.dispose();
    _titlePlayer.dispose();
    super.dispose();
  }

  /// Play title sound "tap the animal sound" when page loads
  Future<void> _playTitleSound() async {
    try {
      await _titlePlayer.setVolume(1.0); // Maximum volume
      await _titlePlayer.setPlayerMode(PlayerMode.mediaPlayer);
      await _titlePlayer.play(AssetSource(titleSoundPath));
      print('Playing title sound: $titleSoundPath');
    } catch (e) {
      print('Title sound file not found. Please add $titleSoundPath to assets folder. Error: $e');
      // Silently fail if sound file doesn't exist
    }
  }

  /// Start game session
  Future<void> _startGameSession() async {
    // Register with backend in background
    try {
      final response = await http.post(
        Uri.parse(BackendConfig.tapGameStartEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'child_id': widget.childId,
          'age_group': widget.childAge != null ? '${widget.childAge}-${widget.childAge! + 1}' : '3-4',
          'game_name': 'Tap the Sound',
        }),
      );

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        setState(() {
          _sessionId = data['session_id'] as String?;
        });
      }
    } catch (e) {
      print('Backend start session error: $e');
    }
  }

  /// Start the game (called when Start button is tapped)
  void _onStartButtonTap() {
    _startButtonController.forward(); // Fade out
    setState(() {
      _gameStarted = true;
    });
    _startNewRound();
  }

  /// Start a new round
  Future<void> _startNewRound() async {
    // Stop and cancel any ongoing sound
    await _playerCompleteSubscription?.cancel();
    await _audioPlayer.stop();
    await Future.delayed(const Duration(milliseconds: 100));

    // Pick random sound animal
    final random = math.Random();
    final soundAnimal = _allAnimals[random.nextInt(_allAnimals.length)];

    // Pick 3 random animals (including the correct one)
    final availableAnimals = List<String>.from(_allAnimals);
    availableAnimals.remove(soundAnimal);
    availableAnimals.shuffle(random);
    
    // Ensure we always have 3 animals
    final displayAnimals = <String>[];
    displayAnimals.add(soundAnimal); // Add correct answer
    displayAnimals.addAll(availableAnimals.take(2)); // Add 2 wrong answers
    
    // If we don't have enough, fill with random animals
    while (displayAnimals.length < 3) {
      final randomAnimal = _allAnimals[random.nextInt(_allAnimals.length)];
      if (!displayAnimals.contains(randomAnimal)) {
        displayAnimals.add(randomAnimal);
      }
    }
    
    // Shuffle the order
    displayAnimals.shuffle(random);

    // Update state FIRST before playing sound
    setState(() {
      _tappedIndex = null;
      _showFeedback = false;
      _isCorrect = false;
      _showNextButton = false;
      _awaitingTap = true;
      _currentSoundType = soundAnimal;
      _displayAnimals = displayAnimals; // Ensure this is set
      _soundStartTime = DateTime.now();
      _soundEndTime = null;
      _isPlayingSound = false; // Reset playing state
      
      // Reset age 5-6 metrics
      _firstTapTime = null;
      _tapHistory = [];
      _soundWasPlayingWhenTapped = false;
      _totalTapsInRound = 0;
      _soundDuration = null;
      _soundRepeatCount = 0; // Reset repeat counter for new round
    });

    // Debug: Print current round info
    print('New round started:');
    print('  Sound: $soundAnimal');
    print('  Display animals: $displayAnimals');
    print('  Animals count: ${displayAnimals.length}');

    // Small delay to ensure UI updates and audio player is ready
    await Future.delayed(const Duration(milliseconds: 200));

    // Play sound - ensure it plays
    await _playSound(soundAnimal);
    
    // Double-check: if sound didn't start after 500ms, retry
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_isPlayingSound && _awaitingTap && _currentSoundType == soundAnimal) {
        print('Sound did not start, retrying...');
        _playSound(soundAnimal);
      }
    });
  }

  StreamSubscription? _playerCompleteSubscription;

  /// Play animal sound
  Future<void> _playSound(String animal) async {
    if (!mounted) return;

    try {
      final soundPath = _getSoundPath(animal);
      if (soundPath == null) {
        print('No sound path found for: $animal');
        return;
      }

      print('Playing sound for: $animal (path: $soundPath)');

      // Cancel previous subscription to avoid multiple listeners
      await _playerCompleteSubscription?.cancel();

      // Stop any currently playing sound first
      await _audioPlayer.stop();
      await Future.delayed(const Duration(milliseconds: 100));

      // Ensure volume and player mode are set before playing - MAXIMUM VOLUME
      await _audioPlayer.setVolume(1.0); // Maximum volume (100%)
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      
      // Set volume again right before playing to ensure maximum loudness
      await _audioPlayer.setVolume(1.0);
      
      // Play the sound at maximum volume
      await _audioPlayer.play(AssetSource(soundPath));
      
      // Set volume once more after starting playback to ensure it's loud
      await Future.delayed(const Duration(milliseconds: 50));
      await _audioPlayer.setVolume(1.0);
      
      setState(() {
        _isPlayingSound = true;
      });

      // Track sound duration (approximate - will be updated when sound completes)
      _soundDuration = null;
      _soundRepeatCount++;
      
      // Listen for completion (no auto-repeat; keeps logic simple and reliable)
      _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
        if (!mounted) return;
        final now = DateTime.now();
        setState(() {
          _isPlayingSound = false;
          _soundEndTime = now;
          if (_soundStartTime != null) {
            _soundDuration = now.difference(_soundStartTime!);
          }
        });
        print('Sound finished for $animal (play count: $_soundRepeatCount)');
      });
    } catch (e, stackTrace) {
      print('Error playing sound for $animal: $e');
      print('Stack trace: $stackTrace');
      // Retry once after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _awaitingTap && _currentSoundType == animal) {
          print('Retrying sound playback for: $animal');
          _playSound(animal);
        }
      });
    }
  }

  /// Replay current sound (when middle sound icon is tapped)
  Future<void> _onSoundIconTap() async {
    if (_currentSoundType == null || !_gameStarted) {
      print(
          'Sound icon tapped but game not ready - started: $_gameStarted, sound: $_currentSoundType');
      return;
    }
    print('Sound icon tapped - replaying sound for: $_currentSoundType');
    // Stop any current playback so we always restart cleanly
    await _audioPlayer.stop();
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    await _playSound(_currentSoundType!);
  }

  /// Play feedback sound (happy for correct, sad for incorrect)
  Future<void> _playFeedbackSound(bool isCorrect) async {
    try {
      // Stop any previous feedback sound
      await _feedbackPlayer.stop();
      
      if (isCorrect) {
        // Play happy sound for correct answer at maximum volume
        print('Correct answer! Playing happy sound...');
        try {
          await _feedbackPlayer.setVolume(1.0); // Maximum volume
          await _feedbackPlayer.play(AssetSource(happySoundPath));
          // Ensure volume is max after starting
          await Future.delayed(const Duration(milliseconds: 50));
          await _feedbackPlayer.setVolume(1.0);
        } catch (e) {
          print('Happy sound file not found. Please add $happySoundPath to assets folder.');
        }
      } else {
        // Optional: Play sad sound for incorrect answer
        print('Incorrect answer.');
        // Uncomment below if you want sad sound for wrong answers:
        // try {
        //   await _feedbackPlayer.play(AssetSource(sadSoundPath));
        // } catch (e) {
        //   print('Sad sound file not found.');
        // }
      }
    } catch (e) {
      print('Error playing feedback sound: $e');
    }
  }

  /// Get sound file path for animal (uses configuration map)
  String? _getSoundPath(String animal) {
    final soundFile = gameItems[animal]?['sound'];
    // AssetSource works with just the filename when assets/ is in pubspec.yaml
    return soundFile;
  }

  /// Handle card tap
  Future<void> _handleCardTap(int index) async {
    if (index >= _displayAnimals.length) return;
    
    final now = DateTime.now();
    final selectedAnimal = _displayAnimals[index];
    
    // Track decision-making: Is this the first tap or a change?
    final isFirstTap = _firstTapTime == null;
    final isTapChange = !isFirstTap && _tappedIndex != null && _tappedIndex != index;
    
    // Track first tap time (for hesitation measurement)
    if (isFirstTap) {
      _firstTapTime = now;
    }
    
    // Track tap history (for decision-making analysis)
    _tapHistory.add(index);
    _totalTapsInRound++;
    
    // Track attention span: Was sound still playing when tapped?
    final soundWasPlaying = _isPlayingSound;
    
    // Calculate reaction time from sound start
    final reactionTimeMs = _soundStartTime != null
        ? now.difference(_soundStartTime!).inMilliseconds
        : 0;
    
    // Calculate hesitation time (time from sound start to first tap)
    final hesitationTimeMs = _soundStartTime != null && _firstTapTime != null
        ? _firstTapTime!.difference(_soundStartTime!).inMilliseconds
        : reactionTimeMs;
    
    final isCorrect = selectedAnimal == _currentSoundType;

    // Stop animal sound if this is the first tap
    if (isFirstTap) {
      _audioPlayer.stop();
      setState(() {
        _awaitingTap = false;
        _soundWasPlayingWhenTapped = soundWasPlaying;
      });
    }

    setState(() {
      _tappedIndex = index;
      _isCorrect = isCorrect;
      _showFeedback = true;
      _showNextButton = true;
      _isPlayingSound = false;
    });

    // Play feedback sound (happy for correct, sad for incorrect)
    _playFeedbackSound(isCorrect);

    // Show feedback animation with enhanced effect
    _feedbackController.forward(from: 0);

    // Send response to backend with all metrics
    await _sendResponseToBackend(
      selectedAnimal: selectedAnimal,
      isCorrect: isCorrect,
      reactionTimeMs: reactionTimeMs,
      hesitationTimeMs: hesitationTimeMs,
      isFirstTap: isFirstTap,
      isTapChange: isTapChange,
      soundWasPlayingWhenTapped: soundWasPlaying,
      totalTapsInRound: _totalTapsInRound,
      tapHistory: _tapHistory,
      soundDuration: _soundDuration?.inMilliseconds,
    );

    // If child selected the correct animal, automatically move to next round
    // after a short delay so they can see the feedback.
    if (isCorrect) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        if (_showNextButton) {
          _onNextButtonTap();
        }
      });
    }
  }

  /// Move to next round (called when Next button is tapped)
  void _onNextButtonTap() {
    setState(() {
      _showNextButton = false;
      _showFeedback = false;
    });
    _startNewRound();
  }

  /// End game (called when End button is tapped)
  void _onEndButtonTap() {
    _audioPlayer.stop();
    Navigator.of(context).maybePop();
  }

  /// Go home (called when Home button is tapped)
  void _onHomeButtonTap() {
    _audioPlayer.stop();
    Navigator.of(context).maybePop();
  }

  /// Send response to backend with comprehensive metrics
  Future<void> _sendResponseToBackend({
    required String selectedAnimal,
    required bool isCorrect,
    required int reactionTimeMs,
    int? hesitationTimeMs,
    bool? isFirstTap,
    bool? isTapChange,
    bool? soundWasPlayingWhenTapped,
    int? totalTapsInRound,
    List<int>? tapHistory,
    int? soundDuration,
  }) async {
    if (_sessionId == null || _currentSoundType == null) return;

    // Determine age group
    final ageGroup = widget.childAge != null 
        ? '${widget.childAge}-${widget.childAge! + 1}' 
        : '3-4';
    
    // Calculate sound discrimination difficulty
    // (Similar sounds are harder to discriminate)
    final soundDifficulty = _calculateSoundDifficulty(_currentSoundType!, _displayAnimals);

    try {
      final responseData = {
        'session_id': _sessionId,
        'child_id': widget.childId,
        'age_group': ageGroup,
        'game_name': 'Tap the Sound',
        'sound_type': _currentSoundType,
        'selected_image': selectedAnimal,
        'is_correct': isCorrect,
        'reaction_time_ms': reactionTimeMs,
        
        // Age 5-6 Specific Metrics
        'hesitation_time_ms': hesitationTimeMs ?? reactionTimeMs,
        'is_first_tap': isFirstTap ?? true,
        'is_tap_change': isTapChange ?? false,
        'sound_was_playing_when_tapped': soundWasPlayingWhenTapped ?? false,
        'total_taps_in_round': totalTapsInRound ?? 1,
        'tap_history': tapHistory ?? [0],
        'sound_duration_ms': soundDuration,
        'sound_difficulty': soundDifficulty,
        
        // Attention span metrics
        'tapped_before_sound_finished': soundWasPlayingWhenTapped ?? false,
        'random_tapping_detected': (totalTapsInRound ?? 1) > 1,
        
        // Decision-making metrics
        'decision_confidence': (isFirstTap ?? true) ? 'high' : 'low', // First tap = confident, changes = uncertain
        'hesitation_level': _calculateHesitationLevel(hesitationTimeMs ?? reactionTimeMs),
      };

      print('Sending metrics to backend:');
      print('  Reaction time: ${reactionTimeMs}ms');
      print('  Hesitation time: ${hesitationTimeMs ?? reactionTimeMs}ms');
      print('  Tap changes: ${isTapChange ?? false}');
      print('  Sound was playing: ${soundWasPlayingWhenTapped ?? false}');
      print('  Total taps: ${totalTapsInRound ?? 1}');

      await http.post(
        Uri.parse(BackendConfig.tapGameResponseEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(responseData),
      );
    } catch (e) {
      print('Backend response error: $e');
    }
  }

  /// Calculate sound difficulty for discrimination ability
  String _calculateSoundDifficulty(String soundType, List<String> displayAnimals) {
    // Group similar sounds
    final mammalSounds = ['dog', 'cat'];
    final birdSounds = [];
    final otherSounds = [];
    
    final soundCategory = mammalSounds.contains(soundType) 
        ? 'mammal' 
        : birdSounds.contains(soundType) 
            ? 'bird' 
            : 'other';
    
    // Check if displayed animals are from same category (harder discrimination)
    final sameCategoryCount = displayAnimals.where((animal) {
      if (soundCategory == 'mammal') return mammalSounds.contains(animal);
      if (soundCategory == 'bird') return birdSounds.contains(animal);
      return false;
    }).length;
    
    if (sameCategoryCount >= 2) return 'hard'; // Similar sounds
    if (sameCategoryCount == 1) return 'medium';
    return 'easy'; // Different sound types
  }

  /// Calculate hesitation level based on time
  String _calculateHesitationLevel(int hesitationMs) {
    if (hesitationMs < 1000) return 'none'; // Very fast
    if (hesitationMs < 3000) return 'low'; // Quick decision
    if (hesitationMs < 5000) return 'medium'; // Some hesitation
    return 'high'; // Significant hesitation
  }

  @override
  Widget build(BuildContext context) {
    // Try to load jungle scene background image
    const String jungleImagePath = 'assets/jungle_scene.jpg';
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Jungle scene background with gradient fallback
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF87CEEB), // Sky blue (sunny jungle sky)
              const Color(0xFF98D8C8), // Light green (bright foliage)
              const Color(0xFF90EE90), // Light green (jungle clearing)
              const Color(0xFF7CB342), // Green (jungle floor)
            ],
          ),
        ),
        child: Stack(
          children: [
            // Jungle scene background image (if available)
            Positioned.fill(
              child: Image.asset(
                jungleImagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback: return empty container if image not found
                  return Container();
                },
              ),
            ),
            // Overlay gradient for better text visibility over jungle scene
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.15),
                    ],
                  ),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Stack(
                children: [
                  // Main game area
                  Column(
                children: [
                  // Top spacing
                  const SizedBox(height: 20),
                  
                  // Title text "Tap the animal sound" - ONLY visible before game starts, centered in middle
                  if (!_gameStarted)
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Curved design container with colorful title
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 35),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.85),
                                    Colors.white.withOpacity(0.75),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(60),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.9),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 25,
                                    spreadRadius: 3,
                                    offset: const Offset(0, 5),
                                  ),
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.2),
                                    blurRadius: 15,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: _ColorfulTitleText(text: 'Tap the animal sound'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Sound icon (ALWAYS VISIBLE) - centered
                  Expanded(
                    flex: _gameStarted ? 3 : 2,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Curved decorative circles
                          Positioned(
                            child: Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          // Sound icon
                          GestureDetector(
                            onTap: _onSoundIconTap,
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isPlayingSound
                                        ? Colors.white.withOpacity(0.9 - (_pulseController.value * 0.3))
                                        : Colors.white.withOpacity(0.3),
                                    boxShadow: _isPlayingSound
                                        ? [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.6),
                                              blurRadius: 30 + (_pulseController.value * 20),
                                              spreadRadius: 10 + (_pulseController.value * 10),
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.2),
                                              blurRadius: 20,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.volume_up,
                                      size: 100,
                                      color: _isPlayingSound
                                          ? const Color(0xFF6C5CE7)
                                          : Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Three large animal cards (only show if game started)
                  if (_gameStarted)
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        child: _displayAnimals.length >= 3
                            ? Row(
                                children: List.generate(3, (index) {
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: index > 0 ? 8 : 0,
                                        right: index < 2 ? 8 : 0,
                                      ),
                                      child: _AnimalCard(
                                        imageKey: _displayAnimals[index],
                                        isTapped: _tappedIndex == index,
                                        isCorrect: _tappedIndex == index && _isCorrect,
                                        onTap: () => _handleCardTap(index),
                                      ),
                                    ),
                                  );
                                }),
                              )
                            : const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    )
                  else
                    const Spacer(flex: 3),
                  
                  // Bottom spacing
                  const SizedBox(height: 20),
                ],
              ),
              
              // Home button (top-left) - Always visible
              Positioned(
                top: 10,
                left: 10,
                child: _HomeButton(onTap: _onHomeButtonTap),
              ),
              
              // End button (top-right) - Visible during gameplay
              if (_gameStarted)
                Positioned(
                  top: 10,
                  right: 10,
                  child: _EndButton(onTap: _onEndButtonTap),
                ),
              
              // Start button (bottom center) - Only visible before game starts
              if (!_gameStarted)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FadeTransition(
                      opacity: _startButtonController,
                      child: _StartButton(onTap: _onStartButtonTap),
                    ),
                  ),
                ),
              
              // Next button (bottom-right) - Appears after image is tapped
              if (_showNextButton)
                Positioned(
                  bottom: 40,
                  right: 20,
                  child: _NextButton(onTap: _onNextButtonTap),
                ),
              
              // Feedback overlay
              if (_showFeedback)
                _FeedbackOverlay(
                  isCorrect: _isCorrect,
                  controller: _feedbackController,
                ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Home button (top-left)
class _HomeButton extends StatelessWidget {
  final VoidCallback onTap;

  const _HomeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.home,
          size: 28,
          color: Color(0xFF6C5CE7),
        ),
      ),
    );
  }
}

/// End button (top-right)
class _EndButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EndButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.stop,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Start button (bottom center)
class _StartButton extends StatelessWidget {
  final VoidCallback onTap;

  const _StartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_arrow,
              size: 40,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              'Start',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Next button (bottom-right, appears after tap)
class _NextButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NextButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_forward,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Large animal card widget
class _AnimalCard extends StatelessWidget {
  final String imageKey;
  final bool isTapped;
  final bool isCorrect;
  final VoidCallback onTap;

  const _AnimalCard({
    required this.imageKey,
    required this.isTapped,
    required this.isCorrect,
    required this.onTap,
  });

  String _assetForKey(String key) {
    // Use configuration map, fallback to default image if not found
    final path = _TapTheSoundPageState.gameItems[key]?['image'] ?? 'image1.jpg';
    print('Loading image for $key: $path');
    // Image.asset needs the full path with assets/ prefix
    return 'assets/$path';
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = _assetForKey(imageKey);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white, // White frame background
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isTapped
                ? (isCorrect ? Colors.green.shade700 : Colors.red.shade700)
                : Colors.white,
            width: isTapped ? 6 : 4, // White frame border
          ),
          boxShadow: [
            BoxShadow(
              color: isTapped
                  ? (isCorrect ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5))
                  : Colors.black.withOpacity(0.15),
              blurRadius: isTapped ? 30 : 20,
              spreadRadius: isTapped ? 5 : 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(21), // Slightly smaller to show white frame
          child: Container(
            padding: const EdgeInsets.all(2), // Minimal padding for maximum image size
            color: Colors.white,
            child: Stack(
              children: [
                // Animal image - full picture with contain fit
                Center(
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain, // Show full image without cropping
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, size: 56, color: Colors.grey[500]),
                              const SizedBox(height: 8),
                              Text(
                                'Add $imageKey to assets/',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Overlay for feedback
                if (isTapped)
                  Container(
                    decoration: BoxDecoration(
                      color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: Center(
                      child: Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        size: 100,
                        color: Colors.white,
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

/// Feedback overlay (smile or sad face)
class _FeedbackOverlay extends StatelessWidget {
  final bool isCorrect;
  final AnimationController controller;

  const _FeedbackOverlay({
    required this.isCorrect,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Opacity(
            opacity: controller.value,
              child: Transform.scale(
              scale: 0.3 + (controller.value * 0.7), // Enhanced scale animation
              child: Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCorrect ? Colors.green : Colors.red,
                    boxShadow: [
                      BoxShadow(
                        color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.6),
                        blurRadius: 50 + (controller.value * 30), // Pulsing shadow
                        spreadRadius: 15 + (controller.value * 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    isCorrect ? Icons.sentiment_very_satisfied : Icons.sentiment_very_dissatisfied,
                    size: 180,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Colorful title text widget with each letter in different colors
class _ColorfulTitleText extends StatelessWidget {
  final String text;

  const _ColorfulTitleText({required this.text});

  // Color palette for letters (similar to PLAY IS design)
  static const List<Color> letterColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFFFF9800), // Orange
    Color(0xFFE91E63), // Red/Pink
    Color(0xFF4CAF50), // Green
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan/Teal
    Color(0xFFFFC107), // Amber
    Color(0xFFF44336), // Red
    Color(0xFF3F51B5), // Indigo
    Color(0xFF009688), // Teal
    Color(0xFFE91E63), // Pink
    Color(0xFF2196F3), // Blue
    Color(0xFFFF9800), // Orange
    Color(0xFF4CAF50), // Green
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFFC107), // Amber
    Color(0xFFF44336), // Red
    Color(0xFF3F51B5), // Indigo
    Color(0xFF009688), // Teal
  ];

  @override
  Widget build(BuildContext context) {
    final characters = text.split('');
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: characters.asMap().entries.map((entry) {
        final index = entry.key;
        final char = entry.value;
        
        if (char == ' ') {
          return const SizedBox(width: 8);
        }
        
        final color = letterColors[index % letterColors.length];
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            char,
            style: TextStyle(
              fontSize: 56, // Increased font size
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.8,
              decoration: TextDecoration.none, // Remove any underline
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(2, 2),
                ),
                Shadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

