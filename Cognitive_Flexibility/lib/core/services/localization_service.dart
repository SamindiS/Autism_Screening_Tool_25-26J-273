import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class LocalizationService {
  static LocalizationService? _instance;
  static Map<String, dynamic> _localizedStrings = {};
  static Locale _currentLocale = const Locale('en');

  LocalizationService._();

  static LocalizationService get instance {
    _instance ??= LocalizationService._();
    return _instance!;
  }

  static Locale get currentLocale => _currentLocale;

  static Future<void> load(Locale locale) async {
    _currentLocale = locale;
    final String jsonString = await rootBundle.loadString(
      'assets/translations/${locale.languageCode}.json',
    );
    _localizedStrings = json.decode(jsonString) as Map<String, dynamic>;
  }

  static String translate(String key) {
    if (_localizedStrings.containsKey(key)) {
      return _localizedStrings[key] as String;
    }
    // Fallback to key if translation not found
    return key;
  }

  static String? translateOrNull(String key) {
    return _localizedStrings[key] as String?;
  }

  // Helper method to get translation with fallback
  static String translateWithFallback(String key, String fallback) {
    return translateOrNull(key) ?? fallback;
  }

  // Check if a key exists
  static bool hasKey(String key) {
    return _localizedStrings.containsKey(key);
  }
}

// Extension to easily access translations
extension LocalizationExtension on String {
  String get tr => LocalizationService.translate(this);
  String? get trOrNull => LocalizationService.translateOrNull(this);
  String trWithFallback(String fallback) => LocalizationService.translateWithFallback(this, fallback);
}


