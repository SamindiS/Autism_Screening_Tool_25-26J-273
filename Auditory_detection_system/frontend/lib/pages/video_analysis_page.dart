import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../config/backend_config.dart';
import 'parent_guidance_page.dart';
import 'tap_the_sound_page.dart';
import 'video_recording_page.dart';

class VideoAnalysisPage extends StatefulWidget {
  final String? childName;
  final int? childAge;
  
  const VideoAnalysisPage({super.key, this.childName, this.childAge});

  @override
  State<VideoAnalysisPage> createState() => _VideoAnalysisPageState();
}

class _VideoAnalysisPageState extends State<VideoAnalysisPage> {
  bool _isRecording = false;
  bool _isAnalyzing = false;
  String _rtnStatus = 'Waiting...';
  double _reactionTime = 0.0;
  List<String> _detectedActions = [];
  int _confidenceLevel = 0;
  String _behaviorClassification = 'No Response';
  
  // ML Prediction results
  String? _mlPrediction; // 'autism' or 'typical'
  double? _autismProbability;
  double? _typicalProbability;
  double? _mlConfidence;
  
  // Expanded behavioral markers (facial expression, body language, attention, vocalization)
  Map<String, dynamic>? _expandedBehavioralMarkers;
  Map<String, dynamic>? _audioAnalysisExpanded; // verbal response, babbling, echolalia
  
  // Video player
  VideoPlayerController? _videoController;
  String? _videoPath;
  bool _isVideoLoaded = false;
  bool _isUploading = false;
  
  // Pre-upload quality validation
  Map<String, dynamic>? _validationResult;
  bool _isValidating = false;
  
  /// True only after a successful full video analysis (200 response with results).
  /// Used to show Analysis Summary, Detailed Metrics, and Charts.
  bool _hasAnalysisResult = false;
  
  // Mock timer for demonstration
  int _elapsedSeconds = 0;

