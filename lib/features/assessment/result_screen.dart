import 'package:flutter/material.dart';
import '../../data/models/child.dart';
import '../../data/models/game_results.dart';

class ResultScreen extends StatelessWidget {
  final Child child;
  final String sessionId;
  final GameResults? gameResults;

  const ResultScreen({
    Key? key,
    required this.child,
    required this.sessionId,
    this.gameResults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Results'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assessment, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Assessment Results',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (gameResults != null) ...[
              Text('Accuracy: ${gameResults!.accuracy.toStringAsFixed(1)}%'),
              Text('Score: ${gameResults!.correctTrials}/${gameResults!.totalTrials}'),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

