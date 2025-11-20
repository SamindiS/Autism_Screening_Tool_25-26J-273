import 'package:flutter/material.dart';

class FlowerStimulus {
  final String color; // 'pink', 'blue', 'yellow'
  final String shape; // 'round' or 'square'
  final String emoji;
  final LinearGradient colorGradient;
  final bool isRound;

  FlowerStimulus({
    required this.color,
    required this.shape,
    required this.emoji,
    required this.colorGradient,
    required this.isRound,
  });

  static List<FlowerStimulus> get allFlowers => [
        FlowerStimulus(
          color: 'pink',
          shape: 'round',
          emoji: '🌺',
          colorGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B8B), Color(0xFFFF8FA3)],
          ),
          isRound: true,
        ),
        FlowerStimulus(
          color: 'blue',
          shape: 'square',
          emoji: '🌼',
          colorGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4ECDC4), Color(0xFF67E2DC)],
          ),
          isRound: false,
        ),
        FlowerStimulus(
          color: 'yellow',
          shape: 'round',
          emoji: '🌻',
          colorGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFD166), Color(0xFFFFE4A1)],
          ),
          isRound: true,
        ),
        FlowerStimulus(
          color: 'pink',
          shape: 'square',
          emoji: '🌸',
          colorGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B8B), Color(0xFFFF8FA3)],
          ),
          isRound: false,
        ),
      ];
}


