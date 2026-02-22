import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class GameAudioService {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _backgroundPlayer = AudioPlayer();
  static bool _soundEnabled = true;
  static bool _initialized = false;
  static bool _backgroundPlaying = false;

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

  static Future<void> startBackgroundMusic() async {
    if (!_soundEnabled || _backgroundPlaying) return;
    try {
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer.setVolume(0.35);
      await _backgroundPlayer.play(
        AssetSource('audio/kid-background.mp3'),
      );
      _backgroundPlaying = true;
    } catch (e) {
      debugPrint('Error starting frog background music: $e');
    }
  }

  static Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping frog background music: $e');
    } finally {
      _backgroundPlaying = false;
    }
  }

  static Future<void> dispose() async {
    try {
      await _player.dispose();
      await _backgroundPlayer.dispose();
    } catch (e) {
      debugPrint('Error disposing audio player: $e');
    }
  }
}