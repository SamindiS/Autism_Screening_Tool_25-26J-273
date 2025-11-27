// lib/features/assessment/games/color_shape_game/services/game_speech_service.dart
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

/// Speech service for DCCS (Dimensional Change Card Sort) game
/// Provides calm, clear voice instructions for children
class GameSpeechService {
  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;
  static bool _speechEnabled = true;

  /// Initializes the calmest, clearest voice for children with autism
  static Future<void> initialize({String language = 'en'}) async {
    try {
      // === BEST VOICE SETTINGS FOR CHILDREN WITH AUTISM ===
      await _tts.setSpeechRate(0.42); // Very slow and calm
      await _tts.setPitch(1.25); // Slightly high, friendly voice
      await _tts.setVolume(1.0);

      // Try to use the best available voice
      await _tts.setEngine('com.google.android.tts');

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
        debugPrint('Language $ttsLanguage not available, falling back to en-US');
        await _tts.setLanguage('en-US');
      }

      _initialized = true;
      debugPrint('DCCS Speech ready! Language: $ttsLanguage');
    } catch (e) {
      debugPrint('Speech init failed: $e');
      _speechEnabled = false;
    }
  }

  static Future<void> setLanguage(String language) async {
    await initialize(language: language);
  }

  // ================================================
  // DCCS GAME INSTRUCTIONS
  // ================================================
  
  /// Speak main game instructions
  static Future<void> speakInstructions(String language) async {
    if (!_speechEnabled || !_initialized) return;
    await _tts.stop();

    String text;
    switch (language) {
      case 'si':
        text = '''
හායි පුංචි යාළුවා...
අපි සෙල්ලමක්  කරමු...
මේ තියෙන්නේ රතු  රවුමකුයි නිල් කොටුවකුයි ...
මුලින්ම අපි පාට තෝරමු ...
කාඩ්පත බැලුවාම, එකේ  පාටම තියෙන පෙට්ටිය තෝරන්න...
ඔයාට පුළුවන්!
''';
        break;
      case 'ta':
        text = '''
வணக்கம் சின்னஞ்சிறிய நண்பனே...
வடிவ விளையாட்டு விளையாடுவோம்...
இங்கே ஒரு சிவப்பு வட்டமும் நீல சதுரமும் உள்ளது...
முதலில் நிற விளையாட்டு விளையாடுவோம்...
அட்டையைப் பார், அதே நிறப் பெட்டியைத் தேர்ந்தெடு...
நீ ரொம்ப அழகாக செய்வாய்!
''';
        break;
      case 'en':
      default:
        text = '''
Hello little friend...
Let's play the sorting game...
Here is a red circle and a blue square...
First, we play the color game...
Look at the card and tap the box with the same color...
You can do it!
''';
        break;
    }
    await _speakSlowly(text);
  }

  /// Speak rule change announcement
  static Future<void> speakRuleChange(String newRule, String language) async {
    if (!_speechEnabled || !_initialized) return;
    await _tts.stop();

    String text;
    switch (language) {
      case 'si':
        text = newRule == 'color'
            ? "දැන් පාට සෙල්ලම... එකම පාට තෝරන්න..."
            : "දැන් හැඩතල සෙල්ලම ... එකම හැඩය තෝරන්න... රවුම්  නම් රවුම , හතරැස් නම් කොටුව...";
        break;
      case 'ta':
        text = newRule == 'color'
            ? "இப்போது நிற விளையாட்டு... அதே நிறப் பெட்டியைத் தேர்ந்தெடு..."
            : "இப்போது வடிவ விளையாட்டு... அதே வடிவப் பெட்டியைத் தேர்ந்தெடு... வட்டம் என்றால் வட்டம், சதுரம் என்றால் சதுரம்...";
        break;
      case 'en':
      default:
        text = newRule == 'color'
            ? "Now we play the color game... Tap the box with the same color..."
            : "Now we play the shape game... Tap the box with the same shape... Circle goes to circle, square goes to square...";
        break;
    }
    await _speakSlowly(text);
  }

  /// Speak feedback after each trial
  static Future<void> speakFeedback(bool isCorrect, String language) async {
    if (!_speechEnabled || !_initialized) return;
    await _tts.stop();

    String text;
    if (isCorrect) {
      switch (language) {
        case 'si':
          text = [
            "හරි!",
            "වාහ්! ගොඩක් හොඳයි!",
            "ඔයා දක්ෂයි!"
          ][DateTime.now().millisecond % 3];
          break;
        case 'ta':
          text = [
            "சரி!",
            "வாவ்! மிக நன்று!",
            "நீ அருமை!"
          ][DateTime.now().millisecond % 3];
          break;
        case 'en':
        default:
          text = [
            "Correct!",
            "Wow! Great job!",
            "You're doing great!"
          ][DateTime.now().millisecond % 3];
          break;
      }
    } else {
      switch (language) {
        case 'si':
          text = "කමක් නැහැ... ඊළඟ එක බලමු...";
          break;
        case 'ta':
          text = "பரவாயில்லை... அடுத்ததைப் பார்ப்போம்...";
          break;
        case 'en':
        default:
          text = "That's okay... Let's try the next one...";
          break;
      }
    }
    await _tts.speak(text);
  }

  /// Speak phase transition message
  static Future<void> speakPhaseStart(String phase, String language) async {
    if (!_speechEnabled || !_initialized) return;
    await _tts.stop();

    String text;
    switch (phase) {
      case 'practice':
        switch (language) {
          case 'si':
            text = "පුහුණුව පටන් ගමු...";
            break;
          case 'ta':
            text = "பயிற்சி தொடங்குகிறது...";
            break;
          default:
            text = "Let's practice first...";
        }
        break;
      case 'pre_switch':
        switch (language) {
          case 'si':
            text = "පාට සෙල්ලම පටන් ගමු!";
            break;
          case 'ta':
            text = "நிற விளையாட்டு தொடங்குகிறது!";
            break;
          default:
            text = "Color game starting!";
        }
        break;
      case 'post_switch':
        switch (language) {
          case 'si':
            text = "දැන් හැඩ සෙල්ලම! හැඩය බලන්න!";
            break;
          case 'ta':
            text = "இப்போது வடிவ விளையாட்டு! வடிவத்தைப் பார்!";
            break;
          default:
            text = "Now the shape game! Look at the shape!";
        }
        break;
      case 'mixed':
        switch (language) {
          case 'si':
            text = "දැන් මිශ්‍ර සෙල්ලම! හොඳින් බලන්න!";
            break;
          case 'ta':
            text = "இப்போது கலப்பு விளையாட்டு! நன்றாகப் பார்!";
            break;
          default:
            text = "Now the mixed game! Watch carefully!";
        }
        break;
      default:
        return;
    }
    await _tts.speak(text);
  }

  /// Speak game completion message
  static Future<void> speakGameComplete(String language) async {
    if (!_speechEnabled || !_initialized) return;
    await _tts.stop();

    String text;
    switch (language) {
      case 'si':
        text = "ඔයා ඉවර කළා! ඔයා ගොඩක් දක්ෂයි! ස්තූතියි!";
        break;
      case 'ta':
        text = "நீ முடித்துவிட்டாய்! நீ மிகவும் சூப்பர்! நன்றி!";
        break;
      case 'en':
      default:
        text = "You finished! You did amazing! Thank you!";
        break;
    }
    await _speakSlowly(text);
  }

  // Helper: speak slowly with small pauses for warmth
  static Future<void> _speakSlowly(String text) async {
    final sentences = text.split('...');
    for (int i = 0; i < sentences.length; i++) {
      if (sentences[i].trim().isNotEmpty) {
        await _tts.speak(sentences[i].trim());
        // Wait for speech to complete
        await Future.delayed(const Duration(milliseconds: 1500));
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
