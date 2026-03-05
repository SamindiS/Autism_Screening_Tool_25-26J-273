import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreferenceService {
  static const String _localeKey = 'selected_locale';
  static const String _autoDetectKey = 'auto_detect_language';

  /// Get saved locale or auto-detect
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

  /// Save selected locale
  static Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    await prefs.setBool(_autoDetectKey, false);
  }

  /// Enable/disable auto-detect
  static Future<void> setAutoDetect(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoDetectKey, enabled);
  }

  /// Get auto-detect setting
  static Future<bool> isAutoDetectEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoDetectKey) ?? true;
  }

  /// Auto-detect device locale
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

  /// Get language display name
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

  /// Get all supported languages
  static List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'native': 'English'},
      {'code': 'si', 'name': 'Sinhala', 'native': 'සිංහල'},
      {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
    ];
  }
}

