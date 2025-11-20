import 'package:flutter/material.dart';
import 'package:senseai/l10n/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context)!;
    final ruleText = widget.rule == 'color' 
        ? localizations.colorButton 
        : localizations.shapeButton;
    final hint = widget.rule == 'color'
        ? localizations.tapColorForPink
        : localizations.tapShapeForRound;

    return AnimatedBuilder(
      animation: _switchController,
      builder: (context, child) {
        final scale = 1.0 + (_switchController.value * 0.05);
        final color = Color.lerp(
          const Color(0xFFFFD166),
          widget.isSwitching ? const Color(0xFFFF6B8B) : const Color(0xFFFFD166),
          _switchController.value,
        );

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isSwitching
                    ? [const Color(0xFFFF6B8B), const Color(0xFF4ECDC4)]
                    : [const Color(0xFFFFE4A1), color ?? const Color(0xFFFFD166)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white70, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '✨ ${localizations.currentRule} ✨',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7C5C1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ruleText.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7C5C1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hint,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7C5C1F),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


