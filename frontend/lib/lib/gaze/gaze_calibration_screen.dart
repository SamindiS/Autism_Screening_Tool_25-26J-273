/// Gaze Calibration Screen (Child-Friendly Version)
///
/// This screen:
/// 1. Shows animated characters for children to look at
/// 2. Collects iris position + head pose data at each point
/// 3. Trains the gaze model in real-time using this data
/// 4. Proceeds to games after training is complete
///
/// Features for 2-6 year olds:
/// - Animated characters (butterfly, star, bee, fish, etc.)
/// - Fun colors and sparkle effects
/// - Encouraging messages
/// - Progress celebrations

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'gaze_tracker.dart';
import 'gaze_service.dart';
import '../main.dart'; // For ButterflyScreen

/// Helper class to hold character data for calibration points
class _CalibrationCharacter {
  final String emoji;
  final String name;
  final Color color;

  const _CalibrationCharacter(this.emoji, this.name, this.color);
}

class GazeCalibrationScreen extends StatefulWidget {
  final String testId;
  final VoidCallback onCalibrationComplete;

  const GazeCalibrationScreen({
    required this.testId,
    required this.onCalibrationComplete,
    super.key,
  });

  @override
  State<GazeCalibrationScreen> createState() => _GazeCalibrationScreenState();
}

