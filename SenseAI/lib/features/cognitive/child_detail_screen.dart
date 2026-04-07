import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/services/storage_service.dart';
import '../../core/services/pdf_report_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/child.dart';
import 'add_child_screen.dart';
import 'age_select_screen.dart';
import 'session_detail_screen.dart';

/// Comprehensive clinical dossier for a specific child.
/// 
/// Displays the child's profile summaries alongside a chronologically ordered 
/// history of all past screening sessions. Exposes critical actions to clinicians 
/// such as starting a new assessment, editing profile info, or instantly generating 
/// and sharing a PDF clinical report.
class ChildDetailScreen extends StatefulWidget {
  final Map<String, dynamic> child;

  const ChildDetailScreen({Key? key, required this.child}) : super(key: key);

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> {
  late Map<String, dynamic> _child;
  late Future<List<Map<String, dynamic>>> _sessionsFuture;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _child = Map<String, dynamic>.from(widget.child);
    _sessionsFuture = _loadSessions();
  }

  // Get study group from child data
  ChildGroup get _studyGroup {
    final groupStr = _child['study_group'] as String? ?? 
                     _child['group'] as String? ?? 
                     'typically_developing';
    return ChildGroup.fromJson(groupStr);
  }

  bool get _isAsdGroup => _studyGroup == ChildGroup.asd;

  // Get ASD level if applicable
  AsdLevel? get _asdLevel {
    final levelStr = _child['asd_level'] as String?;
    return levelStr != null ? AsdLevel.fromJson(levelStr) : null;
  }

  // Get primary color based on group
  Color get _primaryColor => _isAsdGroup 
      ? const Color(0xFF6366F1) 
      : const Color(0xFF10B981);

  Future<List<Map<String, dynamic>>> _loadSessions() async {
    final sessions =
        await StorageService.getSessionsByChild(_child['id'] as String);
    return sessions
        .map((session) => {
              ...session,
              'metrics': _decodeMetrics(session['metrics']),
            })
        .toList();
  }

