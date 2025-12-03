import 'package:flutter/material.dart';

/// Language selection screen for games (DCCS and Frog Jump)
class GameLanguageSelector extends StatelessWidget {
  final Function(String) onLanguageSelected;
  final String gameType; // 'color-shape' or 'frog-jump'
  final Color? backgroundColor;
  final Color? primaryColor;
  final Widget? gameIcon;
  final String? gameTitleEn;
  final String? gameTitleSi;
  final String? gameTitleTa;

  const GameLanguageSelector({
    Key? key,
    required this.onLanguageSelected,
    this.gameType = 'color-shape',
    this.backgroundColor,
    this.primaryColor,
    this.gameIcon,
    this.gameTitleEn,
    this.gameTitleSi,
    this.gameTitleTa,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Default colors for color-shape game
    final defaultBgColor = gameType == 'frog-jump' 
        ? const Color(0xFFFFE5EC) 
        : const Color(0xFFE3F2FD);
    final defaultPrimaryColor = gameType == 'frog-jump'
        ? const Color(0xFFFF6B9D)
        : const Color(0xFF1565C0);
    
    final bgColor = backgroundColor ?? defaultBgColor;
    final primaryColorValue = primaryColor ?? defaultPrimaryColor;
    
    // Default game icon
    Widget defaultIcon;
    if (gameIcon != null) {
      defaultIcon = gameIcon!;
    } else if (gameType == 'frog-jump') {
      defaultIcon = Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: const Text(
          '🐸',
          style: TextStyle(fontSize: 60),
        ),
      );
    } else {
      // Color-shape game icon (DCCS)
      defaultIcon = Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      );
    }
    
    // Default game titles
    final titleEn = gameTitleEn ?? (gameType == 'frog-jump' 
        ? 'Frog Jump Game' 
        : 'Color-Shape Sorting Game');
    final titleSi = gameTitleSi ?? (gameType == 'frog-jump'
        ? 'ගෙම්බා පැනීමේ සෙල්ලම'
        : 'පාට-හැඩ තෝරන සෙල්ලම');
    final titleTa = gameTitleTa ?? (gameType == 'frog-jump'
        ? 'தவளை குதித்தல் விளையாட்டு'
        : 'நிறம்-வடிவம் விளையாட்டு');

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        gradient: gameType == 'frog-jump' 
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFE5EC), Color(0xFFFFC2D4), Color(0xFFFFB5C5)],
              )
            : null,
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game icon
                defaultIcon,
                const SizedBox(height: 30),
                // Title in all three languages
                Column(
                  children: [
                    Text(
                      'Select Language',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColorValue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'භාෂාව තෝරන්න',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: primaryColorValue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'மொழியைத் தேர்ந்தெடு',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: primaryColorValue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        titleEn,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        titleSi,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                      Text(
                        titleTa,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildLanguageButton(
                    context,
                    'English',
                    'en',
                    '🇬🇧',
                    gameType == 'frog-jump' 
                        ? const Color(0xFFFF6B9D)
                        : const Color(0xFF1565C0),
                ),
                const SizedBox(height: 16),
                _buildLanguageButton(
                    context,
                    'සිංහල',
                    'si',
                    '🇱🇰',
                    gameType == 'frog-jump'
                        ? const Color(0xFFFF8EAB)
                        : const Color(0xFF7B1FA2),
                ),
                const SizedBox(height: 16),
                _buildLanguageButton(
                    context,
                    'தமிழ்',
                    'ta',
                    '🇮🇳',
                    gameType == 'frog-jump'
                        ? const Color(0xFFFFB5C5)
                        : const Color(0xFFE65100),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    String label,
    String code,
    String flag,
    Color accentColor,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton(
        onPressed: () => onLanguageSelected(code),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: accentColor.withOpacity(0.5), width: 2),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
