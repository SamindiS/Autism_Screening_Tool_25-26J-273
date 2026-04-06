import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user language preferences and persistence.
/// 
/// This service handles storing the selected locale, managing the 
/// auto-detection of system language, and providing human-readable 
/// language names.
class LanguagePreferenceService {
  static const String _localeKey = 'selected_locale';
  static const String _autoDetectKey = 'auto_detect_language';

  /// Retrieves the saved locale from [SharedPreferences].
  /// 
  /// If auto-detect is enabled or no locale is saved, it attempts to 
  /// detect the device's system locale.
  static Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final autoDetect = prefs.getBool(_autoDetectKey) ?? true;
    
    if (autoDetect) {
      return _getDeviceLocale();
    }
    
    final savedLocaleCode = prefs.getString(_localeKey);
    if (savedLocaleCode != null) {
      return Locale(savedLocaleCode);
    }
    
    return _getDeviceLocale();
  }

  /// Persists the selected [Locale] and disables auto-detection.
  static Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    await prefs.setBool(_autoDetectKey, false);
  }

  /// Enables or disables the automatic detection of system language.
  static Future<void> setAutoDetect(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoDetectKey, enabled);
  }

  /// Checks if auto-detection of language is currently enabled.
  static Future<bool> isAutoDetectEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoDetectKey) ?? true;
  }

  /// Detects the system locale using [ui.window.locale].
  /// 
  /// Falls back to English ('en') if the system language is not supported 
  /// (Sinhala and Tamil are currently supported).
  static Locale _getDeviceLocale() {
    try {
      // Use dart:ui's window.locale (Flutter 2.10.5 compatible)
      final systemLocale = ui.window.locale;
      final languageCode = systemLocale.languageCode;
      
      // Check if we support this language
      if (languageCode == 'si') {
        return const Locale('si');
      } else if (languageCode == 'ta') {
        return const Locale('ta');
      }
      
      // Default to English
      return const Locale('en');
    } catch (e) {
      // Fallback to English
      return const Locale('en');
    }
  }

  /// Returns the localized name of a language given its ISO [code].
  static String getLanguageName(String code) {
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

  /// Returns a list of all languages supported by the application.
  static List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'native': 'English'},
      {'code': 'si', 'name': 'Sinhala', 'native': 'සිංහල'},
      {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
    ];
  }
}

