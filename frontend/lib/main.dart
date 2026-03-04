/// =============================================================================
/// SenseAI - Clinical Gaze Tracking for Autism Screening
/// =============================================================================
///
/// Main entry point for the Flutter mobile application.
///
/// Key Screens (in lib/screens/):
/// - SplashScreen: App introduction with logo animation
/// - EntryFormScreen: Collect child information (name, age)
/// - ParentInfoScreen: Parent/guardian details
/// - GazeCalibrationScreen: 9-point eye calibration (lib/gaze/)
/// - ButterflyScreen: Smooth pursuit tracking test (15s)
/// - BubblesScreen: Visual attention test (30s)
/// - ResultsScreen: Display risk assessment and download PDF report
///
/// Author: SenseAI Research Team
/// Version: 2.0.0
/// =============================================================================

import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme.dart';

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
