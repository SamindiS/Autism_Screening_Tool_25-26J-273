import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/backend_config.dart';

/// Developmental Milestone Tracker: CDC age bands, expected vs actual, flag delays.
class MilestoneTrackerPage extends StatefulWidget {
  final String? childName;
  final int? childAge;
  final String? childId;

  const MilestoneTrackerPage({
    super.key,
    this.childName,
    this.childAge,
    this.childId,
  });

  @override
  State<MilestoneTrackerPage> createState() => _MilestoneTrackerPageState();
}

class _MilestoneTrackerPageState extends State<MilestoneTrackerPage> {
  int _ageMonths = 24;
  List<Map<String, dynamic>> _milestones = [];
  int _ageBandMonths = 24;
  final Set<String> _achievedIds = {};
  bool _loading = true;
  String? _loadError;
  bool _submitting = false;

  String get _effectiveChildId =>
      widget.childId ?? '${widget.childName ?? 'child'}_${widget.childAge ?? 0}';

  @override
  void initState() {
    super.initState();
    if (widget.childAge != null) _ageMonths = widget.childAge! * 12;
    _loadMilestones();
  }

  Future<void> _loadMilestones() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final res = await http
          .get(Uri.parse(BackendConfig.milestonesEndpoint(_ageMonths)))
          .timeout(BackendConfig.connectionTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final band = data['age_band_months'] as int? ?? _ageMonths;
        final rawList = data['milestones'] as List?;
        final list = rawList?.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList() ?? [];
        setState(() {
          _milestones = list;
          _ageBandMonths = band;
          _loading = false;
        });
      } else {
        setState(() {
          _loadError = 'Failed to load milestones: ${res.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _submitProgress() async {
    setState(() => _submitting = true);
    try {
      final body = {
        'child_id': _effectiveChildId,
        'child_name': widget.childName ?? '',
        'age_months': _ageMonths,
        'achieved_ids': _achievedIds.toList(),
      };
      final res = await http
          .post(
            Uri.parse(BackendConfig.milestonesSubmitEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(BackendConfig.receiveTimeout);
      setState(() => _submitting = false);
      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Progress saved.'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Milestone Tracker', style: TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7132C1)))
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_loadError!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: _loadMilestones,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 20),
                      _buildAgeSelector(),
                      const SizedBox(height: 20),
                      _buildTimelineHeader(),
                      const SizedBox(height: 12),
                      ..._milestones.groupBy((m) => m['category'] as String?).entries.map((e) => _buildCategorySection(e.key ?? 'Other', e.value)),
                      const SizedBox(height: 24),
                      _buildSaveButton(),
                      if (_achievedIds.length < _milestones.length && _milestones.isNotEmpty)
                        _buildDelaysFlag(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: const Color(0xFF7132C1)),
              const SizedBox(width: 12),
              const Text(
                'CDC Developmental Milestones',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Age-appropriate checklist (CDC guidelines). Tap when your child has reached a milestone. '
            'Delays that may correlate with autism markers are flagged.',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Child age (months)', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _ageMonths.toDouble(),
                  min: 6,
                  max: 60,
                  divisions: 54,
                  label: '$_ageMonths months',
                  activeColor: const Color(0xFF7132C1),
                  onChanged: (v) {
                    setState(() {
                      _ageMonths = v.round();
                      _achievedIds.clear();
                    });
                    _loadMilestones();
                  },
                ),
              ),
              Text('$_ageMonths mo', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Text(
            'Showing milestones for age band: $_ageBandMonths months',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineHeader() {
    final met = _achievedIds.length;
    final total = _milestones.length;
    return Row(
      children: [
        const Text('Expected vs actual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        const Spacer(),
        Text(
          '$met / $total met',
          style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildCategorySection(String category, List<Map<String, dynamic>> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              category,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF7132C1)),
            ),
          ),
          ...items.map((m) => _buildMilestoneTile(m)),
        ],
      ),
    );
  }

  Widget _buildMilestoneTile(Map<String, dynamic> m) {
    final id = m['id'] as String? ?? '';
    final text = m['text'] as String? ?? '';
    final achieved = _achievedIds.contains(id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() {
          if (achieved) _achievedIds.remove(id); else _achievedIds.add(id);
        }),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: achieved ? const Color(0xFF7132C1).withOpacity(0.08) : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: achieved ? const Color(0xFF7132C1).withOpacity(0.3) : Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(
                achieved ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 24,
                color: achieved ? Colors.green : Colors.grey[400],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    color: achieved ? Colors.grey[700] : const Color(0xFF2C3E50),
                    decoration: achieved ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submitProgress,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7132C1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _submitting
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Save progress'),
      ),
    );
  }

  Widget _buildDelaysFlag() {
    final delays = _milestones.where((m) => !_achievedIds.contains(m['id'])).length;
    if (delays == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.flag, color: Colors.orange[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$delays milestone(s) not yet met for this age band. Discuss with your healthcare provider if delays correlate with other concerns.',
                style: TextStyle(fontSize: 13, color: Colors.orange[900]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _GroupBy<T> on List<T> {
  Map<K, List<T>> groupBy<K>(K Function(T) keyOf) {
    final map = <K, List<T>>{};
    for (final e in this) {
      final k = keyOf(e);
      map.putIfAbsent(k, () => []).add(e);
    }
    return map;
  }
}
