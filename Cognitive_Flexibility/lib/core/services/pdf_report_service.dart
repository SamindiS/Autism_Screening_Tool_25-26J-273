import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

/// Service for generating PDF reports for children
class PdfReportService {
  /// Generate and save a PDF report for a child
  static Future<String?> generateChildReport({
    required Map<String, dynamic> child,
    required List<Map<String, dynamic>> sessions,
  }) async {
    try {
      // Create PDF document
      final pdf = pw.Document();

      // Add pages
      pdf.addPage(_buildCoverPage(child));
      pdf.addPage(_buildChildInfoPage(child));
      
      // Add session pages
      for (var session in sessions) {
        pdf.addPage(_buildSessionPage(child, session));
      }
      
      // Add summary page
      pdf.addPage(_buildSummaryPage(child, sessions));

      // Save PDF
      final output = await getApplicationDocumentsDirectory();
      final fileName = '${child['child_code'] ?? child['name'] ?? 'Child'}_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }

  /// Generate and share PDF report
  static Future<void> generateAndShareReport({
    required Map<String, dynamic> child,
    required List<Map<String, dynamic>> sessions,
  }) async {
    try {
      final filePath = await generateChildReport(
        child: child,
        sessions: sessions,
      );

      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          await Share.shareXFiles(
            [XFile(filePath)],
            text: 'Child Assessment Report: ${child['name'] ?? 'Unknown'}',
            subject: 'SenseAI Assessment Report',
          );
        }
      }
    } catch (e) {
      print('Error sharing PDF: $e');
      rethrow;
    }
  }

  /// Generate and print PDF report
  static Future<void> generateAndPrintReport({
    required Map<String, dynamic> child,
    required List<Map<String, dynamic>> sessions,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(_buildCoverPage(child));
      pdf.addPage(_buildChildInfoPage(child));
      
      for (var session in sessions) {
        pdf.addPage(_buildSessionPage(child, session));
      }
      
      pdf.addPage(_buildSummaryPage(child, sessions));

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      print('Error printing PDF: $e');
      rethrow;
    }
  }

