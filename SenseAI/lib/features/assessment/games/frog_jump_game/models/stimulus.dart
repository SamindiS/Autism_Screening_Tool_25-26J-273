import 'package:flutter/material.dart';

class Stimulus {
  final String type; // 'happy' or 'sleepy'
  final String emoji;
  final Color primaryColor;
  final Color secondaryColor;
  final Color borderColor;
  final LinearGradient gradient;
  final String label;

  Stimulus({
    required this.type,
    required this.emoji,
    required this.primaryColor,
    required this.secondaryColor,
    required this.borderColor,
    required this.gradient,
    required this.label,
  });

  static final Stimulus happyFrog = Stimulus(
    type: 'happy',
    emoji: '🐸',
    primaryColor: const Color(0xFF4CAF50),
    secondaryColor: const Color(0xFF66BB6A),
    borderColor: const Color(0xFF2E7D32),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A), Color(0xFF81C784)],
    ),
    label: 'TAP ME!',
  );

  static final Stimulus sleepyTurtle = Stimulus(
    type: 'sleepy',
    emoji: '🐢',
    primaryColor: const Color(0xFFFF9800),
    secondaryColor: const Color(0xFFFFB74D),
    borderColor: const Color(0xFFE65100),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF9800), Color(0xFFFFB74D), Color(0xFFFFCC80)],
    ),
    label: "DON'T TAP!",
  );
}

