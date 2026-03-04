import 'package:flutter/material.dart';

import '../gaze/data_collection_screen.dart';
import '../gaze/gaze_service.dart';
import '../theme.dart';
import 'parent_info_screen.dart';

class EntryFormScreen extends StatefulWidget {
  const EntryFormScreen({super.key});

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _resetForNewTest();
  }

  void _resetForNewTest() {
    _nameController.clear();
    _ageController.clear();

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

  void _goToParentInfo() {
    final name = _nameController.text.trim();
    final ageText = _ageController.text.trim();

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

    final age = int.tryParse(ageText);
    if (age == null || age <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid age')));
      return;
    }

    final testDateTime = DateTime.now().toIso8601String();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ParentInfoScreen(
          childName: name,
          childAge: age,
          testDateTime: testDateTime,
        ),
      ),
    );
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'collect_data') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DataCollectionScreen()),
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
              const SizedBox(height: 20),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          SenseAIColors.softTeal,
                          SenseAIColors.softPink,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: SenseAIColors.puzzleTeal.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
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
                            Icons.psychology,
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
                    'Child Information',
                    style: TextStyle(
                      fontSize: 28,
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
                  'Let\'s start your adventure',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: SenseAIColors.primaryBlue.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
                        labelText: 'What\'s your name?',
                        labelStyle: const TextStyle(
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
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _ageController,
                      decoration: InputDecoration(
                        labelText: 'How old are you?',
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: SenseAIColors.puzzlePink,
                        ),
                        prefixIcon: const Icon(Icons.cake_outlined,
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
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: SenseAIColors.puzzleTeal.withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: _goToParentInfo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SenseAIColors.puzzleTeal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Let\'s Go!',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SenseAIColors.softTeal.withOpacity(0.3),
                      SenseAIColors.softPink.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: SenseAIColors.puzzleTeal.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fun Games Ahead!',
                      style: TextStyle(
                        color: SenseAIColors.primaryBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'We\'ll play some exciting visual games together',
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
