import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Analysis Dashboard – responsive page for video analysis results.
/// Uses a [mockAnalysisData] map; replace with your Flask API response when ready.
class AnalysisDashboard extends StatefulWidget {
  /// Optional initial data (e.g. from API). If null, [mockAnalysisData] is used.
  final Map<String, dynamic>? initialData;

  const AnalysisDashboard({super.key, this.initialData});

  @override
  State<AnalysisDashboard> createState() => _AnalysisDashboardState();
}

class _AnalysisDashboardState extends State<AnalysisDashboard> {
  /// Mock data – swap with your Flask API response later.
  static Map<String, dynamic> get mockAnalysisData => {
        'rtnStatus': 'Partial Response',
        'reactionTime': 63.0,
        'confidence': 87,
        'behavior': 'Partial Response',
        'detectedActions': [
          'Head Turning',
          'Eye Movement',
          'Facial Expression',
          'Body Movement',
        ],
        'detectedActionsFrequency': {
          'Head Turning': 12,
          'Eye Movement': 8,
          'Facial Expression': 6,
          'Body Movement': 10,
        },
        'mlPrediction': 'AUTISM',
        'autismProbability': 0.851,
        'typicalProbability': 0.149,
        'modelConfidence': 0.871,
      };

  late Map<String, dynamic> _data;
  String _selectedState = 'Partial';

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.initialData ?? mockAnalysisData);
    _selectedState = _data['behavior']?.toString().split(' ').first ?? 'Partial';
  }

  @override
  void didUpdateWidget(covariant AnalysisDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != null) {
      _data = Map<String, dynamic>.from(widget.initialData!);
      _selectedState = _data['behavior']?.toString().split(' ').first ?? 'Partial';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Analysis Dashboard',
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryGrid(),
            const SizedBox(height: 24),
            _buildStateSelector(),
            const SizedBox(height: 24),
            _buildActionChips(),
            const SizedBox(height: 24),
            _buildMLPredictionCard(),
            const SizedBox(height: 24),
            _buildMetricsBarChart(),
            const SizedBox(height: 24),
            _buildChartsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryGrid() {
    final reactionTime = (_data['reactionTime'] as num?)?.toDouble() ?? 0.0;
    final reactionStr =
        reactionTime > 0 ? '${reactionTime.toStringAsFixed(2)}s' : '—';

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _summaryCard(
          title: 'RTN Detection',
          value: _data['rtnStatus']?.toString() ?? '—',
          icon: Icons.hearing,
          color: Colors.orange,
        ),
        _summaryCard(
          title: 'Reaction Time',
          value: reactionStr,
          icon: Icons.timer,
          color: const Color(0xFF2C3E50),
        ),
        _summaryCard(
          title: 'Confidence',
          value: '${_data['confidence'] ?? 0}%',
          icon: Icons.assessment,
          color: Colors.green,
        ),
        _summaryCard(
          title: 'Behavior',
          value: _data['behavior']?.toString() ?? '—',
          icon: Icons.category,
          color: const Color(0xFFC47BE4),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateSelector() {
    const states = ['Immediate', 'Delayed', 'Partial', 'No Response'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RTN State',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: states.map((state) {
            final isSelected = _selectedState == state;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: isSelected ? Colors.purple : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => setState(() => _selectedState = state),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Text(
                      state,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionChips() {
    final actions = _data['detectedActions'] as List<dynamic>?;
    final list = actions
            ?.map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detected Actions',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: list
              .map((label) => Chip(
                    label: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: Colors.blue.shade50,
                    side: BorderSide(color: Colors.blue.shade200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMLPredictionCard() {
    final prediction =
        _data['mlPrediction']?.toString().toUpperCase() ?? '—';
    final autismProb =
        (_data['autismProbability'] as num?)?.toDouble() ?? 0.0;
    final typicalProb =
        (_data['typicalProbability'] as num?)?.toDouble() ?? 0.0;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ML Model Prediction',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              prediction,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            _buildProbabilityBar('Autism Probability', autismProb, Colors.orange),
            const SizedBox(height: 12),
            _buildProbabilityBar('Typical Probability', typicalProb, Colors.blue),
          ],
        ),
      ),
    );
  }

  /// Stack to overlay percentage text on LinearProgressIndicator.
  Widget _buildProbabilityBar(String label, double value, Color color) {
    final pct = (value.clamp(0.0, 1.0) * 100).toStringAsFixed(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '$pct%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(4),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                '$pct%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 1),
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Vertical bar chart: Reaction Time, Confidence, ML Confidence, Autism Prob, Typical Prob (as in reference).
  Widget _buildMetricsBarChart() {
    final reactionTime = (_data['reactionTime'] as num?)?.toDouble() ?? 0.0;
    final confidence = (_data['confidence'] as num?)?.toInt() ?? 0;
    final modelConf = (_data['modelConfidence'] as num?)?.toDouble() ?? 0.0;
    final autismProb = (_data['autismProbability'] as num?)?.toDouble() ?? 0.0;
    final typicalProb = (_data['typicalProbability'] as num?)?.toDouble() ?? 0.0;

    // Reaction Time: show 0 or normalize to 0-100 (e.g. cap at 60s = 100%)
    final reactionTimePct = reactionTime <= 0 ? 0.0 : (reactionTime / 60 * 100).clamp(0.0, 100.0);
    final confidencePct = confidence.clamp(0, 100).toDouble();
    final mlConfPct = (modelConf * 100).clamp(0.0, 100.0);
    final autismPct = (autismProb * 100).clamp(0.0, 100.0);
    final typicalPct = (typicalProb * 100).clamp(0.0, 100.0);

    const labels = ['Reaction Time', 'Confidence', 'ML Confidence', 'Autism Prob', 'Typical Prob'];
    final values = [reactionTimePct, confidencePct, mlConfPct, autismPct, typicalPct];
    final colors = [
      Colors.red,
      Colors.green,
      Colors.green,
      Colors.orange,
      Colors.blue,
    ];

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analysis Metrics',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i >= 0 && i < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[i],
                                style: TextStyle(
                                  color: colors[i],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: Colors.grey[200]!,
                      strokeWidth: 1,
                    ),
                  ),
                  barGroups: List.generate(5, (i) {
                    final isTypical = i == 4;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: values[i],
                          color: colors[i],
                          width: 24,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(isTypical ? 8 : 0),
                          ),
                        ),
                      ],
                      showingTooltipIndicators: [],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    final frequency = _data['detectedActionsFrequency'] as Map<String, dynamic>?;
    final actionEntries = frequency?.entries.toList() ?? [];
    final modelConfidence =
        (_data['modelConfidence'] as num?)?.toDouble() ?? 0.0;
    final confidencePct = (modelConfidence.clamp(0.0, 1.0) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Charts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        if (actionEntries.isNotEmpty) ...[
          Card(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detected Actions Frequency',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Horizontal bar chart: Y-axis = Actions, X-axis = Frequency
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        rotationQuarterTurns: 1, // horizontal bars
                        maxY: (actionEntries
                                    .map((e) =>
                                        (e.value as num).toDouble())
                                    .reduce((a, b) => a > b ? a : b)
                                .ceil() +
                            2)
                            .toDouble(),
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 80,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                if (i >= 0 && i < actionEntries.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      actionEntries[i].key,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
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
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: false,
                          getDrawingVerticalLine: (v) => FlLine(
                            color: Colors.grey[200]!,
                            strokeWidth: 1,
                          ),
                        ),
                        barGroups: actionEntries.asMap().entries.map((e) {
                          final v = (e.value.value as num).toDouble();
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: v,
                                color: Colors.blue.shade300,
                                width: 20,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ],
                            showingTooltipIndicators: [],
                          );
                        }).toList(),
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 200),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Card(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Model Confidence',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              value: confidencePct.toDouble() < 0.5
                                  ? 0.5
                                  : confidencePct.toDouble(),
                              color: Colors.green,
                              radius: 50,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: (100 - confidencePct).toDouble() < 0.5
                                  ? 0.5
                                  : (100 - confidencePct).toDouble(),
                              color: Colors.grey[300]!,
                              radius: 50,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Text(
                          '$confidencePct%',
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
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Confidence: $confidencePct%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
