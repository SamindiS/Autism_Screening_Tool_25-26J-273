import 'package:flutter/material.dart';
import '../services/language_preference_service.dart';

/// A [ChangeNotifier] that manages the application's current [Locale].
///
/// This provider handles loading the user's preferred language from local storage
/// and updating it across the UI when changed.
class LanguageProvider with ChangeNotifier {
  /// The current locale of the application. Default is English.
  Locale _locale = const Locale('en');

  /// Getter to retrieve the current [Locale].
  Locale get locale => _locale;

  /// Initializes the [LanguageProvider] and loads the saved locale.
  LanguageProvider() {
    _loadSavedLocale();
  }

  /// Loads the previously saved locale from [LanguagePreferenceService].
  Future<void> _loadSavedLocale() async {
    _locale = await LanguagePreferenceService.getLocale();
    notifyListeners();
  }

  /// Updates the application's locale and persists it in local storage.
  ///
  /// If the new [locale] is the same as the current one, it returns early.
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    await LanguagePreferenceService.setLocale(locale);
    notifyListeners();
  }

  /// Returns the human-readable language name for a given [code].
  String getLanguageName(String code) {
    return LanguagePreferenceService.getLanguageName(code);
  }

  /// Returns a list of all supported languages in the system.
  List<Map<String, String>> get supportedLanguages {
    return LanguagePreferenceService.getSupportedLanguages();
  }
}


