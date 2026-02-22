/// =============================================================================
/// SenseAI - Clinical Gaze Tracking for Autism Screening
/// =============================================================================
///
/// Main entry point for the Flutter mobile application.
///
/// This app provides interactive games that assess gaze patterns in children
/// aged 2-6 for early autism screening. It uses the front-facing camera with
/// ML Kit face detection to track eye movements during gameplay.
///
/// Key Screens:
/// - SplashScreen: App introduction with logo animation
/// - EntryForm: Collect child information (name, age)
/// - CalibrationScreen: 9-point eye calibration
/// - ButterflyGameScreen: Smooth pursuit tracking test (15s)
/// - BubblesGameScreen: Visual attention test (30s)
/// - ResultsScreen: Display risk assessment and download PDF report
///
/// Author: SenseAI Research Team
/// Version: 2.0.0
/// =============================================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'widgets/animated_butterfly.dart';
import 'widgets/interactive_bubbles.dart';
import 'tflite/tflite_scaffold.dart';
import 'tflite/gaze_model.dart';
import 'gaze/data_collection_screen.dart';
import 'gaze/gaze_calibration_screen.dart';
import 'gaze/gaze_service.dart';
import 'screens/social_object_test_screen.dart';

/// Backend API base URL - update this to your server's IP address
const String API_BASE =
    'http://172.28.31.114:8000'; // change for device testing

// =============================================================================
// SENSEAI BRAND COLORS (extracted from logo)
// =============================================================================
class SenseAIColors {
  // Primary brand colors from logo
  static const Color primaryOrange = Color(0xFFF5A623);
  static const Color primaryBlue = Color(0xFF2C3E7B);
  static const Color puzzleTeal = Color(0xFF4ECDC4);
  static const Color puzzlePink = Color(0xFFE88B9C);
  static const Color puzzleBlue = Color(0xFF5B7DB1);
  static const Color nodeOrange = Color(0xFFE86B4A);
  static const Color nodeTeal = Color(0xFF4ECDC4);

  // Soft clinical variations (for children)
  static const Color softTeal = Color(0xFF88D8D8);
  static const Color softPink = Color(0xFFF7CAC9);
  static const Color softBlue = Color(0xFF87CEEB);
  static const Color softOrange = Color(0xFFFFDAB9);

  // Background colors
  static const Color bgLight = Color(0xFFF5F5F5);
  static const Color bgDark = Color(0xFF2C3E50);

  // App bar color - softer teal that matches the palette
  static const Color appBarColor = Color(0xFF4ECDC4);
}

void main() {
  runApp(const SenseAiApp());
}

