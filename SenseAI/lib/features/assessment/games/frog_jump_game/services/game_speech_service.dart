import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class GameSpeechService {
  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;
  static bool _speechEnabled = true;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // THE SWEETEST VOICE POSSIBLE
      await _tts.setSpeechRate(0.42); // Super slow & calm
      await _tts.setPitch(1.35); // High, cute, child-like voice
      await _tts.setVolume(1.0); // Full but sounds soft with high pitch

      await _tts.setEngine('com.google.android.tts'); // Best quality

      _initialized = true;
      debugPrint('Frog Jump Speech: Loving big-sister voice ready!');
    } catch (e) {
      debugPrint('Error initializing speech service: $e');
      _speechEnabled = false;
    }
  }

  static Future<void> speak(String text, String language) async {
    if (!_speechEnabled || !_initialized) return;

    try {
      await _tts.stop();
      await _tts.setLanguage(language);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('Error speaking: $e');
    }
  }

  static Future<void> speakInstructions(String language) async {
    String text;
    switch (language) {
      case 'si':
        text = "සතුටු ගෙම්බා ඔබන්න! නිදි ගෙම්බා ඔබන්න එපා!";
        break;
      case 'ta':
        text = "மகிழ்ச்சியான தவளை தட்டவும்! தூங்கும் ஆமை தட்ட வேண்டாம்!";
        break;
      case 'en':
      default:
        text = "Tap the happy frog! Don't tap the sleepy turtle!";
        break;
    }
    await speak(text, language);
  }

  static Future<void> speakStimulus(String stimulus, String language) async {
    String text;
    if (stimulus == 'happy') {
      switch (language) {
        case 'si':
          text = "සතුටු ගෙම්බා! ඔබන්න!";
          break;
        case 'ta':
          text = "மகிழ்ச்சியான தவளை! தட்டவும்!";
          break;
        case 'en':
        default:
          text = "Happy frog! Tap it!";
          break;
      }
    } else {
      switch (language) {
        case 'si':
          text = "නිදි ගෙම්බා! ඔබන්න එපා!";
          break;
        case 'ta':
          text = "தூங்கும் ஆமை! தட்ட வேண்டாம்!";
          break;
        case 'en':
        default:
          text = "Sleepy turtle! Don't tap!";
          break;
      }
    }
    await speak(text, language);
  }

  static Future<void> speakFeedback(bool isCorrect, String language) async {
    String text;
    if (isCorrect) {
      switch (language) {
        case 'si':
          text = "හොඳයි!";
          break;
        case 'ta':
          text = "நன்றாக!";
          break;
        case 'en':
        default:
          text = "Great job!";
          break;
      }
    } else {
      switch (language) {
        case 'si':
          text = "නැවත උත්සාහ කරන්න!";
          break;
        case 'ta':
          text = "மீண்டும் முயற்சிக்கவும்!";
          break;
        case 'en':
        default:
          text = "Try again!";
          break;
      }
    }
    await speak(text, language);
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
