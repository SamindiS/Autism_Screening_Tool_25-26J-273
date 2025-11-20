import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GameSpeechService {
  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;
  static bool _speechEnabled = true;
  static String _currentLanguage = 'en';

  static Future<void> initialize({String language = 'en'}) async {
    _currentLanguage = language;
    
    try {
      // Map language codes to TTS language codes
      String ttsLanguage;
      switch (language) {
        case 'si':
          ttsLanguage = 'si-LK'; // Sinhala
          break;
        case 'ta':
          ttsLanguage = 'ta-IN'; // Tamil
          break;
        case 'en':
        default:
          ttsLanguage = 'en-US'; // English
          break;
      }
      
      // Try to set language, fallback to English if not available
      final languages = await _tts.getLanguages;
      if (languages.contains(ttsLanguage)) {
        await _tts.setLanguage(ttsLanguage);
      } else {
        debugPrint('Language $ttsLanguage not available, using en-US');
        await _tts.setLanguage('en-US');
      }
      
      await _tts.setSpeechRate(0.7); // Slower for children
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      _initialized = true;
      debugPrint('Speech service initialized with language: $ttsLanguage');
    } catch (e) {
      debugPrint('Error initializing speech service: $e');
      _speechEnabled = false;
    }
  }

  static Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    await initialize(language: language);
  }

  static Future<void> speak(String text) async {
    if (!_speechEnabled || !_initialized) return;
    
    try {
      await _tts.stop(); // Stop any ongoing speech
      await _tts.speak(text);
    } catch (e) {
      debugPrint('Error speaking: $e');
    }
  }

  static Future<void> speakInstructions(String language) async {
    String text;
    switch (language) {
      case 'si':
        text = "මල් දිහා බලන්න! පාට හරි හැඩය හරි තෝරන්න. විනෝද වන්න!";
        break;
      case 'ta':
        text = "மலர்களைப் பாருங்கள்! நிறம் அல்லது வடிவத்தைத் தேர்ந்தெடுங்கள். வேடிக்கையாக விளையாடுங்கள்!";
        break;
      case 'en':
      default:
        text = "Look at the flowers! Choose COLOR or SHAPE. Have fun!";
        break;
    }
    await speak(text);
  }

  static Future<void> speakRuleChange(String newRule, String language) async {
    String text;
    switch (language) {
      case 'si':
        text = newRule == 'color' 
            ? "දැන් පාට තෝරන්න! පාට මල් තෝරන්න!" 
            : "දැන් හැඩය තෝරන්න! වටකුරු මල් තෝරන්න!";
        break;
      case 'ta':
        text = newRule == 'color'
            ? "இப்போது நிறம் தேர்ந்தெடுங்கள்! நிற மலர்களைத் தேர்ந்தெடுங்கள்!"
            : "இப்போது வடிவம் தேர்ந்தெடுங்கள்! வட்ட மலர்களைத் தேர்ந்தெடுங்கள்!";
        break;
      case 'en':
      default:
        text = newRule == 'color'
            ? "Now choose COLOR! Pick the COLOR flowers!"
            : "Now choose SHAPE! Pick the round flowers!";
        break;
    }
    await speak(text);
  }

  static Future<void> speakFeedback(bool isCorrect, String language) async {
    String text;
    if (isCorrect) {
      switch (language) {
        case 'si':
          text = "හරි! හොඳයි! ඔබ හොඳයි!";
          break;
        case 'ta':
          text = "சரி! நன்றாக! நீங்கள் நன்றாக செய்கிறீர்கள்!";
          break;
        case 'en':
        default:
          text = "Yes! Good job! You're doing great!";
          break;
      }
    } else {
      switch (language) {
        case 'si':
          text = "කමක් නැහැ! නැවත උත්සාහ කරන්න!";
          break;
        case 'ta':
          text = "பரவாயில்லை! மீண்டும் முயற்சிக்கவும்!";
          break;
        case 'en':
        default:
          text = "That's okay! Try again!";
          break;
      }
    }
    await speak(text);
  }

  static void setSpeechEnabled(bool enabled) {
    _speechEnabled = enabled;
  }

  static bool get speechEnabled => _speechEnabled;

  static Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('Error stopping speech: $e');
    }
  }
}


