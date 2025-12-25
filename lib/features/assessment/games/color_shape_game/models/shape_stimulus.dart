import 'package:flutter/material.dart';

/// Simple shape stimulus for clinical DCCS game
/// Only uses conflict stimuli: Red Square OR Blue Circle
class ShapeStimulus {
  final String color; // 'red' or 'blue'
  final String shape; // 'circle' or 'square'

  const ShapeStimulus({
    required this.color,
    required this.shape,
  });

  /// Get the color as a Flutter Color
  Color get colorValue => color == 'red' ? Colors.red : Colors.blue;

  /// Check if shape is circle
  bool get isCircle => shape == 'circle';

  /// Get border radius based on shape
  double get borderRadius => isCircle ? 100 : 16;

  /// Conflict stimuli only - each matches one target by color, other by shape
  /// Left target: Red Circle
  /// Right target: Blue Square
  static const List<ShapeStimulus> conflictStimuli = [
    ShapeStimulus(color: 'red', shape: 'square'),   // Color→Left, Shape→Right
    ShapeStimulus(color: 'blue', shape: 'circle'),  // Color→Right, Shape→Left
  ];

  /// Get correct target side based on rule
  /// Left = Red Circle, Right = Blue Square
  String getCorrectSide(String rule) {
    if (rule == 'color') {
      return color == 'red' ? 'left' : 'right';
    } else {
      return shape == 'circle' ? 'left' : 'right';
    }
  }

  @override
  String toString() => '$color $shape';
}

/// Fixed target boxes for DCCS
class DccsTargets {
  static const ShapeStimulus leftTarget = ShapeStimulus(color: 'red', shape: 'circle');
  static const ShapeStimulus rightTarget = ShapeStimulus(color: 'blue', shape: 'square');
}








