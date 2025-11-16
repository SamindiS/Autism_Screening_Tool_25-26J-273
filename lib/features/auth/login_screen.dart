import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supercharged/supercharged.dart';
import '../../core/services/auth_service.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _hospitalFocus = FocusNode();
  final _pinFocus = FocusNode();
  final _confirmPinFocus = FocusNode();

  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;
  bool _rememberMe = false;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late AnimationController _successController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _successAnimation;

  // Field focus animations
  final Map<String, AnimationController> _fieldControllers = {};
  final Map<String, Animation<double>> _fieldAnimations = {};

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupFieldAnimations();
    _checkRegistrationStatus();
    _addListeners();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: 800.milliseconds,
    );

    _slideController = AnimationController(
      vsync: this,
      duration: 600.milliseconds,
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: 400.milliseconds,
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: 2000.milliseconds,
    )..repeat();

    _successController = AnimationController(
      vsync: this,
      duration: 1200.milliseconds,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
    Future.delayed(200.milliseconds, () => _scaleController.forward());
  }

  void _setupFieldAnimations() {
    final fields = ['name', 'hospital', 'pin', 'confirmPin'];
    for (final field in fields) {
      final controller = AnimationController(
        vsync: this,
        duration: 300.milliseconds,
      );
      _fieldControllers[field] = controller;
      _fieldAnimations[field] = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }
  }

  void _addListeners() {
    _nameFocus.addListener(() => _fieldControllers['name']!
        .animateTo(_nameFocus.hasFocus ? 1.0 : 0.0));
    _hospitalFocus.addListener(() => _fieldControllers['hospital']!
        .animateTo(_hospitalFocus.hasFocus ? 1.0 : 0.0));
    _pinFocus.addListener(() => _fieldControllers['pin']!
        .animateTo(_pinFocus.hasFocus ? 1.0 : 0.0));
    _confirmPinFocus.addListener(() => _fieldControllers['confirmPin']!
        .animateTo(_confirmPinFocus.hasFocus ? 1.0 : 0.0));
  }

  Future<void> _checkRegistrationStatus() async {
    final isRegistered = await AuthService.isRegistered();
    if (mounted) {
      setState(() => _isLogin = isRegistered);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _loading = true);

    bool success = false;
    String message = '';

    try {
      if (_isLogin) {
        // LOGIN
        success = await AuthService.login(_pinCtrl.text);
        message = success
            ? 'Welcome back!'
            : 'Invalid PIN. Please check and try again.';
      } else {
        // REGISTER
        if (_pinCtrl.text != _confirmPinCtrl.text) {
          setState(() => _loading = false);
          HapticFeedback.heavyImpact();
          _showError('PINs do not match! Please try again.');
          return;
        }

        success = await AuthService.register(
          name: _nameCtrl.text.trim(),
          hospital: _hospitalCtrl.text.trim(),
          pin: _pinCtrl.text,
        );
        message = success
            ? 'Registration successful! Welcome to SenseAI!'
            : 'Registration failed. Please check your connection and try again.';
      }

      setState(() => _loading = false);

      if (success) {
        HapticFeedback.mediumImpact();
        _successController.forward();
        _showSuccess(message);
        await Future.delayed(1000.milliseconds);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const DashboardScreen(),
              transitionDuration: 600.milliseconds,
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
            ),
          );
        }
      } else {
        HapticFeedback.heavyImpact();
        _showError(message);
      }
    } catch (e) {
      setState(() => _loading = false);
      HapticFeedback.heavyImpact();
      _showError('An error occurred. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleMode() {
    HapticFeedback.selectionClick();
    setState(() {
      _isLogin = !_isLogin;
      _pinCtrl.clear();
      _confirmPinCtrl.clear();
      _nameCtrl.clear();
      _hospitalCtrl.clear();
      _formKey.currentState?.reset();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    _successController.dispose();
    for (final controller in _fieldControllers.values) {
      controller.dispose();
    }
    _nameCtrl.dispose();
    _hospitalCtrl.dispose();
    _pinCtrl.dispose();
    _confirmPinCtrl.dispose();
    _nameFocus.dispose();
    _hospitalFocus.dispose();
    _pinFocus.dispose();
    _confirmPinFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E3A8A),
              const Color(0xFF3B82F6),
              const Color(0xFF6366F1),
              const Color(0xFF8B5CF6),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Logo with animation
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildLogo(),
                      ),
                      const SizedBox(height: 40),
                      // Title Card with shimmer
                      _buildTitleCard(),
                      const SizedBox(height: 40),
                      // Form Fields with focus animations
                      _buildFormFields(),
                      const SizedBox(height: 24),
                      // Remember Me (Login only)
                      if (_isLogin) _buildRememberMe(),
                      const SizedBox(height: 32),
                      // Submit Button
                      _buildSubmitButton(),
                      const SizedBox(height: 24),
                      // Toggle Button
                      _buildToggleButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/CropLogo.jpg',
              fit: BoxFit.cover,
              width: 140,
              height: 140,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.white.withOpacity(0.1),
                child: const Icon(
                  Icons.medical_services,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            ),
            // Shimmer effect
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(_shimmerAnimation.value, 0),
                        end: Alignment(_shimmerAnimation.value + 1, 0),
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
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

  Widget _buildTitleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _isLogin ? 'Welcome Back' : 'Create Account',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
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
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isLogin
                ? 'Enter your PIN to access the system'
                : 'Set up your clinician profile',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Name Field (Register only)
        if (!_isLogin) ...[
          _buildAdvancedTextField(
            controller: _nameCtrl,
            focusNode: _nameFocus,
            label: 'Full Name',
            icon: Icons.person_outline,
            fieldKey: 'name',
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Name is required';
              }
              if (v.trim().length < 3) {
                return 'Name must be at least 3 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
        ],

        // Hospital Field (Register only)
        if (!_isLogin) ...[
          _buildAdvancedTextField(
            controller: _hospitalCtrl,
            focusNode: _hospitalFocus,
            label: 'Hospital / Clinic Name',
            icon: Icons.local_hospital_outlined,
            fieldKey: 'hospital',
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Hospital name is required';
              }
              if (v.trim().length < 3) {
                return 'Hospital name must be at least 3 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
        ],

        // PIN Field
        _buildAdvancedTextField(
          controller: _pinCtrl,
          focusNode: _pinFocus,
          label: _isLogin ? 'Enter 4-digit PIN' : 'Create 4-digit PIN',
          icon: Icons.lock_outline,
          fieldKey: 'pin',
          obscureText: _obscurePin,
          isNumber: true,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: Colors.white.withOpacity(0.8),
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _obscurePin = !_obscurePin);
            },
          ),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return 'PIN is required';
            }
            if (v.length != 4) {
              return 'PIN must be exactly 4 digits';
            }
            if (!RegExp(r'^\d{4}$').hasMatch(v)) {
              return 'PIN must contain only numbers';
            }
            return null;
          },
          onChanged: (value) {
            if (value.length == 4 && !_isLogin) {
              _pinFocus.unfocus();
              _confirmPinFocus.requestFocus();
            }
          },
        ),

        // PIN Strength Indicator (Register only)
        if (!_isLogin && _pinCtrl.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildPinStrengthIndicator(),
        ],

        // Confirm PIN Field (Register only)
        if (!_isLogin) ...[
          const SizedBox(height: 20),
          _buildAdvancedTextField(
            controller: _confirmPinCtrl,
            focusNode: _confirmPinFocus,
            label: 'Confirm PIN',
            icon: Icons.lock_outline,
            fieldKey: 'confirmPin',
            obscureText: _obscureConfirmPin,
            isNumber: true,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPin
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.white.withOpacity(0.8),
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _obscureConfirmPin = !_obscureConfirmPin);
              },
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Please confirm your PIN';
              }
              if (v != _pinCtrl.text) {
                return 'PINs do not match';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildAdvancedTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required String fieldKey,
    bool obscureText = false,
    bool isNumber = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    final animation = _fieldAnimations[fieldKey] ?? const AlwaysStoppedAnimation(0.0);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final isFocused = focusNode.hasFocus;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15 + (animation.value * 0.1)),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isFocused
                  ? Colors.white.withOpacity(0.6)
                  : Colors.white.withOpacity(0.2),
              width: isFocused ? 2 : 1.5,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            inputFormatters: isNumber
                ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)]
                : null,
            style: const TextStyle(color: Colors.white, fontSize: 17),
            onChanged: onChanged,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isFocused ? 15 : 16,
              ),
              prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.9)),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              errorStyle: const TextStyle(
                color: Colors.yellow,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            validator: validator,
          ),
        );
      },
    );
  }

  Widget _buildPinStrengthIndicator() {
    final pin = _pinCtrl.text;
    final hasRepeats = pin.length == 4 && pin.split('').toSet().length < 3;
    final isSequential = pin.length == 4 &&
        (pin == '1234' || pin == '4321' || pin == '0000' || pin == '1111');
    
    Color color = Colors.green;
    String text = 'Strong PIN';
    if (hasRepeats || isSequential) {
      color = Colors.orange;
      text = 'Weak PIN - Avoid patterns';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            HapticFeedback.selectionClick();
            setState(() => _rememberMe = value ?? false);
          },
          activeColor: Colors.white,
          checkColor: const Color(0xFF6366F1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Text(
          'Remember me',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          onPrimary: const Color(0xFF6366F1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: _loading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin ? 'LOGIN' : 'REGISTER & CONTINUE',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, size: 22),
                ],
              ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isLogin ? Icons.person_add_outlined : Icons.login_outlined,
            size: 18,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(width: 8),
          Text(
            _isLogin ? 'First time? ' : 'Already registered? ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
            ),
          ),
          GestureDetector(
            onTap: _toggleMode,
            child: Text(
              _isLogin ? 'Register here' : 'Login here',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationThickness: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
