import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/backend_config.dart';

/// Parent Report Questionnaire: social communication, repetitive behaviors, sensory, RTN history.
class PrqPage extends StatefulWidget {
  final String? childName;
  final int? childAge;
  final String? childId;

  const PrqPage({
    super.key,
    this.childName,
    this.childAge,
    this.childId,
  });

  @override
  State<PrqPage> createState() => _PrqPageState();
}

class _PrqPageState extends State<PrqPage> {
  List<Map<String, dynamic>> _sections = [];
  final Map<String, Map<String, dynamic>> _answers = {}; // sectionId -> { questionId: value }
  bool _loading = true;
  String? _loadError;
  bool _submitting = false;

  String get _effectiveChildId =>
      widget.childId ?? '${widget.childName ?? 'child'}_${widget.childAge ?? 0}';

  @override
  void initState() {
    super.initState();
    _loadSchema();
  }

  Future<void> _loadSchema() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final res = await http
          .get(Uri.parse(BackendConfig.prqSchemaEndpoint))
          .timeout(BackendConfig.connectionTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rawSections = data['sections'] as List?;
        final sections = rawSections?.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList() ?? [];
        setState(() {
          _sections = sections;
          for (var s in sections) {
            final sid = s['id'] as String? ?? '';
            _answers[sid] = {};
            for (var q in (s['questions'] as List?) ?? []) {
              final qid = (q as Map)['id'] as String? ?? '';
              _answers[sid]![qid] = null;
            }
          }
          _loading = false;
        });
      } else {
        setState(() {
          _loadError = 'Failed to load questionnaire: ${res.statusCode}';
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

  Future<void> _submit() async {
    // Build answers: section_id -> list of { question_id, answer }
    final Map<String, dynamic> payload = {};
    for (var s in _sections) {
      final sid = s['id'] as String? ?? '';
      final sectionAnswers = _answers[sid];
      if (sectionAnswers == null) continue;
      payload[sid] = sectionAnswers.map((qid, v) => MapEntry(qid, v));
    }
    setState(() => _submitting = true);
    try {
      final body = {
        'child_id': _effectiveChildId,
        'child_name': widget.childName ?? '',
        'answers': payload,
      };
      final res = await http
          .post(
            Uri.parse(BackendConfig.prqSubmitEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(BackendConfig.receiveTimeout);
      setState(() => _submitting = false);
      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Questionnaire saved.'), backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Submit failed: ${res.statusCode}')),
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
        title: const Text('Parent Report Questionnaire', style: TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold)),
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
                          onPressed: _loadSchema,
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
                      const SizedBox(height: 24),
                      ..._sections.map((s) => _buildSection(s)),
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
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
              Icon(Icons.assignment, color: const Color(0xFF7132C1)),
              const SizedBox(width: 12),
              const Text(
                'Parent Report Questionnaire (PRQ)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Social communication, repetitive behaviors, sensory sensitivities, and historical RTN patterns. '
            'Answer based on your child\'s usual behavior.',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(Map<String, dynamic> section) {
    final id = section['id'] as String? ?? '';
    final title = section['title'] as String? ?? '';
    final rawQ = section['questions'] as List?;
    final questions = rawQ?.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList() ?? [];
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7132C1)),
            ),
            const SizedBox(height: 16),
            ...questions.map((q) => _buildQuestion(id, q)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(String sectionId, Map<String, dynamic> q) {
    final qid = q['id'] as String? ?? '';
    final text = q['text'] as String? ?? '';
    final type = q['type'] as String? ?? 'yes_no';
    final current = _answers[sectionId]?[qid];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 15, color: Color(0xFF2C3E50)),
          ),
          const SizedBox(height: 8),
          if (type == 'yes_no')
            Row(
              children: [
                _yesNoChoice(sectionId, qid, true, current == true),
                const SizedBox(width: 12),
                _yesNoChoice(sectionId, qid, false, current == false),
              ],
            )
          else if (type == 'scale')
            Wrap(
              spacing: 8,
              children: ['Rarely', 'Sometimes', 'Often', 'Almost always'].asMap().entries.map((e) {
                final val = e.value;
                final selected = current == val;
                return ChoiceChip(
                  label: Text(val),
                  selected: selected,
                  onSelected: (s) => setState(() {
                    _answers[sectionId] ??= {};
                    _answers[sectionId]![qid] = val;
                  }),
                  selectedColor: const Color(0xFF7132C1).withOpacity(0.3),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _yesNoChoice(String sectionId, String qid, bool yes, bool selected) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _answers[sectionId] ??= {};
          _answers[sectionId]![qid] = yes;
        }),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF7132C1).withOpacity(0.15) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? const Color(0xFF7132C1) : Colors.grey[300]!,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 20,
                color: selected ? const Color(0xFF7132C1) : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                yes ? 'Yes' : 'No',
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? const Color(0xFF7132C1) : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7132C1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _submitting
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Save questionnaire'),
      ),
    );
  }
}
