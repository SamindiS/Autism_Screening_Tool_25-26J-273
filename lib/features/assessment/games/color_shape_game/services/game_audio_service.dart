// lib/core/services/game_audio_service.dart
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class GameAudioService {
  static final AudioPlayer _sfxPlayer = AudioPlayer()
    ..setPlayerMode(PlayerMode.lowLatency);
  static final AudioPlayer _backgroundPlayer = AudioPlayer();

  static bool _soundEnabled = true;
  static bool _backgroundPlaying = false;

  // ================================================
  // PUBLIC CONTROLS
  // ================================================
  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled && _backgroundPlaying) {
      stopBackgroundMusic();
    }
  }

  static bool get soundEnabled => _soundEnabled;

  // ================================================
  // FEEDBACK SOUNDS
  // ================================================
  static Future<void> playCorrectSound() async {
    if (!_soundEnabled) return;
    await _playTone(523.25, 180); // C5
    await Future.delayed(const Duration(milliseconds: 80));
    await _playTone(659.25, 180); // E5
    await Future.delayed(const Duration(milliseconds: 80));
    await _playTone(783.99, 250); // G5 – happy finish!
  }

  static Future<void> playWrongSound() async {
    if (!_soundEnabled) return;
    await _playTone(349.23, 200); // F4
    await Future.delayed(const Duration(milliseconds: 100));
    await _playTone(261.63, 400); // C4 – sad low tone
  }

  static Future<void> playTapSound() async {
    if (!_soundEnabled) return;
    await _playTone(880, 80); // A5 – quick, light tap
  }

  static Future<void> playRuleChangeSound() async {
    if (!_soundEnabled) return;
    await _playTone(392.00, 150); // G4
    await Future.delayed(const Duration(milliseconds: 100));
    await _playTone(587.33, 150); // D5
    await Future.delayed(const Duration(milliseconds: 100));
    await _playTone(880.00, 300); // A5 – "attention!"
  }

  // ================================================
  // BACKGROUND MUSIC (very soft)
  // ================================================
  static Future<void> startBackgroundMusic() async {
    if (!_soundEnabled || _backgroundPlaying) return;

    try {
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer
          .setVolume(0.25); // ← VERY LOW, calming, never annoying
      await _backgroundPlayer.play(AssetSource('audio/kid-background.mp3'));
      _backgroundPlaying = true;
      debugPrint('Background music started (volume: 0.25)');
    } catch (e) {
      debugPrint('Background music failed: $e');
    }
  }

  static Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundPlayer.stop();
      _backgroundPlaying = false;
    } catch (e) {
      debugPrint('Error stopping background music: $e');
    }
  }

  // ================================================
  // REAL TONE GENERATOR (sine wave) – WORKS ON ALL DEVICES
  // ================================================
  static Future<void> _playTone(double frequency, int durationMs) async {
    if (!_soundEnabled) return;

    try {
      const sampleRate = 44100;
      final bytes = <int>[];
      final amplitude = 32767 * 0.3; // 30% volume for feedback tones

      for (var i = 0; i < (sampleRate * durationMs / 1000); i++) {
        final sine = sin(2 * pi * frequency * i / sampleRate);
        final sample = (sine * amplitude).toInt();

        // 16-bit little-endian
        bytes.add(sample & 0xFF);
        bytes.add((sample >> 8) & 0xFF);
      }

      await _sfxPlayer.play(BytesSource(Uint8List.fromList(bytes)));
    } catch (e) {
      if (kDebugMode) debugPrint('Tone failed: $e');
    }
  }
}
