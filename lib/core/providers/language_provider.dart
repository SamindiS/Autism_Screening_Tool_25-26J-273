import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/localization_service.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  static const String _localeKey = 'selected_locale';

  Locale get locale => _locale;

  LanguageProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocaleCode = prefs.getString(_localeKey);
    if (savedLocaleCode != null) {
      _locale = Locale(savedLocaleCode);
      await LocalizationService.load(_locale);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    await LocalizationService.load(locale);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    
    notifyListeners();
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'si':
        return 'සිංහල';
      case 'ta':
        return 'தமிழ்';
      default:
        return 'English';
    }
  }

  List<Map<String, String>> get supportedLanguages => [
        {'code': 'en', 'name': 'English', 'native': 'English'},
        {'code': 'si', 'name': 'Sinhala', 'native': 'සිංහල'},
        {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
      ];
}

