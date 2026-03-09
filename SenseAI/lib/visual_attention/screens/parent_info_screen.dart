import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../gaze/gaze_calibration_screen.dart';
import '../models/parent_info.dart';
import '../theme.dart';

/// Parent Information Screen
/// 
/// Collects parent/guardian information after child information is entered.
/// This screen appears between ChildInfoScreen and CalibrationScreen.
class ParentInfoScreen extends StatefulWidget {
  final String childName;
  final int childAge;
  final String testDateTime;

  const ParentInfoScreen({
    required this.childName,
    required this.childAge,
    required this.testDateTime,
    super.key,
  });

  @override
  State<ParentInfoScreen> createState() => _ParentInfoScreenState();
}

class _ParentInfoScreenState extends State<ParentInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _relationship;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return 'Parent/guardian name is required';
    }
    if (v.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return 'Email is required';
    }
    // Basic email validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(v)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    // Remove spaces for validation
    final v = (value ?? '').replaceAll(RegExp(r'\s+'), '');
    if (v.isEmpty) {
      return 'Phone number is required';
    }
    // Allow + and digits, 9-15 digits total
    final phoneRegex = RegExp(r'^\+?[0-9]{9,15}$');
    if (!phoneRegex.hasMatch(v)) {
      return 'Please enter a valid phone number (9-15 digits)';
    }
    return null;
  }

  String _normalizePhone(String value) {
    // Remove spaces, keep + and digits
    return value.replaceAll(RegExp(r'\s+'), '');
  }

  Future<bool> _trySubmitAndNavigate(Map<String, dynamic> payload) async {
    // Step 1: Quick health check - fail fast if backend unreachable
    try {
      debugPrint('Checking server connectivity...');
      final healthRes = await http
          .get(Uri.parse('$API_BASE/health'))
          .timeout(const Duration(seconds: 8));
      if (healthRes.statusCode != 200) {
        debugPrint('Health check failed: ${healthRes.statusCode}');
        return false;
      }
      debugPrint('Server reachable, submitting...');
    } catch (e) {
      debugPrint('Health check failed (server unreachable): $e');
      return false;
    }

    // Step 2: Submit with longer timeout and retries
    const connectTimeout = Duration(seconds: 25);
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        debugPrint('Submitting (attempt ${attempt + 1}/3)...');
        final res = await http
            .post(
              Uri.parse('$API_BASE/submit_info'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
            .timeout(connectTimeout);

        if (res.statusCode == 200) {
          final body = jsonDecode(res.body);
          final testId = body['test_id'] as String;
          if (!mounted) return true;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => GazeCalibrationScreen(
                testId: testId,
                onCalibrationComplete: () {},
              ),
            ),
          );
          return true;
        } else {
          if (!mounted) return true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Server error: ${res.statusCode}'),
              duration: const Duration(seconds: 4),
            ),
          );
          return true;
        }
      } catch (e) {
        debugPrint('Submit error (attempt ${attempt + 1}): $e');
        if (attempt < 2) {
          await Future.delayed(const Duration(milliseconds: 800));
        }
      }
    }
    return false;
  }

  void _showConnectionErrorDialog(Map<String, dynamic> payload) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Connection Failed'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cannot reach the backend server.',
                style: Theme.of(ctx).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Connecting to: $API_BASE',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Fix steps:\n\n'
                '1. On PC: Run run_backend.ps1 (keep it open)\n'
                '2. On PC: Run allow_backend_firewall.ps1 as Administrator (one-time)\n'
                '3. Same WiFi: Phone and PC on same network\n'
                '4. Correct IP: Run ipconfig on PC. If IP differs, edit lib/theme.dart',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                'Verify: Open $API_BASE/health in PC browser.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (!mounted) return;
              final offlineTestId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => GazeCalibrationScreen(
                    testId: offlineTestId,
                    onCalibrationComplete: () {},
                  ),
                ),
              );
            },
            child: const Text('Continue Offline'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Retrying connection...'),
                  duration: Duration(seconds: 2),
                ),
              );
              final ok = await _trySubmitAndNavigate(payload);
              if (mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              }
              if (!ok && mounted) {
                _showConnectionErrorDialog(payload);
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final parentInfo = ParentInfo(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _normalizePhone(_phoneController.text),
      relationship: _relationship!.trim(),
    );

    final payload = {
      'name': widget.childName,
      'age': widget.childAge,
      'test_datetime': widget.testDateTime,
      'parent': parentInfo.toJson(),
    };

    setState(() => _submitting = true);

    try {
      final ok = await _trySubmitAndNavigate(payload);
      if (!ok && mounted) {
        _showConnectionErrorDialog(payload);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SenseAIColors.bgLight,
      appBar: AppBar(
        title: const Text('Parent Information'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          SenseAIColors.softBlue,
                          SenseAIColors.softOrange,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: SenseAIColors.puzzleBlue.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/logo/Logo2_without_text.jpg',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.family_restroom,
                            size: 70,
                            color: SenseAIColors.primaryOrange,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: const Text(
                    'Parent/Guardian Information',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: SenseAIColors.primaryBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Tell us about the parent or guardian',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: SenseAIColors.primaryBlue.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Form card
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Parent/Guardian Name',
                          labelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: SenseAIColors.puzzleTeal,
                          ),
                          prefixIcon: const Icon(Icons.person_outline,
                              color: SenseAIColors.puzzleTeal, size: 28),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: SenseAIColors.puzzleTeal, width: 3),
                          ),
                          filled: true,
                          fillColor: SenseAIColors.softTeal.withOpacity(0.2),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: _validateName,
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: SenseAIColors.puzzlePink,
                          ),
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: SenseAIColors.puzzlePink, size: 28),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: SenseAIColors.puzzlePink, width: 3),
                          ),
                          filled: true,
                          fillColor: SenseAIColors.softPink.withOpacity(0.2),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validateEmail,
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: SenseAIColors.puzzleBlue,
                          ),
                          prefixIcon: const Icon(Icons.phone_outlined,
                              color: SenseAIColors.puzzleBlue, size: 28),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: SenseAIColors.puzzleBlue, width: 3),
                          ),
                          filled: true,
                          fillColor: SenseAIColors.softBlue.withOpacity(0.2),
                          helperText: 'Include country code (e.g., +1)',
                          helperMaxLines: 2,
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: _validatePhone,
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _relationship,
                        decoration: InputDecoration(
                          labelText: 'Relationship',
                          labelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: SenseAIColors.primaryOrange,
                          ),
                          prefixIcon: const Icon(Icons.family_restroom,
                              color: SenseAIColors.primaryOrange, size: 28),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: SenseAIColors.primaryOrange, width: 3),
                          ),
                          filled: true,
                          fillColor: SenseAIColors.softOrange.withOpacity(0.2),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Mother',
                            child: Text('Mother'),
                          ),
                          DropdownMenuItem(
                            value: 'Father',
                            child: Text('Father'),
                          ),
                          DropdownMenuItem(
                            value: 'Guardian',
                            child: Text('Guardian'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _relationship = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a relationship';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: SizedBox(
                              height: 64,
                              child: OutlinedButton(
                                onPressed: _submitting
                                    ? null
                                    : () {
                                        Navigator.of(context).pop();
                                      },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  side: BorderSide(
                                    color: SenseAIColors.primaryBlue.withOpacity(0.6),
                                    width: 2,
                                  ),
                                ),
                                child: const Text(
                                  'Back',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: SenseAIColors.primaryBlue,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: SenseAIColors.puzzleTeal.withOpacity(0.4),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                height: 64,
                                child: ElevatedButton(
                                  onPressed: _submitting ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: SenseAIColors.puzzleTeal,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: _submitting
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Continue',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Info section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SenseAIColors.softBlue.withOpacity(0.3),
                      SenseAIColors.softOrange.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: SenseAIColors.puzzleBlue.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Safe & Secure',
                      style: TextStyle(
                        color: SenseAIColors.primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'This information helps us create your report',
                      style: TextStyle(
                        color: SenseAIColors.primaryBlue.withOpacity(0.8),
                        fontSize: 14,
                        height: 1.4,
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
