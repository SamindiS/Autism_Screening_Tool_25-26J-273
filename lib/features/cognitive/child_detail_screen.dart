import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/services/storage_service.dart';
import 'add_child_screen.dart';
import 'age_select_screen.dart';

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

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Child'),
          content: const Text(
            'Are you sure you want to delete this child and all associated sessions? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Child deleted successfully'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Details'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _handleEdit,
            tooltip: 'Edit Child',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleting ? null : _handleDelete,
            tooltip: 'Delete Child',
          ),
        ],
      ),
      body: RefreshIndicator(
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
              _buildActions(),
              const SizedBox(height: 24),
              _buildSessionHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(int ageYears, int ageMonths, DateTime dob) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _child['name'] as String? ?? 'Unnamed Child',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.cake_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat.yMMMd().format(dob)} • $ageYears y $ageMonths m',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 20),
                const SizedBox(width: 8),
                Text(_child['gender']?.toString() ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.language, size: 20),
                const SizedBox(width: 8),
                Text((_child['language'] as String?)?.toUpperCase() ?? 'N/A'),
              ],
            ),
            if (_child['hospital_id'] != null &&
                (_child['hospital_id'] as String?)?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.local_hospital_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(_child['hospital_id'] as String),
                  ],
                ),
              ),
          ],
        ),
      ),
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
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.play_circle_fill),
            label: const Text('Start Assessment'),
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
              children: const [
                Text(
                  'Session History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text('No sessions recorded yet.'),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    final status = endTimestamp == null ? 'In Progress' : 'Completed';
    final risk = session['risk_level'] ?? 'N/A';
    final metrics = session['metrics'] as Map<String, dynamic>?;
    final score = metrics?['score'] ?? metrics?['accuracy'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          _formatSessionType(session['session_type'] as String? ?? 'Session'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat.yMMMd().add_jm().format(start)),
            Text('Status: $status'),
            if (score != null) Text('Score: $score'),
            if (risk != 'N/A') Text('Risk level: $risk'),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          // Reserved for future session detail screen
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
        return 'Color & Shape Game';
      case 'manual_assessment':
        return 'Manual Assessment';
      default:
        return type.replaceAll('_', ' ').toUpperCase();
    }
  }
}