class SenseAiApp extends StatelessWidget {
  const SenseAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SenseAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: SenseAIColors.primaryBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: SenseAIColors.primaryBlue,
          primary: SenseAIColors.primaryBlue,
          secondary: SenseAIColors.puzzleTeal,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: SenseAIColors.appBarColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: SenseAIColors.softTeal,
            foregroundColor: SenseAIColors.primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// =============================================================================
// SPLASH SCREEN WITH LOGO
// =============================================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Auto-navigate after animation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const EntryForm()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SenseAIColors.bgLight,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo placeholder - will show actual logo when image is added
                    _buildLogo(),
                    const SizedBox(height: 24),
                    // App name
                    const Text(
                      'SenseAI',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: SenseAIColors.primaryBlue,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tagline
                    Text(
                      'Multi-Sensory Behavioral Autism\nDetection System',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: SenseAIColors.primaryBlue.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Loading indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          SenseAIColors.puzzleTeal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo() {
    // Load the square logo (without text) for splash screen
    return Image.asset(
      'assets/logo/Logo2_without_text.jpg',
      width: 150,
      height: 150,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback: Create a styled logo placeholder matching the brand
        return Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: SenseAIColors.primaryBlue.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Puzzle pieces representation
              const Icon(
                Icons.psychology,
                size: 80,
                color: SenseAIColors.primaryOrange,
              ),
              Positioned(
                top: 25,
                right: 25,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: SenseAIColors.nodeOrange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 15,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: SenseAIColors.puzzleTeal,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// ENTRY FORM (Child Info)
// =============================================================================

class EntryForm extends StatefulWidget {
  const EntryForm({super.key});

  @override
  State<EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? testId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Reset everything for a new test
    _resetForNewTest();
  }

  void _resetForNewTest() {
    // Clear the form fields
    _nameController.clear();
    _ageController.clear();
    testId = null;

    // Reset the gaze service calibration for a fresh start
    if (gazeService.isInitialized) {
      gazeService.resetForNewTest();
    }

    debugPrint('EntryForm: Reset for new test');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _startTest() async {
    final name = _nameController.text.trim();
    final ageText = _ageController.text.trim();

    // Validate inputs
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter a name')));
      return;
    }
    if (ageText.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter an age')));
      return;
    }

    final age = int.tryParse(ageText) ?? 0;

    setState(() => _loading = true);

    try {
      final payload = {
        'name': name,
        'age': age,
        'test_datetime': DateTime.now().toIso8601String()
      };
      debugPrint('Submitting info: $payload');
      final res = await http
          .post(
            Uri.parse('$API_BASE/submit_info'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() {
          testId = body['test_id'];
        });
        final currentTestId = testId!;
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => GazeCalibrationScreen(
                  testId: currentTestId,
                  onCalibrationComplete: () {
                    // Calibration complete - GazeCalibrationScreen navigates to ButterflyScreen internally
                  },
                )));
      } else {
        debugPrint('Server error: ${res.statusCode} - ${res.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Server error: ${res.statusCode} - ${res.body}')));
      }
    } catch (e) {
      // If backend is not available, use offline mode with a generated test ID
      debugPrint('Connection error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Offline mode: $e')));
      // Generate a local test ID and proceed anyway
      final offlineTestId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
      Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => GazeCalibrationScreen(
                testId: offlineTestId,
                onCalibrationComplete: () {
                  // Calibration complete - GazeCalibrationScreen navigates to ButterflyScreen internally
                },
              )));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SenseAIColors.bgLight,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/logo/Logo2_without_text.jpg',
                height: 32,
                width: 32,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.psychology, size: 28),
              ),
            ),
            const SizedBox(width: 10),
            const Text('SenseAI'),
          ],
        ),
        actions: [
          // Developer menu for data collection
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'collect_data') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DataCollectionScreen()),
                );
              } else if (value == 'social_object') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SocialObjectTestScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'collect_data',
                child: Row(
                  children: [
                    Icon(Icons.camera_alt, color: SenseAIColors.primaryBlue),
                    SizedBox(width: 8),
                    Text('Collect Training Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'social_object',
                child: Row(
                  children: [
                    Icon(Icons.face, color: SenseAIColors.primaryBlue),
                    SizedBox(width: 8),
                    Text('Social vs Object Test'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo and welcome section
              const SizedBox(height: 20),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/logo/Logo2_without_text.jpg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: SenseAIColors.primaryBlue.withOpacity(0.1),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology,
                        size: 60,
                        color: SenseAIColors.primaryOrange,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Child Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: SenseAIColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Please enter the child\'s details to begin',
                  style: TextStyle(
                    fontSize: 14,
                    color: SenseAIColors.primaryBlue.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Form card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: SenseAIColors.primaryBlue.withOpacity(0.08),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Child\'s Name',
                        prefixIcon: const Icon(Icons.person_outline,
                            color: SenseAIColors.puzzleTeal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: SenseAIColors.puzzleTeal, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ageController,
                      decoration: InputDecoration(
                        labelText: 'Age (years)',
                        prefixIcon: const Icon(Icons.cake_outlined,
                            color: SenseAIColors.puzzlePink),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: SenseAIColors.puzzlePink, width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _startTest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SenseAIColors.puzzleTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ))
                            : const Text(
                                'Start Assessment',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Info section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SenseAIColors.softTeal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: SenseAIColors.puzzleTeal.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: SenseAIColors.puzzleTeal,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The assessment includes fun visual games to analyze gaze patterns. It takes about 5-10 minutes.',
                        style: TextStyle(
                          color: SenseAIColors.primaryBlue.withOpacity(0.7),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CalibrationScreen extends StatefulWidget {
  final String testId;
  const CalibrationScreen({required this.testId, super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  int step = 0;
  Map<String, dynamic> calib = {};
  // calibration samples
  final List<List<double>> _preds = [];
  final List<List<double>> _trues = [];
  final TFLiteScaffold _tflite = TFLiteScaffold();

  @override
  void initState() {
    super.initState();
    // ensure model ready
    _tflite.loadModel();
  }

  void _next() async {
    // when pressing Next, record one calibration sample: ask model for current gaze
    // target position (normalized) for the current step
    final targets = [
      [0.1, 0.1],
      [0.9, 0.1],
      [0.5, 0.9]
    ];
    final tpos = targets[step % targets.length];
    // sample model prediction (currently stub)
    final pred = await _tflite.predictGaze();
    _preds.add(pred);
    _trues.add([tpos[0], tpos[1]]);
    setState(() {
      step += 1;
    });
    if (step >= targets.length) {
      // fit affine
      try {
        final calib = GazeCalibrator.fitAffine(_preds, _trues);
        appCalibrator.setCalibration(calib);
      } catch (e) {
        // ignore, use identity
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ButterflyScreen(testId: widget.testId)));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dot positions: top-left, top-right, bottom-center
    final dotPositions = [
      const Alignment(-0.8, -0.8), // top-left
      const Alignment(0.8, -0.8), // top-right
      const Alignment(0.0, 0.8), // bottom-center
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Calibration')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Look at the dot: ${step + 1}/3',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: dotPositions[step % dotPositions.length],
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              ),
              child: Text(step < 2 ? 'Next' : 'Start Games'),
            ),
          ),
        ],
      ),
    );
  }
}

class ButterflyScreen extends StatefulWidget {
  final String testId;
  const ButterflyScreen({required this.testId, super.key});

  @override
  State<ButterflyScreen> createState() => _ButterflyScreenState();
}

class _ButterflyScreenState extends State<ButterflyScreen> {
  bool _showInstructions = true; // Show instructions first
  final List<Map<String, dynamic>> events = [];
  Timer? _tickTimer;
  final int durationSec = 15; // 15 seconds for butterfly game
  late DateTime _startTime;
  int _remainingSeconds = 15;
  bool _gameFinished = false;

  // Real gaze tracking
  StreamSubscription<GazeData>? _gazeSubscription;
  Offset? _currentGaze;
  bool _gazeTrackingActive = false;
  String _debugStatus = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _remainingSeconds = durationSec;
    // Don't start game automatically - wait for instructions to be dismissed
  }

  void _startGame() {
    setState(() {
      _showInstructions = false;
    });
    _startTime = DateTime.now();
    _initGazeTracking();
    // Use a simple 1-second timer for countdown
    _tickTimer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  Future<void> _initGazeTracking() async {
    try {
      setState(() => _debugStatus = 'Checking gaze service...');

      // Initialize gaze service if not already done
      if (!gazeService.isInitialized) {
        setState(() => _debugStatus = 'Initializing gaze service...');
        await gazeService.initialize();
      }

      // Start tracking if not already
      if (!gazeService.isTracking) {
        setState(() => _debugStatus = 'Starting gaze tracking...');
        await gazeService.startTracking();
      }

      setState(() => _debugStatus = 'Subscribing to gaze stream...');

      // Subscribe to gaze stream
      _gazeSubscription = gazeService.gazeStream.listen((gazeData) {
        if (mounted && !_gameFinished) {
          setState(() {
            // Update face detection status and gaze position
            _gazeTrackingActive = gazeData.faceDetected;
            if (gazeData.faceDetected) {
              _currentGaze = gazeData.position;
              _debugStatus =
                  'Gaze: (${gazeData.position.dx.toStringAsFixed(2)}, ${gazeData.position.dy.toStringAsFixed(2)})';
            } else {
              _currentGaze = null; // Hide gaze indicator when face lost
              _debugStatus = 'No face detected';
            }
          });
        }
      });

      setState(() {
        _gazeTrackingActive = gazeService.faceDetected;
        _debugStatus = 'Gaze tracking active!';
      });
    } catch (e) {
      setState(() => _debugStatus = 'Gaze error: $e');
      debugPrint('Gaze tracking error: $e');
    }
  }

  void _tick(Timer t) {
    if (_gameFinished) {
      t.cancel();
      return;
    }

    final elapsed = DateTime.now().difference(_startTime).inSeconds;
    final remaining = durationSec - elapsed;

    if (remaining <= 0) {
      _finish();
    } else {
      setState(() {
        _remainingSeconds = remaining;
      });
    }
  }

  void _handleSample(double gxPx, double gyPx, double txNorm, double tyNorm) {
    // Use real gaze if available, otherwise use widget's simulated gaze
    final box = context.findRenderObject() as RenderBox?;
    final w = box?.size.width ?? 1.0;
    final h = box?.size.height ?? 1.0;

    double gazeX, gazeY;
    if (_currentGaze != null) {
      // Use real gaze tracking
      gazeX = _currentGaze!.dx;
      gazeY = _currentGaze!.dy;
    } else {
      // Use simulated gaze (from widget callback)
      gazeX = (gxPx / w).clamp(0.0, 1.0);
      gazeY = (gyPx / h).clamp(0.0, 1.0);
    }

    final e = {
      'timestamp': DateTime.now().millisecondsSinceEpoch / 1000.0,
      'x': gazeX,
      'y': gazeY,
      'target_x': txNorm,
      'target_y': tyNorm,
      'game': 'butterfly',
      'real_gaze': _currentGaze != null,
    };
    events.add(e);
    if (events.length > 400) events.removeAt(0);
  }

  void _finish() async {
    if (_gameFinished) return; // Prevent double-finish
    _gameFinished = true;

    _tickTimer?.cancel();
    _gazeSubscription?.cancel();

    // Navigate to next screen immediately, upload in background
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => BubblesScreen(testId: widget.testId, score: 0.0)));

    // Upload data in background (don't wait)
    try {
      final res = await http
          .post(
            Uri.parse('$API_BASE/upload_gaze'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'test_id': widget.testId, 'events': events}),
          )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        debugPrint('Butterfly game: Data uploaded successfully');
      }
    } catch (e) {
      debugPrint('Butterfly game: Upload failed (offline mode): $e');
    }
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _gazeSubscription?.cancel();
    super.dispose();
  }

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
                // Decorative butterfly icons
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🦋', style: TextStyle(fontSize: 40)),
                    SizedBox(width: 16),
                    Text('🌸', style: TextStyle(fontSize: 40)),
                    SizedBox(width: 16),
                    Text('🦋', style: TextStyle(fontSize: 40)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Butterfly Game',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FFF0), // Very light green tint
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3)),
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
                      const Text(
                        '🌿 How to Play',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInstructionItem('🦋', 'Watch the butterfly',
                          'A colorful butterfly will fly around'),
                      const SizedBox(height: 16),
                      _buildInstructionItem('👀', 'Follow with your eyes',
                          'Try to look at where it goes'),
                      const SizedBox(height: 16),
                      _buildInstructionItem('🌸', 'Visit the flowers',
                          'The butterfly loves flowers!'),
                      const SizedBox(height: 16),
                      _buildInstructionItem(
                          '⏱️', '15 seconds', 'The game lasts 15 seconds'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Start Game',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  Widget _buildInstructionItem(String emoji, String title, String description) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50))),
              Text(description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showInstructions) {
      return _buildInstructionScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Follow the Butterfly'),
        actions: [
          // Gaze status indicator
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _gazeTrackingActive ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _gazeTrackingActive ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _gazeTrackingActive ? 'Tracking' : 'No Face',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background - soft green gradient matching butterfly widget
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8F5E9), // Light green (starts higher)
                  Color(0xFFC8E6C9), // Soft mint green
                  Color(0xFFA5D6A7), // Gentle green
                ],
              ),
            ),
          ),

          // Butterfly animation
          AnimatedButterfly(onSample: _handleSample),

          // Progress bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 80,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value:
                      (1.0 - (_remainingSeconds / durationSec)).clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withOpacity(0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_remainingSeconds}s remaining',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          // Debug status (shows gaze tracking state)
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _debugStatus,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),

          // Skip button
          Positioned(
            right: 16,
            bottom: 16,
            child: ElevatedButton(
              onPressed: _finish,
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }
}

