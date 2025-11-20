import 'package:flutter/material.dart';
import '../services/language_preference_service.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    _locale = await LanguagePreferenceService.getLocale();
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    await LanguagePreferenceService.setLocale(locale);
    notifyListeners();
  }

  String getLanguageName(String code) {
    return LanguagePreferenceService.getLanguageName(code);
  }

  List<Map<String, String>> get supportedLanguages {
    return LanguagePreferenceService.getSupportedLanguages();
  }
}


