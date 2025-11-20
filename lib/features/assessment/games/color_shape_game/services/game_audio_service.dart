import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class GameAudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _soundEnabled = true;

  static Future<void> playCorrectSound() async {
    if (!_soundEnabled) return;
    try {
      // Play two tones for correct answer
      await _playTone(523.25, 200); // C5
      await Future.delayed(const Duration(milliseconds: 100));
      await _playTone(659.25, 150); // E5
    } catch (e) {
      debugPrint('Error playing correct sound: $e');
    }
  }

  static Future<void> playWrongSound() async {
    if (!_soundEnabled) return;
    try {
      await _playTone(261.63, 300); // C4 (lower, sadder tone)
    } catch (e) {
      debugPrint('Error playing wrong sound: $e');
    }
  }

  static Future<void> playTapSound() async {
    if (!_soundEnabled) return;
    try {
      await _playTone(440, 100); // A4
    } catch (e) {
      debugPrint('Error playing tap sound: $e');
    }
  }

  static Future<void> playRuleChangeSound() async {
    if (!_soundEnabled) return;
    try {
      await _playTone(392, 150); // G4
      await Future.delayed(const Duration(milliseconds: 100));
      await _playTone(523.25, 150); // C5
      await Future.delayed(const Duration(milliseconds: 100));
      await _playTone(659.25, 150); // E5
    } catch (e) {
      debugPrint('Error playing rule change sound: $e');
    }
  }

  static Future<void> _playTone(double frequency, int durationMs) async {
    // Note: audioplayers doesn't support tone generation directly
    // For now, we'll use a simple approach
    // In production, you might want to use audio files or a tone generator package
    // This is a placeholder - you can add actual sound files later
    debugPrint('Playing tone: $frequency Hz for ${durationMs}ms');
  }

  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  static bool get soundEnabled => _soundEnabled;
}


