import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/child.dart';
import 'add_child_screen.dart';
import 'child_detail_screen.dart';

class ChildListScreen extends StatefulWidget {
  const ChildListScreen({Key? key}) : super(key: key);

  @override
  State<ChildListScreen> createState() => _ChildListScreenState();
}

class _ChildListScreenState extends State<ChildListScreen> {
  List<Map<String, dynamic>> _children = [];
  bool _loading = true;
  String _filterGroup = 'all'; // 'all', 'asd', 'td'

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() => _loading = true);
    final children = await StorageService.getAllChildren();
    if (mounted) {
      setState(() {
        _children = children;
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredChildren {
    if (_filterGroup == 'all') return _children;
    return _children.where((child) {
      final groupStr = child['study_group'] as String? ?? child['group'] as String? ?? 'typically_developing';
      final group = ChildGroup.fromJson(groupStr);
      if (_filterGroup == 'asd') return group == ChildGroup.asd;
      return group == ChildGroup.typicallyDeveloping;
    }).toList();
  }

  int get _asdCount => _children.where((child) {
    final groupStr = child['study_group'] as String? ?? child['group'] as String? ?? 'typically_developing';
    return ChildGroup.fromJson(groupStr) == ChildGroup.asd;
  }).length;

  int get _tdCount => _children.where((child) {
    final groupStr = child['study_group'] as String? ?? child['group'] as String? ?? 'typically_developing';
    return ChildGroup.fromJson(groupStr) == ChildGroup.typicallyDeveloping;
  }).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Profiles'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChildren,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6366F1).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Stats and Filter Bar
            _buildStatsBar(),
            
            // Children List
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredChildren.isEmpty
                      ? _buildEmptyState()
                      : _buildChildrenList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddChildScreen()),
          );
          _loadChildren();
        },
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add),
        label: const Text('Add Child'),
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total',
                  count: _children.length,
                  color: Colors.grey.shade700,
                  icon: Icons.people,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Existing ASD diagnosis',
                  count: _asdCount,
                  color: const Color(0xFF6366F1),
                  icon: Icons.medical_services,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'New / screening',
                  count: _tdCount,
                  color: const Color(0xFF10B981),
                  icon: Icons.school,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Filter Chips
          Row(
            children: [
              _buildFilterChip('All', 'all', Colors.grey.shade700),
              const SizedBox(width: 8),
              _buildFilterChip('ASD', 'asd', const Color(0xFF6366F1)),
              const SizedBox(width: 8),
              _buildFilterChip('Control', 'td', const Color(0xFF10B981)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color color) {
    final isSelected = _filterGroup == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterGroup = selected ? value : 'all');
      },
      backgroundColor: Colors.white,
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey.shade600,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String subtitle;
    
    if (_filterGroup == 'asd') {
      message = 'No children with existing ASD diagnosis';
      subtitle = 'Add children who already have a confirmed diagnosis';
    } else if (_filterGroup == 'td') {
      message = 'No new / screening children';
      subtitle = 'Add children you are screening for ASD';
    } else {
      message = 'No Children Added';
      subtitle = 'Add your first child to start assessments';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.child_care_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddChildScreen()),
                );
                _loadChildren();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Child'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenList() {
    return RefreshIndicator(
      onRefresh: _loadChildren,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredChildren.length,
        itemBuilder: (context, index) {
          final child = _filteredChildren[index];
          return _buildChildCard(child);
        },
      ),
    );
  }

  Widget _buildChildCard(Map<String, dynamic> child) {
    final age = child['age'] as double? ?? 0.0;
    final ageInMonths = child['age_in_months'] as int?;
    final ageYears = age.floor();
    final ageMonthsRemaining = ((age - ageYears) * 12).floor();
    
    // Get study group (prior diagnosis status)
    final groupStr = child['study_group'] as String? ?? child['group'] as String? ?? 'typically_developing';
    final group = ChildGroup.fromJson(groupStr);
    final isAsd = group == ChildGroup.asd;

    final diagnosisType = (child['diagnosis_type'] as String?) ?? 'new';
    final diagnosisTypeLabel =
        diagnosisType == 'existing' ? 'Diagnosis before' : 'New diagnosis';
    
    // Get ASD level if applicable
    final asdLevelStr = child['asd_level'] as String?;
    final asdLevel = asdLevelStr != null ? AsdLevel.fromJson(asdLevelStr) : null;
    
    // Get child code
    final childCode = child['child_code'] as String? ?? child['name'] as String? ?? 'Unknown';
    final childName = child['name'] as String?;
    
    // Colors based on group
    final primaryColor = isAsd ? const Color(0xFF6366F1) : const Color(0xFF10B981);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () async {
          final updated = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => ChildDetailScreen(child: child),
            ),
          );
          if (updated == true) {
            _loadChildren();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with group indicator
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  isAsd ? Icons.medical_services : Icons.school,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Child Code & Name
                    Row(
                      children: [
                        Text(
                          childCode,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (childName != null && childName != childCode) ...[
                          const SizedBox(width: 8),
                          Text(
                            '($childName)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Age and Gender Row
                    Row(
                      children: [
                        Icon(Icons.cake, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          ageInMonths != null 
                              ? '$ageInMonths mo' 
                              : '$ageYears y $ageMonthsRemaining m',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.person, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          child['gender'] as String? ?? 'N/A',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Group Badge (prior diagnosis vs new)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            diagnosisTypeLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        if (isAsd && asdLevel != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.shade200,
                              ),
                            ),
                            child: Text(
                              asdLevel.shortName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
