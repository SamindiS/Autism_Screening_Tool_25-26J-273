import 'package:flutter/material.dart';

/// Simple button widget for DCCS game (not used in current clinical version)
/// Kept for backwards compatibility
class WandButton extends StatefulWidget {
  final String type; // 'color' or 'shape'
  final VoidCallback onTap;
  final bool isActive;

  const WandButton({
    Key? key,
    required this.type,
    required this.onTap,
    this.isActive = true,
  }) : super(key: key);

  @override
  State<WandButton> createState() => _WandButtonState();
}

class _WandButtonState extends State<WandButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isColor = widget.type == 'color';
    final gradient = isColor
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red, Color(0xFFEF5350)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Color(0xFF42A5F5)],
          );

    return GestureDetector(
      onTapDown: widget.isActive
          ? (_) => _animationController.forward()
          : null,
      onTapUp: widget.isActive
          ? (_) {
              _animationController.reverse();
              widget.onTap();
            }
          : null,
      onTapCancel: widget.isActive
          ? () => _animationController.reverse()
          : null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final scale = 1.0 - (_animationController.value * 0.05);
          final opacity = widget.isActive ? 1.0 : 0.5;
          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isColor ? Icons.palette : Icons.category,
                      color: Colors.white,
                      size: 34,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isColor ? 'COLOR' : 'SHAPE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
