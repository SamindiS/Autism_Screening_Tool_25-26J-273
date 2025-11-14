import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../auth/login_screen.dart';
import '../cognitive/cognitive_dashboard_screen.dart';
import '../cognitive/add_child_screen.dart';
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
      final children = await StorageService.getAllChildren();
      final sessions = await StorageService.getAllSessions();
      
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      final completed = sessions.where((s) => s['end_time'] != null).length;
      final pending = sessions.where((s) => s['end_time'] == null).length;
      final todayCount = sessions.where((s) {
        final sessionDate = DateTime.fromMillisecondsSinceEpoch(s['created_at'] as int);
        return sessionDate.isAfter(todayStart);
      }).length;
      
      if (mounted) {
        setState(() {
          _clinicianName = info['name'];
          _hospitalName = info['hospital'];
          _totalChildren = children.length;
          _completedAssessments = completed;
          _pendingAssessments = pending;
          _todayAssessments = todayCount;
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading dashboard: $e'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Retry',
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
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
            const Text(
              'SenseAI Dashboard',
              style: TextStyle(
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
                'Error: $_errorMessage',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                primary: const Color(0xFF0A7C7F),
                onPrimary: Colors.white,
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
        complete: const Text(
          'Refreshed',
          style: TextStyle(color: Colors.green),
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
                    _buildStatisticsCards(isDark),
                    const SizedBox(height: 24),
                    _buildComponentsSection(),
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Total Children',
                value: _totalChildren,
                icon: Icons.child_care_rounded,
                color: const Color(0xFF3B82F6),
                bgColor: isDark
                    ? Colors.blue[900]!
                    : const Color(0xFFDBEAFE),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Completed',
                value: _completedAssessments,
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF10B981),
                bgColor: isDark
                    ? Colors.green[900]!
                    : const Color(0xFFD1FAE5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Pending',
                value: _pendingAssessments,
                icon: Icons.pending_actions_rounded,
                color: const Color(0xFFF59E0B),
                bgColor: isDark
                    ? Colors.orange[900]!
                    : const Color(0xFFFEF3C7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'Today',
                value: _todayAssessments,
                icon: Icons.today_rounded,
                color: const Color(0xFF8B5CF6),
                bgColor: isDark
                    ? Colors.purple[900]!
                    : const Color(0xFFEDE9FE),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComponentsSection() {
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
            const Text(
              'Assessment Components',
              style: TextStyle(
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
              title: 'Cognitive Flexibility',
              subtitle: 'Rule Switching',
              color: const Color(0xFF2563EB),
              gradient: const [
                Color(0xFF3B82F6),
                Color(0xFF60A5FA),
              ],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CognitiveDashboardScreen(),
                  ),
                );
              },
            ),
            ComponentTile(
              icon: Icons.repeat_rounded,
              title: 'RRB',
              subtitle: 'Restricted & Repetitive',
              color: const Color(0xFF7C3AED),
              gradient: const [
                Color(0xFF8B5CF6),
                Color(0xFFA78BFA),
              ],
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('RRB Component - Coming Soon'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            ComponentTile(
              icon: Icons.hearing_rounded,
              title: 'Auditory Checking',
              subtitle: 'Sound Processing',
              color: const Color(0xFF0EA5E9),
              gradient: const [
                Color(0xFF06B6D4),
                Color(0xFF22D3EE),
              ],
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Auditory Checking - Coming Soon'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            ComponentTile(
              icon: Icons.remove_red_eye_rounded,
              title: 'Visual Checking',
              subtitle: 'Visual Processing',
              color: const Color(0xFF059669),
              gradient: const [
                Color(0xFF10B981),
                Color(0xFF34D399),
              ],
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Visual Checking - Coming Soon'),
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
    return Row(
      children: [
        Expanded(
          child: QuickActionButton(
            label: 'Add New Child',
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
            label: 'View Reports',
            icon: Icons.assessment_rounded,
            color: const Color(0xFF0A7C7F),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('View Reports - Coming Soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
