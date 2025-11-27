import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/age_calculator.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/language_selector.dart';
import '../../data/models/child.dart';
import 'add_child_screen.dart';
import 'child_list_screen.dart';
import 'age_select_screen.dart';

class CognitiveDashboardScreen extends StatefulWidget {
  const CognitiveDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CognitiveDashboardScreen> createState() => _CognitiveDashboardScreenState();
}

class _CognitiveDashboardScreenState extends State<CognitiveDashboardScreen> {
  bool _loading = true;
  List<Child> _children = [];
  List<Map<String, dynamic>> _sessions = [];
  
  // Statistics
  int _totalChildren = 0;
  int _completedAssessments = 0;
  int _pendingAssessments = 0;
  int _todayAssessments = 0;
  
  // Search and filter
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'all'; // 'all', 'completed', 'pending'

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Note: Data refresh is handled explicitly after navigation returns
    // to avoid double-loading issues
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      // Load children
      final childrenData = await StorageService.getAllChildren();
      _children = childrenData.map((data) {
        // Convert storage format to Child model
        final dob = DateTime.fromMillisecondsSinceEpoch(data['date_of_birth'] as int);
        final groupStr = data['study_group'] as String? ?? data['group'] as String? ?? 'typically_developing';
        return Child(
          id: data['id'] as String,
          childCode: data['child_code'] as String? ?? data['name'] as String,
          name: data['name'] as String,
          dateOfBirth: dob,
          ageInMonths: data['age_in_months'] as int? ?? _calculateAgeInMonths(dob),
          gender: data['gender'] as String,
          language: data['language'] as String,
          age: (data['age'] as num).toDouble(),
          createdAt: DateTime.fromMillisecondsSinceEpoch(data['created_at'] as int),
          group: ChildGroup.fromJson(groupStr),
          asdLevel: data['asd_level'] != null ? AsdLevel.fromJson(data['asd_level'] as String) : null,
          diagnosisSource: data['diagnosis_source'] as String? ?? 'Unknown',
        );
      }).toList();

      // Load sessions
      _sessions = await StorageService.getAllSessions();

      // Calculate statistics
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      _completedAssessments = _sessions.where((s) => s['end_time'] != null).length;
      _pendingAssessments = _sessions.where((s) => s['end_time'] == null).length;
      _todayAssessments = _sessions.where((s) {
        final sessionDate = DateTime.fromMillisecondsSinceEpoch(s['created_at'] as int);
        return sessionDate.isAfter(todayStart);
      }).length;

