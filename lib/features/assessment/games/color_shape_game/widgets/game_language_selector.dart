import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senseai/l10n/app_localizations.dart';
import 'package:senseai/core/providers/language_provider.dart';

class GameLanguageSelector extends StatelessWidget {
  final Function(String) onLanguageSelected;

  const GameLanguageSelector({
    Key? key,
    required this.onLanguageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🌺',
                    style: TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    localizations.selectLanguage,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  _buildLanguageButton(
                    context,
                    'English',
                    'en',
                    '🇬🇧',
                    languageProvider.locale.languageCode == 'en',
                    onLanguageSelected,
                  ),
                  const SizedBox(height: 20),
                  _buildLanguageButton(
                    context,
                    'සිංහල',
                    'si',
                    '🇱🇰',
                    languageProvider.locale.languageCode == 'si',
                    onLanguageSelected,
                  ),
                  const SizedBox(height: 20),
                  _buildLanguageButton(
                    context,
                    'தமிழ்',
                    'ta',
                    '🇱🇰',
                    languageProvider.locale.languageCode == 'ta',
                    onLanguageSelected,
                  ),
                ],
              ),
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
    String emoji,
    bool isSelected,
    Function(String) onSelected,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: () => onSelected(code),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color(0xFFFF6B8B)
              : Colors.white.withOpacity(0.2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 3,
            ),
          ),
          elevation: isSelected ? 8 : 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 15),
            Text(
              label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

