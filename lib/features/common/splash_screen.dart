import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late final AnimationController _gradientCtrl;
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _fadeCtrl;

  // Animations
  late final Animation<double> _gradientAnim;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoRotate;
  late final Animation<double> _textSlide;
  late final Animation<double> _particleAnim;
  late final Animation<double> _fadeAnim;

  // Particles
  final List<_ParticleData> _particles = [];
  final List<AnimationController> _particleControllers = [];
  final List<AnimationController> _particleFadeControllers = [];
  final List<double> _particleScales = [];

  final List<Color> _particleColors = [
    const Color(0xFF60A5FA),
    const Color(0xFF3B82F6),
    const Color(0xFF2563EB),
    const Color(0xFF1D4ED8),
    const Color(0xFF6366F1),
    const Color(0xFF8B5CF6),
  ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    // 1. Gradient background (2 seconds)
    _gradientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _gradientAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _gradientCtrl, curve: Curves.easeInOut),
    );

    // 2. Logo scale + rotation (3 seconds with spring)
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _logoScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoRotate = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );

    // 3. Text slide up (1.2 seconds)
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _textSlide = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutBack),
    );

    // 4. Particle animation (1.5 seconds)
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _particleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _particleCtrl, curve: Curves.linear),
    );

    // 5. Fade out controller
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut),
    );

    // Initialize particles
    _initializeParticles();

    // Start all animations
    _startAll();
  }

  void _initializeParticles() {
    final random = math.Random();
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi;
      final distance = 120 + random.nextDouble() * 80;
      final delay = i * 100;
      final scale = 0.6 + random.nextDouble() * 0.4;

      final particleCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );

      final fadeCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );

      _particleControllers.add(particleCtrl);
      _particleFadeControllers.add(fadeCtrl);
      _particleScales.add(scale);

      _particles.add(_ParticleData(
        angle: angle,
        distance: distance,
        delay: delay,
        color: _particleColors[i % _particleColors.length],
        scaleController: particleCtrl,
        fadeController: fadeCtrl,
      ));
    }
  }

  void _startAll() {
    // Start gradient
    _gradientCtrl.forward();

    // Start logo and text after small delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _logoCtrl.forward();
      _textCtrl.forward();
    });

    // Start particles after logo animation
    _logoCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _startParticles();
      }
    });

    // Auto exit after 4 seconds
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        _exit();
      }
    });
  }

  void _startParticles() {
    _particleCtrl.forward();

    // Animate each particle with delay
    for (int i = 0; i < _particles.length; i++) {
      final particle = _particles[i];
      Future.delayed(Duration(milliseconds: particle.delay), () {
        if (mounted) {
          _particleControllers[i].forward();
        }
      });
    }
  }

  void _exit() {
    // Fade out particles
    for (final fadeCtrl in _particleFadeControllers) {
      fadeCtrl.forward();
    }

    // Fade out main content
    _fadeCtrl.forward();

    // Navigate to login after fade
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _gradientCtrl.dispose();
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _particleCtrl.dispose();
    _fadeCtrl.dispose();
    for (final ctrl in _particleControllers) {
      ctrl.dispose();
    }
    for (final ctrl in _particleFadeControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _gradientCtrl,
        _logoCtrl,
        _textCtrl,
        _particleCtrl,
        _fadeCtrl,
      ]),
      builder: (_, __) {
        final bgColor = Color.lerp(
          COLORS.primary,
          COLORS.secondary,
          _gradientAnim.value,
        )!;

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Background circles
              _buildBgCircles(),

              // Particles
              ..._buildParticles(),

              // Main Content
              FadeTransition(
                opacity: _fadeAnim,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo with glow + rotation
                      _buildLogo(),
                      const SizedBox(height: SPACING.xxl),

                      // Text
                      Transform.translate(
                        offset: Offset(0, _textSlide.value),
                        child: _buildText(),
                      ),

                      const SizedBox(height: SPACING.xl),

                      // Loading bar
                      _buildLoadingBar(),
                    ],
                  ),
                ),
              ),

              // Version info
              Positioned(
                bottom: SPACING.xl,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: const [
                      Text(
                        'v1.0.0',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '© 2024 SenseAI Labs',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBgCircles() {
    return Stack(
      children: [
        Positioned(
          top: -200,
          right: -200,
          child: Container(
            width: 600,
            height: 600,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x05FFFFFF),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x05FFFFFF),
            ),
          ),
        ),
        Positioned(
          top: 200,
          left: 80,
          child: Container(
            width: 300,
            height: 300,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x05FFFFFF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 0,
              ),
            ],
          ),
        ),

        // Rotating + scaling logo
        Transform.scale(
          scale: _logoScale.value,
          child: Transform.rotate(
            angle: _logoRotate.value * 2 * math.pi,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 3,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 12),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  'assets/images/CropLogo.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.white.withOpacity(0.1),
                    child: const Icon(
                      Icons.healing,
                      size: 90,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Border effect
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildText() {
    return Column(
      children: [
        const Text(
          'SenseAI',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Multi-Sensory Behavioral Autism Detection System',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            height: 1.4,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 1),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingBar() {
    return Column(
      children: [
        Container(
          width: 200,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.24),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: _particleAnim.value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Initializing Intelligence...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildParticles() {
    final widgets = <Widget>[];
    for (int i = 0; i < _particles.length; i++) {
      final particle = _particles[i];
      final scaleCtrl = _particleControllers[i];
      final fadeCtrl = _particleFadeControllers[i];
      final baseScale = _particleScales[i];

      widgets.add(
        AnimatedBuilder(
          animation: Listenable.merge([scaleCtrl, fadeCtrl, _particleAnim]),
          builder: (_, __) {
            final scale = scaleCtrl.value * baseScale;
            final pulse = _particleAnim.value < 0.5
                ? 1 + _particleAnim.value * 0.2
                : 1.2 - (_particleAnim.value - 0.5) * 0.2;

            final dx = math.cos(particle.angle) * particle.distance * scaleCtrl.value;
            final dy = math.sin(particle.angle) * particle.distance * scaleCtrl.value;

            return Positioned.fill(
              child: Center(
                child: Transform.translate(
                  offset: Offset(dx, dy),
                  child: Opacity(
                    opacity: fadeCtrl.isCompleted
                        ? 0
                        : scaleCtrl.value * 0.8 * (1 - fadeCtrl.value),
                    child: Transform.scale(
                      scale: scale * pulse,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: particle.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: particle.color.withOpacity(0.6),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    return widgets;
  }
}

// Helper class for particle data
class _ParticleData {
  final double angle;
  final double distance;
  final int delay;
  final Color color;
  final AnimationController scaleController;
  final AnimationController fadeController;

  _ParticleData({
    required this.angle,
    required this.distance,
    required this.delay,
    required this.color,
    required this.scaleController,
    required this.fadeController,
  });
}
