// lib/core/services/game_speech_service.dart
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class GameSpeechService {
  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;
  static bool _speechEnabled = true;

  /// Initializes the cutest, calmest voice possible
  static Future<void> initialize({String language = 'en'}) async {
    try {
      // === BEST VOICE SETTINGS FOR CHILDREN WITH AUTISM ===
      await _tts.setSpeechRate(0.45); // Very slow and calm
      await _tts.setPitch(1.3); // High, cute, child-like voice
      await _tts.setVolume(1.0); // Full volume but sounds soft with high pitch

      // Try to use the best available voice (Google or Samsung)
      await _tts
          .setEngine('com.google.android.tts'); // Best quality on most devices

      // Set language
      String ttsLanguage;
      switch (language) {
        case 'si':
          ttsLanguage = 'si-LK';
          break;
        case 'ta':
          ttsLanguage = 'ta-IN';
          break;
        case 'en':
        default:
          ttsLanguage = 'en-US';
          break;
      }

      final languages = await _tts.getLanguages;
      if (languages.contains(ttsLanguage)) {
        await _tts.setLanguage(ttsLanguage);
      } else {
        debugPrint(
            'Language $ttsLanguage not available, falling back to en-US');
        await _tts.setLanguage('en-US');
        await _tts.setPitch(1.3); // Keep cute voice even in English
      }

      _initialized = true;
      debugPrint('Cute calm voice ready! Language: $ttsLanguage');
    } catch (e) {
      debugPrint('Speech init failed: $e');
      _speechEnabled = false;
    }
  }

  static Future<void> setLanguage(String language) async {
    await initialize(language: language);
  }

  // ================================================
  // SUPER CALM & CUTE INSTRUCTIONS
  // ================================================
  static Future<void> speakInstructions(String language) async {
    if (!_speechEnabled || !_initialized) return;
    await _tts.stop();

    String text;
    switch (language) {
      case 'si':
        text =
            "හායි  පුංචි  යාළුවා... මල් බලමුද? පාට හෝ හැඩයෙන් තෝරමු... ඔයාට පුළුවන්!";
        break;
      case 'ta':
        text =
            "வணக்கம் சின்னஞ்சிறிய நண்பனே... மலர்களைப் பார்ப்போமா? நிறம் அல்லது வடிவம் தேர்ந்தெடுப்போம்... நீ ரொம்ப அழகாக செய்வாய்!";
        break;
      case 'en':
      default:
        text =
            "Hello little friend... Shall we look at the flowers? We can choose by color or by shape... You're going to do so well!";
        break;
    }
    await _speakSlowly(text);
  }

  static Future<void> speakRuleChange(String newRule, String language) async {
    if (!_speechEnabled || !_initialized) return;
    await _tts.stop();

    String text;
    switch (language) {
      case 'si':
        text = newRule == 'color'
            ? "දැන් අපි පාට තෝරමු? ඔයාගේ කැමතිම  පාට මල තෝරමු."
            : "දැන් හැඩය තෝරමු... රවුම්  මල් තෝරමු... ";
        break;
      case 'ta':
        text = newRule == 'color'
            ? "இப்போது நிறத்தால் தேர்ந்தெடுப்போம் சரியா? உனக்குப் பிடித்த நிற மலரைத் தேர்ந்தெடு..."
            : "இப்போது வடிவத்தால் தேர்ந்தெடுப்போம்... வட்ட மலர்களைத் தேர்ந்தெடு... நீ ரொம்ப அற்புதமாக செய்கிறாய்!";
        break;
      case 'en':
      default:
        text = newRule == 'color'
            ? "Now we're choosing by color, okay? Pick your favorite color flower..."
            : "Now we're choosing by shape... Let's pick the round flowers... You're so clever!";
        break;
    }
    await _speakSlowly(text);
  }

  static Future<void> speakFeedback(bool isCorrect, String language) async {
    if (!_speechEnabled || !_initialized) return;
    await _tts.stop();

    String text;
    if (isCorrect) {
      switch (language) {
        case 'si':
          text = [
            "වාහ්! ඔයා ගොඩක් දක්ෂයි!",
            "හරිම හොඳයි පුංචි යාළුවා!"
          ][DateTime.now().millisecond % 3];
          break;
        case 'ta':
          text = [
            "வாவ்! நீ ரொம்ப சூப்பர்!",
            "மிகவும் நன்றாக செய்தாய்!",
            "உன்னால் ரொம்ப நன்றாக முடியும்!"
          ][DateTime.now().millisecond % 3];
          break;
        case 'en':
        default:
          text = [
            "Wow! You're so smart!",
            "Amazing job, little friend!",
            "You did it! Well done!"
          ][DateTime.now().millisecond % 3];
          break;
      }
    } else {
      switch (language) {
        case 'si':
          text = "කමක් නැහැ ...අපි නැවත උත්සාහ කරමු..";
          break;
        case 'ta':
          text =
              "பரவாயில்லை சின்ன நண்பா... மீண்டும் முயற்சி செய்வோம்... உன்னால் முடியும்!";
          break;
        case 'en':
        default:
          text =
              "It's okay, little friend... Let's try again... You can do it!";
          break;
      }
    }
    await _speakSlowly(text);
  }

  // Helper: speak slowly with small pauses for warmth
  static Future<void> _speakSlowly(String text) async {
    final sentences = text.split('...');
    for (int i = 0; i < sentences.length; i++) {
      if (sentences[i].trim().isNotEmpty) {
        await _tts.speak(sentences[i].trim());
        if (i < sentences.length - 1) {
          await Future.delayed(
              const Duration(milliseconds: 800)); // gentle pause
        }
      }
    }
  }

  // ================================================
  // CONTROLS
  // ================================================
  static Future<void> speak(String text) async {
    if (!_speechEnabled || !_initialized) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  static void setSpeechEnabled(bool enabled) {
    _speechEnabled = enabled;
  }

  static bool get speechEnabled => _speechEnabled;

  static Future<void> stop() async {
    await _tts.stop();
  }
}
