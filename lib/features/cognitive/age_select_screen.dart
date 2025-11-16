import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/logger_service.dart';
import '../../data/models/child.dart';
import '../assessment/game_screen.dart';
import '../assessment/ai_doctor_bot_screen.dart';

class AgeSelectScreen extends StatefulWidget {
  final String childId;
  const AgeSelectScreen({Key? key, required this.childId}) : super(key: key);

  @override
  State<AgeSelectScreen> createState() => _AgeSelectScreenState();
}

class _AgeSelectScreenState extends State<AgeSelectScreen> {
  final _ageController = TextEditingController();
  Map<String, dynamic>? _childData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChildData();
  }

  Future<void> _loadChildData() async {
    final child = await StorageService.getChild(widget.childId);
    if (mounted) {
      setState(() {
        _childData = child;
        if (child != null && child['age'] != null) {
          _ageController.text = (child['age'] as double).toStringAsFixed(1);
        }
        _loading = false;
      });
    }
  }

  Future<void> _startAssessment() async {
    final age = double.tryParse(_ageController.text) ?? 0.0;

    if (age < 2.0 || age >= 6.9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Age must be between 2.0 and 6.9 years'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Log age entry
    LoggerService.logEvent({
      'event': 'age_entered',
      'child_id': widget.childId,
      'age': age,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Get child data - try by ID first, if not found, get all and find by name
    var childData = await StorageService.getChild(widget.childId);
    
    // If child not found by ID, try to get from all children
    if (childData == null) {
      try {
        final allChildren = await StorageService.getAllChildren();
        // Try to find by the ID or get the most recent child
        if (allChildren.isNotEmpty) {
          childData = allChildren.firstWhere(
            (c) => c['id'] == widget.childId,
            orElse: () => allChildren.first,
          );
        }
      } catch (e) {
        debugPrint('Error loading children: $e');
      }
    }
    
    if (childData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Child data not found. Please add the child again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create Child model
    final child = Child.fromJson(childData);

    // Route based on age
    if (age >= 2.0 && age < 3.5) {
      // Age 2.0-3.4: Parent Questionnaire + Clinician Reflection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AIDoctorBotScreen(
            child: child,
          ),
        ),
      );
    } else if (age >= 3.5 && age < 5.5) {
      // Age 3.5-5.4: Frog Jump Game + Clinician Reflection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(
            child: child,
            gameType: 'frog-jump',
          ),
        ),
      );
    } else if (age >= 5.5 && age < 6.9) {
      // Age 5.5-6.8: Color-Shape Game + Clinician Reflection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(
            child: child,
            gameType: 'color-shape',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid age range. Please enter age between 2.0 and 6.9'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Age Selection'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade50,
              Colors.white,
            ],
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Child Info Card
                      if (_childData != null) _buildChildInfoCard(),
                      const SizedBox(height: 40),
                      // Age Input Section
                      _buildAgeInputSection(),
                      const SizedBox(height: 40),
                      // Age Groups Info
                      _buildAgeGroupsInfo(),
                      const SizedBox(height: 40),
                      // Start Button
                      _buildStartButton(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildChildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.child_care, color: Colors.orange.shade700, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _childData!['name'] as String? ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gender: ${_childData!['gender'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeInputSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Enter Child Age',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Age must be between 2.0 and 6.9 years',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _ageController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
            ],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
            decoration: InputDecoration(
              hintText: '3.5',
              hintStyle: TextStyle(
                fontSize: 48,
                color: Colors.grey.shade300,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.orange.shade300, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.orange.shade300, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.orange, width: 3),
              ),
              filled: true,
              fillColor: Colors.orange.shade50,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'years',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeGroupsInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              const Text(
                'Age Groups',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAgeGroupItem('2.0 - 3.4 years', 'Parent Questionnaire + Clinician Reflection', Colors.blue),
          const SizedBox(height: 12),
          _buildAgeGroupItem('3.5 - 5.4 years', 'Frog Jump Game + Clinician Reflection', Colors.green),
          const SizedBox(height: 12),
          _buildAgeGroupItem('5.5 - 6.8 years', 'Color-Shape Game + Clinician Reflection', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildAgeGroupItem(String ageRange, String assessment, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ageRange,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                assessment,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _startAssessment,
        style: ElevatedButton.styleFrom(
          primary: Colors.orange,
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
        ),
        child: const Text(
          'START ASSESSMENT',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
