/// Real-Time Audio Detection Service
/// 
/// Records audio from microphone and detects:
/// - Name calling events
/// - Child vocalizations
/// - Sound events
/// - Sends to backend for analysis in real-time
/// 
/// This is a NEW service - does not modify existing files

import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import '../config/backend_config.dart';

/// Real-time audio detection service
class RealtimeAudioDetectionService {
  // Stream controllers for real-time audio events
  final _audioEventController = StreamController<AudioDetectionEvent>.broadcast();
  final _nameCallController = StreamController<NameCallEvent>.broadcast();
  final _vocalizationController = StreamController<VocalizationEvent>.broadcast();
  final _soundEventController = StreamController<SoundEvent>.broadcast();
  
  // State
  bool _isRecording = false;
  bool _isProcessing = false;
  Timer? _processingTimer;
  String? _childName;
  
  // Audio processing settings
  static const int sampleRate = 16000; // 16kHz for speech
  static const int chunkDurationMs = 500; // Process every 500ms
  static const double soundThreshold = 0.02; // Minimum sound level
  
  /// Stream of all audio detection events
  Stream<AudioDetectionEvent> get audioEventStream => _audioEventController.stream;
  
  /// Stream of name call detections
  Stream<NameCallEvent> get nameCallStream => _nameCallController.stream;
  
  /// Stream of child vocalization detections
  Stream<VocalizationEvent> get vocalizationStream => _vocalizationController.stream;
  
  /// Stream of general sound events
  Stream<SoundEvent> get soundEventStream => _soundEventController.stream;
  
  /// Start real-time audio detection
  /// 
  /// [childName] - Name of the child to detect when called
  Future<bool> startDetection({required String childName}) async {
    if (_isRecording) {
      print('Audio detection already running');
      return true;
    }
    
    // Request microphone permission
    final permissionStatus = await Permission.microphone.request();
    if (!permissionStatus.isGranted) {
      print('Microphone permission denied');
      return false;
    }
    
    _childName = childName;
    _isRecording = true;
    _isProcessing = true;
    
    print('Starting real-time audio detection for: $childName');
    
    // Start processing audio chunks
    _processingTimer = Timer.periodic(
      Duration(milliseconds: chunkDurationMs),
      (_) => _processAudioChunk(),
    );
    
    return true;
  }
  
  /// Stop real-time audio detection
  void stopDetection() {
    if (!_isRecording) return;
    
    _isRecording = false;
    _isProcessing = false;
    _processingTimer?.cancel();
    _processingTimer = null;
    
    print('Stopped real-time audio detection');
  }
  
  /// Process audio chunk (sends to backend for analysis)
  Future<void> _processAudioChunk() async {
    if (!_isProcessing || _childName == null) return;
    
    try {
      // In a real implementation, you would:
      // 1. Record audio chunk from microphone
      // 2. Convert to appropriate format
      // 3. Send to backend for analysis
      // 4. Process response and emit events
      
      // For now, this is a framework that can be extended
      // You would use packages like:
      // - record (for microphone recording)
      // - flutter_sound (for audio processing)
      // - or platform channels for native audio recording
      
      // Example: Send audio chunk to backend
      await _sendAudioChunkToBackend();
      
    } catch (e) {
      print('Error processing audio chunk: $e');
    }
  }
  
  /// Send audio chunk to backend for real-time analysis
  Future<void> _sendAudioChunkToBackend() async {
    try {
      // This would send actual audio data to backend
      // For now, it's a placeholder that shows the structure
      
      final response = await http.post(
        Uri.parse('${BackendConfig.baseUrl}/api/analyze-audio-realtime'),
        headers: {'Content-Type': 'application/json'},
        body: {
          'child_name': _childName ?? '',
          'timestamp': DateTime.now().toIso8601String(),
          // 'audio_data': base64EncodedAudioChunk, // In real implementation
        },
      ).timeout(const Duration(seconds: 2));
      
      if (response.statusCode == 200) {
        // Parse response and emit events
        // final data = jsonDecode(response.body);
        // _processBackendResponse(data);
      }
    } catch (e) {
      // Silently handle errors (network issues, etc.)
      // Don't spam console with errors during real-time processing
    }
  }
  
  /// Process backend response and emit events
  void _processBackendResponse(Map<String, dynamic> data) {
    final timestamp = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    // Check for name calls
    if (data['name_call_detected'] == true) {
      final nameCallEvent = NameCallEvent(
        timestamp: timestamp,
        confidence: (data['confidence'] ?? 0.8).toDouble(),
        childName: _childName ?? '',
      );
      
      _nameCallController.add(nameCallEvent);
      _audioEventController.add(AudioDetectionEvent(
        type: AudioEventType.nameCall,
        timestamp: timestamp,
        confidence: nameCallEvent.confidence,
      ));
    }
    
    // Check for vocalizations
    if (data['vocalization_detected'] == true) {
      final vocalizationEvent = VocalizationEvent(
        timestamp: timestamp,
        confidence: (data['confidence'] ?? 0.7).toDouble(),
      );
      
      _vocalizationController.add(vocalizationEvent);
      _audioEventController.add(AudioDetectionEvent(
        type: AudioEventType.vocalization,
        timestamp: timestamp,
        confidence: vocalizationEvent.confidence,
      ));
    }
    
    // Check for sound events
    if (data['sound_detected'] == true) {
      final soundEvent = SoundEvent(
        timestamp: timestamp,
        intensity: (data['intensity'] ?? 0.5).toDouble(),
      );
      
      _soundEventController.add(soundEvent);
      _audioEventController.add(AudioDetectionEvent(
        type: AudioEventType.sound,
        timestamp: timestamp,
        confidence: soundEvent.intensity,
      ));
    }
  }
  
  /// Manually trigger a name call event (for testing)
  void simulateNameCall({double confidence = 0.85}) {
    if (!_isRecording) return;
    
    final event = NameCallEvent(
      timestamp: DateTime.now().millisecondsSinceEpoch / 1000.0,
      confidence: confidence,
      childName: _childName ?? '',
    );
    
    _nameCallController.add(event);
    _audioEventController.add(AudioDetectionEvent(
      type: AudioEventType.nameCall,
      timestamp: event.timestamp,
      confidence: event.confidence,
    ));
  }
  
  /// Dispose resources
  void dispose() {
    stopDetection();
    _audioEventController.close();
    _nameCallController.close();
    _vocalizationController.close();
    _soundEventController.close();
  }
}

// ============================================================================
// Data Models
// ============================================================================

/// Base audio detection event
class AudioDetectionEvent {
  final AudioEventType type;
  final double timestamp;
  final double confidence;
  
  AudioDetectionEvent({
    required this.type,
    required this.timestamp,
    required this.confidence,
  });
}

/// Types of audio events
enum AudioEventType {
  nameCall,      // Child's name was called
  vocalization,  // Child made a sound/vocalization
  sound,         // General sound detected
}

/// Name call detection event
class NameCallEvent {
  final double timestamp;
  final double confidence; // 0.0 to 1.0
  final String childName;
  
  NameCallEvent({
    required this.timestamp,
    required this.confidence,
    required this.childName,
  });
}

/// Child vocalization detection event
class VocalizationEvent {
  final double timestamp;
  final double confidence; // 0.0 to 1.0
  
  VocalizationEvent({
    required this.timestamp,
    required this.confidence,
  });
}

/// General sound event
class SoundEvent {
  final double timestamp;
  final double intensity; // 0.0 to 1.0
  
  SoundEvent({
    required this.timestamp,
    required this.intensity,
  });
}















