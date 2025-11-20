import 'package:flutter/material.dart';
import 'package:senseai/l10n/app_localizations.dart';

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
  bool _isPressed = false;

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
    final gradient = widget.type == 'color'
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B8B), Color(0xFFFF8FA3)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4ECDC4), Color(0xFF67E2DC)],
          );

    return GestureDetector(
      onTapDown: widget.isActive
          ? (_) {
              setState(() => _isPressed = true);
              _animationController.forward();
            }
          : null,
      onTapUp: widget.isActive
          ? (_) {
              setState(() => _isPressed = false);
              _animationController.reverse();
              widget.onTap();
            }
          : null,
      onTapCancel: widget.isActive
          ? () {
              setState(() => _isPressed = false);
              _animationController.reverse();
            }
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
                    Text(
                      widget.type == 'color' ? '🎨' : '🔷',
                      style: const TextStyle(fontSize: 34),
                    ),
                    const SizedBox(height: 3),
                    Builder(
                      builder: (context) {
                        final localizations = AppLocalizations.of(context)!;
                        final label = widget.type == 'color' 
                            ? localizations.colorButton 
                            : localizations.shapeButton;
                        return Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
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


