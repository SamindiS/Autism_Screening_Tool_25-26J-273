import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/services/storage_service.dart';
import '../../core/services/api_service.dart';

class SessionDetailScreen extends StatefulWidget {
  final String sessionId;
  final String childName;
  final Color primaryColor;

  const SessionDetailScreen({
    Key? key,
    required this.sessionId,
    required this.childName,
    required this.primaryColor,
  }) : super(key: key);

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  Map<String, dynamic>? _session;
  List<Map<String, dynamic>> _trials = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  Future<void> _loadSessionData() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      // Load session details
      final session = await ApiService.getSession(widget.sessionId);
      
      // Load trials for this session
      final trials = await StorageService.getTrialsBySession(widget.sessionId);

      setState(() {
        _session = session;
        _trials = trials;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load session data: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Summary'),
        backgroundColor: widget.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSessionData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _session == null
                  ? const Center(child: Text('Session not found'))
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    final session = _session!;
    final startTime = DateTime.fromMillisecondsSinceEpoch(session['start_time'] as int);
    final endTime = session['end_time'] != null
        ? DateTime.fromMillisecondsSinceEpoch(session['end_time'] as int)
        : null;
    final duration = endTime != null
        ? endTime.difference(startTime)
        : null;

    final metrics = session['metrics'] as Map<String, dynamic>?;
    final gameResults = session['game_results'] as Map<String, dynamic>?;
    final questionnaireResults = session['questionnaire_results'] as Map<String, dynamic>?;
    final reflectionResults = session['reflection_results'] as Map<String, dynamic>?;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.primaryColor.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _loadSessionData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSessionInfoCard(session, startTime, endTime, duration),
              const SizedBox(height: 16),
              
              // Quick Summary - Key metrics only
              _buildQuickSummaryCard(session, metrics, gameResults, questionnaireResults),
              const SizedBox(height: 16),

              // Game Results (with charts/tables)
              if (gameResults != null && gameResults.isNotEmpty) ...[
                _buildSectionCard(
                  'Game Performance',
                  Icons.games,
                  _buildGameResultsContent(gameResults),
                ),
                const SizedBox(height: 16),
              ],

              // Trials List (collapsible)
              if (_trials.isNotEmpty) ...[
                _buildSectionCard(
                  'Trial Details',
                  Icons.list,
                  _buildTrialsContent(),
                  isExpanded: false,
                ),
                const SizedBox(height: 16),
              ],

              // Additional Details (collapsible)
              _buildSectionCard(
                'Additional Details',
                Icons.info,
                _buildAdditionalDetailsContent(session, metrics, questionnaireResults, reflectionResults),
                isExpanded: false,
              ),

              // Raw Data (for debugging/advanced users - collapsed by default)
              _buildSectionCard(
                'Raw Data (Advanced)',
                Icons.code,
                _buildRawDataContent(session),
                isExpanded: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSummaryCard(
    Map<String, dynamic> session,
    Map<String, dynamic>? metrics,
    Map<String, dynamic>? gameResults,
    Map<String, dynamic>? questionnaireResults,
  ) {
    // Extract key summary data
    final riskLevel = session['risk_level'] as String?;
    final riskScore = session['risk_score'] as num?;
    final interpretation = _extractInterpretation(session, gameResults, questionnaireResults);
    
    // Extract key metrics
    final summary = gameResults?['summary'] as Map<String, dynamic>?;
    final overallAccuracy = _extractNumericNullable(summary ?? {}, ['overall_accuracy', 'accuracy', 'go_accuracy']) ?? 
                           _extractNumericNullable(gameResults ?? {}, ['accuracy', 'overall_accuracy', 'score']) ?? 0.0;
    final totalTrials = _extractNumericNullable(summary ?? {}, ['total_trials', 'main_trials']) ?? 
                       _extractNumericNullable(gameResults ?? {}, ['total_trials', 'trials']) ?? 0.0;
    final completionTime = summary?['completion_time_sec'] ?? 
                          gameResults?['completion_time_sec'] ??
                          gameResults?['completion_time'];
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: widget.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Risk Level Badge
            if (riskLevel != null || riskScore != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.assessment,
                    color: widget.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Risk Assessment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (riskLevel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getRiskLevelColor(riskLevel).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getRiskLevelColor(riskLevel),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        riskLevel.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _getRiskLevelColor(riskLevel),
                        ),
                      ),
                    ),
                  if (riskScore != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      'Score: ${riskScore.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Interpretation
            if (interpretation != null && interpretation.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        interpretation,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Key Metrics Grid
            if (overallAccuracy > 0 || totalTrials > 0 || completionTime != null) ...[
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (overallAccuracy > 0)
                    Expanded(
                      child: _buildSummaryMetric(
                        'Accuracy',
                        '${overallAccuracy.toStringAsFixed(0)}%',
                        Icons.gps_fixed,
                        Colors.blue,
                      ),
                    ),
                  if (totalTrials > 0) ...[
                    if (overallAccuracy > 0) const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryMetric(
                        'Trials',
                        totalTrials.toInt().toString(),
                        Icons.list_alt,
                        Colors.green,
                      ),
                    ),
                  ],
                  if (completionTime != null) ...[
                    if (overallAccuracy > 0 || totalTrials > 0) const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryMetric(
                        'Duration',
                        _formatTime(completionTime),
                        Icons.timer,
                        Colors.orange,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String? _extractInterpretation(
    Map<String, dynamic> session,
    Map<String, dynamic>? gameResults,
    Map<String, dynamic>? questionnaireResults,
  ) {
    // Try to find interpretation in various places
    if (gameResults?['interpretation'] != null) {
      return gameResults!['interpretation'] as String?;
    }
    if (questionnaireResults?['interpretation'] != null) {
      return questionnaireResults!['interpretation'] as String?;
    }
    if (session['interpretation'] != null) {
      return session['interpretation'] as String?;
    }
    return null;
  }

  double? _extractNumericNullable(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null) {
        if (value is num) return value.toDouble();
        if (value is String) {
          final parsed = double.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
    }
    return null;
  }

  String _formatTime(dynamic time) {
    if (time is num) {
      final seconds = time.toInt();
      if (seconds < 60) return '${seconds}s';
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '${minutes}m ${secs}s';
    }
    return time.toString();
  }

  Widget _buildAdditionalDetailsContent(
    Map<String, dynamic> session,
    Map<String, dynamic>? metrics,
    Map<String, dynamic>? questionnaireResults,
    Map<String, dynamic>? reflectionResults,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Metrics
        if (metrics != null && metrics.isNotEmpty) ...[
          const Text(
            'Performance Metrics',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildCompactMetrics(metrics),
          const SizedBox(height: 16),
        ],
        
        // Questionnaire Results
        if (questionnaireResults != null && questionnaireResults.isNotEmpty) ...[
          const Text(
            'Questionnaire Results',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildCompactMetrics(questionnaireResults),
          const SizedBox(height: 16),
        ],
        
        // Reflection Results
        if (reflectionResults != null && reflectionResults.isNotEmpty) ...[
          const Text(
            'Reflection Results',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildCompactMetrics(reflectionResults),
        ],
      ],
    );
  }

  Widget _buildCompactMetrics(Map<String, dynamic> data) {
    // Filter out large nested objects and only show key metrics
    final filtered = <String, dynamic>{};
    for (final entry in data.entries) {
      final key = entry.key.toLowerCase();
      // Skip large nested objects and arrays
      if (entry.value is Map && (entry.value as Map).length > 5) continue;
      if (entry.value is List && (entry.value as List).length > 10) continue;
      // Skip summary object (already shown in quick summary)
      if (key == 'summary') continue;
      filtered[entry.key] = entry.value;
    }
    
    if (filtered.isEmpty) {
      return const Text('No additional metrics available.');
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filtered.entries.take(10).map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  _formatKey(entry.key),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                flex: 3,
                child: _buildCompactValue(entry.value),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompactValue(dynamic value) {
    if (value is Map) {
      return Text(
        '${(value as Map).length} items',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      );
    } else if (value is List) {
      return Text(
        '${(value as List).length} items',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      );
    } else {
      return Text(
        value.toString(),
        style: const TextStyle(fontSize: 12),
      );
    }
  }

  Widget _buildSessionInfoCard(
    Map<String, dynamic> session,
    DateTime startTime,
    DateTime? endTime,
    Duration? duration,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.info_outline, color: widget.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatSessionType(session['session_type'] as String? ?? 'Unknown'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Child: ${widget.childName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Start Time', DateFormat.yMMMd().add_jm().format(startTime)),
            if (endTime != null)
              _buildInfoRow('End Time', DateFormat.yMMMd().add_jm().format(endTime)),
            if (duration != null)
              _buildInfoRow('Duration', _formatDuration(duration)),
            if (session['age_group'] != null)
              _buildInfoRow('Age Group', session['age_group'] as String),
            _buildInfoRow(
              'Status',
              endTime != null ? 'Completed' : 'In Progress',
              valueColor: endTime != null ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Widget content, {bool isExpanded = true}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        leading: Icon(icon, color: widget.primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsContent(Map<String, dynamic> metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: metrics.entries.map((entry) {
        final value = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  _formatKey(entry.key),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                flex: 3,
                child: _buildValueWidget(value),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGameResultsContent(Map<String, dynamic> gameResults) {
    // Check if this is DCCS/Color-Shape game data
    if (gameResults.containsKey('trials') || gameResults.containsKey('accuracy') || 
        gameResults.containsKey('correct') || gameResults.containsKey('incorrect')) {
      return _buildDCCSGameResults(gameResults);
    }
    
    // Check if this is Frog Jump game data
    if (gameResults.containsKey('jumps') || gameResults.containsKey('totalJumps') ||
        gameResults.containsKey('successfulJumps')) {
      return _buildFrogJumpGameResults(gameResults);
    }
    
    // Generic game results display
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: gameResults.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatKey(entry.key),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              _buildValueWidget(entry.value),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDCCSGameResults(Map<String, dynamic> gameResults) {
    final accuracy = _extractNumericNullable(gameResults, ['accuracy', 'score', 'correctPercentage']) ?? 0.0;
    final correct = _extractNumericNullable(gameResults, ['correct', 'correctCount', 'correctTrials']) ?? 0.0;
    final incorrect = _extractNumericNullable(gameResults, ['incorrect', 'incorrectCount', 'incorrectTrials']) ?? 0.0;
    final total = correct + incorrect;
    final trials = gameResults['trials'] as List?;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Accuracy',
                accuracy > 0 ? '${accuracy.toStringAsFixed(1)}%' : '-',
                Icons.gps_fixed,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Correct',
                correct.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Incorrect',
                incorrect.toString(),
                Icons.cancel,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Accuracy Chart
        if (accuracy > 0)
          Card(
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Accuracy Breakdown',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 150,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: correct.toDouble(),
                            title: '${((correct / total) * 100).toStringAsFixed(0)}%',
                            color: Colors.green,
                            radius: 60,
                          ),
                          PieChartSectionData(
                            value: incorrect.toDouble(),
                            title: '${((incorrect / total) * 100).toStringAsFixed(0)}%',
                            color: Colors.red,
                            radius: 60,
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Trials Table
        if (trials != null && trials.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildTrialsTable(trials),
        ],
        
        // Other game data
        if (gameResults.length > 3) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Additional Data',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...gameResults.entries.where((e) => 
            !['trials', 'accuracy', 'score', 'correct', 'incorrect', 'correctCount', 
              'incorrectCount', 'correctPercentage'].contains(e.key)
          ).map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      _formatKey(entry.key),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _buildValueWidget(entry.value),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildFrogJumpGameResults(Map<String, dynamic> gameResults) {
    final totalJumps = _extractNumericNullable(gameResults, ['totalJumps', 'jumps', 'total']) ?? 0.0;
    final successfulJumps = _extractNumericNullable(gameResults, ['successfulJumps', 'successful', 'correct']) ?? 0.0;
    final failedJumps = totalJumps - successfulJumps;
    final successRate = totalJumps > 0 ? (successfulJumps / totalJumps * 100) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Success Rate',
                '${successRate.toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Successful',
                successfulJumps.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Failed',
                failedJumps.toString(),
                Icons.cancel,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Success Rate Chart
        if (totalJumps > 0)
          Card(
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jump Success Rate',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 150,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: successfulJumps.toDouble(),
                            title: '${successRate.toStringAsFixed(0)}%',
                            color: Colors.green,
                            radius: 60,
                          ),
                          PieChartSectionData(
                            value: failedJumps.toDouble(),
                            title: '${((failedJumps / totalJumps) * 100).toStringAsFixed(0)}%',
                            color: Colors.red,
                            radius: 60,
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Other game data
        if (gameResults.length > 3) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Additional Data',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...gameResults.entries.where((e) => 
            !['totalJumps', 'jumps', 'total', 'successfulJumps', 'successful', 'correct'].contains(e.key)
          ).map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      _formatKey(entry.key),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _buildValueWidget(entry.value),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrialsTable(List trials) {
    return Card(
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Trial-by-Trial Results',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
              columns: const [
                DataColumn(label: Text('Trial', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Stimulus', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Response', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('RT (ms)', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Result', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: trials.asMap().entries.map((entry) {
                final trial = entry.value is Map ? entry.value as Map : {};
                final trialNum = entry.key + 1;
                final stimulus = trial['stimulus']?.toString() ?? '-';
                final response = trial['response']?.toString() ?? '-';
                final rt = trial['reactionTime'] ?? trial['rt'] ?? trial['reaction_time'] ?? '-';
                final correct = trial['correct'] ?? trial['isCorrect'] ?? false;
                
                return DataRow(
                  cells: [
                    DataCell(Text(trialNum.toString())),
                    DataCell(Text(stimulus.toString())),
                    DataCell(Text(response.toString())),
                    DataCell(Text(rt.toString())),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            correct == true || correct == 1 ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: correct == true || correct == 1 ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            correct == true || correct == 1 ? 'Correct' : 'Incorrect',
                            style: TextStyle(
                              color: correct == true || correct == 1 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionnaireContent(Map<String, dynamic> questionnaireResults) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: questionnaireResults.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatKey(entry.key),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              _buildValueWidget(entry.value),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReflectionContent(Map<String, dynamic> reflectionResults) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: reflectionResults.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatKey(entry.key),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              _buildValueWidget(entry.value),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrialsContent() {
    if (_trials.isEmpty) {
      return const Text('No trials recorded for this session.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Trials: ${_trials.length}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ..._trials.asMap().entries.map((entry) {
          final index = entry.key;
          final trial = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: Colors.grey.shade50,
            child: ListTile(
              dense: true,
              title: Text('Trial ${trial['trial_number'] ?? index + 1}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (trial['stimulus'] != null)
                    Text('Stimulus: ${trial['stimulus']}'),
                  if (trial['response'] != null)
                    Text('Response: ${trial['response']}'),
                  if (trial['reaction_time'] != null)
                    Text('Reaction Time: ${trial['reaction_time']}ms'),
                  if (trial['correct'] != null)
                    Row(
                      children: [
                        Icon(
                          (trial['correct'] == 1 || trial['correct'] == true)
                              ? Icons.check_circle
                              : Icons.cancel,
                          size: 16,
                          color: (trial['correct'] == 1 || trial['correct'] == true)
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (trial['correct'] == 1 || trial['correct'] == true)
                              ? 'Correct'
                              : 'Incorrect',
                          style: TextStyle(
                            color: (trial['correct'] == 1 || trial['correct'] == true)
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRiskAssessmentContent(Map<String, dynamic> session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (session['risk_score'] != null)
          _buildInfoRow(
            'Risk Score',
            '${(session['risk_score'] as num).toStringAsFixed(2)}',
            valueColor: _getRiskColor(session['risk_score'] as num),
          ),
        if (session['risk_level'] != null)
          _buildInfoRow(
            'Risk Level',
            (session['risk_level'] as String).toUpperCase(),
            valueColor: _getRiskLevelColor(session['risk_level'] as String),
          ),
      ],
    );
  }

  Widget _buildRawDataContent(Map<String, dynamic> session) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        const JsonEncoder.withIndent('  ').convert(session),
        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueWidget(dynamic value) {
    if (value is Map) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          const JsonEncoder.withIndent('  ').convert(value),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
        ),
      );
    } else if (value is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: value.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('• ${entry.value}'),
          );
        }).toList(),
      );
    } else {
      return Text(
        value.toString(),
        style: const TextStyle(fontSize: 14),
      );
    }
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatSessionType(String type) {
    switch (type) {
      case 'ai_doctor_bot':
        return 'AI Doctor Bot';
      case 'frog_jump':
        return 'Frog Jump Game';
      case 'color_shape':
        return 'DCCS Game';
      case 'manual_assessment':
        return 'Manual Assessment';
      case 'rrb':
        return 'RRB Assessment';
      case 'auditory':
        return 'Auditory Assessment';
      case 'visual':
        return 'Visual Assessment';
      default:
        return type.replaceAll('_', ' ').split(' ').map((w) =>
            w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1)).join(' ');
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '$minutes min ${seconds}s';
    }
    return '$seconds seconds';
  }

  Color _getRiskColor(num score) {
    if (score >= 70) return Colors.red;
    if (score >= 40) return Colors.orange;
    return Colors.green;
  }

  Color _getRiskLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

