import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../gaze/gaze_service.dart';
import '../theme.dart';
import 'entry_form_screen.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/language_selector.dart';

class ResultsScreen extends StatelessWidget {
  final String testId;
  final double score;
  final String riskCategory;
  const ResultsScreen({
    required this.testId,
    required this.score,
    this.riskCategory = '',
    super.key,
  });

  Future<File?> _downloadPdfToFile(BuildContext context) async {
    return await _waitForReportAndDownload(context);
  }

  Future<void> _showReportOptions(BuildContext context) async {
    final scaffoldContext = context;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              AppLocalizations.of(context)?.reportOptions ?? 'Report Options',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildOptionButton(
                    modalContext: modalContext,
                    icon: Icons.share,
                    label: AppLocalizations.of(context)?.share ?? 'Share',
                    color: SenseAIColors.puzzleTeal,
                    onTap: () => _shareReport(scaffoldContext),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOptionButton(
                    modalContext: modalContext,
                    icon: Icons.download,
                    label: AppLocalizations.of(context)?.download ?? 'Download',
                    color: SenseAIColors.puzzleBlue,
                    onTap: () => _downloadReport(scaffoldContext),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required BuildContext modalContext,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(modalContext).pop();
        // Delay so modal is fully disposed before async work (prevents _dependents.isEmpty)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onTap();
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareReport(BuildContext context) async {
    final file = await _waitForReportAndDownload(context);
    if (file == null) return;

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    try {
      final localizations = AppLocalizations.of(context);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: localizations?.assessmentReportTitle ?? 'SenseAI Assessment Report',
        subject: localizations?.gazeReportSubject ?? 'Gaze Assessment Report',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.reportShared ?? 'Report shared successfully!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)?.errorSharing ?? 'Error sharing report'}: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _downloadReport(BuildContext context) async {
    final file = await _waitForReportAndDownload(context);
    if (file == null) return;

    try {
      final localizations = AppLocalizations.of(context);
      final result = await OpenFile.open(file.path);

      if (result.type != ResultType.done && context.mounted) {
        if (result.type == ResultType.error || result.type == ResultType.noAppToOpen) {
          await Share.shareXFiles(
            [XFile(file.path)],
            subject: localizations?.assessmentReportTitle ?? 'SenseAI Report',
            text: localizations?.assessmentReportTitle ?? 'SenseAI Gaze Assessment Report',
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${localizations?.couldNotOpenReport ?? 'Could not open report'}: ${result.message ?? "Unknown error"}'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.reportOpened ?? 'Report opened successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final localizations = AppLocalizations.of(context);
        try {
          await Share.shareXFiles(
            [XFile(file.path)],
            subject: localizations?.assessmentReportTitle ?? 'SenseAI Report',
            text: localizations?.assessmentReportTitle ?? 'SenseAI Gaze Assessment Report',
          );
        } catch (shareError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${localizations?.errorOpening ?? 'Error opening report'}: ${e.toString()}'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<File?> _waitForReportAndDownload(BuildContext context) async {
    if (context.mounted) {
      final localizations = AppLocalizations.of(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(localizations?.preparingReport ?? 'Preparing your report...'),
              const SizedBox(height: 10),
              Text(
                localizations?.takesFewSeconds ?? 'This usually takes a few seconds',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    try {
      const maxAttempts = 15;
      const pollInterval = Duration(milliseconds: 800);

      try {
        final downloadUrl = Uri.parse('$API_BASE/report/$testId/download');
        final response = await http.get(downloadUrl).timeout(const Duration(seconds: 25));

        if (response.statusCode == 200) {
          final directory = await getTemporaryDirectory();
          final file = File(
            '${directory.path}/SenseAI_Report_${testId.substring(0, 8)}.pdf',
          );
          await file.writeAsBytes(response.bodyBytes);

          if (context.mounted) {
            Navigator.of(context).pop();
          }
          return file;
        }
      } catch (e) {
        debugPrint('Report generation triggered (will poll): $e');
      }

      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        try {
          final statusUrl = Uri.parse('$API_BASE/report/$testId/status');
          final statusResponse = await http.get(statusUrl).timeout(
            const Duration(seconds: 5),
          );

          if (statusResponse.statusCode == 200) {
            final statusData = jsonDecode(statusResponse.body);
            if (statusData['ready'] == true) {
              final downloadUrl = Uri.parse('$API_BASE/report/$testId/download');
              final downloadResponse = await http.get(downloadUrl).timeout(
                const Duration(seconds: 20),
              );

              if (downloadResponse.statusCode == 200) {
                final directory = await getTemporaryDirectory();
                final file = File(
                  '${directory.path}/SenseAI_Report_${testId.substring(0, 8)}.pdf',
                );
                await file.writeAsBytes(downloadResponse.bodyBytes);

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                return file;
              }
            }
          }
        } catch (e) {
          debugPrint('Error checking report status: $e');
        }

        if (attempt < maxAttempts - 1) {
          await Future.delayed(pollInterval);
        }
      }

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.couldNotLoadReport ?? 'Could not load report. Please check your connection and try again.',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }

  String _getRiskCategory(BuildContext context, double score) {
    if (riskCategory.isNotEmpty) return riskCategory;
    final l = AppLocalizations.of(context);
    if (score >= 80) return l?.lowRisk ?? 'Low Risk';
    if (score >= 60) return l?.moderateRisk ?? 'Moderate - Further Evaluation Recommended';
    if (score >= 40) return l?.elevatedRisk ?? 'Elevated Risk - Professional Consultation Advised';
    return l?.highRisk ?? 'High Risk - Immediate Professional Evaluation Recommended';
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final scoreColor = _getScoreColor(score);
    final celebrationEmoji = score >= 80 ? '🎉' : score >= 60 ? '🌟' : score >= 40 ? '👍' : '💪';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎊', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(localizations?.allDone ?? 'All Done!'),
            const SizedBox(width: 8),
            const Text('🎊', style: TextStyle(fontSize: 24)),
          ],
        ),
        actions: const [
          LanguageSelector(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎉', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 12),
                  Text('🎊', style: TextStyle(fontSize: 56)),
                  const SizedBox(width: 12),
                  Text('🎉', style: TextStyle(fontSize: 48)),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                localizations?.youDidGreat ?? 'You Did Great!',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: SenseAIColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$celebrationEmoji ${localizations?.amazingJob ?? 'Amazing job completing the games!'} $celebrationEmoji',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: SenseAIColors.primaryBlue.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scoreColor.withOpacity(0.2),
                      scoreColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: scoreColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: scoreColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      localizations?.yourScore ?? 'Your Score',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: SenseAIColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${score.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            '%',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: scoreColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getRiskCategory(context, score),
                        style: TextStyle(
                          fontSize: 16,
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SenseAIColors.softTeal.withOpacity(0.3),
                      SenseAIColors.softPink.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: SenseAIColors.puzzleTeal.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text('📄', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 12),
                    Text(
                      localizations?.yourSpecialReport ?? 'Your Special Report',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: SenseAIColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${localizations?.creatingReportWith ?? 'We\'re creating your amazing report with:'}\n'
                      '${localizations?.featureAttention ?? '✨ How well you paid attention'}\n'
                      '${localizations?.featureEyetracking ?? '🦋 Your eye tracking skills'}\n'
                      '${localizations?.featureFocus ?? '🎯 Your focus patterns'}\n'
                      '${localizations?.featureRecommendations ?? '💡 Special recommendations'}\n\n'
                      '${localizations?.readySoon ?? 'It will be ready soon!'}',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: SenseAIColors.primaryBlue.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: SenseAIColors.puzzleTeal.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton.icon(
                    onPressed: () => _showReportOptions(context),
                    icon: Text('📄', style: TextStyle(fontSize: 28)),
                    label: Text(
                      localizations?.getReport ?? 'Get Your Report',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SenseAIColors.puzzleTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (gazeService.isInitialized) {
                      gazeService.resetForNewTest();
                    }
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const EntryFormScreen()),
                      (route) => false,
                    );
                  },
                  icon: Text('🔄', style: TextStyle(fontSize: 22)),
                  label: Text(
                    localizations?.playAgain ?? 'Play Again!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    side: BorderSide(
                      color: SenseAIColors.primaryBlue.withOpacity(0.6),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
