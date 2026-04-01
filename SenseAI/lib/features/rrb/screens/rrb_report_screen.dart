import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/detection_result_model.dart';
import '../config/rrb_config.dart';

/// RRB Report Screen — patient info form + PDF generation (Android & Web)
class RrbReportScreen extends StatefulWidget {
  final RrbDetectionResult detectionResult;
  const RrbReportScreen({super.key, required this.detectionResult});

  @override
  State<RrbReportScreen> createState() => _RrbReportScreenState();
}

class _RrbReportScreenState extends State<RrbReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _guardianCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _patientNumCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  final _clinicianCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _gender = 'Male';
  bool _isGenerating = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _guardianCtrl.dispose();
    _contactCtrl.dispose();
    _patientNumCtrl.dispose();
    _schoolCtrl.dispose();
    _clinicianCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── PDF Generation ────────────────────────────────────────────────────────────
  Future<void> _generatePdf() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isGenerating = true);
    try {
      final bytes = await _buildPdf();
      final name =
          'RRB_Report_${_nameCtrl.text.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await Printing.layoutPdf(onLayout: (_) async => bytes, name: name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to generate PDF: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<Uint8List> _buildPdf() async {
    final pdf = pw.Document();
    final result = widget.detectionResult;
    final now = DateTime.now();

    final primary = PdfColor.fromHex('0369A1');
    final accent = PdfColor.fromHex('059669');
    final warning = PdfColor.fromHex('EA580C');
    final lightBg = PdfColor.fromHex('EFF6FF');
    final textDark = PdfColor.fromHex('1E3A5F');
    final textGray = PdfColor.fromHex('6B7280');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => _pdfHeader(primary, textDark, now),
        footer: (ctx) => _pdfFooter(ctx, textGray),
        build: (ctx) => [
          _patientSection(primary, lightBg, textDark, textGray),
          pw.SizedBox(height: 20),
          _summarySection(result, primary, accent, warning, lightBg, textDark),
          pw.SizedBox(height: 20),
          // Each behavior card is a SEPARATE top-level item so MultiPage can
          // paginate them individually — never nest them in a pw.Column.
          if (result.behaviors.isNotEmpty) ...[
            _sectionTitle('Detected Behaviors — Clinical Details', primary),
            pw.SizedBox(height: 10),
            ...result.behaviors
                .map((b) => _behaviorCard(b, textDark, textGray)),
            pw.SizedBox(height: 10),
          ],
          _metadataSection(result, primary, lightBg, textDark, textGray, now),
          pw.SizedBox(height: 20),
          _disclaimerSection(textGray),
        ],
      ),
    );
    return Uint8List.fromList(await pdf.save());
  }

  // ── PDF Sections ─────────────────────────────────────────────────────────────

  pw.Widget _pdfHeader(PdfColor primary, PdfColor textDark, DateTime now) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
          border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.blueGrey200, width: 1))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('SenseAI Clinical Report',
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: primary)),
            pw.Text('Restrictive & Repetitive Behaviors (RRB) Assessment',
                style:
                    pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey600)),
          ]),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text('Date: ${now.day}/${now.month}/${now.year}',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey500)),
            pw.Text(
                'Time: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey500)),
          ]),
        ],
      ),
    );
  }

  pw.Widget _pdfFooter(pw.Context ctx, PdfColor textGray) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
          border: pw.Border(
              top: pw.BorderSide(color: PdfColors.blueGrey200, width: 0.5))),
      child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('SenseAI — AI-Powered ASD Screening Tool',
                style: pw.TextStyle(fontSize: 8, color: textGray)),
            pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                style: pw.TextStyle(fontSize: 8, color: textGray)),
          ]),
    );
  }

  pw.Widget _patientSection(PdfColor primary, PdfColor lightBg,
      PdfColor textDark, PdfColor textGray) {
    return pw
        .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _sectionTitle('Patient Information', primary),
      pw.SizedBox(height: 10),
      pw.Container(
        decoration: pw.BoxDecoration(
            color: lightBg,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
        padding: const pw.EdgeInsets.all(14),
        child: pw.Table(
          columnWidths: {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(2)
          },
          children: [
            _tableRow('Patient Name', _nameCtrl.text, textDark, textGray),
            _tableRow('Age', '${_ageCtrl.text} years', textDark, textGray),
            _tableRow('Gender', _gender, textDark, textGray),
            _tableRow(
                "Guardian's Name", _guardianCtrl.text, textDark, textGray),
            _tableRow('Contact Number', _contactCtrl.text, textDark, textGray),
            _tableRow(
                'Patient / File No.',
                _patientNumCtrl.text.isNotEmpty ? _patientNumCtrl.text : '—',
                textDark,
                textGray),
            if (_schoolCtrl.text.isNotEmpty)
              _tableRow(
                  'School / Centre', _schoolCtrl.text, textDark, textGray),
            if (_clinicianCtrl.text.isNotEmpty)
              _tableRow('Referring Clinician', _clinicianCtrl.text, textDark,
                  textGray),
            if (_notesCtrl.text.isNotEmpty)
              _tableRow('Clinical Notes', _notesCtrl.text, textDark, textGray),
          ],
        ),
      ),
    ]);
  }

  pw.Widget _summarySection(RrbDetectionResult result, PdfColor primary,
      PdfColor accent, PdfColor warning, PdfColor lightBg, PdfColor textDark) {
    final detected = result.detected;
    final statusColor = detected ? warning : accent;
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle('Detection Summary', primary),
          pw.SizedBox(height: 10),
          pw.Container(
            decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
            padding: const pw.EdgeInsets.all(14),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(children: [
                    pw.Container(
                        width: 12,
                        height: 12,
                        decoration: pw.BoxDecoration(
                            color: statusColor, shape: pw.BoxShape.circle)),
                    pw.SizedBox(width: 8),
                    pw.Text(
                        detected ? 'RRB Behaviors Detected' : 'No RRB Detected',
                        style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                            color: statusColor)),
                  ]),
                  if (result.primaryBehavior != null) ...[
                    pw.SizedBox(height: 6),
                    pw.Text('Primary Behavior: ${result.primaryBehavior}',
                        style: pw.TextStyle(fontSize: 10, color: textDark)),
                  ],
                  if (result.confidence != null) ...[
                    pw.SizedBox(height: 6),
                    pw.Text(
                        'Overall Confidence: ${(result.confidence! * 100).toStringAsFixed(1)}%',
                        style: pw.TextStyle(fontSize: 10, color: textDark)),
                    pw.SizedBox(height: 4),
                    pw.LinearProgressIndicator(
                        value: result.confidence!,
                        backgroundColor: PdfColors.blueGrey100,
                        valueColor: statusColor),
                  ],
                ]),
          ),
        ]);
  }

  // ── Flexible config lookup (case-insensitive fallback) ───────────────────────
  /// Finds a value in a const config map using exact match first, then
  /// case-insensitive match so backend naming differences don't silently fail.
  String _lookupDesc(String behavior) {
    if (RrbConfig.behaviorDescriptions.containsKey(behavior)) {
      return RrbConfig.behaviorDescriptions[behavior]!;
    }
    final lower = behavior.toLowerCase().trim();
    for (final entry in RrbConfig.behaviorDescriptions.entries) {
      if (entry.key.toLowerCase().trim() == lower) return entry.value;
    }
    return 'No clinical description available for this behavior.';
  }

  String _lookupInstr(String behavior) {
    if (RrbConfig.behaviorInstructions.containsKey(behavior)) {
      return RrbConfig.behaviorInstructions[behavior]!;
    }
    final lower = behavior.toLowerCase().trim();
    for (final entry in RrbConfig.behaviorInstructions.entries) {
      if (entry.key.toLowerCase().trim() == lower) return entry.value;
    }
    return 'Consult the child\'s clinical team for tailored recommendations.';
  }

  int _lookupColor(String behavior) {
    if (RrbConfig.categoryColors.containsKey(behavior)) {
      return RrbConfig.categoryColors[behavior]!;
    }
    final lower = behavior.toLowerCase().trim();
    for (final entry in RrbConfig.categoryColors.entries) {
      if (entry.key.toLowerCase().trim() == lower) return entry.value;
    }
    return 0xFF2196F3;
  }

  // ── Single behavior card (top-level MultiPage item) ───────────────────────────
  pw.Widget _behaviorCard(
      RrbBehaviorDetection b, PdfColor textDark, PdfColor textGray) {
    final ci = _lookupColor(b.behavior);
    final r = (ci >> 16 & 0xFF) / 255.0;
    final g = (ci >> 8 & 0xFF) / 255.0;
    final bl = (ci & 0xFF) / 255.0;
    final bColor = PdfColor(r, g, bl);
    final bColorBg = PdfColor(r, g, bl, 0.1);
    final desc = _lookupDesc(b.behavior);
    final instr = _lookupInstr(b.behavior);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      decoration: pw.BoxDecoration(
          border: pw.Border.all(color: bColor, width: 1),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
      child:
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        // Header band
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: pw.BoxDecoration(
              color: bColorBg,
              borderRadius: const pw.BorderRadius.only(
                  topLeft: pw.Radius.circular(8),
                  topRight: pw.Radius.circular(8))),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(b.behavior,
                    style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: bColor)),
                pw.Text(
                    '${(b.confidence * 100).toStringAsFixed(1)}% confidence',
                    style: pw.TextStyle(fontSize: 10, color: bColor)),
              ]),
        ),
        // Body
        pw.Padding(
          padding: const pw.EdgeInsets.all(12),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(children: [
                  pw.Text('Occurrences: ${b.occurrences}',
                      style: pw.TextStyle(fontSize: 10, color: textGray)),
                  pw.SizedBox(width: 20),
                  pw.Text('Duration: ${b.totalDuration.toStringAsFixed(1)}s',
                      style: pw.TextStyle(fontSize: 10, color: textGray)),
                ]),
                pw.SizedBox(height: 8),
                pw.Text('Clinical Description:',
                    style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: textDark)),
                pw.SizedBox(height: 3),
                pw.Text(desc,
                    style: pw.TextStyle(
                        fontSize: 10, color: textDark, lineSpacing: 3)),
                pw.SizedBox(height: 8),
                pw.Text('Recommendations:',
                    style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: textDark)),
                pw.SizedBox(height: 3),
                pw.Text(instr,
                    style: pw.TextStyle(
                        fontSize: 10, color: textDark, lineSpacing: 3)),
              ]),
        ),
      ]),
    );
  }

  pw.Widget _metadataSection(RrbDetectionResult result, PdfColor primary,
      PdfColor lightBg, PdfColor textDark, PdfColor textGray, DateTime now) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle('Video Analysis Summary', primary),
          pw.SizedBox(height: 10),
          pw.Container(
            decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
            padding: const pw.EdgeInsets.all(14),
            child: pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(1)
              },
              children: [
                _tableRow(
                    'Video Duration',
                    '${result.metadata.duration.toStringAsFixed(1)} sec',
                    textDark,
                    textGray),
                _tableRow('Frame Rate', '${result.metadata.fps} fps', textDark,
                    textGray),
                _tableRow('Sequences Analyzed',
                    '${result.metadata.sequencesAnalyzed}', textDark, textGray),
                _tableRow(
                    'Analysis Date',
                    '${result.timestamp.day}/${result.timestamp.month}/${result.timestamp.year}',
                    textDark,
                    textGray),
                _tableRow('Report Generated',
                    '${now.day}/${now.month}/${now.year}', textDark, textGray),
              ],
            ),
          ),
        ]);
  }

  pw.Widget _disclaimerSection(PdfColor textGray) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
          color: PdfColors.amber50,
          border: pw.Border.all(color: PdfColors.amber200, width: 0.5),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
      child: pw.Text(
        'DISCLAIMER: This report is generated by an AI model for clinical observation support. '
        'It does not constitute a clinical diagnosis. All findings must be reviewed and interpreted '
        'by a qualified healthcare professional. SenseAI results should be used in conjunction with '
        'comprehensive clinical evaluation.',
        style: pw.TextStyle(fontSize: 9, color: textGray, lineSpacing: 3),
      ),
    );
  }

  pw.Widget _sectionTitle(String title, PdfColor color) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  fontSize: 13, fontWeight: pw.FontWeight.bold, color: color)),
          pw.Divider(color: color, thickness: 1.5, height: 8),
        ]);
  }

  pw.TableRow _tableRow(
      String label, String value, PdfColor textDark, PdfColor textGray) {
    return pw.TableRow(children: [
      pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 5),
          child: pw.Text(label,
              style: pw.TextStyle(fontSize: 10, color: textGray))),
      pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 5),
          child: pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: textDark))),
    ]);
  }

  // ── Flutter UI ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: AppBar(
        title: const Text('Generate Clinical Report'),
        backgroundColor: const Color(0xFF0369A1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoBanner(),
              const SizedBox(height: 22),
              _buildSectionLabel('Patient Details', Icons.person_rounded,
                  const Color(0xFF0369A1)),
              const SizedBox(height: 12),
              _buildTextField(_nameCtrl, 'Full Name *', Icons.badge_rounded,
                  required: true),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _buildTextField(
                        _ageCtrl, 'Age *', Icons.cake_rounded,
                        keyboardType: TextInputType.number,
                        required: true,
                        isAge: true)),
                const SizedBox(width: 12),
                Expanded(child: _buildGenderDropdown()),
              ]),
              const SizedBox(height: 12),
              _buildTextField(_guardianCtrl, "Guardian's Name *",
                  Icons.supervisor_account_rounded,
                  required: true),
              const SizedBox(height: 12),
              _buildTextField(
                  _contactCtrl, 'Contact Number *', Icons.phone_rounded,
                  keyboardType: TextInputType.phone, required: true),
              const SizedBox(height: 12),
              _buildTextField(_patientNumCtrl, 'Patient / File Number',
                  Icons.numbers_rounded),
              const SizedBox(height: 22),
              _buildSectionLabel('Clinical Details',
                  Icons.local_hospital_rounded, const Color(0xFF7C3AED)),
              const SizedBox(height: 12),
              _buildTextField(
                  _schoolCtrl, 'School / Therapy Centre', Icons.school_rounded),
              const SizedBox(height: 12),
              _buildTextField(_clinicianCtrl, 'Referring Clinician',
                  Icons.medical_services_rounded),
              const SizedBox(height: 12),
              _buildTextField(
                  _notesCtrl, 'Additional Clinical Notes', Icons.notes_rounded,
                  maxLines: 3),
              const SizedBox(height: 22),
              _buildDetectionPreviewCard(),
              const SizedBox(height: 24),
              _buildGenerateButton(),
              const SizedBox(height: 16),
              _buildPlatformNote(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(children: [
        Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 38),
        SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Clinical PDF Report',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            SizedBox(height: 4),
            Text(
                'Fill in the patient details below. A comprehensive PDF report with detected behaviors, clinical descriptions, and recommendations will be generated.',
                style: TextStyle(
                    color: Colors.white70, fontSize: 12, height: 1.4)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon, Color color) {
    return Row(children: [
      Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 16)),
      const SizedBox(width: 10),
      Text(label,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: color)),
    ]);
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
    bool isAge = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0369A1), size: 20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0369A1), width: 2)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      validator: required
          ? (v) {
              if (v == null || v.trim().isEmpty) {
                return 'This field is required';
              }
              if (isAge) {
                final n = int.tryParse(v.trim());
                if (n == null || n < 1 || n > 25) {
                  return 'Enter a valid age (1–25)';
                }
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _gender,
      decoration: InputDecoration(
        labelText: 'Gender *',
        prefixIcon:
            const Icon(Icons.wc_rounded, color: Color(0xFF0369A1), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0369A1), width: 2)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      items: ['Male', 'Female', 'Other']
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
      onChanged: (v) => setState(() => _gender = v ?? 'Male'),
    );
  }

  Widget _buildDetectionPreviewCard() {
    final result = widget.detectionResult;
    final detected = result.detected;
    final statusColor =
        detected ? const Color(0xFFEA580C) : const Color(0xFF059669);
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.summarize_rounded, color: statusColor, size: 18),
          const SizedBox(width: 8),
          Text('Report Will Include',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: statusColor)),
        ]),
        const SizedBox(height: 12),
        _previewRow(
            Icons.check_circle_outline, 'Patient & guardian information'),
        _previewRow(
            Icons.check_circle_outline,
            detected
                ? 'RRB detected — ${result.behaviors.length} behavior(s) found'
                : 'No RRB detected'),
        if (result.primaryBehavior != null)
          _previewRow(
              Icons.check_circle_outline, 'Primary: ${result.primaryBehavior}'),
        _previewRow(Icons.check_circle_outline,
            'Clinical descriptions & recommendations'),
        _previewRow(Icons.check_circle_outline, 'Video analysis metadata'),
        _previewRow(Icons.check_circle_outline, 'Clinical disclaimer'),
      ]),
    );
  }

  Widget _previewRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF059669), size: 15),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFF374151)))),
      ]),
    );
  }

  Widget _buildGenerateButton() {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(16),
      shadowColor: const Color(0xFF059669).withValues(alpha: 0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _isGenerating ? null : _generatePdf,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF10B981)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight),
          ),
          child: _isGenerating
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5)),
                      SizedBox(width: 14),
                      Text('Generating PDF…',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ])
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Icon(Icons.picture_as_pdf_rounded,
                          color: Colors.white, size: 26),
                      SizedBox(width: 12),
                      Text('Generate & Download PDF',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ]),
        ),
      ),
    );
  }

  Widget _buildPlatformNote() {
    final msg = kIsWeb
        ? 'On Web: A print/save dialog will open. Choose "Save as PDF" to download.'
        : 'On Android: A print preview will appear. Tap the download icon to save the PDF.';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF7DD3FC))),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded,
            color: Color(0xFF0284C7), size: 16),
        const SizedBox(width: 8),
        Expanded(
            child: Text(msg,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF075985), height: 1.4))),
      ]),
    );
  }
}
