import 'package:flutter/material.dart';
import '../models/shape_stimulus.dart';

/// Widget to display a shape stimulus in DCCS game
class GameShapeWidget extends StatelessWidget {
  final ShapeStimulus shape;
  final double size;
  final bool showBorder;

  const GameShapeWidget({
    Key? key,
    required this.shape,
    this.size = 80,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: shape.colorValue,
        borderRadius: BorderRadius.circular(shape.borderRadius),
        border: showBorder
            ? Border.all(color: Colors.white, width: 3)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

/// Widget to display a target box (left or right) in DCCS game
class DccsTargetBox extends StatelessWidget {
  final String side; // 'left' or 'right'
  final VoidCallback onTap;
  final bool isHighlighted;

  const DccsTargetBox({
    Key? key,
    required this.side,
    required this.onTap,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLeft = side == 'left';
    final target = isLeft ? DccsTargets.leftTarget : DccsTargets.rightTarget;
    final label = isLeft ? 'LEFT' : 'RIGHT';
    final description = isLeft ? 'Red Circle' : 'Blue Square';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHighlighted
                ? (isLeft ? Colors.red : Colors.blue)
                : Colors.grey.shade300,
            width: isHighlighted ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            GameShapeWidget(
              shape: target,
              size: 70,
              showBorder: false,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}









