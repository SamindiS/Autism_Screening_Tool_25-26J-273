import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.healing,
                  size: 96,
                  color: Colors.teal.shade400,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'SenseAI',
              style: Theme.of(context).textTheme.headline5?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Clinical ASD Screening Pilot',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

