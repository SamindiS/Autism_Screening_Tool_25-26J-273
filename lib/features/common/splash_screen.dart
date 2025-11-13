// lib/features/common/splash_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _exitController;
  late final Animation<double> _fade;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoRotate;
  late final Animation<double> _textSlide;
  late final Animation<double> _gradient;
  late final Animation<double> _progress;
  late final Animation<double> _exitFade;

  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: 4.seconds);
    
    // Exit animation controller
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _fade = 0.0.tweenTo(1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.25)),
    );

    _logoScale = 0.0.tweenTo(1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
    );

    _logoRotate = 0.0.tweenTo(1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.75, curve: Curves.elasticOut)),
    );

    _textSlide = 50.0.tweenTo(0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack)),
    );

    _gradient = 0.0.tweenTo(1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeInOut)),
    );

    _progress = 0.0.tweenTo(1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.linear)),
    );

    // Generate 12 particles
    final random = math.Random(42);
    for (int i = 0; i < 12; i++) {
      final angle = i / 12 * 2 * math.pi;
      final distance = 120 + random.nextDouble() * 80;
      final delay = i * 0.1;
      final scale = 0.6 + random.nextDouble() * 0.4;
      _particles.add(_Particle(
        angle: angle,
        distance: distance,
        delay: delay,
        scale: scale,
        color: _getParticleColor(i),
      ));
    }

    // Navigate to login after animation completes
    _controller.forward().then((_) async {
      if (!mounted) return;
      
      // Start exit fade-out animation
      await _exitController.forward();
      
      // Wait a moment for fade to complete
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  Color _getParticleColor(int index) {
    const colors = [
      Color(0xFF60A5FA),
      Color(0xFF3B82F6),
      Color(0xFF2563EB),
      Color(0xFF1D4ED8),
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
    ];
    return colors[index % colors.length];
  }

  @override
  void dispose() {
    _controller.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_controller, _exitController]),
        builder: (context, child) {
          final bgColor = Color.lerp(
            const Color(0xFF1E3A8A),
            const Color(0xFF6366F1),
            _gradient.value,
          )!;

          return Opacity(
            opacity: _exitFade.value,
            child: Container(
            width: double.infinity,
            height: double.infinity,
            color: bgColor,
            child: Stack(
              children: [
                // Background Circles
                _buildBackgroundCircles(),

                // Floating Particles
                ..._particles.map((p) => _buildParticle(p)),

                // Main Content
                Opacity(
                  opacity: _fade.value,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLogo(),
                        const SizedBox(height: 32),
                        _buildTextContent(),
                        const SizedBox(height: 48),
                        _buildLoadingIndicator(),
                      ],
                    ),
                  ),
                ),

                // Version
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: _fade.value,
                    child: Column(
                      children: const [
                        Text(
                          'v1.0.0',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          '© 2024 SenseAI Labs',
                          style: TextStyle(color: Colors.white60, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundCircles() {
    return Stack(
      children: [
        _buildCircle(600, -200, -200),
        _buildCircle(400, null, -100, left: -100),
        _buildCircle(300, 30, 20),
      ],
    );
  }

  Widget _buildCircle(
    double size,
    double? top,
    double? right, {
    double? left,
    double? bottom,
  }) {
    return Positioned(
      top: top,
      right: right,
      left: left,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.03),
        ),
      ),
    );
  }

  Widget _buildParticle(_Particle p) {
    final t = (_controller.value - p.delay).clamp(0.0, 1.0);
    if (t <= 0) return const SizedBox();

    final x = math.cos(p.angle) * p.distance * t;
    final y = math.sin(p.angle) * p.distance * t;

    final pulse = _progress.value < 0.5
        ? 1.0 + 0.2 * (math.sin(_controller.value * 2 * math.pi * 3) * 0.5 + 0.5)
        : 1.0;

    return Transform.translate(
      offset: Offset(x, y),
      child: Transform.scale(
        scale: p.scale * t * pulse,
        child: Opacity(
          opacity: 0.8 * t,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: p.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: p.color.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
        ),

        // Logo
        Transform.scale(
          scale: _logoScale.value,
          child: Transform.rotate(
            angle: _logoRotate.value * 2 * math.pi,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 12),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  'assets/images/CropLogo.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.biotech, size: 80, color: Colors.white),
                ),
              ),
            ),
          ),
        ),

        // Border Glow
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent() {
    return Transform.translate(
      offset: Offset(0, _textSlide.value),
      child: Column(
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
                  color: Color(0x40000000), // black26 → 40% opacity
                  offset: Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Multi-Sensory Behavioral Autism Detection System',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white, // white90 → full white + opacity in parent
                height: 1.4,
                letterSpacing: 0.3,
                shadows: [
                  Shadow(
                    color: Color(0x1A000000), // black12 → 10% opacity
                    offset: Offset(0, 1),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Opacity(
      opacity: _fade.value,
      child: Column(
        children: [
          Container(
            width: 200,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: _progress.value,
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
          const Text(
            'Initializing Intelligence...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final double delay;
  final double scale;
  final Color color;
  _Particle({
    required this.angle,
    required this.distance,
    required this.delay,
    required this.scale,
    required this.color,
  });
}