      if (mounted) {
        setState(() {
          _totalChildren = _children.length;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Text('${l10n?.translate('error_loading') ?? "Error loading data"}: $e');
              },
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Child> _getFilteredChildren() {
    var filtered = _children;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((child) {
        return child.name.toLowerCase().contains(_searchQuery) ||
               child.gender.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply status filter (if needed in future)
    // For now, we'll just return filtered children

    // Sort by most recent first
    filtered.sort((a, b) {
      final aSessions = _sessions.where((s) => s['child_id'] == a.id).toList();
      final bSessions = _sessions.where((s) => s['child_id'] == b.id).toList();
      
      if (aSessions.isEmpty && bSessions.isEmpty) return 0;
      if (aSessions.isEmpty) return 1;
      if (bSessions.isEmpty) return -1;
      
      final aLatest = aSessions.first['created_at'] as int;
      final bLatest = bSessions.first['created_at'] as int;
      return bLatest.compareTo(aLatest);
    });

    return filtered.take(5).toList(); // Show only 5 most recent
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Text(
              '${l10n?.cognitiveFlexibility ?? "Cognitive Flexibility"} & ${l10n?.ruleSwitching ?? "Rule Switching"}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          },
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const LanguageSelector(),
          ),
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: l10n?.refresh ?? 'Refresh',
                  onPressed: _loadData,
                ),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade50,
                    Colors.white,
                  ],
                ),
              ),
              child: SafeArea(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  color: Colors.blue.shade600,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card
                        _buildHeaderCard(),
                        const SizedBox(height: 24),
                        // Statistics Cards
                        _buildStatisticsCards(),
                        const SizedBox(height: 24),
                        // Quick Actions
                        _buildQuickActions(),
                        const SizedBox(height: 24),
                        // Search Bar
                        _buildSearchBar(),
                        const SizedBox(height: 24),
                        // Recent Children
                        _buildRecentChildren(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.lightBlue.shade400],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context);
                        return Text(
                          l10n?.cognitiveFlexibility ?? 'Cognitive Flexibility',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context);
                        return Text(
                          l10n?.ruleSwitching ?? 'Rule Switching Assessment',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context);
                      return Text(
                        l10n?.translate('assess_children_info') ?? 'Assess children aged 2-6 years for cognitive flexibility and rule-switching abilities',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Text(
              l10n?.statistics ?? 'Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        l10n?.totalChildren ?? 'Total Children',
                        _totalChildren.toString(),
                        Icons.child_care,
                        Colors.blue.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        l10n?.completed ?? 'Completed',
                        _completedAssessments.toString(),
                        Icons.check_circle,
                        Colors.lightBlue.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        l10n?.pending ?? 'Pending',
                        _pendingAssessments.toString(),
                        Icons.pending,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        l10n?.today ?? 'Today',
                        _todayAssessments.toString(),
                        Icons.today,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Text(
              l10n?.quickActions ?? 'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return _buildActionCard(
                    icon: Icons.person_add,
                    title: l10n?.addChild ?? 'Add Child',
                    color: Colors.blue.shade700,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddChildScreen(),
                        ),
                      );
                      _loadData();
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return _buildActionCard(
                    icon: Icons.list_alt,
                    title: l10n?.viewAll ?? 'View All',
                    color: Colors.blue.shade700,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChildListScreen(),
                        ),
                      );
                      _loadData();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n?.searchChildren ?? 'Search children by name...',
              prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: InputBorder.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentChildren() {
    final filteredChildren = _getFilteredChildren();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Text(
                  l10n?.recentChildren ?? 'Recent Children',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                );
              },
            ),
            TextButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChildListScreen(),
                  ),
                );
                _loadData(); // Refresh after returning
              },
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return Text(l10n?.viewAll ?? 'View All');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (filteredChildren.isEmpty)
          _buildEmptyState()
        else
          ...filteredChildren.map((child) => _buildChildCard(child)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.child_care_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(
                _searchQuery.isNotEmpty
                    ? (l10n?.translate('no_children_found') ?? 'No children found matching "$_searchQuery"').replaceAll('{query}', _searchQuery)
                    : (l10n?.noChildren ?? 'No children added yet'),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(
                _searchQuery.isNotEmpty
                    ? (l10n?.tryDifferentSearch ?? 'Try a different search term')
                    : (l10n?.addFirstChild ?? 'Add your first child to start assessments'),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddChildScreen(),
                  ),
                );
                _loadData(); // Refresh after returning
              },
              icon: const Icon(Icons.add),
              label: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return Text(l10n?.addChild ?? 'Add Child');
                },
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChildCard(Child child) {
    final childSessions = _sessions.where((s) => s['child_id'] == child.id).toList();
    final completedSessions = childSessions.where((s) => s['end_time'] != null).length;
    final hasPendingSession = childSessions.any((s) => s['end_time'] == null);
    
    final latestSession = childSessions.isNotEmpty
        ? childSessions.first
        : null;
    
    final lastAssessmentDate = latestSession != null
        ? DateTime.fromMillisecondsSinceEpoch(latestSession['created_at'] as int)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasPendingSession ? Colors.orange.withOpacity(0.3) : Colors.blue.withOpacity(0.2),
          width: hasPendingSession ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.child_care,
            color: Colors.blue.shade700,
            size: 28,
          ),
        ),
        title: Text(
          child.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                final ageResult = AgeCalculator.calculate(child.dateOfBirth);
                return Text(
                  '${l10n?.age ?? "Age"}: ${ageResult.years}${l10n?.years ?? "y"} ${ageResult.months}${l10n?.months ?? "m"} | ${child.gender}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                );
              },
            ),
            if (lastAssessmentDate != null) ...[
              const SizedBox(height: 4),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return Text(
                    '${l10n?.lastAssessment ?? "Last assessment"}: ${_formatDate(lastAssessmentDate, context)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: completedSessions > 0 ? Colors.blue.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context);
                      return Text(
                        '$completedSessions ${l10n?.completedSessions ?? "completed"}',
                        style: TextStyle(
                          fontSize: 11,
                          color: completedSessions > 0 ? Colors.blue.shade700 : Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                if (hasPendingSession) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context);
                        return Text(
                          l10n?.pendingSession ?? 'Pending',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.blue.shade700,
          size: 20,
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AgeSelectScreen(childId: child.id),
            ),
          );
          _loadData(); // Refresh after assessment
        },
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return l10n?.todayText ?? 'Today';
    } else if (difference.inDays == 1) {
      return l10n?.yesterday ?? 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${l10n?.daysAgo ?? "days ago"}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  int _calculateAgeInMonths(DateTime dob) {
    final now = DateTime.now();
    int months = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (now.day < dob.day) months--;
    return months;
  }
}
