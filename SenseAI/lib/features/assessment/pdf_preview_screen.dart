import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../core/services/pdf_report_service.dart';

class PdfPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> childData;
  final List<Map<String, dynamic>> sessions;

  const PdfPreviewScreen({
    Key? key,
    required this.childData,
    required this.sessions,
  }) : super(key: key);

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    return await PdfReportService.generatePdfBytes(
      child: widget.childData,
      sessions: widget.sessions,
    );
  }

  Future<void> _downloadPdf(BuildContext context, Uint8List bytes) async {
    try {
      final childName = widget.childData['name'] ?? 'Child';
      final fileName = '${childName}_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      
      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        // We can either just share it immediately for the user to save to files, 
        // or just show a success message if we only wanted to save it internally.
        // Usually on mobile "Download" is best handled via sharing so user can pick where to save.
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Clinical Assessment Report: $childName',
          subject: 'SenseAI Assessment Report',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Preview'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Cancel',
          )
        ],
      ),
      body: PdfPreview(
        build: _generatePdf,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
        onShared: (context) {
          // Additional logic on share if needed
        },
        actions: [
          PdfPreviewAction(
            icon: const Icon(Icons.download),
            onPressed: (context, build, pageFormat) async {
               final bytes = await build(pageFormat);
               _downloadPdf(context, bytes);
            },
          ),
        ],
      ),
    );
  }
}