  /// Copy the selected/recorded video into an app-private cache directory so it
  /// is stable for validation and analysis (prevents \"Video file not found\").
  Future<String> _cacheVideoLocally(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return sourcePath;
      final appDir = await getApplicationDocumentsDirectory();
      final videosDir = Directory(p.join(appDir.path, 'videos'));
      if (!await videosDir.exists()) {
        await videosDir.create(recursive: true);
      }
      final ext = p.extension(sourcePath);
      final fileName =
          'analysis_${DateTime.now().millisecondsSinceEpoch}$ext';
      final cachedPath = p.join(videosDir.path, fileName);
      await sourceFile.copy(cachedPath);
      return cachedPath;
    } catch (_) {
      // If anything goes wrong, fall back to original path.
      return sourcePath;
    }
  }

  @override
  void initState() {
    super.initState();
    // Don't start mock analysis automatically - wait for video upload
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _startMockAnalysis() {
    // Mock analysis - in real app, this would connect to video processing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = true;
          _rtnStatus = 'Analyzing...';
        });
      }
    });
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _startAnalysis();
      } else {
        _stopAnalysis();
      }
    });
  }

  void _startAnalysis() {
    _isAnalyzing = true;
    _elapsedSeconds = 0;
    // Simulate real-time updates
    _simulateDetection();
  }

  void _stopAnalysis() {
    _isAnalyzing = false;
  }

  void _simulateDetection() {
    if (!_isAnalyzing) return;
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _isAnalyzing) {
        setState(() {
          _elapsedSeconds++;
          _reactionTime = _elapsedSeconds * 0.5;
          
          // Simulate detection events
          if (_elapsedSeconds == 2) {
            _rtnStatus = 'Responded';
            _behaviorClassification = 'Immediate Response';
            _detectedActions = ['Head turning', 'Eye movement'];
            _confidenceLevel = 85;
          } else if (_elapsedSeconds > 5 && _rtnStatus == 'Waiting...') {
            _rtnStatus = 'Not Responded';
            _behaviorClassification = 'No Response';
            _confidenceLevel = 60;
          }
        });
        _simulateDetection();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          'Auditory Response Analysis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Display Area
            _buildVideoDisplay(),
            const SizedBox(height: 24),
            
            // Control Buttons
            _buildControlButtons(),
            const SizedBox(height: 24),
            
            // Video quality validation result (pre-upload checks)
            if (_validationResult != null) ...[
              _buildValidationCard(),
              const SizedBox(height: 24),
            ],
            if (_isValidating)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFF7132C1)),
                      SizedBox(height: 12),
                      Text('Validating video quality...', style: TextStyle(color: Color(0xFF2C3E50))),
                    ],
                  ),
                ),
              ),
            
            // Real-Time Analysis Panel
            _buildAnalysisPanel(),
            const SizedBox(height: 24),
            
            // Behavior Classification
            _buildBehaviorClassification(),
            const SizedBox(height: 24),
            
            // Detected Actions
            _buildDetectedActions(),
            const SizedBox(height: 24),
            
            // Expanded Behavioral Markers (after analysis)
            if (_expandedBehavioralMarkers != null || _audioAnalysisExpanded != null) ...[
              _buildExpandedBehavioralMarkers(),
              const SizedBox(height: 24),
            ],
            
            // ML Prediction Results (if available)
            if (_mlPrediction != null)
              _buildMLPrediction(),
            if (_mlPrediction != null)
              const SizedBox(height: 24),
            
            // Full video analysis output (Summary, Detailed Metrics, Charts) – only after successful analysis
            if (_hasAnalysisResult) _buildAnalysisSummary(),
            if (_hasAnalysisResult) const SizedBox(height: 24),
            
            // Parent Guidance Button (shown after analysis or if age is 1-2)
            if (widget.childAge != null && widget.childAge! >= 1 && widget.childAge! <= 2)
              _buildParentGuidanceButton(),
            
            // Tap the Sound Game Button (shown if age is 3-4, for testing/direct access)
            if (widget.childAge != null && widget.childAge! >= 3 && widget.childAge! <= 4)
              _buildTapTheSoundButton(),
            
            // Quick Test Button (always visible for easy testing)
            _buildQuickTestButton(),
            const SizedBox(height: 16),
            
            // Export / Print PDF report for video analysis results
            _buildExportPdfButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoDisplay() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isAnalyzing ? const Color(0xFFC47BE4) : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Video player or placeholder
          if (_isVideoLoaded && _videoController != null)
            Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam,
                    size: 64,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isRecording ? 'Recording...' : _videoPath != null 
                        ? 'Video loaded: ${_videoPath!.split('/').last}'
                        : 'No video selected',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  if (_videoPath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton(
                        onPressed: _playVideo,
                        child: const Text(
                          'Play Video',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // Recording indicator
          if (_isRecording)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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

  Widget _buildControlButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadVideo,
                icon: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(_isUploading ? 'Uploading...' : 'Upload Video'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC47BE4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : _openRecordingPage,
                icon: const Icon(Icons.videocam),
                label: const Text('Record'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC47BE4),
                  side: const BorderSide(color: Color(0xFFC47BE4)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isVideoLoaded && !_isAnalyzing && _videoPath != null
                ? () => _analyzeVideoWithBackend(_videoPath!)
                : null,
            icon: _isAnalyzing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.analytics),
            label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Video'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFC47BE4),
              side: const BorderSide(color: Color(0xFFC47BE4)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (_isVideoLoaded) ...[
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _playVideo,
            icon: Icon(_videoController?.value.isPlaying ?? false
                ? Icons.pause
                : Icons.play_arrow),
            label: Text(_videoController?.value.isPlaying ?? false
                ? 'Pause'
                : 'Play'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _testBackendConnection,
          icon: const Icon(Icons.wifi_find),
          label: const Text('Test Backend Connection'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            side: const BorderSide(color: Colors.blue),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  /// Video quality validation result card (pre-upload checks)
  Widget _buildValidationCard() {
    final v = _validationResult!;
    final passed = v['passed'] == true;
    final rawChecks = v['checks'];
    final checks = (rawChecks == null || rawChecks is! Map) ? <String, dynamic>{} : Map<String, dynamic>.from(rawChecks as Map);
    final messages = (v['messages'] as List?)?.cast<dynamic>().map((e) => e.toString()).toList() ?? [];
    final labels = {
      'resolution': 'Resolution (720p min)',
      'duration': 'Duration (30s min)',
      'lighting': 'Lighting',
      'audio': 'Audio clarity',
      'face_visibility': 'Face visibility',
    };
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: passed ? Colors.green.withOpacity(0.5) : Colors.orange.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                passed ? Icons.check_circle : Icons.warning_amber_rounded,
                color: passed ? Colors.green : Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Video Quality Validation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (passed ? Colors.green : Colors.orange).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  passed ? 'PASSED' : 'ISSUES FOUND',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: passed ? Colors.green[800] : Colors.orange[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...checks.entries.map((e) {
            final check = e.value as Map?;
            final ok = check?['passed'] == true;
            final msg = check?['message']?.toString() ?? '';
            final label = labels[e.key] ?? e.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    ok ? Icons.check_circle : Icons.cancel,
                    size: 20,
                    color: ok ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                            fontSize: 14,
                          ),
                        ),
                        if (msg.isNotEmpty)
                          Text(
                            msg,
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          if (messages.isNotEmpty && !passed)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'You can still analyze the video, but results may be less accurate.',
                style: TextStyle(fontSize: 12, color: Colors.orange[800], fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalysisPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC47BE4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Color(0xFFC47BE4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Real-Time Analysis',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // RTN Status
          _buildStatusCard(
            'RTN Status',
            _rtnStatus,
            _getStatusColor(_rtnStatus),
          ),
          const SizedBox(height: 16),
          
          // Reaction Time
          _buildStatusCard(
            'Reaction Time',
            _reactionTime > 0 ? '${_reactionTime.toStringAsFixed(2)} seconds' : 'Not detected',
            const Color(0xFF2C3E50),
          ),
          const SizedBox(height: 16),
          
          // Confidence Level
          _buildConfidenceCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confidence Level',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$_confidenceLevel%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _confidenceLevel / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getConfidenceColor(_confidenceLevel),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBehaviorClassification() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC47BE4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.category,
                  color: Color(0xFFC47BE4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Behavior Classification',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildClassificationChip('Immediate Response', _behaviorClassification == 'Immediate Response'),
              _buildClassificationChip('Delayed Response', _behaviorClassification == 'Delayed Response'),
              _buildClassificationChip('Partial Response', _behaviorClassification == 'Partial Response'),
              _buildClassificationChip('No Response', _behaviorClassification == 'No Response'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFC47BE4)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? const Color(0xFFC47BE4)
              : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildDetectedActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC47BE4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.visibility,
                  color: Color(0xFFC47BE4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Detected Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_detectedActions.isEmpty)
            Text(
              'No actions detected yet',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _detectedActions.map((action) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC47BE4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFC47BE4).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: const Color(0xFFC47BE4),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        action,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// Expanded behavioral markers: facial expression, body language, attention, vocalization
  Widget _buildExpandedBehavioralMarkers() {
    final expanded = _expandedBehavioralMarkers;
    final audio = _audioAnalysisExpanded;
    if (expanded == null && audio == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC47BE4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Color(0xFFC47BE4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Expanded Behavioral Markers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (expanded != null) ...[
            _buildExpandedSection('Facial expression', Icons.face, [
              _expandedLine('Smile when name called', expanded['facial_expression']?['smile_detected_when_name_called']),
              _expandedLine('Dominant expression', expanded['facial_expression']?['dominant_expression']?.toString()),
              _expandedLine('Emotional coding', _formatEmotionalCoding(expanded['facial_expression']?['emotional_response_coding'])),
            ]),
            const SizedBox(height: 12),
            _buildExpandedSection('Body language', Icons.accessibility_new, [
              _expandedLine('Full-body orientation changes', expanded['body_language']?['full_body_orientation_changes']),
              _expandedLine('Hand/arm movements', expanded['body_language']?['hand_arm_movements_detected']),
              _expandedLine('Stimming candidate', expanded['body_language']?['stimming_candidate']),
              _expandedLine('Proximity seeking', expanded['body_language']?['proximity_seeking_count']),
            ]),
            const SizedBox(height: 12),
            _buildExpandedSection('Attention maintenance', Icons.visibility, [
              _expandedLine('Eye contact duration (s)', expanded['attention_maintenance']?['eye_contact_duration_seconds']),
              _expandedLine('Return to activity (s)', expanded['attention_maintenance']?['return_to_activity_speed_seconds']),
              _expandedLine('Return to activity detected', expanded['attention_maintenance']?['return_to_activity_detected']),
            ]),
          ],
          if (audio != null) ...[
            if (expanded != null) const SizedBox(height: 12),
            _buildExpandedSection('Vocalization', Icons.record_voice_over, [
              _expandedLine('Child verbally responded', audio['child_verbally_responded']),
              _expandedLine('Verbal responses count', (audio['verbal_responses'] as List?)?.length ?? 0),
              _expandedLine('Babbling/sound as response', (audio['babbling_or_sound_as_response'] as List?)?.length ?? 0),
              _expandedLine('Echolalia detected', (audio['echolalia_patterns'] as Map?)?['detected']),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedSection(String title, IconData icon, List<Widget> lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFFC47BE4)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...lines,
      ],
    );
  }

  Widget _expandedLine(String label, dynamic value) {
    final v = value == null ? '—' : value.toString();
    return Padding(
      padding: const EdgeInsets.only(left: 26, top: 4),
      child: Text(
        '$label: $v',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  String _formatEmotionalCoding(dynamic coding) {
    if (coding == null || coding is! Map) return '—';
    final n = coding['neutral'] ?? 0;
    final p = coding['positive'] ?? 0;
    final neg = coding['negative'] ?? 0;
    return 'neutral: $n, positive: $p, negative: $neg';
  }

  Widget _buildMLPrediction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC47BE4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Color(0xFFC47BE4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'ML Model Prediction',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Prediction result
          _buildStatusCard(
            'Prediction',
            _mlPrediction?.toUpperCase() ?? 'Unknown',
            _mlPrediction == 'autism' ? Colors.orange : Colors.blue,
          ),
          const SizedBox(height: 16),
          
          // Autism probability
          if (_autismProbability != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Autism Probability',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(_autismProbability! * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _autismProbability,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          if (_autismProbability != null)
            const SizedBox(height: 16),
          
          // Typical probability
          if (_typicalProbability != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Typical Probability',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(_typicalProbability! * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _typicalProbability,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          if (_typicalProbability != null)
            const SizedBox(height: 16),
          
          // Overall confidence
          if (_mlConfidence != null)
            _buildStatusCard(
              'Model Confidence',
              '${(_mlConfidence! * 100).toStringAsFixed(1)}%',
              _getConfidenceColor((_mlConfidence! * 100).toInt()),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC47BE4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.dashboard,
                  color: Color(0xFFC47BE4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Analysis Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Grid layout for summary cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              // RTN Detection
              _buildSummaryCard(
                'RTN Detection',
                _rtnStatus,
                _getStatusColor(_rtnStatus),
                Icons.hearing,
              ),
              
              // Reaction Time
              _buildSummaryCard(
                'Reaction Time',
                _reactionTime > 0 ? '${_reactionTime.toStringAsFixed(2)}s' : 'Not detected',
                const Color(0xFF2C3E50),
                Icons.timer,
              ),
              
              // Confidence Score
              _buildSummaryCard(
                'Confidence',
                '$_confidenceLevel%',
                _getConfidenceColor(_confidenceLevel),
                Icons.assessment,
              ),
              
              // Behavior Classification
              _buildSummaryCard(
                'Behavior',
                _behaviorClassification,
                const Color(0xFFC47BE4),
                Icons.category,
              ),
              
              // Detected Actions Count
              _buildSummaryCard(
                'Actions',
                '${_detectedActions.length}',
                Colors.blue,
                Icons.visibility,
              ),
              
              // ML Prediction (if available)
              if (_mlPrediction != null)
                _buildSummaryCard(
                  'ML Prediction',
                  _mlPrediction!.toUpperCase(),
                  _mlPrediction == 'autism' ? Colors.orange : Colors.blue,
                  Icons.psychology,
                )
              else
                _buildSummaryCard(
                  'ML Prediction',
                  'N/A',
                  Colors.grey,
                  Icons.psychology,
                ),
            ],
          ),
          
          // Detailed breakdown section
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          
          // Detailed metrics
          const Text(
            'Detailed Metrics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          
          // RTN Status detail
          _buildDetailRow('RTN Status', _rtnStatus, _getStatusColor(_rtnStatus)),
          const SizedBox(height: 12),
          
          // Reaction Time detail
          _buildDetailRow('Reaction Time', _reactionTime > 0 ? '${_reactionTime.toStringAsFixed(2)} seconds' : 'Not detected', const Color(0xFF2C3E50)),
          const SizedBox(height: 12),
          
          // Confidence Level detail
          _buildDetailRow('Confidence Level', '$_confidenceLevel%', _getConfidenceColor(_confidenceLevel)),
          const SizedBox(height: 12),
          
          // Behavior Classification detail
          _buildDetailRow('Behavior Classification', _behaviorClassification, const Color(0xFFC47BE4)),
          const SizedBox(height: 12),
          
          // Detected Actions detail
          _buildDetailRow(
            'Detected Actions',
            _detectedActions.isEmpty ? 'None' : _detectedActions.join(', '),
            Colors.blue,
          ),
          
          // ML Prediction details (if available)
          if (_mlPrediction != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow('ML Prediction', _mlPrediction!.toUpperCase(), _mlPrediction == 'autism' ? Colors.orange : Colors.blue),
            if (_autismProbability != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Autism Probability: ${(_autismProbability! * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
            if (_typicalProbability != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Typical Probability: ${(_typicalProbability! * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
            if (_mlConfidence != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Model Confidence: ${(_mlConfidence! * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ],
          
          // Analytical Visualizations Section
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),
          
          const Text(
            'Analytical Visualizations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 20),
          
          // ML Prediction Probabilities Bar Chart
          if (_mlPrediction != null && _autismProbability != null && _typicalProbability != null)
            _buildMLPredictionChart(),
          
          if (_mlPrediction != null && _autismProbability != null && _typicalProbability != null)
            const SizedBox(height: 20),
          
          // Confidence Level Gauge Chart
          _buildConfidenceGauge(),
          
          const SizedBox(height: 20),
          
          // Reaction Time Visualization
          _buildReactionTimeChart(),
          
          const SizedBox(height: 20),
          
          // Detected Actions Frequency Chart
          if (_detectedActions.isNotEmpty)
            _buildActionsFrequencyChart(),
          
          if (_detectedActions.isNotEmpty)
            const SizedBox(height: 20),
          
          // RTN Status Breakdown
          _buildRTNStatusChart(),
          
          const SizedBox(height: 20),
          
          // Behavior Classification Chart
          _buildBehaviorClassificationChart(),
          
          const SizedBox(height: 20),
          
          // Comprehensive Metrics Comparison
          _buildMetricsComparisonChart(),
        ],
      ),
    );
  }

  // ML Prediction Probabilities Bar Chart
  Widget _buildMLPredictionChart() {
    final autismProb = (_autismProbability ?? 0.0) * 100;
    final typicalProb = (_typicalProbability ?? 0.0) * 100;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ML Prediction Probabilities',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.grey[800]!,
                    tooltipRoundedRadius: 8,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Autism',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          case 1:
                            return const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Typical',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          default:
                            return const Text('');
                        }
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        final v = value.toInt();
                        if (v % 20 != 0 && v != 0) return const SizedBox.shrink();
                        return Text(
                          '$v%',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: autismProb.clamp(0.0, 100.0),
                        color: Colors.orange,
                        width: 40,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: typicalProb.clamp(0.0, 100.0),
                        color: Colors.blue,
                        width: 40,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ],
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200]!,
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Confidence Level Gauge Chart (donut with percentage in center, like reference)
  Widget _buildConfidenceGauge() {
    final confValue = _confidenceLevel.toDouble();
    final otherValue = (100 - _confidenceLevel).toDouble();
    // Avoid zero-size section so donut renders correctly
    final safeConf = confValue < 0.5 ? 0.5 : confValue;
    final safeOther = otherValue < 0.5 ? 0.5 : otherValue;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confidence Level',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    sections: [
                      PieChartSectionData(
                        value: safeConf,
                        title: '',
                        color: _getConfidenceColor(_confidenceLevel),
                        radius: 50,
                      ),
                      PieChartSectionData(
                        value: safeOther,
                        title: '',
                        color: Colors.grey[300]!,
                        radius: 50,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    '$_confidenceLevel%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Confidence: $_confidenceLevel%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _getConfidenceColor(_confidenceLevel),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reaction Time Chart
  Widget _buildReactionTimeChart() {
    // Normalize reaction time to a scale (assuming max 5 seconds)
    final maxReactionTime = 5.0;
    final normalizedTime = (_reactionTime / maxReactionTime * 100).clamp(0.0, 100.0);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reaction Time Analysis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.grey[800]!,
                    tooltipRoundedRadius: 8,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${_reactionTime.toStringAsFixed(2)}s',
                            style: const TextStyle(
                              color: Color(0xFF2C3E50),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: normalizedTime,
                        color: _reactionTime < 1.0
                            ? Colors.green
                            : _reactionTime < 2.0
                                ? Colors.orange
                                : Colors.red,
                        width: 60,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ],
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200]!,
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Fast (<1s)', Colors.green),
              _buildLegendItem('Moderate (1-2s)', Colors.orange),
              _buildLegendItem('Slow (>2s)', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  // Detected Actions Frequency Chart
  Widget _buildActionsFrequencyChart() {
    // Count frequency of each action
    final actionCounts = <String, int>{};
    for (var action in _detectedActions) {
      actionCounts[action] = (actionCounts[action] ?? 0) + 1;
    }
    
    final sortedActions = actionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detected Actions Frequency',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: sortedActions.length * 50.0 + 40,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                maxY: sortedActions.isEmpty
                    ? 1
                    : sortedActions.first.value.toDouble() + 1,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.grey[800]!,
                    tooltipRoundedRadius: 8,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 100,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < sortedActions.length) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              sortedActions[index].key,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < sortedActions.length) {
                          return Text(
                            '${sortedActions[index].value}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: sortedActions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final action = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: action.value.toDouble(),
                        color: Colors.blue.withOpacity(0.7),
                        width: 20,
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200]!,
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // RTN Status Breakdown Pie Chart
  Widget _buildRTNStatusChart() {
    final statusColor = _getStatusColor(_rtnStatus);
    final isResponded = _rtnStatus == 'Responded';
    final respondedValue = isResponded ? 100.0 : 0.0;
    final notRespondedValue = isResponded ? 0.0 : 100.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RTN Status Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: [
                        PieChartSectionData(
                          value: respondedValue,
                          title: isResponded ? '100%' : '0%',
                          color: isResponded ? Colors.green : Colors.grey[300],
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: notRespondedValue,
                          title: isResponded ? '0%' : '100%',
                          color: isResponded ? Colors.grey[300] : Colors.red,
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusLegendItem('Responded', Colors.green, isResponded),
                    const SizedBox(height: 12),
                    _buildStatusLegendItem('Not Responded', Colors.red, !isResponded),
                    const SizedBox(height: 12),
                    _buildStatusLegendItem('Partial', Colors.orange, _rtnStatus == 'Partial'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLegendItem(String label, Color color, bool isActive) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isActive ? color : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? color : Colors.grey,
          ),
        ),
      ],
    );
  }

  // Behavior Classification Chart
  Widget _buildBehaviorClassificationChart() {
    // Create a visual representation of behavior classification
    final behaviorTypes = ['No Response', 'Partial Response', 'Full Response', 'Engaged'];
    final behaviorValues = [
      _behaviorClassification == 'No Response' ? 1.0 : 0.0,
      _behaviorClassification == 'Partial' ? 1.0 : 0.0,
      _behaviorClassification == 'Full Response' ? 1.0 : 0.0,
      _behaviorClassification == 'Engaged' ? 1.0 : 0.0,
    ];
    
    final behaviorColors = [
      Colors.red,
      Colors.orange,
      Colors.blue,
      Colors.green,
    ];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Behavior Classification',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1.0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.grey[800]!,
                    tooltipRoundedRadius: 8,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < behaviorTypes.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              behaviorTypes[index].split(' ').first,
                              style: TextStyle(
                                color: behaviorColors[index],
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 50,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: behaviorTypes.asMap().entries.map((entry) {
                  final index = entry.key;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: behaviorValues[index],
                        color: behaviorColors[index],
                        width: 30,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                gridData: FlGridData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(_behaviorClassification).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(_behaviorClassification),
                  width: 2,
                ),
              ),
              child: Text(
                'Current: $_behaviorClassification',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(_behaviorClassification),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Comprehensive Metrics Comparison Chart
  Widget _buildMetricsComparisonChart() {
    // Normalize all metrics to 0-100 scale for comparison
    final reactionTimeScore = ((5.0 - _reactionTime.clamp(0.0, 5.0)) / 5.0 * 100).clamp(0.0, 100.0);
    final confidenceScore = _confidenceLevel.toDouble();
    final mlConfidenceScore = (_mlConfidence ?? 0.0) * 100;
    final autismProbScore = (_autismProbability ?? 0.0) * 100;
    final typicalProbScore = (_typicalProbability ?? 0.0) * 100;
    
    final metrics = [
      'Reaction\nTime',
      'Confidence',
      'ML Confidence',
      'Autism Prob',
      'Typical Prob',
    ];
    
    final values = [
      reactionTimeScore,
      confidenceScore,
      mlConfidenceScore,
      autismProbScore,
      typicalProbScore,
    ];
    
    final colors = [
      _reactionTime < 1.0 ? Colors.green : _reactionTime < 2.0 ? Colors.orange : Colors.red,
      _getConfidenceColor(_confidenceLevel),
      _mlConfidence != null ? _getConfidenceColor((_mlConfidence! * 100).toInt()) : Colors.grey,
      Colors.orange,
      Colors.blue,
    ];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comprehensive Metrics Comparison',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.grey[800]!,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${values[groupIndex].toStringAsFixed(1)}%',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < metrics.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              metrics[index],
                              style: TextStyle(
                                color: colors[index],
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 50,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: metrics.asMap().entries.map((entry) {
                  final index = entry.key;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: values[index],
                        color: colors[index],
                        width: 35,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200]!,
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      // RTN Status
      case 'Responded':
        return Colors.green;
      case 'Not Responded':
        return Colors.red;
      case 'Partial':
        return Colors.orange;
      // Behavior Classification
      case 'No Response':
        return Colors.red;
      case 'Full Response':
        return Colors.green;
      case 'Engaged':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getConfidenceColor(int level) {
    if (level >= 80) return Colors.green;
    if (level >= 60) return Colors.orange;
    return Colors.red;
  }

  /// Upload video from device
  Future<void> _uploadVideo() async {
    try {
      setState(() {
        _isUploading = true;
      });

      // Try to pick video file first (file_picker handles permissions automatically on Android 13+)
      // For older Android versions, we may need to request permission
      FilePickerResult? result;
      
      try {
        result = await FilePicker.platform.pickFiles(
          type: FileType.video,
          allowMultiple: false,
        );
      } catch (e) {
        // If file picker fails, try requesting permissions for older Android
        bool hasPermission = false;
        
        // Check if we already have permission
        if (await Permission.videos.isGranted || 
            await Permission.photos.isGranted ||
            await Permission.storage.isGranted) {
          hasPermission = true;
        } else {
          // Request appropriate permission based on Android version
          // Try videos permission first (Android 13+)
          var videosStatus = await Permission.videos.request();
          if (videosStatus.isGranted) {
            hasPermission = true;
          } else {
            // Fallback to storage permission (Android 12 and below)
            var storageStatus = await Permission.storage.request();
            hasPermission = storageStatus.isGranted;
          }
        }

        if (!hasPermission) {
          setState(() {
            _isUploading = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permission denied. Please grant media/storage permission to upload videos.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        // Try picking again after permission granted
        result = await FilePicker.platform.pickFiles(
          type: FileType.video,
          allowMultiple: false,
        );
      }

      if (result != null && result.files.single.path != null) {
        final originalPath = result.files.single.path!;
        final fileName = result.files.single.name;
        // Cache the video inside the app directory so it persists for analysis.
        final filePath = await _cacheVideoLocally(originalPath);
        setState(() {
          _videoPath = filePath;
          _isUploading = false;
          _validationResult = null;
        });

        // Initialize video player
        await _initializeVideoPlayer(filePath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Video loaded: $fileName. Validating quality...'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Pre-upload quality validation (resolution, lighting, audio, face, duration)
        await _validateVideo(filePath);

        // Auto-run analysis so RTN Status, Reaction Time, Confidence, Behavior, Detected Actions are measured
        if (mounted && _videoPath != null) {
          _analyzeVideoWithBackend(_videoPath!);
        }
      } else {
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Open in-app recording with framing guide, countdown, and hints
  Future<void> _openRecordingPage() async {
    final path = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const VideoRecordingPage(minDurationSeconds: 30),
      ),
    );
    if (path == null || path.isEmpty || !mounted) return;
    // Cache recording inside app directory for stable access.
    final cachedPath = await _cacheVideoLocally(path);
    setState(() {
      _videoPath = cachedPath;
      _validationResult = null;
    });
    await _initializeVideoPlayer(cachedPath);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recording saved. Validating quality...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
    await _validateVideo(cachedPath);
    // Auto-run analysis so all metrics (RTN, reaction time, confidence, behavior, actions) are measured
    if (mounted && _videoPath != null) {
      _analyzeVideoWithBackend(_videoPath!);
    }
  }

  /// Pre-upload video quality validation: resolution, lighting, audio, face visibility, duration
  Future<void> _validateVideo(String filePath) async {
    setState(() => _isValidating = true);
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        setState(() {
          _isValidating = false;
          _validationResult = {
            'passed': false,
            'messages': ['Video file not found. Please upload or record again.'],
            'checks': {},
          };
          _videoPath = null;
          _isVideoLoaded = false;
        });
        return;
      }
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(BackendConfig.validateVideoEndpoint),
      );
      request.files.add(await http.MultipartFile.fromPath('video', filePath));
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);
      final data = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      setState(() {
        _isValidating = false;
        _validationResult = data;
      });
      if (mounted && (data['passed'] == true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quality checks passed. You can analyze the video.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (mounted && data['passed'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (data['messages'] as List?)?.join(' ') ?? 'Some quality checks failed. You may still analyze.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isValidating = false;
        _validationResult = {
          'passed': false,
          'messages': ['Validation failed: $e. You can try analyzing anyway.'],
          'checks': {},
        };
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not validate (backend may be offline). You can still analyze.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Initialize video player with selected video
  Future<void> _initializeVideoPlayer(String filePath) async {
    try {
      _videoController?.dispose();

      _videoController = VideoPlayerController.file(File(filePath));
      await _videoController!.initialize();

      setState(() {
        _isVideoLoaded = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Play/Stop video
  void _playVideo() {
    if (_videoController != null) {
      setState(() {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
      });
    }
  }

  /// Test backend server connection
  Future<void> _testBackendConnection() async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Testing backend connection...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final response = await http.get(
        Uri.parse(BackendConfig.healthEndpoint),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Backend is connected!\n'
                  'Server: ${BackendConfig.baseUrl}\n'
                  'Status: ${data['status'] ?? 'OK'}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        throw Exception('Server returned status ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Cannot connect to backend server!\n\n'
                'Server URL: ${BackendConfig.baseUrl}\n'
                'Error: ${e.toString()}\n\n'
                'Please make sure:\n'
                '1. Backend server is running\n'
                '   Run: cd backend && python app.py\n'
                '2. Server URL is correct\n'
                '3. Your device can reach the server'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }
  }

  /// Analyze video with Python backend
  Future<void> _analyzeVideoWithBackend(String filePath) async {
    if (filePath.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No video file path provided'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    // Check if file exists
    final file = File(filePath);
    if (!await file.exists()) {
      setState(() {
        _isAnalyzing = false;
        _rtnStatus = 'Error';
        _videoPath = null;
        _isVideoLoaded = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Video file not found. Please upload or record the video again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    setState(() {
      _isAnalyzing = true;
      _hasAnalysisResult = false;
      _rtnStatus = 'Analyzing...';
      _detectedActions = [];
      _reactionTime = 0.0;
      _confidenceLevel = 0;
      _behaviorClassification = 'No Response';
      _mlPrediction = null;
      _autismProbability = null;
      _typicalProbability = null;
      _mlConfidence = null;
      _expandedBehavioralMarkers = null;
      _audioAnalysisExpanded = null;
    });
    
    try {
      // First, check if backend is reachable
      try {
        final healthCheck = await http.get(
          Uri.parse(BackendConfig.healthEndpoint),
        ).timeout(const Duration(seconds: 5));
        
        if (healthCheck.statusCode != 200) {
          throw Exception('Backend server is not responding. Please make sure the backend server is running.');
        }
      } catch (e) {
        setState(() {
          _isAnalyzing = false;
          _rtnStatus = 'Error';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot connect to backend server.\n\n'
                  'Please make sure:\n'
                  '1. Backend server is running (run: python backend/app.py)\n'
                  '2. Server URL is correct: ${BackendConfig.baseUrl}\n'
                  '3. Your device/emulator can reach the server\n\n'
                  'Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 8),
            ),
          );
        }
        return;
      }
      
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(BackendConfig.analyzeVideoEndpoint),
      );
      
      // Add video file
      request.files.add(
        await http.MultipartFile.fromPath('video', filePath),
      );
      
      // Add child name if available
      if (widget.childName != null && widget.childName!.isNotEmpty) {
        request.fields['child_name'] = widget.childName!;
      }
      // Add child_id for benchmark comparison (M-CHAT vs AI)
      if (widget.childName != null && widget.childAge != null) {
        request.fields['child_id'] = '${widget.childName}_${widget.childAge}';
      }
      
      // Add analysis type
      request.fields['analysis_type'] = 'full';
      
      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 120), // 2 minutes timeout for video analysis
      );
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        // Check if there's an error in the result
        if (result.containsKey('error')) {
          throw Exception(result['message'] ?? result['error'] ?? 'Analysis failed');
        }
        
        // Update UI with results (full video analysis output)
        setState(() {
          _isAnalyzing = false;
          _hasAnalysisResult = true;
          // RTN Status
          _rtnStatus = _formatRTNStatus(result['RTN_Status']?.toString() ?? 'noResponse');
          // Reaction Time
          // Primary: backend's Reaction_Time (already computed from name call to response when audio is good)
          final rawRt = result['Reaction_Time'];
          double rt = rawRt is num
              ? rawRt.toDouble()
              : (double.tryParse(rawRt?.toString() ?? '0') ?? 0.0);
          // Fallback: if 0, try Response_Time_From_Name_Call or Response_At_Seconds
          if (rt <= 0) {
            final fallbackRt = result['Response_Time_From_Name_Call'] ?? result['Response_At_Seconds'];
            final fb = fallbackRt is num
                ? fallbackRt.toDouble()
                : (double.tryParse(fallbackRt?.toString() ?? '0') ?? 0.0);
            rt = fb;
          }
          // Keep only sensible values (0–60s); otherwise treat as not detected
          _reactionTime = (rt > 0 && rt <= 60) ? rt : 0.0;
          // Confidence Level (0-100)
          final conf = result['Confidence_Score'];
          _confidenceLevel = conf is int ? conf : (conf is num ? conf.round() : int.tryParse(conf?.toString() ?? '0') ?? 0).clamp(0, 100);
          // Behavior Classification (from RTN)
          _behaviorClassification = _formatBehaviorClassification(result['RTN_Status']?.toString() ?? 'noResponse');
          // Detected Actions (list of behavior types)
          final behaviors = result['Detected_Behaviors'] as List?;
          if (behaviors != null && behaviors.isNotEmpty) {
            _detectedActions = behaviors
                .map((b) {
                  if (b is Map) {
                    final t = b['type']?.toString();
                    return t != null ? t.replaceAll('_', ' ').toUpperCase() : '';
                  }
                  return b?.toString() ?? '';
                })
                .where((action) => action.isNotEmpty)
                .toList();
          } else {
            _detectedActions = [];
          }
          // ML Prediction (if available)
          final mlPrediction = result['ML_Prediction'] as Map?;
          if (mlPrediction != null && mlPrediction.isNotEmpty) {
            _mlPrediction = mlPrediction['prediction']?.toString();
            final ap = mlPrediction['autism_probability'];
            _autismProbability = ap is num ? ap.toDouble() : (double.tryParse(ap?.toString() ?? '') ?? 0.5);
            final tp = mlPrediction['typical_probability'];
            _typicalProbability = tp is num ? tp.toDouble() : (double.tryParse(tp?.toString() ?? '') ?? 0.5);
            final mc = mlPrediction['confidence'];
            _mlConfidence = mc is num ? mc.toDouble() : (double.tryParse(mc?.toString() ?? '') ?? 0.0);
          } else {
            _mlPrediction = null;
            _autismProbability = null;
            _typicalProbability = null;
            _mlConfidence = null;
          }
          
          // Expanded behavioral markers (safe cast from JSON)
          final rawMarkers = result['Expanded_Behavioral_Markers'];
          _expandedBehavioralMarkers = (rawMarkers == null || rawMarkers is! Map) ? null : Map<String, dynamic>.from(rawMarkers as Map);
          final audioAnalysis = result['Audio_Analysis'] as Map?;
          if (audioAnalysis != null) {
            _audioAnalysisExpanded = {
              'child_verbally_responded': audioAnalysis['child_verbally_responded'],
              'verbal_responses': audioAnalysis['verbal_responses'],
              'babbling_or_sound_as_response': audioAnalysis['babbling_or_sound_as_response'],
              'echolalia_patterns': audioAnalysis['echolalia_patterns'],
            };
          } else {
            _audioAnalysisExpanded = null;
          }
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video analysis completed successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Note: Automatic navigation removed - users can manually navigate using buttons
          // if needed. The analysis results will be displayed on this page.
          // Uncomment the line below if you want automatic navigation based on age:
          // _navigateAfterAnalysis();
        }
      } else {
        // Handle error response
        String errorMessage = 'Analysis failed with status ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (_) {
          errorMessage = 'Server returned status ${response.statusCode}: ${response.body}';
        }
        throw Exception(errorMessage);
      }
      
    } on http.ClientException catch (e) {
      setState(() {
        _isAnalyzing = false;
        _rtnStatus = 'Error';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: ${e.message}\n\n'
                'Please check:\n'
                '1. Backend server is running\n'
                '2. Network connection is active\n'
                '3. Server URL: ${BackendConfig.baseUrl}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } on TimeoutException catch (e) {
      setState(() {
        _isAnalyzing = false;
        _rtnStatus = 'Error';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request timeout: ${e.message}\n\n'
                'The video analysis is taking too long. This might be due to:\n'
                '1. Large video file size\n'
                '2. Slow network connection\n'
                '3. Backend server is overloaded\n\n'
                'Please try again with a smaller video file.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _rtnStatus = 'Error';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis error: ${e.toString()}\n\n'
                'Please check:\n'
                '1. Backend server is running\n'
                '2. Video file is valid\n'
                '3. Server URL: ${BackendConfig.baseUrl}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }
  }

  /// Build button to export current video analysis as a printable PDF report.
  Widget _buildExportPdfButton() {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton.icon(
        onPressed: _hasAnalysisResult ? _exportPdfReport : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7132C1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text(
          'Export Analysis as PDF',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Generate and print a professional PDF report of the current analysis.
  Future<void> _exportPdfReport() async {
    if (!_hasAnalysisResult) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Run video analysis first to generate a report.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      final doc = pw.Document();

      final childName = widget.childName ?? 'N/A';
      final childAge = widget.childAge != null ? '${widget.childAge} years' : 'N/A';
      final reaction =
          _reactionTime > 0 ? '${_reactionTime.toStringAsFixed(2)} seconds' : 'Not detected';
      final actionsSummary =
          _detectedActions.isEmpty ? 'None detected' : _detectedActions.join(', ');
      final mlLabel = _mlPrediction?.toUpperCase() ?? 'N/A';
      final autismPct = _autismProbability != null ? (_autismProbability! * 100).toStringAsFixed(1) : 'N/A';
      final typicalPct = _typicalProbability != null ? (_typicalProbability! * 100).toStringAsFixed(1) : 'N/A';
      final mlConfPct = _mlConfidence != null ? (_mlConfidence! * 100).toStringAsFixed(1) : 'N/A';
      final generatedAt = DateTime.now().toLocal().toString().split('.').first;

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          header: (pw.Context context) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Video Analysis Report',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Generated: $generatedAt',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
          footer: (pw.Context context) => pw.Padding(
            padding: const pw.EdgeInsets.only(top: 12),
            child: pw.Center(
              child: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          ),
          build: (pw.Context context) => [
            // Title
            pw.Center(
              child: pw.Text(
                'Auditory Response Video Analysis Report',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Child information box
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Child Information',
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    children: [
                      pw.Expanded(child: pw.Text('Name: $childName', style: const pw.TextStyle(fontSize: 11))),
                      pw.Expanded(child: pw.Text('Age: $childAge', style: const pw.TextStyle(fontSize: 11))),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Summary metrics table
            pw.Text(
              'Response to Name (RTN) & Metrics',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(3),
              },
              children: [
                _pdfTableRow('RTN Status', _rtnStatus),
                _pdfTableRow('Reaction Time', reaction),
                _pdfTableRow('Confidence Level', '$_confidenceLevel%'),
                _pdfTableRow('Behavior Classification', _behaviorClassification),
                _pdfTableRow('Detected Actions', actionsSummary),
              ],
            ),
            pw.SizedBox(height: 16),

            // ML prediction section
            pw.Text(
              'ML Model Prediction',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(3),
              },
              children: [
                _pdfTableRow('Prediction', mlLabel),
                _pdfTableRow('Autism Probability', '$autismPct%'),
                _pdfTableRow('Typical Probability', '$typicalPct%'),
                _pdfTableRow('Model Confidence', '$mlConfPct%'),
              ],
            ),
            pw.SizedBox(height: 24),

            // Disclaimer
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Disclaimer',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'This report is for informational and support purposes only. '
                    'It is not a medical or diagnostic tool. RTN status and reaction time depend on '
                    'audio quality and visible response in the video; many recordings will show '
                    '"Not detected" when name calls or response cannot be reliably measured. '
                    'Always consult a qualified healthcare provider for assessment.',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF report: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  pw.TableRow _pdfTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: pw.Text(label, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
    );
  }
  
  String _formatRTNStatus(String status) {
    switch (status.toLowerCase()) {
      case 'immediateresponse':
        return 'Responded';
      case 'delayedresponse':
        return 'Delayed Response';
      case 'partialresponse':
        return 'Partial Response';
      case 'noresponse':
        return 'Not Responded';
      default:
        return status;
    }
  }
  
  String _formatBehaviorClassification(String status) {
    switch (status.toLowerCase()) {
      case 'immediateresponse':
        return 'Immediate Response';
      case 'delayedresponse':
        return 'Delayed Response';
      case 'partialresponse':
        return 'Partial Response';
      case 'noresponse':
        return 'No Response';
      default:
        return 'Unknown';
    }
  }
  
  /// Navigate after successful analysis based on child's age:
  /// - Age 1–2: show ParentGuidancePage.
  /// - Age 3–4: show TapTheSoundPage game.
  /// - Other ages: stay on this page (no navigation).
  void _navigateAfterAnalysis() {
    final name = widget.childName;
    final age = widget.childAge;

    if (name == null || name.isEmpty || age == null) {
      return;
    }

    // Small delay so the success snackbar can be seen.
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      if (age >= 1 && age <= 2) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ParentGuidancePage(
              childName: name,
              childAge: age,
            ),
          ),
        );
      } else if (age >= 3 && age <= 4) {
        // For now, use the child's name as a simple identifier.
        // You can replace this with a real childId from your profile system.
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TapTheSoundPage(
              childId: name,
              childName: name,
              childAge: age,
            ),
          ),
        );
      }
    });
  }
  
  Widget _buildParentGuidanceButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC47BE4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.family_restroom,
                  color: Color(0xFFC47BE4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Parent Guidance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Get personalized guidance and resources for your child\'s age group.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF2C3E50),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (widget.childName != null && widget.childName!.isNotEmpty && 
                    widget.childAge != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ParentGuidancePage(
                        childName: widget.childName!,
                        childAge: widget.childAge!,
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                'View Parent Guidance – Age 1 to 2 Years',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC47BE4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTapTheSoundButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC47BE4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.games,
                  color: Color(0xFFC47BE4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tap the Sound Game',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Interactive game for children aged 4-6 years. Play sound, see images, and tap!',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF2C3E50),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (widget.childName != null && widget.childName!.isNotEmpty && 
                    widget.childAge != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TapTheSoundPage(
                        childId: widget.childName!,
                        childName: widget.childName!,
                        childAge: widget.childAge!,
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                'Start Tap the Sound Game',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC47BE4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Quick Test button - always visible for easy game testing
  Widget _buildQuickTestButton() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.flash_on,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Quick Test',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Test the Tap the Sound game directly (for development/testing)',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF2C3E50),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Direct navigation to game for testing
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TapTheSoundPage(
                      childId: widget.childName ?? 'test_child',
                      childName: widget.childName ?? 'Test Child',
                      childAge: widget.childAge ?? 3,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.games, color: Colors.orange),
              label: const Text(
                'Test Tap the Sound Game',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.orange, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

