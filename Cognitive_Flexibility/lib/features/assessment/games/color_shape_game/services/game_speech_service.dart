// lib/features/assessment/games/color_shape_game/services/game_speech_service.dart
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// Speech service for DCCS (Dimensional Change Card Sort) game
/// Provides calm, clear voice instructions for children
class GameSpeechService {
  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;
  static bool _speechEnabled = true;
  static Completer<void>? _speechCompleter;

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

      // Set up completion handler to properly wait for speech to finish
      _tts.setCompletionHandler(() {
        if (_speechCompleter != null && !_speechCompleter!.isCompleted) {
          _speechCompleter!.complete();
        }
      });

      _initialized = true;
      debugPrint('DCCS Speech ready! Language: $ttsLanguage');
    } catch (e) {
      debugPrint('Speech init failed: $e');
      _speechEnabled = false;
    }
  }

  static Future<void> setLanguage(String language) async {
    if (!_initialized) {
      await initialize(language: language);
      return;
    }
    
    // Just update the language without re-initializing everything
    try {
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
        // Slightly slower rate for Sinhala/Tamil to ensure clarity
        if (language == 'si' || language == 'ta') {
          await _tts.setSpeechRate(0.38); // Even slower for non-English
        } else {
          await _tts.setSpeechRate(0.42); // Normal slow rate for English
        }
        debugPrint('Language set to: $ttsLanguage');
      } else {
        debugPrint('Language $ttsLanguage not available');
      }
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }

  // ================================================
  // DCCS GAME INSTRUCTIONS
  // ================================================
  
  /// Speak main game instructions
  static Future<void> speakInstructions(String language) async {
    if (!_speechEnabled || !_initialized) return;
    await _tts.stop();
    
    // Ensure language is set before speaking
    await setLanguage(language);

    String text;
    switch (language) {
      case 'si':
        text = '''
හායි පුංචි යාළුවා...
අපි සෙල්ලමක් කරමු...
මේ තියෙන්නේ රතු රවුමකුයි නිල් කොටුවකුයි...
මුලින්ම අපි පාට තෝරමු...
කාඩ්පත බැලුවාම, එකේ පාටම තියෙන පෙට්ටිය තෝරන්න...
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
    
    // Ensure language is set before speaking
    await setLanguage(language);

    String text;
    switch (language) {
      case 'si':
        text = newRule == 'color'
            ? "දැන් පාට සෙල්ලම... එකම පාට තෝරන්න..."
            : "දැන් හැඩතල සෙල්ලම... එකම හැඩය තෝරන්න... රවුම් නම් රවුම, හතරැස් නම් කොටුව...";
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
    
    // Ensure language is set before speaking
    await setLanguage(language);

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
    await speak(text, language: language);
  }

  /// Speak phase transition message
  static Future<void> speakPhaseStart(String phase, String language) async {
    if (!_speechEnabled || !_initialized) return;
    await _tts.stop();
    
    // Ensure language is set before speaking
    await setLanguage(language);

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
    await speak(text, language: language);
  }

  /// Speak game completion message
  static Future<void> speakGameComplete(String language) async {
    if (!_speechEnabled || !_initialized) return;
    await _tts.stop();
    
    // Ensure language is set before speaking
    await setLanguage(language);

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
  // Properly waits for each sentence to complete before speaking the next
  static Future<void> _speakSlowly(String text) async {
    if (!_speechEnabled || !_initialized) return;
    
    // Split by ellipsis (...) or periods for natural pauses
    // Keep the delimiter to maintain natural flow
    final sentences = text.split(RegExp(r'(\.\.\.|\.)'));
    final List<String> cleanSentences = [];
    
    // Reconstruct sentences with their punctuation
    for (int i = 0; i < sentences.length; i++) {
      final part = sentences[i].trim();
      if (part.isEmpty) continue;
      
      // Check if next part is punctuation
      if (i + 1 < sentences.length && 
          (sentences[i + 1] == '...' || sentences[i + 1] == '.')) {
        cleanSentences.add(part + sentences[i + 1]);
        i++; // Skip the punctuation in next iteration
      } else {
        cleanSentences.add(part);
      }
    }
    
    for (int i = 0; i < cleanSentences.length; i++) {
      final sentence = cleanSentences[i].trim();
      if (sentence.isEmpty) continue;
      
      // Create a completer for this sentence
      _speechCompleter = Completer<void>();
      
      try {
        // Speak the sentence
        await _tts.speak(sentence);
        
        // Calculate timeout based on sentence length (longer sentences need more time)
        // Sinhala/Tamil characters might need more time per character
        final estimatedDuration = sentence.length * 150; // ~150ms per character
        final timeoutDuration = Duration(
          milliseconds: estimatedDuration.clamp(3000, 20000), // Min 3s, Max 20s
        );
        
        // Wait for speech to actually complete (with adaptive timeout)
        await _speechCompleter!.future.timeout(
          timeoutDuration,
          onTimeout: () {
            debugPrint('Speech timeout for sentence (${sentence.length} chars): ${sentence.substring(0, sentence.length > 30 ? 30 : sentence.length)}...');
          },
        );
        
        // Add a pause between sentences for clarity
        // Longer pause for longer sentences and non-English
        final isLongSentence = sentence.length > 30;
        final pauseDuration = isLongSentence 
            ? const Duration(milliseconds: 1000) // 1 second for long sentences
            : const Duration(milliseconds: 600);   // 600ms for shorter sentences
        await Future.delayed(pauseDuration);
        
      } catch (e) {
        debugPrint('Error speaking sentence: $e');
        // Continue with next sentence even if one fails
      } finally {
        _speechCompleter = null;
      }
    }
  }

  // ================================================
  // CONTROLS
  // ================================================
  static Future<void> speak(String text, {String? language}) async {
    if (!_speechEnabled || !_initialized) return;
    await _tts.stop();
    
    // Set language if provided
    if (language != null) {
      await setLanguage(language);
    }
    
    // Use completer to wait for completion
    _speechCompleter = Completer<void>();
    await _tts.speak(text);
    
    try {
      await _speechCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Speech timeout for: $text');
        },
      );
    } catch (e) {
      debugPrint('Error waiting for speech: $e');
    } finally {
      _speechCompleter = null;
    }
  }

  static void setSpeechEnabled(bool enabled) {
    _speechEnabled = enabled;
  }

  static bool get speechEnabled => _speechEnabled;

  static Future<void> stop() async {
    await _tts.stop();
  }
}