  /// Build cover page
  static pw.Page _buildCoverPage(Map<String, dynamic> child) {
    final childName = child['name'] as String? ?? 'Unknown';
    final childCode = child['child_code'] as String? ?? '';
    final date = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'SenseAI',
                style: pw.TextStyle(
                  fontSize: 48,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue700,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Autism Spectrum Disorder Screening',
                style: pw.TextStyle(
                  fontSize: 20,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 60),
              pw.Container(
                padding: const pw.EdgeInsets.all(30),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue700, width: 2),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Child Assessment Report',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Child Name: $childName',
                      style: const pw.TextStyle(fontSize: 18),
                    ),
                    if (childCode.isNotEmpty) ...[
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Child Code: $childCode',
                        style: const pw.TextStyle(fontSize: 18),
                      ),
                    ],
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Generated: $date',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build child information page
  static pw.Page _buildChildInfoPage(Map<String, dynamic> child) {
    final dob = child['date_of_birth'] != null
        ? DateTime.fromMillisecondsSinceEpoch((child['date_of_birth'] as num).toInt())
        : null;
    final ageInMonths = child['age_in_months'] as int?;
    final gender = child['gender'] as String? ?? 'Not specified';
    final studyGroup = child['study_group'] as String? ?? child['group'] as String? ?? 'Not specified';
    final asdLevel = child['asd_level'] as String?;
    final language = child['language_preference'] as String? ?? 'Not specified';

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 1,
              child: pw.Text(
                'Child Information',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 30),
            _buildInfoRow('Name', child['name'] as String? ?? 'Unknown'),
            _buildInfoRow('Child Code', child['child_code'] as String? ?? 'N/A'),
            if (dob != null)
              _buildInfoRow('Date of Birth', DateFormat('MMMM dd, yyyy').format(dob)),
            if (ageInMonths != null)
              _buildInfoRow('Age', '${ageInMonths} months (${(ageInMonths / 12).toStringAsFixed(1)} years)'),
            _buildInfoRow('Gender', gender),
            _buildInfoRow('Study Group', studyGroup.replaceAll('_', ' ').toUpperCase()),
            if (asdLevel != null)
              _buildInfoRow('ASD Level', asdLevel.replaceAll('_', ' ').toUpperCase()),
            _buildInfoRow('Language Preference', language),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Text(
              'This report contains assessment results and screening data collected through the SenseAI system.',
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey700,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build session page
  static pw.Page _buildSessionPage(Map<String, dynamic> child, Map<String, dynamic> session) {
    final sessionType = session['session_type'] as String? ?? 'Unknown';
    final startTime = session['start_time'] != null
        ? DateTime.fromMillisecondsSinceEpoch((session['start_time'] as num).toInt())
        : null;
    final endTime = session['end_time'] != null
        ? DateTime.fromMillisecondsSinceEpoch((session['end_time'] as num).toInt())
        : null;
    final riskScore = session['risk_score'] as num?;
    final riskLevel = session['risk_level'] as String?;
    final metrics = session['metrics'] as Map<String, dynamic>?;
    final gameResults = session['game_results'] as Map<String, dynamic>?;
    final questionnaireResults = session['questionnaire_results'] as Map<String, dynamic>?;

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 1,
              child: pw.Text(
                'Session: ${_formatSessionType(sessionType)}',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            _buildInfoRow('Session Type', _formatSessionType(sessionType)),
            if (startTime != null)
              _buildInfoRow('Start Time', DateFormat('MMMM dd, yyyy - HH:mm').format(startTime)),
            if (endTime != null)
              _buildInfoRow('End Time', DateFormat('MMMM dd, yyyy - HH:mm').format(endTime)),
            if (startTime != null && endTime != null)
              _buildInfoRow(
                'Duration',
                '${endTime.difference(startTime).inMinutes} minutes ${endTime.difference(startTime).inSeconds % 60} seconds',
              ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),
            
            // Risk Assessment
            if (riskScore != null || riskLevel != null) ...[
              pw.Text(
                'Risk Assessment',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              if (riskScore != null)
                _buildInfoRow('Risk Score', '${riskScore.toStringAsFixed(1)}%'),
              if (riskLevel != null)
                _buildInfoRow(
                  'Risk Level',
                  riskLevel.toUpperCase(),
                  valueStyle: pw.TextStyle(
                    color: _getRiskColor(riskLevel),
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              pw.SizedBox(height: 20),
            ],

            // Game Results
            if (gameResults != null && gameResults.isNotEmpty) ...[
              pw.Text(
                'Game Results',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              ...gameResults.entries.map((e) => _buildInfoRow(
                _formatKey(e.key),
                _formatValue(e.value),
              )),
              pw.SizedBox(height: 20),
            ],

            // Questionnaire Results
            if (questionnaireResults != null && questionnaireResults.isNotEmpty) ...[
              pw.Text(
                'Questionnaire Results',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              ...questionnaireResults.entries.map((e) => _buildInfoRow(
                _formatKey(e.key),
                _formatValue(e.value),
              )),
              pw.SizedBox(height: 20),
            ],

            // Metrics
            if (metrics != null && metrics.isNotEmpty) ...[
              pw.Text(
                'Additional Metrics',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              ...metrics.entries.take(10).map((e) => _buildInfoRow(
                _formatKey(e.key),
                _formatValue(e.value),
              )),
            ],
          ],
        );
      },
    );
  }

  /// Build summary page
  static pw.Page _buildSummaryPage(Map<String, dynamic> child, List<Map<String, dynamic>> sessions) {
    final completedSessions = sessions.where((s) => s['end_time'] != null).toList();
    final totalSessions = sessions.length;
    final avgRiskScore = _calculateAverageRiskScore(sessions);
    final highRiskSessions = sessions.where((s) => s['risk_level'] == 'high').length;
    final moderateRiskSessions = sessions.where((s) => s['risk_level'] == 'moderate').length;
    final lowRiskSessions = sessions.where((s) => s['risk_level'] == 'low').length;

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 1,
              child: pw.Text(
                'Summary',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 30),
            
            // Statistics
            pw.Text(
              'Assessment Statistics',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 15),
            _buildInfoRow('Total Sessions', totalSessions.toString()),
            _buildInfoRow('Completed Sessions', completedSessions.length.toString()),
            if (avgRiskScore != null)
              _buildInfoRow('Average Risk Score', '${avgRiskScore.toStringAsFixed(1)}%'),
            pw.SizedBox(height: 20),
            
            // Risk Level Distribution
            pw.Text(
              'Risk Level Distribution',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 15),
            _buildInfoRow(
              'High Risk Sessions',
              highRiskSessions.toString(),
              valueStyle: pw.TextStyle(
                color: PdfColors.red700,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            _buildInfoRow(
              'Moderate Risk Sessions',
              moderateRiskSessions.toString(),
              valueStyle: pw.TextStyle(
                color: PdfColors.orange700,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            _buildInfoRow(
              'Low Risk Sessions',
              lowRiskSessions.toString(),
              valueStyle: pw.TextStyle(
                color: PdfColors.green700,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 30),
            
            // Session List
            pw.Text(
              'Session History',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 15),
            ...sessions.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final session = entry.value;
              final sessionType = session['session_type'] as String? ?? 'Unknown';
              final date = session['start_time'] != null
                  ? DateTime.fromMillisecondsSinceEpoch((session['start_time'] as num).toInt())
                  : null;
              final riskLevel = session['risk_level'] as String?;
              
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Row(
                  children: [
                    pw.Text(
                      '$index. ',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        '${_formatSessionType(sessionType)} - ${date != null ? DateFormat('MMM dd, yyyy').format(date) : 'N/A'}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ),
                    if (riskLevel != null)
                      pw.Text(
                        riskLevel.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: _getRiskColor(riskLevel),
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              );
            }),
            
            pw.Spacer(),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Text(
              'Report generated by SenseAI System\n${DateFormat('MMMM dd, yyyy - HH:mm').format(DateTime.now())}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
                fontStyle: pw.FontStyle.italic,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  /// Helper: Build info row
  static pw.Widget _buildInfoRow(String label, String value, {pw.TextStyle? valueStyle}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: valueStyle ?? const pw.TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper: Format session type
  static String _formatSessionType(String type) {
    return type
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Helper: Format key
  static String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Helper: Format value
  static String _formatValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is num) {
      if (value % 1 == 0) {
        return value.toInt().toString();
      } else {
        return value.toStringAsFixed(2);
      }
    }
    return value.toString();
  }

  /// Helper: Get risk color
  static PdfColor _getRiskColor(String? riskLevel) {
    switch (riskLevel?.toLowerCase()) {
      case 'high':
        return PdfColors.red700;
      case 'moderate':
        return PdfColors.orange700;
      case 'low':
        return PdfColors.green700;
      default:
        return PdfColors.grey700;
    }
  }

  /// Helper: Calculate average risk score
  static double? _calculateAverageRiskScore(List<Map<String, dynamic>> sessions) {
    final scores = sessions
        .where((s) => s['risk_score'] != null)
        .map((s) => (s['risk_score'] as num).toDouble())
        .toList();
    
    if (scores.isEmpty) return null;
    
    final sum = scores.reduce((a, b) => a + b);
    return sum / scores.length;
  }
}

