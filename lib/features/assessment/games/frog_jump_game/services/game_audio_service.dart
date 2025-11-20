import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class GameAudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _soundEnabled = true;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    debugPrint('Frog Jump Audio service initialized');
  }

  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  static Future<void> playCorrectSound() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('audio/correct.mp3'), mode: PlayerMode.lowLatency);
    } catch (e) {
      debugPrint('Error playing correct sound: $e');
    }
  }

  static Future<void> playWrongSound() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('audio/wrong.mp3'), mode: PlayerMode.lowLatency);
    } catch (e) {
      debugPrint('Error playing wrong sound: $e');
    }
  }

  static Future<void> playTapSound() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('audio/tap.mp3'), mode: PlayerMode.lowLatency);
    } catch (e) {
      debugPrint('Error playing tap sound: $e');
    }
  }

  static Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (e) {
      debugPrint('Error disposing audio player: $e');
    }
  }
}

