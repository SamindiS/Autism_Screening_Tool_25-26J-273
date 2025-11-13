import 'package:flutter/material.dart';
import '../../data/models/child.dart';
import '../../data/models/game_results.dart';

class ClinicianReflectionScreen extends StatefulWidget {
  final Child child;
  final String sessionId;
  final GameResults gameResults;

  const ClinicianReflectionScreen({
    Key? key,
    required this.child,
    required this.sessionId,
    required this.gameResults,
  }) : super(key: key);

  @override
  State<ClinicianReflectionScreen> createState() => _ClinicianReflectionScreenState();
}

class _ClinicianReflectionScreenState extends State<ClinicianReflectionScreen> {
  // TODO: Implement clinician reflection questionnaire
  // 5 questions about child's behavior during assessment

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinician Reflection'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Clinician Reflection',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Coming Soon'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to Results screen
                Navigator.pop(context);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

