/// Real-Time Audio Detection Page
/// 
/// NEW PAGE - Shows how to use real-time audio detection
/// Does not modify existing files

import 'package:flutter/material.dart';
import 'dart:async';
import '../services/realtime_audio_detection_service.dart';

class RealtimeAudioPage extends StatefulWidget {
  final String childName;
  
  const RealtimeAudioPage({
    super.key,
    required this.childName,
  });

  @override
  State<RealtimeAudioPage> createState() => _RealtimeAudioPageState();
}

class _RealtimeAudioPageState extends State<RealtimeAudioPage> {
  final RealtimeAudioDetectionService _audioService = RealtimeAudioDetectionService();
  
  bool _isDetecting = false;
  final List<String> _detections = [];
  StreamSubscription? _nameCallSubscription;
  StreamSubscription? _vocalizationSubscription;
  StreamSubscription? _soundSubscription;
  
  int _nameCallCount = 0;
  int _vocalizationCount = 0;
  int _soundEventCount = 0;
  
  @override
  void initState() {
    super.initState();
    _setupListeners();
  }
  
  void _setupListeners() {
    // Listen for name call detections
    _nameCallSubscription = _audioService.nameCallStream.listen((event) {
      setState(() {
        _nameCallCount++;
        _detections.insert(0, 
          '[${_formatTime(event.timestamp)}] Name called: ${event.childName} (${(event.confidence * 100).toStringAsFixed(0)}% confidence)'
        );
        if (_detections.length > 20) _detections.removeLast();
      });
    });
    
    // Listen for vocalizations
    _vocalizationSubscription = _audioService.vocalizationStream.listen((event) {
      setState(() {
        _vocalizationCount++;
        _detections.insert(0,
          '[${_formatTime(event.timestamp)}] Child vocalization detected (${(event.confidence * 100).toStringAsFixed(0)}% confidence)'
        );
        if (_detections.length > 20) _detections.removeLast();
      });
    });
    
    // Listen for sound events
    _soundSubscription = _audioService.soundEventStream.listen((event) {
      setState(() {
        _soundEventCount++;
      });
    });
  }
  
  String _formatTime(double timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).toInt());
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }
  
  Future<void> _toggleDetection() async {
    if (_isDetecting) {
      _audioService.stopDetection();
      setState(() {
        _isDetecting = false;
      });
    } else {
      final started = await _audioService.startDetection(childName: widget.childName);
      if (started) {
        setState(() {
          _isDetecting = true;
          _detections.clear();
          _nameCallCount = 0;
          _vocalizationCount = 0;
          _soundEventCount = 0;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start audio detection. Please grant microphone permission.')),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _nameCallSubscription?.cancel();
    _vocalizationSubscription?.cancel();
    _soundSubscription?.cancel();
    _audioService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Audio Detection'),
        backgroundColor: const Color(0xFF7132C1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Status card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isDetecting ? Colors.green.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isDetecting ? Colors.green : Colors.grey,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isDetecting ? Icons.mic : Icons.mic_off,
                      size: 40,
                      color: _isDetecting ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isDetecting ? 'Listening...' : 'Stopped',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _isDetecting ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _toggleDetection,
                  icon: Icon(_isDetecting ? Icons.stop : Icons.play_arrow),
                  label: Text(_isDetecting ? 'Stop Detection' : 'Start Detection'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isDetecting ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
          
          // Statistics
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Name Calls',
                    count: _nameCallCount,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Vocalizations',
                    count: _vocalizationCount,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Sounds',
                    count: _soundEventCount,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Detections list
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Real-Time Detections',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _detections.isEmpty
                        ? Center(
                            child: Text(
                              _isDetecting
                                  ? 'Listening for audio events...'
                                  : 'Start detection to begin monitoring',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _detections.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  _detections[index],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  
  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}





