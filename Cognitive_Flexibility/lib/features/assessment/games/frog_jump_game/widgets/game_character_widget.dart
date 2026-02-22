import 'package:flutter/material.dart';
import '../models/stimulus.dart';

class GameCharacterWidget extends StatefulWidget {
  final Stimulus stimulus;
  final VoidCallback? onTap;
  final bool isActive;

  const GameCharacterWidget({
    Key? key,
    required this.stimulus,
    this.onTap,
    this.isActive = true,
  }) : super(key: key);

  @override
  State<GameCharacterWidget> createState() => _GameCharacterWidgetState();
}

class _GameCharacterWidgetState extends State<GameCharacterWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _tapController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isActive || widget.onTap == null) return;
    _tapController.forward().then((_) => _tapController.reverse());
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isActive ? _handleTap : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _tapController]),
        builder: (context, child) {
          final pulseScale = 1.0 + (_pulseController.value * 0.1);
          final tapScale = 1.0 - (_tapController.value * 0.15);
          final scale = pulseScale * tapScale;
          final opacity = widget.isActive ? 1.0 : 0.6;

          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      gradient: widget.stimulus.gradient,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.stimulus.borderColor,
                        width: 8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.stimulus.emoji,
                        style: const TextStyle(fontSize: 180),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: widget.stimulus.primaryColor,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.stimulus.label,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: widget.stimulus.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

