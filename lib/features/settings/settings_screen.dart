import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/services/language_preference_service.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoDetect = true;

  @override
  void initState() {
    super.initState();
    _loadAutoDetectSetting();
  }

  Future<void> _loadAutoDetectSetting() async {
    final autoDetect = await LanguagePreferenceService.isAutoDetectEnabled();
    setState(() {
      _autoDetect = autoDetect;
    });
  }

  Future<void> _handleLanguageChange(Locale newLocale) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    // Update the locale - this will trigger notifyListeners() which rebuilds MaterialApp
    await languageProvider.setLocale(newLocale);
    
    if (mounted) {
      // Close settings screen
      Navigator.of(context).pop();
      
      // Show confirmation message
      // The MaterialApp will rebuild with new locale, updating all screens
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language changed to ${LanguagePreferenceService.getLanguageName(newLocale.languageCode)}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.teal,
          ),
        );
      }
    }
  }

  Future<void> _handleAutoDetectChange(bool value) async {
    await LanguagePreferenceService.setAutoDetect(value);
    setState(() {
      _autoDetect = value;
    });

    if (value) {
      // If auto-detect is enabled, use device locale
      final deviceLocale = await LanguagePreferenceService.getLocale();
      _handleLanguageChange(deviceLocale);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLocale = languageProvider.locale;
    final supportedLanguages = languageProvider.supportedLanguages;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Auto-detect section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language, color: Colors.teal),
                      const SizedBox(width: 12),
                      Text(
                        'Auto-detect Language',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Automatically use your device language',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Switch(
                    value: _autoDetect,
                    onChanged: _handleAutoDetectChange,
                    activeColor: Colors.teal,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Language selection section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.translate, color: Colors.teal),
                      const SizedBox(width: 12),
                      Text(
                        'Select Language',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...supportedLanguages.map((lang) {
                    final isSelected = currentLocale.languageCode == lang['code'];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.teal.shade100 : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            lang['native']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.teal.shade700 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        lang['name']!,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.teal.shade700 : Colors.grey.shade800,
                        ),
                      ),
                      subtitle: Text(
                        lang['native']!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: Colors.teal.shade700)
                          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                      onTap: _autoDetect
                          ? null
                          : () => _handleLanguageChange(Locale(lang['code']!)),
                      enabled: !_autoDetect,
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Info card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _autoDetect
                          ? 'Language is automatically detected from your device settings. Disable auto-detect to manually select a language.'
                          : 'You can manually select your preferred language. Enable auto-detect to use your device language.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

