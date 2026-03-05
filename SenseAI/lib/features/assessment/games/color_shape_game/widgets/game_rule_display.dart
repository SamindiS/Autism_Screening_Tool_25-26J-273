import 'package:flutter/material.dart';

/// Display widget for showing the current rule in DCCS game
class GameRuleDisplay extends StatefulWidget {
  final String rule; // 'color' or 'shape'
  final bool isSwitching;

  const GameRuleDisplay({
    Key? key,
    required this.rule,
    this.isSwitching = false,
  }) : super(key: key);

  @override
  State<GameRuleDisplay> createState() => _GameRuleDisplayState();
}

class _GameRuleDisplayState extends State<GameRuleDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _switchController;

  @override
  void initState() {
    super.initState();
    _switchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.isSwitching) {
      _switchController.forward();
    }
  }

  @override
  void didUpdateWidget(GameRuleDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSwitching && !oldWidget.isSwitching) {
      _switchController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _switchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isColorRule = widget.rule == 'color';
    final ruleText = isColorRule ? 'COLOR' : 'SHAPE';
    final hint = isColorRule
        ? 'Match by color (red or blue)'
        : 'Match by shape (circle or square)';

    return AnimatedBuilder(
      animation: _switchController,
      builder: (context, child) {
        final scale = 1.0 + (_switchController.value * 0.05);

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isColorRule
                  ? const Color(0xFFFFEBEE)
                  : const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isColorRule ? Colors.red : Colors.blue,
                width: 2,
              ),
              boxShadow: [
                if (widget.isSwitching)
                  BoxShadow(
                    color: (isColorRule ? Colors.red : Colors.blue)
                        .withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isColorRule ? Icons.palette : Icons.category,
                      color: isColorRule ? Colors.red : Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$ruleText GAME',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isColorRule ? Colors.red : Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  hint,
                  style: TextStyle(
                    fontSize: 14,
                    color: isColorRule
                        ? Colors.red.shade700
                        : Colors.blue.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
