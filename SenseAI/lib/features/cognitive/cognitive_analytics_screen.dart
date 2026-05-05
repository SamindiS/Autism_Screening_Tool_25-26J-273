import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/child.dart';

/// Interactive Analytics Screen for the Cognitive Flexibility module.
/// 
/// Consumes raw child and session data to project clinical cohort statistics 
/// using advanced interactive charts. Provides insights on Diagnostic Spread,
/// Risk Level Distribution, and Cohort representation.
class CognitiveAnalyticsScreen extends StatefulWidget {
  final List<Child> children;
  final List<Map<String, dynamic>> sessions;

  const CognitiveAnalyticsScreen({
    Key? key,
    required this.children,
    required this.sessions,
  }) : super(key: key);

  @override
  State<CognitiveAnalyticsScreen> createState() => _CognitiveAnalyticsScreenState();
}

class _CognitiveAnalyticsScreenState extends State<CognitiveAnalyticsScreen> {
  int _touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(l10n?.translate('clinical_analytics') ?? 'Clinical Analytics'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: widget.children.isEmpty
          ? Center(
              child: Text(
                l10n?.translate('no_data_analytics') ?? 'No data available for analytics.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 24),
                  _buildDiagnosticSpreadChart(),
                  const SizedBox(height: 24),
                  _buildRiskLevelChart(),
                  const SizedBox(height: 24),
                  _buildCompletionRateChart(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    final completedSessions = widget.sessions.where((s) => s['end_time'] != null).length;
    final pendingSessions = widget.sessions.where((s) => s['end_time'] == null).length;

    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            l10n?.translate('total_cohort') ?? 'Total Cohort',
            widget.children.length.toString(),
            Icons.people,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            l10n?.translate('completed') ?? 'Completed',
            completedSessions.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            l10n?.translate('pending') ?? 'Pending',
            pendingSessions.toString(),
            Icons.pending_actions,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticSpreadChart() {
    int asdCount = widget.children.where((c) => c.isAsdGroup).length;
    int controlCount = widget.children.length - asdCount;
    final l10n = AppLocalizations.of(context);

    return _buildChartCard(
      title: l10n?.translate('current_diagnostic_spread') ?? 'Current Diagnostic Spread',
      subtitle: l10n?.translate('ratio_diagnostic_spread') ?? 'Ratio of children with standing ASD diagnosis vs. control screening',
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedPieIndex = -1;
                      return;
                    }
                    _touchedPieIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              sections: [
                PieChartSectionData(
                  color: Colors.purple.shade400,
                  value: asdCount.toDouble(),
                  title: _touchedPieIndex == 0 ? '$asdCount' : (l10n?.translate('asd') ?? 'ASD'),
                  radius: _touchedPieIndex == 0 ? 60.0 : 50.0,
                  titleStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                PieChartSectionData(
                  color: Colors.teal.shade400,
                  value: controlCount.toDouble(),
                  title: _touchedPieIndex == 1 ? '$controlCount' : (l10n?.translate('control') ?? 'Control'),
                  radius: _touchedPieIndex == 1 ? 60.0 : 50.0,
                  titleStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.children.length}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text(
                l10n?.translate('total_users') ?? 'Total Users',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRiskLevelChart() {
    int highRisk = 0;
    int modRisk = 0;
    int lowRisk = 0;

    for (var session in widget.sessions) {
      if (session['end_time'] != null && session['risk_level'] != null) {
        String risk = session['risk_level'].toString().toLowerCase();
        if (risk == 'high') highRisk++;
        if (risk == 'moderate') modRisk++;
        if (risk == 'low') lowRisk++;
      }
    }

    final maxY = [highRisk, modRisk, lowRisk, 5].reduce((a, b) => a > b ? a : b).toDouble();
    final l10n = AppLocalizations.of(context);

    return _buildChartCard(
      title: l10n?.translate('algorithmic_risk_distribution') ?? 'Algorithmic Risk Distribution',
      subtitle: l10n?.translate('breakdown_predictions') ?? 'Breakdown of completed session predictions',
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: maxY + 2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = l10n?.translate('low') ?? 'Low';
                      break;
                    case 1:
                      text = l10n?.translate('moderate') ?? 'Moderate';
                      break;
                    case 2:
                      text = l10n?.translate('high') ?? 'High';
                      break;
                    default:
                      text = '';
                      break;
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(text, style: style),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: lowRisk.toDouble(),
                  color: Colors.green.shade400,
                  width: 35,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: modRisk.toDouble(),
                  color: Colors.orange.shade400,
                  width: 35,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: highRisk.toDouble(),
                  color: Colors.red.shade400,
                  width: 35,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionRateChart() {
    int v2_3 = 0, v3_5 = 0, v5_6 = 0;
    
    // Fallback classification if age group is directly stored, else rough age parse
    for (var child in widget.children) {
      int months = _calculateAgeInMonths(child.dateOfBirth);
      if (months >= 24 && months < 42) v2_3++;
      else if (months >= 42 && months < 66) v3_5++;
      else if (months >= 66) v5_6++;
      else v2_3++; // Default lowest
    }

    final maxY = [v2_3, v3_5, v5_6, 5].reduce((a, b) => a > b ? a : b).toDouble();
    final l10n = AppLocalizations.of(context);

    return _buildChartCard(
      title: l10n?.translate('demographic_age_cohorts') ?? 'Demographic Age Cohorts',
      subtitle: l10n?.translate('cohort_representation') ?? 'Cohort representation matching the target ML Models',
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
                  if (value.toInt() == 0) return SideTitleWidget(child: Text(l10n?.translate('age_group_2_3') ?? '2-3.5 yrs', style: style), axisSide: meta.axisSide);
                  if (value.toInt() == 1) return SideTitleWidget(child: Text(l10n?.translate('age_group_3_5') ?? '3.5-5.5 yrs', style: style), axisSide: meta.axisSide);
                  if (value.toInt() == 2) return SideTitleWidget(child: Text(l10n?.translate('age_group_5_6') ?? '5.5-6.9 yrs', style: style), axisSide: meta.axisSide);
                  return const SizedBox.shrink();
                },
                interval: 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false), // simplified
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 2,
          minY: 0,
          maxY: maxY + 2,
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, v2_3.toDouble()),
                FlSpot(1, v3_5.toDouble()),
                FlSpot(2, v5_6.toDouble()),
              ],
              isCurved: true,
              color: Colors.blue.shade600,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard({required String title, required String subtitle, required double height, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: height,
            width: double.infinity,
            child: child,
          ),
        ],
      ),
    );
  }

  int _calculateAgeInMonths(DateTime dob) {
    final now = DateTime.now();
    int months = (now.year - dob.year) * 12 + now.month - dob.month;
    if (now.day < dob.day) months--;
    return months;
  }
}
