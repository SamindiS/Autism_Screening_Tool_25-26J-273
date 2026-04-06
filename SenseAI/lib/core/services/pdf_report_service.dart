import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

/// Service for generating advanced, professional clinical PDF reports.
/// 
/// This service utilizes the `pdf` and `printing` packages to construct
/// multi-page, visually distinct reports containing patient demographics,
/// session analysis, risk gauges, XAI feature contributions, and historical trends.
class PdfReportService {
  /// Primary color used for headers and visual emphasis (Indigo).
  static const primaryColor = PdfColor.fromInt(0xff6366f1);
  
  /// Secondary color used for positive accents (Emerald).
  static const secondaryColor = PdfColor.fromInt(0xff10b981);
  
  /// Dark typography color for primary text elements.
  static const darkText = PdfColor.fromInt(0xff1f2937);
  
  /// Light typography color for secondary text and labels.
  static const lightText = PdfColor.fromInt(0xff6b7280);

  /// Generates a complete PDF document entirely in memory.
  /// 
  /// Takes the [child] profile and their assessment [sessions]. The sessions
  /// are automatically sorted chronologically to ensure the latest analysis
  /// is presented first. Returns the raw [Uint8List] bytes.
  static Future<Uint8List> generatePdfBytes({
    required Map<String, dynamic> child,
    required List<Map<String, dynamic>> sessions,
  }) async {
    final pdf = pw.Document();

    // Ensure sessions are sorted by time (newest first)
    final sortedSessions = List<Map<String, dynamic>>.from(sessions);
    sortedSessions.sort((a, b) {
      final timeA = a['start_time'] as num? ?? 0;
      final timeB = b['start_time'] as num? ?? 0;
      return timeB.compareTo(timeA);
    });

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (context) => _buildHeader(child),
        footer: (context) => _buildFooter(context),
        build: (context) {
          return [
            _buildPatientInfo(child),
            pw.SizedBox(height: 20),
            if (sortedSessions.isNotEmpty) ...[
              _buildSessionAnalysis(sortedSessions.first),
              if (sortedSessions.length > 1) ...[
                pw.SizedBox(height: 30),
                _buildHistorySummary(sortedSessions),
              ]
            ] else ...[
              pw.Center(
                  child: pw.Text("No assessment sessions recorded.",
                      style: const pw.TextStyle(color: lightText))),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Generates the PDF and saves it securely to the local filesystem.
  /// 
  /// Uses [getApplicationDocumentsDirectory] to store the file. The filename
  /// is uniquely generated using the child's code/name and the current timestamp.
  /// Returns the absolute filesystem [path] of the generated PDF.
  static Future<String?> generateChildReport({
    required Map<String, dynamic> child,
    required List<Map<String, dynamic>> sessions,
  }) async {
    try {
      final bytes = await generatePdfBytes(child: child, sessions: sessions);

      final output = await getApplicationDocumentsDirectory();
      final fileName =
          '${child['child_code'] ?? child['name'] ?? 'Child'}_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(bytes);

      return file.path;
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }

  /// Wraps PDF generation and invokes the native sharing dialog.
  /// 
  /// Enables clinicians to export the generated document via email, 
  /// messaging apps, or save it to cloud storage using [Share.shareXFiles].
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
            text: 'Clinical Assessment Report: ${child['name'] ?? 'Unknown'}',
            subject: 'SenseAI Assessment Report',
          );
        }
      }
    } catch (e) {
      print('Error sharing PDF: $e');
      rethrow;
    }
  }

