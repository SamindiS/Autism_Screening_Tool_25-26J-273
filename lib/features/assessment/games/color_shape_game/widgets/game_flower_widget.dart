import 'package:flutter/material.dart';
import '../models/flower_stimulus.dart';

class GameFlowerWidget extends StatefulWidget {
  final FlowerStimulus flower;
  final VoidCallback onTap;

  const GameFlowerWidget({
    Key? key,
    required this.flower,
    required this.onTap,
  }) : super(key: key);

  @override
  State<GameFlowerWidget> createState() => _GameFlowerWidgetState();
}

class _GameFlowerWidgetState extends State<GameFlowerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final scale = 1.0 - (_animationController.value * 0.1);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                gradient: widget.flower.colorGradient,
                borderRadius: widget.flower.isRound
                    ? BorderRadius.circular(65)
                    : BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.flower.emoji,
                  style: const TextStyle(fontSize: 56),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


