import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/backend_config.dart';

/// M-CHAT-R/F Digital Form: 20 yes/no questions, auto-scoring, comparison with ML.
class MchatPage extends StatefulWidget {
  final String? childName;
  final int? childAge;
  final String? childId;

  const MchatPage({
    super.key,
    this.childName,
    this.childAge,
    this.childId,
  });

  @override
  State<MchatPage> createState() => _MchatPageState();
}

class _MchatPageState extends State<MchatPage> {
  List<Map<String, dynamic>> _questions = [];
  final Map<int, bool?> _answers = {}; // item_id -> true=yes, false=no
  bool _loading = true;
  String? _loadError;
  bool _submitting = false;
  Map<String, dynamic>? _scoreResult;
  Map<String, dynamic>? _comparison;

  String get _effectiveChildId =>
      widget.childId ?? '${widget.childName ?? 'child'}_${widget.childAge ?? 0}';

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    // Also load last saved result so previous answers / score show up
    // when coming back to this page.
    _loadLastSavedResult();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final res = await http
          .get(Uri.parse(BackendConfig.mchatQuestionsEndpoint))
          .timeout(BackendConfig.connectionTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rawList = data['questions'] as List?;
        final q = rawList?.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList() ?? [];
        setState(() {
          _questions = q;
          for (var item in q) {
            final id = item['id'] as int?;
            if (id != null) _answers[id] = null;
          }
          _loading = false;
        });
      } else {
        setState(() {
          _loadError = 'Failed to load questions: ${res.statusCode}';
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

  Future<void> _loadLastSavedResult() async {
    try {
      final uri = Uri.parse(
          '${BackendConfig.mchatHistoryEndpoint}?child_id=$_effectiveChildId');
      final res =
          await http.get(uri).timeout(BackendConfig.connectionTimeout);
      if (res.statusCode != 200) return;
      final data = jsonDecode(res.body);
      final history = data['history'] as List?;
      if (history == null || history.isEmpty) return;
      final latestRaw = history.last;
      if (latestRaw is! Map) return;
      final latest =
          Map<String, dynamic>.from(latestRaw as Map<dynamic, dynamic>);
      final scoreRaw = latest['score'];
      final score = scoreRaw is Map
          ? Map<String, dynamic>.from(scoreRaw as Map<dynamic, dynamic>)
          : null;
      final answersList = latest['answers'] as List?;
      if (!mounted) return;
      setState(() {
        if (score != null) {
          _scoreResult = score;
        }
        if (answersList != null) {
          for (final a in answersList) {
            if (a is! Map) continue;
            final id = a['item_id'] as int?;
            final ansStr = a['answer']?.toString().toLowerCase();
            if (id == null || !_answers.containsKey(id)) continue;
            if (ansStr == 'yes') {
              _answers[id] = true;
            } else if (ansStr == 'no') {
              _answers[id] = false;
            }
          }
        }
      });
    } catch (_) {}
  }

  Future<void> _submit() async {
    final answers = <Map<String, dynamic>>[];
    for (var q in _questions) {
      final id = q['id'] as int?;
      if (id == null) continue;
      final a = _answers[id];
      if (a == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please answer all 20 questions.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      answers.add({'item_id': id, 'answer': a ? 'yes' : 'no'});
    }
    setState(() => _submitting = true);
    try {
      final body = {
        'child_id': _effectiveChildId,
        'child_name': widget.childName ?? '',
        'child_age_months': widget.childAge != null ? widget.childAge! * 12 : null,
        'answers': answers,
      };
      final res = await http
          .post(
            Uri.parse(BackendConfig.mchatSubmitEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(BackendConfig.receiveTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rawScore = data['score'];
        final score = (rawScore == null || rawScore is! Map) ? null : Map<String, dynamic>.from(rawScore as Map);
        setState(() {
          _scoreResult = score;
          _submitting = false;
        });
        _loadComparison();
      } else {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submit failed: ${res.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _loadComparison() async {
    try {
      final res = await http
          .get(Uri.parse(BackendConfig.compareEndpoint(_effectiveChildId)))
          .timeout(BackendConfig.connectionTimeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => _comparison = data is Map ? Map<String, dynamic>.from(data as Map) : null);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('M-CHAT-R/F', style: TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold)),
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
                          onPressed: _loadQuestions,
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
                      ..._questions.map((q) => _buildQuestion(q)),
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
                      if (_scoreResult != null) ...[
                        const SizedBox(height: 24),
                        _buildScoreCard(),
                      ],
                      if (_comparison != null) ...[
                        const SizedBox(height: 16),
                        _buildComparisonCard(),
                      ],
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
              Icon(Icons.checklist, color: const Color(0xFF7132C1)),
              const SizedBox(width: 12),
              const Text(
                'Modified Checklist for Autism in Toddlers',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '20 yes/no questions for parents. Answer based on your child\'s usual behavior. '
            'Scores: 0–2 Low risk, 3–7 Medium (follow-up), 8–20 High risk.',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(Map<String, dynamic> q) {
    final id = q['id'] as int? ?? 0;
    final text = q['text'] as String? ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$id. $text',
              style: const TextStyle(fontSize: 15, color: Color(0xFF2C3E50)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _choice(true, id),
                const SizedBox(width: 16),
                _choice(false, id),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _choice(bool yes, int id) {
    final selected = _answers[id] == yes;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _answers[id] = yes),
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
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text('Submit & See Score'),
      ),
    );
  }

  Widget _buildScoreCard() {
    final score = _scoreResult!;
    final total = score['total_score'] as int? ?? 0;
    final level = score['risk_level'] as String? ?? 'unknown';
    Color levelColor = Colors.grey;
    if (level == 'low') levelColor = Colors.green;
    if (level == 'medium') levelColor = Colors.orange;
    if (level == 'high') levelColor = Colors.red;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'M-CHAT Score',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Total: $total / 20', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  level.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: levelColor),
                ),
              ),
            ],
          ),
          if (score['follow_up_needed'] == true)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Follow-up recommended. Discuss with your healthcare provider.',
                style: TextStyle(fontSize: 13, color: Colors.orange[800]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard() {
    final comp = _comparison!;
    final mchat = comp['latest_mchat'] as Map?;
    final ml = comp['latest_ml_prediction'] as Map?;
    final agreement = comp['agreement'] as bool?;
    if (mchat == null && ml == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparison: M-CHAT vs AI Screening',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
          ),
          const SizedBox(height: 12),
          if (mchat != null)
            Text(
              'M-CHAT risk: ${(mchat['score'] as Map?)?['risk_level'] ?? '—'}',
              style: const TextStyle(fontSize: 14),
            ),
          if (ml != null)
            Text(
              'AI prediction: ${ml['prediction'] ?? '—'} (confidence: ${ml['confidence'] ?? '—'})',
              style: const TextStyle(fontSize: 14),
            ),
          if (agreement != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                agreement
                    ? 'Traditional screening and AI screening agree.'
                    : 'Traditional screening and AI screening differ. Discuss with a professional.',
                style: TextStyle(fontSize: 13, color: agreement ? Colors.green[700] : Colors.orange[800]),
              ),
            ),
        ],
      ),
    );
  }
}