class BubblesScreen extends StatefulWidget {
  final String testId;
  final double? score;
  const BubblesScreen({required this.testId, this.score, super.key});

  @override
  State<BubblesScreen> createState() => _BubblesScreenState();
}

class _BubblesScreenState extends State<BubblesScreen> {
  bool _showInstructions = true; // Show instructions first
  final List<Map<String, dynamic>> events = [];

  // Real gaze tracking
  StreamSubscription<GazeData>? _gazeSubscription;
  Offset? _currentGaze;
  bool _gazeTrackingActive = false;
  bool _gameFinished = false;

  // Game duration
  final int durationSec = 30; // 30 seconds for bubble game
  int _remainingSeconds = 30;
  late DateTime _startTime;
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = durationSec;
    // Don't start game automatically - wait for instructions
  }

  void _startGame() {
    setState(() {
      _showInstructions = false;
    });
    _startTime = DateTime.now();
    _initGazeTracking();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_gameFinished) {
        t.cancel();
        return;
      }

      final elapsed = DateTime.now().difference(_startTime).inSeconds;
      final remaining = durationSec - elapsed;

      if (remaining <= 0) {
        _finish();
      } else {
        setState(() {
          _remainingSeconds = remaining;
        });
      }
    });
  }

  Future<void> _initGazeTracking() async {
    try {
      // Make sure gaze service is initialized and tracking
      if (!gazeService.isInitialized) {
        await gazeService.initialize();
      }

      if (!gazeService.isTracking) {
        await gazeService.startTracking();
      }

      // Subscribe to gaze stream
      _gazeSubscription = gazeService.gazeStream.listen((gazeData) {
        if (mounted && !_gameFinished) {
          setState(() {
            // Update face detection status and gaze position
            _gazeTrackingActive = gazeData.faceDetected;
            if (gazeData.faceDetected) {
              _currentGaze = gazeData.position;
            } else {
              _currentGaze = null; // Hide gaze indicator when face lost
            }
          });

          // Record gaze event with current bubble positions (only if face detected)
          if (gazeData.faceDetected) {
            _recordGazeEvent(gazeData);
          }
        }
      });

      setState(() {
        _gazeTrackingActive = gazeService.faceDetected;
      });
    } catch (e) {
      debugPrint('Gaze tracking error in bubbles: $e');
    }
  }

  void _recordGazeEvent(GazeData gazeData) {
    final e = {
      'timestamp': DateTime.now().millisecondsSinceEpoch / 1000.0,
      'x': gazeData.position.dx,
      'y': gazeData.position.dy,
      'real_gaze': true,
      'game': 'bubbles',
    };
    events.add(e);
    if (events.length > 800) events.removeAt(0);
  }

  void _onBubbleEvent(Map<String, dynamic> e) {
    // Add gaze position to bubble event if available
    if (_currentGaze != null) {
      e['gaze_x'] = _currentGaze!.dx;
      e['gaze_y'] = _currentGaze!.dy;
      e['real_gaze'] = true;
    }
    events.add(e);
    if (events.length > 800) events.removeAt(0);
  }

  void _finish() async {
    if (_gameFinished) return; // Prevent double-finish
    _gameFinished = true;

    _tickTimer?.cancel();
    _gazeSubscription?.cancel();

    // Show loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Analyzing gaze data...'),
            ],
          ),
        ),
      );
    }

    // Upload data and wait for analysis
    double score = 0.0;
    try {
      final res = await http
          .post(
            Uri.parse('$API_BASE/upload_gaze'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'test_id': widget.testId, 'events': events}),
          )
          .timeout(const Duration(seconds: 30)); // Longer timeout for analysis

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        score = (data['score'] ?? 0.0).toDouble();
        debugPrint('Bubbles game: Data uploaded successfully, score: $score');
      }
    } catch (e) {
      debugPrint('Bubbles game: Upload failed (offline mode): $e');
    }

    // Close loading dialog and navigate to results
    if (mounted) {
      Navigator.of(context).pop(); // Close loading dialog
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ResultsScreen(testId: widget.testId, score: score)));
    }
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _gazeSubscription?.cancel();
    super.dispose();
  }

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
                // Decorative bubble icons
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🫧', style: TextStyle(fontSize: 36)),
                    SizedBox(width: 12),
                    Text('✨', style: TextStyle(fontSize: 40)),
                    SizedBox(width: 12),
                    Text('🫧', style: TextStyle(fontSize: 36)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bubble Pop Game',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA), // Very light cyan tint
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: const Color(0xFF00ACC1).withOpacity(0.3)),
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
                      const Text(
                        '🎯 How to Play',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00838F),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInstructionItem('🫧', 'See the bubbles',
                          'Colorful bubbles will float on screen'),
                      const SizedBox(height: 16),
                      _buildInstructionItem('👆', 'Tap to pop!',
                          'Touch the bubbles to pop them!'),
                      const SizedBox(height: 16),
                      _buildInstructionItem(
                          '🎉', 'Have fun!', 'Pop as many bubbles as you can!'),
                      const SizedBox(height: 16),
                      _buildInstructionItem(
                          '⏱️', '30 seconds', 'The game lasts 30 seconds'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00ACC1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Start Game',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  Widget _buildInstructionItem(String emoji, String title, String description) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50))),
              Text(description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showInstructions) {
      return _buildInstructionScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pop the Bubbles'),
        actions: [
          // Gaze status indicator
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _gazeTrackingActive ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _gazeTrackingActive ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _gazeTrackingActive ? 'Tracking' : 'No Face',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Bubbles game - now gaze-controlled!
          InteractiveBubbles(
            onEvent: _onBubbleEvent,
            useCamera: true,
            modelEnabled: gazeService.isCalibrated,
          ),

          // Progress bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 80,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value:
                      (1.0 - (_remainingSeconds / durationSec)).clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withOpacity(0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_remainingSeconds}s remaining',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          // Gaze tracking is hidden - data collected in background
          // No visible instructions needed for touch-based bubble popping

          // Skip button
          Positioned(
            right: 16,
            bottom: 16,
            child: ElevatedButton(
              onPressed: _finish,
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }
}

class ResultsScreen extends StatelessWidget {
  final String testId;
  final double score;
  const ResultsScreen({required this.testId, required this.score, super.key});

  Future<void> _downloadReport(BuildContext context) async {
    final url = Uri.parse('$API_BASE/report/$testId/download');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Could not open report. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _getRiskCategory(double score) {
    if (score >= 80) return 'Low Risk';
    if (score >= 60) return 'Moderate - Further Evaluation Recommended';
    if (score >= 40) return 'Elevated Risk - Professional Consultation Advised';
    return 'High Risk - Immediate Professional Evaluation Recommended';
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screening Results')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Test Complete!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Score display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getScoreColor(score).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _getScoreColor(score), width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'Overall Score',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${score.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(score),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getRiskCategory(score),
                    style: TextStyle(
                      fontSize: 14,
                      color: _getScoreColor(score),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'Test ID: ${testId.substring(0, 8)}...',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),

            const SizedBox(height: 30),
            const Text(
              'A detailed PDF report has been generated with:\n'
              '• Attention analysis\n'
              '• Fixation patterns\n'
              '• Tracking ability\n'
              '• Clinical recommendations',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _downloadReport(context),
                icon: const Icon(Icons.download),
                label: const Text('Download PDF Report'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Reset gaze service before going back to start fresh
                  if (gazeService.isInitialized) {
                    gazeService.resetForNewTest();
                  }
                  // Navigate back to the first screen (EntryForm)
                  // Use pushAndRemoveUntil to create a fresh instance
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const EntryForm()),
                    (route) => false, // Remove all routes
                  );
                },
                child: const Text('Start New Test'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
