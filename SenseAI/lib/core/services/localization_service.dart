import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// Service responsible for loading and managing localized strings from JSON files.
/// 
/// This service provides a centralized way to translate keys into 
/// human-readable strings based on the current application locale.
class LocalizationService {
  static LocalizationService? _instance;
  static Map<String, dynamic> _localizedStrings = {};
  static Locale _currentLocale = const Locale('en');

  LocalizationService._();

  /// Returns the singleton instance of [LocalizationService].
  static LocalizationService get instance {
    _instance ??= LocalizationService._();
    return _instance!;
  }

  /// Retrieves the current [Locale] being used for translations.
  static Locale get currentLocale => _currentLocale;

  /// Loads the translation JSON file for the given [locale] from assets.
  /// 
  /// The files are expected to be located at `assets/translations/{languageCode}.json`.
  static Future<void> load(Locale locale) async {
    _currentLocale = locale;
    final String jsonString = await rootBundle.loadString(
      'assets/translations/${locale.languageCode}.json',
    );
    _localizedStrings = json.decode(jsonString) as Map<String, dynamic>;
  }

  /// Translates a given [key] into the current language.
  /// 
  /// If the [key] is not found, the [key] itself is returned as a fallback.
  static String translate(String key) {
    if (_localizedStrings.containsKey(key)) {
      return _localizedStrings[key] as String;
    }
    // Fallback to key if translation not found
    return key;
  }

  /// Attempts to translate a [key], returning null if not found.
  static String? translateOrNull(String key) {
    return _localizedStrings[key] as String?;
  }

  /// Translates a [key] with a custom [fallback] string if the key is missing.
  static String translateWithFallback(String key, String fallback) {
    return translateOrNull(key) ?? fallback;
  }

  /// Checks if a translation exists for the given [key].
  static bool hasKey(String key) {
    return _localizedStrings.containsKey(key);
  }
}

/// Extension providing convenient translation methods on [String] objects.
extension LocalizationExtension on String {
  /// Translates the string key using [LocalizationService.translate].
  String get tr => LocalizationService.translate(this);
  
  /// Attempts to translate the string key, returning null if missing.
  String? get trOrNull => LocalizationService.translateOrNull(this);
  
  /// Translates the string key with a custom [fallback].
  String trWithFallback(String fallback) => LocalizationService.translateWithFallback(this, fallback);
}