  Map<String, dynamic>? _decodeMetrics(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _refreshChild() async {
    final latest = await StorageService.getChild(_child['id'] as String);
    if (latest != null && mounted) {
      setState(() {
        _child = latest;
      });
    }
  }

  Future<void> _handleEdit() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddChildScreen(child: _child),
      ),
    );

    if (updated == true) {
      await _refreshChild();
      setState(() {
        _sessionsFuture = _loadSessions();
      });
    }
  }

  bool _generatingReport = false;

  Future<void> _handleDownloadReport() async {
    if (_generatingReport) return;

    setState(() => _generatingReport = true);

    try {
      // Load sessions
      final sessions = await _loadSessions();

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return AlertDialog(
              content: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 20),
                  Text(l10n?.translate('generating_pdf_report') ?? 'Generating PDF report...'),
                ],
              ),
            );
          },
        );
      }

      // Generate and share PDF
      await PdfReportService.generateAndShareReport(
        child: _child,
        sessions: sessions,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.translate('pdf_report_success') ?? 'PDF report generated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _generatingReport = false);
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n?.translate('delete_child') ?? 'Delete Child'),
          content: Text(
            l10n?.translate('delete_child_confirm') ??
                'Are you sure you want to delete this child and all associated sessions? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                l10n?.translate('delete_label') ?? 'Delete',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _deleting = true);
    try {
      await StorageService.deleteChild(_child['id'] as String);
      if (mounted) {
        Navigator.pop(context, true);
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.translate('child_deleted_success') ?? 'Child deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete child: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  void _startAssessment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgeSelectScreen(childId: _child['id'] as String),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dob = DateTime.fromMillisecondsSinceEpoch(
      (_child['date_of_birth'] as num).toInt(),
    );
    final ages = _ageBreakdown(dob, _child['age'] as num?);
    final ageYears = ages[0];
    final ageMonths = ages[1];

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.translate('child_profile') ?? 'Child Profile'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _handleDownloadReport,
            tooltip: l10n?.exportPdf ?? 'Download PDF Report',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _handleEdit,
            tooltip: l10n?.translate('edit_label') ?? 'Edit Child',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleting ? null : _handleDelete,
            tooltip: l10n?.translate('delete_child') ?? 'Delete Child',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            await _refreshChild();
            setState(() {
              _sessionsFuture = _loadSessions();
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileCard(ageYears, ageMonths, dob),
                const SizedBox(height: 16),
                _buildStudyInfoCard(),
                const SizedBox(height: 16),
                _buildActions(),
                const SizedBox(height: 24),
                _buildSessionHistory(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(int ageYears, int ageMonths, DateTime dob) {
    final childCode = _child['child_code'] as String? ?? _child['name'] as String? ?? 'Unknown';
    final childName = _child['name'] as String?;
    final ageInMonths = _child['age_in_months'] as int?;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with group badge
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _isAsdGroup ? Icons.medical_services : Icons.school,
                    color: _primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        childCode,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (childName != null && childName != childCode)
                        Text(
                          childName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Builder(builder: (ctx) {
                    final l10n = AppLocalizations.of(ctx);
                    return Text(
                      _isAsdGroup
                          ? (l10n?.translate('previously_diagnosed') ?? 'Previously diagnosed')
                          : (l10n?.translate('screening_label') ?? 'Screening'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            
            // Age Row
            _buildInfoRow(
              icon: Icons.cake_outlined,
              label: l10n?.age ?? 'Age',
              value: ageInMonths != null
                  ? '$ageInMonths ${l10n?.months ?? "months"} ($ageYears${l10n?.translate("years_short") ?? "y"} $ageMonths${l10n?.translate("months_short") ?? "m"})'
                  : '$ageYears ${l10n?.years ?? "years"} $ageMonths ${l10n?.months ?? "months"}',
            ),
            const SizedBox(height: 12),
            // Date of Birth Row
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: l10n?.dateOfBirth ?? 'Date of Birth',
              value: DateFormat.yMMMd().format(dob),
            ),
            const SizedBox(height: 12),
            // Gender Row
            _buildInfoRow(
              icon: Icons.person_outline,
              label: l10n?.gender ?? 'Gender',
              value: _child['gender']?.toString() ?? 'N/A',
            ),
            const SizedBox(height: 12),
            // Language Row
            _buildInfoRow(
              icon: Icons.language,
              label: l10n?.language ?? 'Language',
              value: _getLanguageName(_child['language'] as String? ?? 'en'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyInfoCard() {
    final diagnosisSource = _child['diagnosis_source'] as String? ?? 'Unknown';
    final diagnosisType = (_child['diagnosis_type'] as String?) ?? 'new';
    final l10nStudy = AppLocalizations.of(context);
    final diagnosisTypeLabel = diagnosisType == 'existing'
        ? (l10nStudy?.translate('diagnosis_before') ?? 'Diagnosis before')
        : (l10nStudy?.translate('new_diagnosis') ?? 'New diagnosis');
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_information, color: _primaryColor),
                const SizedBox(width: 8),
                Text(
                  l10nStudy?.translate('clinical_information') ?? 'Clinical Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Diagnosis status
            _buildInfoRow(
              icon: _isAsdGroup ? Icons.medical_services : Icons.school,
              label: l10nStudy?.translate('diagnosis_status') ?? 'Diagnosis Status',
              value: diagnosisTypeLabel,
            ),
            const SizedBox(height: 12),
            // ASD Level (only for ASD group)
            if (_isAsdGroup) ...[
              _buildInfoRow(
                icon: Icons.assessment,
                label: l10nStudy?.translate('asd_level') ?? 'ASD Level',
                value: _asdLevel?.displayName ?? (l10nStudy?.translate('not_specified') ?? 'Not specified'),
                valueWidget: _asdLevel != null ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    _asdLevel!.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ) : null,
              ),
              const SizedBox(height: 12),
            ],
            
            // Diagnosis Source Row
            _buildInfoRow(
              icon: _isAsdGroup ? Icons.local_hospital : Icons.school,
              label: l10nStudy?.translate('diagnosis_source') ?? 'Diagnosis Source',
              value: diagnosisSource,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? valueWidget,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              valueWidget ?? Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _startAssessment,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.play_circle_fill),
            label: Builder(builder: (ctx) {
              final l10n = AppLocalizations.of(ctx);
              return Text(
                l10n?.startAssessment ?? 'Start DCCS Game',
                style: const TextStyle(fontWeight: FontWeight.bold),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionHistory() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _sessionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final sessions = snapshot.data ?? [];
        if (sessions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.history, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    Builder(builder: (ctx) {
                      final l10n = AppLocalizations.of(ctx);
                      return Text(
                        l10n?.translate('session_history') ?? 'Session History',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.games, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Builder(builder: (ctx) {
                        final l10n = AppLocalizations.of(ctx);
                        return Column(children: [
                          Text(
                            l10n?.translate('no_sessions_yet') ?? 'No sessions recorded yet',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n?.translate('no_sessions_desc') ?? 'Start the DCCS game to begin collecting data',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ]);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Builder(builder: (ctx) {
                  final l10n = AppLocalizations.of(ctx);
                  return Text(
                    l10n?.translate('session_history') ?? 'Session History',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  );
                }),
                const Spacer(),
                Text(
                  '${sessions.length} session${sessions.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...sessions.map(_buildSessionTile).toList(),
          ],
        );
      },
    );
  }

  Widget _buildSessionTile(Map<String, dynamic> session) {
    final start =
        DateTime.fromMillisecondsSinceEpoch(session['start_time'] as int);
    final endTimestamp = session['end_time'] as int?;
    final l10n = AppLocalizations.of(context);
    final status = endTimestamp == null
        ? (l10n?.translate('in_progress') ?? 'In Progress')
        : (l10n?.translate('completed_text') ?? 'Completed');
    final metrics = session['metrics'] as Map<String, dynamic>?;
    final score = metrics?['score'] ?? metrics?['accuracy'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.games,
            color: _primaryColor,
          ),
        ),
        title: Text(
          _formatSessionType(session['session_type'] as String? ?? 'Session'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormat.yMMMd().add_jm().format(start),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: endTimestamp != null 
                        ? Colors.green.shade50 
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: endTimestamp != null 
                          ? Colors.green.shade700 
                          : Colors.orange.shade700,
                    ),
                  ),
                ),
                if (score != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${l10n?.score ?? "Score"}: $score',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SessionDetailScreen(
                sessionId: session['id'] as String,
                childName: _child['name'] as String? ?? 'Unknown',
                primaryColor: _primaryColor,
              ),
            ),
          );
        },
      ),
    );
  }

  List<int> _ageBreakdown(DateTime dob, num? cachedAge) {
    if (cachedAge != null) {
      final years = cachedAge.floor();
      final months = ((cachedAge - years) * 12).round();
      return [years, months];
    }
    final totalYears = DateTime.now().difference(dob).inDays / 365.25;
    final years = totalYears.floor();
    final months = ((totalYears - years) * 12).round();
    return [years, months];
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
      default:
        return type.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _getLanguageName(String code) {
    switch (code.toLowerCase()) {
      case 'en':
        return 'English';
      case 'si':
        return 'Sinhala (සිංහල)';
      case 'ta':
        return 'Tamil (தமிழ்)';
      default:
        return code.toUpperCase();
    }
  }
}
