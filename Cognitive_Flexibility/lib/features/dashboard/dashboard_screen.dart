import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/child.dart';
import 'package:senseai/l10n/app_localizations.dart';
import '../auth/login_screen.dart';
import '../cognitive/cognitive_dashboard_screen.dart';
import '../cognitive/add_child_screen.dart';
import '../cognitive/child_list_screen.dart';
import '../cognitive/age_select_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/stat_card.dart';
import 'widgets/component_tile.dart';
import 'widgets/quick_action_button.dart';
import 'widgets/info_card.dart';
import 'widgets/welcome_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  String? _clinicianName;
  String? _hospitalName;
  bool _loading = true;
  String? _errorMessage;

  // Statistics
  int _totalChildren = 0;
  int _completedAssessments = 0;
  int _pendingAssessments = 0;
  int _todayAssessments = 0;
  
  // Pilot Study Statistics
  int _asdGroupCount = 0;
  int _controlGroupCount = 0;
  
  // Children list for overview
  List<Child> _recentChildren = [];

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _loadData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool isRefresh = false}) async {
    if (!isRefresh) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }

    try {
      final info = await AuthService.getClinicianInfo();

      // Load statistics
      final childrenData = await StorageService.getAllChildren();
      final sessions = await StorageService.getAllSessions();

      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      final completed = sessions.where((s) => s['end_time'] != null).length;
      final pending = sessions.where((s) => s['end_time'] == null).length;
      final todayCount = sessions.where((s) {
        final sessionDate =
            DateTime.fromMillisecondsSinceEpoch(s['created_at'] as int);
        return sessionDate.isAfter(todayStart);
      }).length;

      // Convert to Child models and calculate study group stats
      final children = childrenData.map((data) {
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

      // Calculate study group counts
      final asdCount = children.where((c) => c.isAsdGroup).length;
      final controlCount = children.where((c) => c.isControlGroup).length;

      // Get recent children (last 5)
      final recentChildren = children.take(5).toList();

      if (mounted) {
        setState(() {
          _clinicianName = info['name'];
          _hospitalName = info['hospital'];
          _totalChildren = children.length;
          _completedAssessments = completed;
          _pendingAssessments = pending;
          _todayAssessments = todayCount;
          _asdGroupCount = asdCount;
          _controlGroupCount = controlCount;
          _recentChildren = recentChildren;
          _loading = false;
          _errorMessage = null;
        });

        if (!isRefresh) {
          // Start animations only on initial load
          _fadeController.forward();
          _slideController.forward();
        }
      }

      if (isRefresh) {
        _refreshController.refreshCompleted();
      }
    } catch (e, stackTrace) {
      print('Error in _loadData: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = e.toString();
        });

        if (isRefresh) {
          _refreshController.refreshFailed();
        }

        if (!isRefresh) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.error} loading dashboard: $e'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: l10n.retry,
                textColor: Colors.white,
                onPressed: () => _loadData(),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadData(isRefresh: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only refresh if not already loading to avoid multiple calls
    if (!_loading && _clinicianName == null && _errorMessage == null) {
      _loadData();
    }
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.logout,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.dashboard, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.senseaiDashboard,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0A7C7F),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_loading && _errorMessage == null) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A7C7F),
              Color(0xFF14B8A6),
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    if (_errorMessage != null && !_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                '${AppLocalizations.of(context)!.error}: $_errorMessage',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadData(),
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A7C7F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      header: WaterDropHeader(
        waterDropColor: const Color(0xFF0A7C7F),
        complete: Text(
          AppLocalizations.of(context)!.refreshed,
          style: const TextStyle(color: Colors.green),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.grey[900]!, Colors.grey[800]!]
                : [
                    const Color(0xFFF5F7FA),
                    const Color(0xFFE8F4F8),
                  ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WelcomeCard(
                      name: _clinicianName,
                      hospital: _hospitalName,
                    ),
                    const SizedBox(height: 20),
                    // Assessment Components at the top
                    _buildComponentsSection(),
                    const SizedBox(height: 20),
                    _buildStatisticsCards(isDark),
                    const SizedBox(height: 20),
                    _buildPilotStudyStats(isDark),
                    const SizedBox(height: 24),
                    _buildRecentChildrenSection(isDark),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    const InfoCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: l10n.totalChildren,
                value: _totalChildren,
                icon: Icons.child_care_rounded,
                color: const Color(0xFF3B82F6),
                bgColor: isDark ? Colors.blue[900]! : const Color(0xFFDBEAFE),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: l10n.completed,
                value: _completedAssessments,
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF10B981),
                bgColor: isDark ? Colors.green[900]! : const Color(0xFFD1FAE5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: l10n.pending,
                value: _pendingAssessments,
                icon: Icons.pending_actions_rounded,
                color: const Color(0xFFF59E0B),
                bgColor: isDark ? Colors.orange[900]! : const Color(0xFFFEF3C7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: l10n.today,
                value: _todayAssessments,
                icon: Icons.today_rounded,
                color: const Color(0xFF8B5CF6),
                bgColor: isDark ? Colors.purple[900]! : const Color(0xFFEDE9FE),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComponentsSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A7C7F),
                    Color(0xFF14B8A6),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.assessmentComponents,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ComponentTile(
              icon: Icons.psychology_rounded,
              title: l10n.cognitiveFlexibility,
              subtitle: l10n.ruleSwitching,
              color: const Color(0xFF2563EB),
              gradient: const [
                Color(0xFF3B82F6),
                Color(0xFF60A5FA),
              ],
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CognitiveDashboardScreen(),
                  ),
                );
                _loadData(); // Refresh after returning
              },
            ),
            ComponentTile(
              icon: Icons.repeat_rounded,
              title: l10n.rrb,
              subtitle: l10n.restrictedRepetitive,
              color: const Color(0xFF7C3AED),
              gradient: const [
                Color(0xFF8B5CF6),
                Color(0xFFA78BFA),
              ],
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.rrbComingSoon),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            ComponentTile(
              icon: Icons.hearing_rounded,
              title: l10n.auditoryChecking,
              subtitle: l10n.soundProcessing,
              color: const Color(0xFF0EA5E9),
              gradient: const [
                Color(0xFF06B6D4),
                Color(0xFF22D3EE),
              ],
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.auditoryComingSoon),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            ComponentTile(
              icon: Icons.remove_red_eye_rounded,
              title: l10n.visualChecking,
              subtitle: l10n.visualProcessing,
              color: const Color(0xFF059669),
              gradient: const [
                Color(0xFF10B981),
                Color(0xFF34D399),
              ],
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.visualComingSoon),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: QuickActionButton(
            label: l10n.addNewChild,
            icon: Icons.person_add_rounded,
            gradient: const [
              Color(0xFF0A7C7F),
              Color(0xFF14B8A6),
            ],
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddChildScreen()),
              );
              _loadData();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: QuickActionButton(
            label: l10n.viewReports,
            icon: Icons.assessment_rounded,
            color: const Color(0xFF0A7C7F),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.viewReportsComingSoon),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPilotStudyStats(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [Colors.indigo.shade900, Colors.purple.shade900]
              : [const Color(0xFF6366F1).withOpacity(0.1), const Color(0xFF10B981).withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.indigo.shade700 : const Color(0xFF6366F1).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, color: isDark ? Colors.white : const Color(0xFF6366F1)),
              const SizedBox(width: 8),
              Text(
                'Pilot Study Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStudyGroupCard(
                  title: 'Existing ASD Diagnosis',
                  count: _asdGroupCount,
                  target: '30-50',
                  color: const Color(0xFF6366F1),
                  icon: Icons.medical_services,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStudyGroupCard(
                  title: 'Screening (No Prior Diagnosis)',
                  count: _controlGroupCount,
                  target: '40-60',
                  color: const Color(0xFF10B981),
                  icon: Icons.school,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudyGroupCard({
    required String title,
    required int count,
    required String target,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
          Text(
            'Target: $target',
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white54 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentChildrenSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF6366F1), Color(0xFF10B981)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Recent Children',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChildListScreen()),
                );
                _loadData();
              },
              icon: const Icon(Icons.list, size: 18),
              label: const Text('View All'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0A7C7F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_recentChildren.isEmpty)
          _buildEmptyChildrenState(isDark)
        else
          ..._recentChildren.map((child) => _buildChildCard(child, isDark)),
      ],
    );
  }

  Widget _buildEmptyChildrenState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.child_care_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No children added yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add children to start pilot study data collection',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard(Child child, bool isDark) {
    final isAsd = child.isAsdGroup;
    final primaryColor = isAsd ? const Color(0xFF6366F1) : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AgeSelectScreen(childId: child.id),
            ),
          );
          _loadData();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Icon(
                  isAsd ? Icons.medical_services : Icons.school,
                  color: primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          child.childCode,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: primaryColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            isAsd ? 'ASD' : 'Control',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        if (isAsd && child.asdLevel != null) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              child.asdLevel!.shortName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${child.ageInMonths} months • ${child.gender}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.play_circle_fill,
                color: primaryColor,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateAgeInMonths(DateTime dob) {
    final now = DateTime.now();
    int months = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (now.day < dob.day) months--;
    return months;
  }
}