  /// Generates the PDF and queues it directly to the system print spooler.
  /// 
  /// Uses [Printing.layoutPdf] to interact with Android/iOS print dialogs.
  static Future<void> generateAndPrintReport({
    required Map<String, dynamic> child,
    required List<Map<String, dynamic>> sessions,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (context) => _buildHeader(child),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildPatientInfo(child),
          pw.SizedBox(height: 20),
          if (sessions.isNotEmpty) _buildSessionAnalysis(sessions.first),
          if (sessions.length > 1) _buildHistorySummary(sessions),
        ],
      ));

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      print('Error printing PDF: $e');
      rethrow;
    }
  }

  static pw.Widget _buildHeader(Map<String, dynamic> child) {
    return pw
        .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('SenseAI',
                  style: pw.TextStyle(
                      color: primaryColor,
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold)),
              pw.Text('Autism Spectrum Disorder Clinical Screening',
                  style: const pw.TextStyle(color: lightText, fontSize: 10)),
            ],
          ),
          pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('CONFIDENTIAL REPORT',
                        style: pw.TextStyle(
                            color: PdfColors.red700,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                        'Date: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                        style:
                            const pw.TextStyle(color: darkText, fontSize: 10)),
                  ])),
        ],
      ),
      pw.SizedBox(height: 16),
      pw.Divider(color: primaryColor, thickness: 2),
      pw.SizedBox(height: 16),
    ]);
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
        margin: const pw.EdgeInsets.only(top: 20),
        child: pw.Column(children: [
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 5),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                    'Generated by SenseAI System - Intended for clinical support only.',
                    style: const pw.TextStyle(color: lightText, fontSize: 8)),
                pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                    style: const pw.TextStyle(color: lightText, fontSize: 8)),
              ])
        ]));
  }

  static pw.Widget _buildPatientInfo(Map<String, dynamic> child) {
    final dob = child['date_of_birth'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            (child['date_of_birth'] as num).toInt())
        : null;
    final ageInMonths = child['age_in_months'] as int?;
    final studyGroup =
        child['study_group'] as String? ?? child['group'] as String? ?? 'N/A';

    return pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.grey200)),
        child:
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Expanded(
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                _buildInfoLine(
                    'Patient Name:', child['name'] as String? ?? 'Unknown'),
                _buildInfoLine(
                    'Patient ID:', child['child_code'] as String? ?? 'N/A'),
                _buildInfoLine('Gender:', child['gender'] as String? ?? 'N/A'),
              ])),
          pw.Expanded(
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                _buildInfoLine(
                    'Date of Birth:',
                    dob != null
                        ? DateFormat('MMM dd, yyyy').format(dob)
                        : 'N/A'),
                _buildInfoLine('Age:',
                    ageInMonths != null ? '$ageInMonths months' : 'N/A'),
                _buildInfoLine(
                    'Diagnostic Status:',
                    studyGroup == 'asd'
                        ? 'Prior ASD Diagnosis'
                        : 'Screening (No Prior Diagnosis)'),
              ]))
        ]));
  }

  static pw.Widget _buildInfoLine(String label, String value) {
    return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child:
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.SizedBox(
              width: 100,
              child: pw.Text(label,
                  style: pw.TextStyle(
                      color: lightText,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold))),
          pw.Expanded(
              child: pw.Text(value,
                  style: const pw.TextStyle(color: darkText, fontSize: 10))),
        ]));
  }

  static pw.Widget _buildSessionAnalysis(Map<String, dynamic> session) {
    final riskScore = session['risk_score'] as num?;
    final riskLevel = session['risk_level'] as String?;
    final mlPrediction = session['ml_prediction'] as Map<String, dynamic>? ??
        session['questionnaire_results']?['ml_prediction']
            as Map<String, dynamic>? ??
        session['game_results']?['ml_prediction'] as Map<String, dynamic>?;

    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('CLINICAL ASSESSMENT RESULTS',
              style: pw.TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),

          // Visual Risk Gauge
          if (riskScore != null)
            _buildRiskGauge(riskScore.toDouble(), riskLevel),

          pw.SizedBox(height: 16),

          // Explainable AI Insights (If provided)
          if (mlPrediction != null && mlPrediction['explanations'] != null) ...[
            _buildXAICharts(
                List<Map<String, dynamic>>.from(mlPrediction['explanations'])),
            pw.SizedBox(height: 16),
          ],

          // Metrics Split Data
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            if (session['game_results'] != null)
              pw.Expanded(
                  child: _buildMetricsBox('Cognitive DCCS Game Metrics',
                      session['game_results'] as Map<String, dynamic>)),
            if (session['game_results'] != null &&
                (session['metrics'] != null ||
                    session['questionnaire_results'] != null))
              pw.SizedBox(width: 16),
            if (session['metrics'] != null)
              pw.Expanded(
                  child: _buildMetricsBox('Behavioral Observations',
                      session['metrics'] as Map<String, dynamic>)),
            if (session['questionnaire_results'] != null &&
                session['metrics'] == null)
              pw.Expanded(
                  child: _buildMetricsBox(
                      'Questionnaire Scoring',
                      session['questionnaire_results']
                          as Map<String, dynamic>)),
          ])
        ]);
  }

  static pw.Widget _buildRiskGauge(double score, String? level) {
    // Determine bounds. Standard risk scores are 0-100 or 0-5. Let's assume 0-5 if score is very small, else 0-100.
    final bool isSmallScale = score <= 10.0;
    final double maxScore = isSmallScale ? (score > 5.0 ? 10.0 : 5.0) : 100.0;
    final double normalizedPercent = (score / maxScore).clamp(0.0, 1.0);

    PdfColor color;
    PdfColor bgColor;
    PdfColor borderColor;

    if (level == 'low') {
      color = PdfColors.green500;
      bgColor = PdfColor.fromInt(0xfff0fdf4);
      borderColor = PdfColor.fromInt(0xffbbf7d0);
    } else if (level == 'moderate') {
      color = PdfColors.orange500;
      bgColor = PdfColor.fromInt(0xfffff7ed);
      borderColor = PdfColor.fromInt(0xfffed7aa);
    } else {
      color = PdfColors.red500;
      bgColor = PdfColor.fromInt(0xfffef2f2);
      borderColor = PdfColor.fromInt(0xfffecaca);
    }

    return pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
            color: bgColor,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: borderColor)),
        child: pw
            .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Overall Risk Component Assessment',
                    style: pw.TextStyle(
                        color: darkText,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text(
                    '${(normalizedPercent * 100).toStringAsFixed(1)}% / ${level?.toUpperCase() ?? 'N/A'}',
                    style: pw.TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold)),
              ]),
          pw.SizedBox(height: 12),
          // Progress Bar background
          pw.Container(
              height: 12,
              width: double.infinity,
              decoration: pw.BoxDecoration(
                color: PdfColors.grey300,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Stack(children: [
                pw.Container(
                    height: 12,
                    // We can't use FractionallySizedBox, so we map normalizedPercent physically to a static width or use Expanded in a Row.
                    // Since the parent container is technically unbound width in standard layout unless specified, let's use a 400 fixed width proxy for the parent container logic, OR just use pw.Expanded with flex.
                    // Easiest is to use Row with Expanded flex values:
                    child: pw.Row(children: [
                      pw.Expanded(
                          flex: (normalizedPercent * 100).toInt(),
                          child: pw.Container(
                              decoration: pw.BoxDecoration(
                            color: color,
                            borderRadius: pw.BorderRadius.circular(6),
                          ))),
                      pw.Expanded(
                        flex: ((1.0 - normalizedPercent) * 100).toInt(),
                        child: pw.SizedBox(),
                      )
                    ]))
              ])),
          pw.SizedBox(height: 6),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Low Risk',
                    style: const pw.TextStyle(color: lightText, fontSize: 8)),
                pw.Text('Moderate Risk',
                    style: const pw.TextStyle(color: lightText, fontSize: 8)),
                pw.Text('High Risk',
                    style: const pw.TextStyle(color: lightText, fontSize: 8)),
              ])
        ]));
  }

  static pw.Widget _buildXAICharts(List<Map<String, dynamic>> explanations) {
    if (explanations.isEmpty) return pw.SizedBox();

    return pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.grey200)),
        child: pw
            .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(children: [
            pw.Text('Explainable AI (XAI) Feature Contributions',
                style: pw.TextStyle(
                    color: darkText,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 8),
            pw.Text('How the model arrived at this score',
                style: pw.TextStyle(
                    color: lightText,
                    fontSize: 9,
                    fontStyle: pw.FontStyle.italic)),
          ]),
          pw.SizedBox(height: 12),
          pw.Column(
              children: explanations.take(6).map((e) {
            final feature =
                (e['feature'] as String?)?.replaceAll('_', ' ').toUpperCase() ??
                    'UNKNOWN';
            final direction = (e['direction'] as String?) ?? 'increases_risk';
            final contribution = (e['contribution'] as num?)?.toDouble() ?? 0.0;
            final isIncrease = direction == 'increases_risk';
            final barColor = isIncrease ? PdfColors.red400 : PdfColors.green400;

            // Normalize bar width (max contribution width visually)
            final double widthFactor =
                (contribution.abs() / 0.5).clamp(0.01, 1.0);

            return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.SizedBox(
                        width: 160,
                        child: pw.Text(feature,
                            style: const pw.TextStyle(
                                color: darkText, fontSize: 8)),
                      ),
                      pw.Expanded(
                          child: pw.Row(children: [
                        if (!isIncrease) pw.Spacer(),
                        pw.Container(
                          height: 10,
                          width: 130 * widthFactor,
                          decoration: pw.BoxDecoration(
                            color: barColor,
                            borderRadius: pw.BorderRadius.circular(2),
                          ),
                        ),
                        if (isIncrease) pw.Spacer(),
                      ])),
                      pw.SizedBox(
                        width: 40,
                        child: pw.Text(
                            '${isIncrease ? '+' : '-'}${contribution.abs().toStringAsFixed(3)}',
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(
                                color: lightText, fontSize: 8)),
                      ),
                    ]));
          }).toList())
        ]));
  }

  static pw.Widget _buildMetricsBox(String title, Map<String, dynamic> data) {
    if (data.isEmpty) {
      return pw.SizedBox();
    }

    final ignoredKeys = [
      'trials',
      'ml_prediction',
      'additional_metrics',
      'ml_features'
    ];
    final validEntries = data.entries
        .where((e) =>
            !ignoredKeys.contains(e.key) &&
            e.value != null &&
            !(e.value is Map || e.value is List))
        .toList();

    if (validEntries.isEmpty) return pw.SizedBox();

    return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey200),
            borderRadius: pw.BorderRadius.circular(8)),
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title,
                  style: pw.TextStyle(
                      color: darkText,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.grey200, height: 1),
              pw.SizedBox(height: 8),
              pw.Column(
                  children: validEntries.map((e) {
                String valStr = e.value.toString();
                if (e.value is num && e.value is! int) {
                  valStr = (e.value as num).toStringAsFixed(2);
                }
                return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 3),
                    child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                              child: pw.Text(
                                  e.key.replaceAll('_', ' ').toUpperCase(),
                                  style: const pw.TextStyle(
                                      color: lightText, fontSize: 8))),
                          pw.Text(valStr,
                              style: pw.TextStyle(
                                  color: darkText,
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold)),
                        ]));
              }).toList())
            ]));
  }

  static pw.Widget _buildHistorySummary(List<Map<String, dynamic>> sessions) {
    final completedSessions =
        sessions.where((s) => s['end_time'] != null).toList();

    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('HISTORICAL TREND SUMMARY',
              style: pw.TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey200),
                  borderRadius: pw.BorderRadius.circular(8)),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total Assessments: ${sessions.length}',
                              style: pw.TextStyle(
                                  color: darkText,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text('Completed: ${completedSessions.length}',
                              style: pw.TextStyle(
                                  color: darkText,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold)),
                        ]),
                    pw.SizedBox(height: 10),
                    pw.Divider(color: PdfColors.grey200, height: 1),
                    pw.SizedBox(height: 10),
                    // Mini Table
                    pw.Row(children: [
                      pw.Expanded(
                          flex: 3,
                          child: pw.Text('DATE',
                              style: pw.TextStyle(
                                  color: lightText,
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(
                          flex: 3,
                          child: pw.Text('TYPE',
                              style: pw.TextStyle(
                                  color: lightText,
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(
                          flex: 2,
                          child: pw.Text('RISK',
                              style: pw.TextStyle(
                                  color: lightText,
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(
                          flex: 2,
                          child: pw.Text('SCORE',
                              style: pw.TextStyle(
                                  color: lightText,
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold))),
                    ]),
                    pw.SizedBox(height: 4),
                    pw.Column(
                        children: sessions.take(10).map((session) {
                      final date = session['start_time'] != null
                          ? DateFormat('MMM dd, yyyy').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  session['start_time'] as int))
                          : 'N/A';
                      final type = (session['session_type'] as String?)
                              ?.replaceAll('_', ' ')
                              .toUpperCase() ??
                          'UNKNOWN';
                      final level =
                          (session['risk_level'] as String?)?.toUpperCase() ??
                              '-';
                      final score = session['risk_score'] != null
                          ? (session['risk_score'] as num).toStringAsFixed(1)
                          : '-';

                      PdfColor levelColor = lightText;
                      if (level == 'HIGH') levelColor = PdfColors.red600;
                      if (level == 'MODERATE') levelColor = PdfColors.orange600;
                      if (level == 'LOW') levelColor = PdfColors.green600;

                      return pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 4),
                          child: pw.Row(children: [
                            pw.Expanded(
                                flex: 3,
                                child: pw.Text(date,
                                    style: const pw.TextStyle(
                                        color: darkText, fontSize: 9))),
                            pw.Expanded(
                                flex: 3,
                                child: pw.Text(type,
                                    style: const pw.TextStyle(
                                        color: darkText, fontSize: 9))),
                            pw.Expanded(
                                flex: 2,
                                child: pw.Text(level,
                                    style: pw.TextStyle(
                                        color: levelColor,
                                        fontSize: 9,
                                        fontWeight: pw.FontWeight.bold))),
                            pw.Expanded(
                                flex: 2,
                                child: pw.Text(score,
                                    style: const pw.TextStyle(
                                        color: darkText, fontSize: 9))),
                          ]));
                    }).toList())
                  ]))
        ]);
  }
}