class _GazeCalibrationScreenState extends State<GazeCalibrationScreen>
    with TickerProviderStateMixin {
  bool _showInstructions = true; // Show instructions first
  bool _isInitialized = false;
  bool _isCalibrating = false;
  bool _isTraining = false;
  bool _calibrationComplete = false;
  String _status = 'Setting up camera...';
  String _instruction = 'Please wait...';

  StreamSubscription<GazeData>? _gazeSubscription;

  int _currentPointIndex = 0;

  // ==========================================================================
  // CLINICALLY RECOMMENDED COLOR PALETTE FOR CHILDREN (especially ASD)
  // ==========================================================================
  // Research shows soft, muted, pastel colors are:
  // - Less overstimulating for sensory-sensitive children
  // - Calming and maintain attention without causing distress
  // - Better tolerated by children with autism spectrum conditions
  //
  // Key principles:
  // - Soft pastels over bright saturated colors
  // - Blue/green/lavender hues are generally calming
  // - Avoid harsh reds and bright yellows
  // - Nature-inspired tones (sky, grass, clouds)
  // ==========================================================================

  // Clinically appropriate soft color palette
  static const Color _softSkyBlue = Color(0xFF87CEEB); // Calming sky blue
  static const Color _softMint = Color(0xFF98D8C8); // Soothing mint green
  static const Color _softLavender = Color(0xFFB8A9C9); // Gentle lavender
  static const Color _softPeach = Color(0xFFFFDAB9); // Warm soft peach
  static const Color _softCoral = Color(0xFFF7CAC9); // Muted coral pink
  static const Color _softSage = Color(0xFFB2D3C2); // Calming sage green
  static const Color _softPeriwinkle = Color(0xFFCCCCFF); // Soft periwinkle
  static const Color _softApricot = Color(0xFFFFE5B4); // Gentle apricot
  static const Color _softTeal = Color(0xFF88D8D8); // Soothing teal
  static const Color _softLilac = Color(0xFFDCD0FF); // Soft lilac
  static const Color _softAqua = Color(0xFFA0E7E5); // Calm aqua
  static const Color _softBlush = Color(0xFFF4C2C2); // Gentle blush
  static const Color _softCream = Color(0xFFFFF8DC); // Warm cream

  // Child-friendly characters with clinically appropriate soft colors
  final List<_CalibrationCharacter> _characters = [
    _CalibrationCharacter('\u{1F98B}', 'Butterfly', _softLavender),
    _CalibrationCharacter('\u{2B50}', 'Star', _softApricot),
    _CalibrationCharacter('\u{1F41D}', 'Bee', _softPeach),
    _CalibrationCharacter('\u{1F420}', 'Fish', _softTeal),
    _CalibrationCharacter('\u{1F338}', 'Flower', _softCoral),
    _CalibrationCharacter('\u{1F426}', 'Bird', _softSkyBlue),
    _CalibrationCharacter('\u{1F31F}', 'Twinkle Star', _softCream),
    _CalibrationCharacter('\u{1F422}', 'Turtle', _softSage),
    _CalibrationCharacter('\u{1F388}', 'Balloon', _softMint),
    _CalibrationCharacter('\u{1F430}', 'Bunny', _softLilac),
    _CalibrationCharacter('\u{1F319}', 'Moon', _softPeriwinkle),
    _CalibrationCharacter('\u{1F340}', 'Clover', _softAqua),
    _CalibrationCharacter('\u{1F433}', 'Whale', _softBlush),
  ];

  // Calm, encouraging messages - not overly stimulating
  // Avoiding excessive punctuation and emoji overload
  final List<String> _encouragements = [
    'Well done!',
    'Great!',
    'Nice work!',
    'Good job!',
    'Wonderful!',
    'Perfect!',
    'You did it!',
    'So good!',
    'Lovely!',
    'That\'s right!',
  ];

  // 13-point calibration grid for better coverage
  final List<Offset> _calibrationPoints = [
    const Offset(0.5, 0.5), // CENTER first (most important)
    const Offset(0.15, 0.15), // Top-left
    const Offset(0.5, 0.15), // Top-center
    const Offset(0.85, 0.15), // Top-right
    const Offset(0.15, 0.5), // Middle-left
    const Offset(0.85, 0.5), // Middle-right
    const Offset(0.15, 0.85), // Bottom-left
    const Offset(0.5, 0.85), // Bottom-center
    const Offset(0.85, 0.85), // Bottom-right
    // Additional points for better coverage
    const Offset(0.33, 0.33), // Inner top-left
    const Offset(0.67, 0.33), // Inner top-right
    const Offset(0.33, 0.67), // Inner bottom-left
    const Offset(0.67, 0.67), // Inner bottom-right
  ];

  // Collected samples count
  int _totalSamplesCollected = 0;

  // Latest data for visualization
  EyeLandmarks? _latestLandmarks;
  Offset? _currentGaze;

  // Samples per point - increased for better training
  final int _samplesPerPoint = 15;
  int _currentPointSamples = 0;

  // Animation controllers
  late AnimationController _dotAnimationController;
  late Animation<double> _dotPulseAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnimation;
  late AnimationController _celebrationController;

  // Celebration state
  bool _showCelebration = false;
  String _celebrationMessage = '';
  Offset _celebrationPosition =
      const Offset(0.5, 0.5); // Where to show celebration

  // Countdown timer
  Timer? _captureTimer;
  int _countdown = 0;

  // Random for encouragements
  final _random = Random();

  @override
  void initState() {
    super.initState();

    // Main pulsing animation
    _dotAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _dotPulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _dotAnimationController, curve: Curves.easeInOut),
    );

    // Bouncing animation for the character
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Sparkle rotation animation
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _sparkleAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.linear),
    );

    // Celebration animation
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Don't auto-initialize - wait for user to click "Start" button
    // _initializeGazeTracking();
  }

  Future<void> _initializeGazeTracking() async {
    try {
      setState(() {
        _status = 'Getting ready...';
        _instruction = 'One moment please!';
      });

      await gazeService.initialize();
      await gazeService.startTracking();

      _gazeSubscription = gazeService.gazeStream.listen((gazeData) {
        if (mounted) {
          setState(() {
            if (gazeData.faceDetected) {
              _latestLandmarks = gazeData.landmarks;
              _currentGaze = gazeData.position;
            } else {
              _latestLandmarks = null;
              _currentGaze = null;
            }
          });
        }
      });

      setState(() {
        _isInitialized = true;
        _status = 'All set!';
        _instruction = 'Let\'s play a game! Tap the button!';
      });
    } catch (e) {
      setState(() {
        _status = 'Oops! Something went wrong';
        _instruction = 'Please check camera permissions';
      });
    }
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _dotAnimationController.dispose();
    _bounceController.dispose();
    _sparkleController.dispose();
    _celebrationController.dispose();
    _gazeSubscription?.cancel();
    super.dispose();
  }

  /// Show celebration when a point is completed
  void _showPointCelebration() {
    // Save the position of the completed point for showing celebration there
    _celebrationPosition = _calibrationPoints[
        _currentPointIndex > 0 ? _currentPointIndex - 1 : _currentPointIndex];
    _celebrationMessage =
        _encouragements[_random.nextInt(_encouragements.length)];
    _showCelebration = true;
    _celebrationController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _showCelebration = false;
        });
      }
    });
  }

  /// Start the calibration process
  void _startCalibration() {
    // Tell the gaze service to start collecting training data
    gazeService.startCalibration();

    final character = _characters[0];
    setState(() {
      _isCalibrating = true;
      _currentPointIndex = 0;
      _currentPointSamples = 0;
      _totalSamplesCollected = 0;
      _instruction = 'Find the ${character.name}! ${character.emoji}';
    });

    _startCountdown();
  }

  /// Start countdown for auto-capture
  void _startCountdown() {
    // For first sample of each point, give user time to look at the dot
    // For subsequent samples, capture quickly
    final isFirstSample = _currentPointSamples == 0;
    final character = _characters[_currentPointIndex % _characters.length];
    _countdown = isFirstSample ? 2 : 0;
    _captureTimer?.cancel();

    if (_countdown > 0) {
      setState(() {
        _status = 'Look at the ${character.name}! $_countdown';
        _instruction = 'Find the ${character.name}! ${character.emoji}';
      });

      _captureTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_countdown > 0) {
          setState(() {
            _countdown--;
            _status = _countdown > 0
                ? 'Look at the ${character.name}! $_countdown'
                : 'Perfect! Hold still!';
          });
        } else {
          timer.cancel();
          _captureCurrentPoint();
        }
      });
    } else {
      // Quick capture for subsequent samples (every 100ms)
      setState(() {
        _status = 'Keep looking!';
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _isCalibrating) {
          _captureCurrentPoint();
        }
      });
    }
  }

  /// Capture data for current calibration point
  void _captureCurrentPoint() async {
    if (_latestLandmarks == null) {
      setState(() {
        _status = 'Where did you go?‘€ Look at me!';
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _isCalibrating) {
          _startCountdown();
        }
      });
      return;
    }

    // Get target position
    final target = _calibrationPoints[_currentPointIndex];

    // Add training sample to the model
    gazeService.addCalibrationSample(_latestLandmarks!, target);

    _currentPointSamples++;
    _totalSamplesCollected++;

    final character = _characters[_currentPointIndex % _characters.length];
    setState(() {
      _status = 'Looking at ${character.name}!‘';
    });

    // Only log every 5th sample to avoid spam
    if (_currentPointSamples % 5 == 0) {
      print(
          'Calibration: Captured sample #$_totalSamplesCollected for point $_currentPointIndex');
    }

    if (_currentPointSamples >= _samplesPerPoint) {
      // Move to next point
      _currentPointSamples = 0;
      _currentPointIndex++;

      // Show celebration for completing a point!
      _showPointCelebration();

      if (_currentPointIndex >= _calibrationPoints.length) {
        // All points captured - train the model
        _trainModel();
      } else {
        final nextCharacter =
            _characters[_currentPointIndex % _characters.length];
        setState(() {
          _instruction =
              'Now find the ${nextCharacter.name}! ${nextCharacter.emoji}';
        });
        // Short delay before next point to let user see the new position
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted && _isCalibrating) _startCountdown();
        });
      }
    } else {
      // Quickly capture more samples for this point
      _startCountdown();
    }
  }

  /// Train the model with collected data
  void _trainModel() {
    _captureTimer?.cancel();

    setState(() {
      _isTraining = true;
      _status = 'Almost done!¨';
      _instruction = 'Creating your magic vision!';
    });

    // Train the model (this is fast, but we add a small delay for UX)
    Future.delayed(const Duration(milliseconds: 500), () {
      gazeService.finishCalibration();

      final loss = gazeService.trainingLoss;
      final samples = gazeService.trainingSampleCount;
      final isCalibrated = gazeService.isCalibrated;

      setState(() {
        _isCalibrating = false;
        _isTraining = false;
        _calibrationComplete = true;

        if (isCalibrated) {
          _status = 'You did amazing!';
          _instruction = 'Ready for some fun games?®';
        } else {
          _status = 'Good try! Let' 's play anyway!';
          _instruction = 'Time for games!®';
        }
      });

      print(
          'Calibration complete: $samples samples, loss=$loss, isCalibrated=$isCalibrated');
    });
  }

  /// Proceed to games
  void _proceedToGames() {
    widget.onCalibrationComplete();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ButterflyScreen(testId: widget.testId)));
  }

  /// Build instruction screen shown before calibration
  Widget _buildInstructionScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF5F5F5), // Very light grey
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decorative icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility, size: 36, color: Color(0xFF9C27B0)),
                    SizedBox(width: 12),
                    Icon(Icons.gps_fixed, size: 40, color: Color(0xFF7B1FA2)),
                    SizedBox(width: 12),
                    Icon(Icons.visibility, size: 36, color: Color(0xFF9C27B0)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Eye Calibration',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 32),

                // Instructions card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE4EC), // Very light pink tint
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: const Color(0xFFE91E63).withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.gps_fixed,
                              size: 24, color: Color(0xFFEC407A)),
                          SizedBox(width: 8),
                          Text(
                            'How to Play',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEC407A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInstructionItem(
                        Icons.pets,
                        'Look at the animals',
                        'Fun characters will appear on screen',
                      ),
                      const SizedBox(height: 16),
                      _buildInstructionItem(
                        Icons.visibility,
                        'Follow with your eyes',
                        'Look at each character when it appears',
                      ),
                      const SizedBox(height: 16),
                      _buildInstructionItem(
                        Icons.sentiment_satisfied,
                        'Keep your head still',
                        'Try to move only your eyes',
                      ),
                      const SizedBox(height: 16),
                      _buildInstructionItem(
                        Icons.timer,
                        'Wait for the countdown',
                        'Each character stays for a few seconds',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Start button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showInstructions = false;
                      });
                      _initializeGazeTracking();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFEC407A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Start Calibration',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildInstructionItem(
      IconData icon, String title, String description) {
    return Row(
      children: [
        Icon(icon, size: 32, color: const Color(0xFFEC407A)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show instructions screen first
    if (_showInstructions) {
      return _buildInstructionScreen();
    }

    // Clinically calming background colors
    const bgTop = Color(0xFF2C3E50); // Soft dark blue-grey (calming)
    const bgMiddle = Color(0xFF34495E); // Muted slate blue
    const bgBottom = Color(0xFF1A252F); // Deep soft navy

    return Scaffold(
      backgroundColor: bgTop,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient - soft, calming clinical colors
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bgTop,
                  bgMiddle,
                  bgBottom,
                ],
              ),
            ),
          ),

          // Camera preview (dimmed)
          if (_isInitialized && gazeService.cameraController != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.2,
                child: Transform.scale(
                  scaleX: -1,
                  child: gazeService.cameraController!.buildPreview(),
                ),
              ),
            ),

          // Calibration dot
          if (_isCalibrating && !_isTraining) _buildCalibrationDot(),

          // Celebration overlay
          _buildCelebration(),

          // Real-time gaze indicator
          if (_currentGaze != null && _isCalibrating && !_isTraining)
            Builder(
              builder: (context) {
                final screenSize = MediaQuery.of(context).size;
                return Positioned(
                  left: _currentGaze!.dx * screenSize.width - 12,
                  top: _currentGaze!.dy * screenSize.height - 12,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 2),
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                );
              },
            ),

          // Training indicator - using calming clinical colors
          if (_isTraining)
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _softSkyBlue.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _softSkyBlue.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_empty,
                        size: 48, color: Color(0xFF2C3E50)),
                    const SizedBox(height: 16),
                    CircularProgressIndicator(color: _softMint),
                    const SizedBox(height: 20),
                    const Text(
                      'Almost done!',
                      style: TextStyle(
                        color: Color(0xFF2C3E50),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Great job so far!',
                      style: TextStyle(
                        color: Color(0xFF5D6D7E),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Face detection indicator - using soft clinical colors
          if (_latestLandmarks != null && !_isTraining)
            Positioned(
              top: 50,
              left: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _softMint.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sentiment_satisfied,
                        size: 18, color: Color(0xFF2C3E50)),
                    SizedBox(width: 8),
                    Text('I can see you!',
                        style: TextStyle(color: Color(0xFF2C3E50))),
                  ],
                ),
              ),
            )
          else if (_isInitialized && !_isTraining)
            Positioned(
              top: 50,
              left: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _softPeach.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, size: 18, color: Color(0xFF2C3E50)),
                    SizedBox(width: 8),
                    Text('Where are you?',
                        style: TextStyle(color: Color(0xFF2C3E50))),
                  ],
                ),
              ),
            ),

          // DEBUG: Show iris position in real-time - MOVED TO TOP-LEFT to avoid overlap
          if (_latestLandmarks != null && !_isTraining)
            Positioned(
              top: 100, // Below the face detection indicator
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.cyan.withOpacity(0.5), width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility, size: 11, color: Colors.cyan),
                        SizedBox(width: 4),
                        Text(
                          'IRIS',
                          style: TextStyle(
                              color: Colors.cyan,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'L: ${(_latestLandmarks?.leftIrisCenter?.dx ?? 0.5).toStringAsFixed(2)}, ${(_latestLandmarks?.leftIrisCenter?.dy ?? 0.5).toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'monospace'),
                    ),
                    Text(
                      'R: ${(_latestLandmarks?.rightIrisCenter?.dx ?? 0.5).toStringAsFixed(2)}, ${(_latestLandmarks?.rightIrisCenter?.dy ?? 0.5).toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'monospace'),
                    ),
                    if (_latestLandmarks?.leftIrisCenter == null)
                      const Text(
                        'NO IRIS',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ),

          // Instructions and status
          if (!_isTraining)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress indicator
                    if (_isCalibrating)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: LinearProgressIndicator(
                          value: _currentPointIndex / _calibrationPoints.length,
                          backgroundColor: Colors.white24,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),

                    // Status text
                    Text(
                      _status,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Instruction text
                    Text(
                      _instruction,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Action buttons - using clinical soft colors
                    if (!_isCalibrating &&
                        !_calibrationComplete &&
                        _isInitialized)
                      ElevatedButton.icon(
                        onPressed: _startCalibration,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Let' 's Start!'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          backgroundColor: _softTeal,
                          foregroundColor: const Color(0xFF2C3E50),
                          textStyle: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),

                    if (_calibrationComplete)
                      Column(
                        children: [
                          Text(
                            _getChildFriendlyQuality(gazeService.trainingLoss),
                            style: TextStyle(
                              color: _getQualityColor(gazeService.trainingLoss),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _proceedToGames,
                            icon: const Icon(Icons.videogame_asset),
                            label: const Text('Let' 's Play!'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              backgroundColor: _softMint,
                              foregroundColor: const Color(0xFF2C3E50),
                              textStyle: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),

                    if (!_isInitialized)
                      CircularProgressIndicator(color: _softSkyBlue),
                  ],
                ),
              ),
            ),

          // Skip button - highlighted for visibility
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextButton.icon(
                onPressed: () {
                  _captureTimer?.cancel();
                  widget.onCalibrationComplete();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (_) => ButterflyScreen(testId: widget.testId)));
                },
                icon: const Icon(Icons.skip_next, color: Color(0xFF2C3E50)),
                label: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getChildFriendlyQuality(double loss) {
    // Calm, encouraging messages - not overly stimulating
    if (loss < 0.05) return 'Wonderful!';
    if (loss < 0.15) return 'Great job!';
    if (loss < 0.30) return 'Good try!';
    return 'Nice effort!';
  }

  Color _getQualityColor(double loss) {
    // Using soft clinical colors instead of harsh green/red
    if (loss < 0.05) return _softMint;
    if (loss < 0.15) return _softSkyBlue;
    if (loss < 0.30) return _softPeach;
    return _softCoral;
  }

  /// Build the animated calibration target with child-friendly character
  Widget _buildCalibrationDot() {
    final screenSize = MediaQuery.of(context).size;
    final point = _calibrationPoints[_currentPointIndex];
    final character = _characters[_currentPointIndex % _characters.length];

    final dotX = point.dx * screenSize.width;
    final dotY = point.dy * screenSize.height;

    return Positioned(
      left: dotX - 60,
      top: dotY - 60,
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Sparkle ring effect
            AnimatedBuilder(
              animation: _sparkleAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _sparkleAnimation.value,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: character.color.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: Stack(
                      children: List.generate(8, (index) {
                        final angle = (index * 45) * pi / 180;
                        return Positioned(
                          left: 55 + cos(angle) * 50 - 6,
                          top: 55 + sin(angle) * 50 - 6,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: character.color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: character.color.withOpacity(0.5),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),

            // Main character with bounce and pulse
            AnimatedBuilder(
              animation:
                  Listenable.merge([_dotPulseAnimation, _bounceAnimation]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: Transform.scale(
                    scale: _dotPulseAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: character.color.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: character.color, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: character.color.withOpacity(0.6),
                            blurRadius: 25,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          character.emoji,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build celebration overlay when a point is completed
  /// Shows at the position of the completed calibration point
  Widget _buildCelebration() {
    if (!_showCelebration) return const SizedBox.shrink();

    final screenSize = MediaQuery.of(context).size;
    final celebX = _celebrationPosition.dx * screenSize.width;
    final celebY = _celebrationPosition.dy * screenSize.height;

    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        final opacity = 1.0 - _celebrationController.value;
        final scale =
            1.0 + (_celebrationController.value * 0.3); // Gentler scale

        // Float the message upward as it fades
        final yOffset = -30 * _celebrationController.value;

        return Positioned(
          left: celebX - 80,
          top: celebY - 40 + yOffset,
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 160,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _softMint.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _softMint.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Text(
                  _celebrationMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
