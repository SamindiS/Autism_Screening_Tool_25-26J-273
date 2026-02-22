import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/child.dart';
import 'age_select_screen.dart';

/// Child Profile Screen for pilot study data collection
/// 
/// Captures:
/// - Child code (e.g., LRH-027, PRE-112)
/// - Age (in months)
/// - Gender
/// - Group (ASD or Typically Developing)
/// - ASD Level (Level 1/2/3) - only shown for ASD group
/// - Diagnosis source (hospital name or "Preschool screening")
class AddChildScreen extends StatefulWidget {
  final Map<String, dynamic>? child;

  const AddChildScreen({Key? key, this.child}) : super(key: key);

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _childCodeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _diagnosisSourceCtrl = TextEditingController();
  
  String? _selectedGender;
  String? _selectedLanguage = 'en';
  DateTime? _selectedDate;
  double? _calculatedAge;
  int? _calculatedAgeInMonths;
  
  // Study-specific fields
  ChildGroup _selectedGroup = ChildGroup.typicallyDeveloping;
  AsdLevel? _selectedAsdLevel;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final Map<String, String> _languages = {
    'en': 'English',
    'si': 'Sinhala',
    'ta': 'Tamil',
  };

  // Hospital from registered account (auto-filled)
  String? _registeredHospital;
  
  // Clinician Medical ID controller for ASD group (manual input required)
  final _clinicianIdCtrl = TextEditingController();

  @override
  void dispose() {
    _childCodeCtrl.dispose();
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _diagnosisSourceCtrl.dispose();
    _clinicianIdCtrl.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.child != null;

  @override
  void initState() {
    super.initState();
    _loadRegisteredHospital();
    if (_isEditing) {
      _prefillChildData();
    } else {
      // Default to "Preschool screening" for control group
      _diagnosisSourceCtrl.text = 'Preschool screening';
      // Note: LRH ID will be auto-generated when user selects ASD group
    }
  }

  Future<void> _loadRegisteredHospital() async {
    final clinicianInfo = await AuthService.getClinicianInfo();
    if (mounted && clinicianInfo['hospital'] != null) {
      setState(() {
        _registeredHospital = clinicianInfo['hospital'];
      });
      debugPrint('📋 Loaded hospital from account: ${clinicianInfo['hospital']}');
    }
  }

  /// Generate the next sequential LRH-### ID for ASD children
  Future<void> _generateNextAsdId() async {
    try {
      // Get all children
      final allChildren = await StorageService.getAllChildren();
      
      // Filter ASD children and extract LRH-### codes
      final asdChildren = allChildren.where((child) {
        final groupStr = child['study_group'] as String? ?? child['group'] as String? ?? 'typically_developing';
        return groupStr == 'asd';
      }).toList();
      
      // Extract numbers from LRH-### pattern
      final lrhPattern = RegExp(r'^LRH-(\d+)$', caseSensitive: false);
      int maxNumber = 0;
      
      for (final child in asdChildren) {
        final childCode = (child['child_code'] as String? ?? '').trim();
        final match = lrhPattern.firstMatch(childCode);
        if (match != null) {
          final number = int.tryParse(match.group(1) ?? '0') ?? 0;
          if (number > maxNumber) {
            maxNumber = number;
          }
        }
      }
      
      // Generate next ID
      final nextNumber = maxNumber + 1;
      final nextId = 'LRH-${nextNumber.toString().padLeft(3, '0')}';
      
      if (mounted) {
        setState(() {
          _childCodeCtrl.text = nextId;
        });
        debugPrint('✅ Auto-generated next ASD ID: $nextId (previous max: $maxNumber)');
      }
    } catch (e) {
      debugPrint('⚠️ Error generating ASD ID: $e');
      // Fallback to LRH-001 if error
      if (mounted) {
        setState(() {
          _childCodeCtrl.text = 'LRH-001';
        });
      }
    }
  }

  void _prefillChildData() {
    final child = widget.child!;
    _childCodeCtrl.text = child['child_code'] as String? ?? child['name'] as String? ?? '';
    _nameCtrl.text = child['name'] as String? ?? '';

    final dobMillis = child['date_of_birth'];
    if (dobMillis is int) {
      final dob = DateTime.fromMillisecondsSinceEpoch(dobMillis);
      _selectedDate = dob;
      _dobCtrl.text = DateFormat('yyyy-MM-dd').format(dob);
      _calculatedAge = (child['age'] is num)
          ? (child['age'] as num).toDouble()
          : _calculateAgeFromDate(dob);
      _calculatedAgeInMonths = child['age_in_months'] as int? ?? _calculateAgeInMonthsFromDate(dob);
    }

    final gender = (child['gender'] as String?) ?? '';
    final match = _genders.firstWhere(
      (value) => value.toLowerCase() == gender.toLowerCase(),
      orElse: () => '',
    );
    _selectedGender =
        match.isNotEmpty ? match : (gender.isEmpty ? null : gender);

    _selectedLanguage = (child['language'] as String?) ?? 'en';

    // Load study-specific fields
    final groupStr = child['study_group'] as String? ?? child['group'] as String?;
    if (groupStr != null) {
      _selectedGroup = ChildGroup.fromJson(groupStr);
    }

    final asdLevelStr = child['asd_level'] as String?;
    if (asdLevelStr != null) {
      _selectedAsdLevel = AsdLevel.fromJson(asdLevelStr);
    }

    _diagnosisSourceCtrl.text = child['diagnosis_source'] as String? ?? 
        (_selectedGroup == ChildGroup.asd ? '' : 'Preschool screening');
    
    // Prefill clinician ID for ASD children
    _clinicianIdCtrl.text = child['clinician_id'] as String? ?? '';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      firstDate: DateTime(2018),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _selectedGroup == ChildGroup.asd 
                  ? const Color(0xFF6366F1) // Indigo for ASD
                  : const Color(0xFF10B981), // Emerald for TD
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
        _calculateAge();
      });
    }
  }

  void _calculateAge() {
    if (_selectedDate != null) {
      final now = DateTime.now();
      final difference = now.difference(_selectedDate!);
      _calculatedAge = difference.inDays / 365.25;
      _calculatedAgeInMonths = _calculateAgeInMonthsFromDate(_selectedDate!);
      setState(() {});
    }
  }

  int _calculateAgeInMonthsFromDate(DateTime dob) {
    final now = DateTime.now();
    int months = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (now.day < dob.day) months--;
    return months;
  }

  double _calculateAgeFromDate(DateTime date) {
    final now = DateTime.now();
    return now.difference(date).inDays / 365.25;
  }

  void _onGroupChanged(ChildGroup group) {
    setState(() {
      _selectedGroup = group;
    });
    
    // Auto-generate LRH ID when ASD group is selected (only for new children)
    if (group == ChildGroup.asd && !_isEditing) {
      _generateNextAsdId();
    } else if (group == ChildGroup.typicallyDeveloping && !_isEditing) {
      // Clear child code for control group (user will enter manually)
      setState(() {
        _childCodeCtrl.clear();
      });
    }
  }

  Future<void> _saveChild() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select gender')),
      );
      return;
    }

    if (_selectedGroup == ChildGroup.asd && _selectedAsdLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select ASD level for ASD group')),
      );
      return;
    }

    if (_selectedGroup == ChildGroup.asd && _clinicianIdCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the Clinician Medical ID')),
      );
      return;
    }

    // No longer need to validate clinician ID input since we use logged clinician automatically

    if (_isEditing) {
      await _updateChild();
    } else {
      await _createChild();
    }
  }

  Future<void> _createChild() async {
    try {
      // Determine diagnosis source and clinician info based on group
      String diagnosisSource;
      String? clinicianId;
      String? hospitalId;
      
      if (_selectedGroup == ChildGroup.asd) {
        // Automatically use hospital from registered account
        diagnosisSource = _registeredHospital ?? 'Unknown Hospital';
        hospitalId = _registeredHospital; // Set hospital_id from logged clinician's hospital
        // Use manually entered Clinician Medical ID
        clinicianId = _clinicianIdCtrl.text.trim();
        debugPrint('✅ Creating ASD child with:');
        debugPrint('   Hospital: $diagnosisSource (auto-filled from account)');
        debugPrint('   Clinician ID: $clinicianId (manual entry)');
      } else {
        diagnosisSource = 'Preschool screening';
        clinicianId = null;
        hospitalId = null;
      }

      final childData = await StorageService.saveChild(
        childCode: _childCodeCtrl.text.trim(),
        name: _nameCtrl.text.trim().isNotEmpty 
            ? _nameCtrl.text.trim() 
            : _childCodeCtrl.text.trim(),
        dateOfBirth: _selectedDate!,
        ageInMonths: _calculatedAgeInMonths!,
        gender: _selectedGender!,
        language: _selectedLanguage!,
        age: _calculatedAge!,
        hospitalId: hospitalId, // Auto-filled from logged clinician's hospital
        group: _selectedGroup,
        asdLevel: _selectedGroup == ChildGroup.asd ? _selectedAsdLevel : null,
        diagnosisSource: diagnosisSource, // Auto-filled from logged clinician's hospital
        clinicianId: clinicianId, // Manual entry (Clinician Medical ID)
        clinicianName: null, // Not needed
      );

      final childId = (childData?['id'] as String?) ??
          (await StorageService.getAllChildren()).first['id'] as String;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_selectedGroup == ChildGroup.asd 
              ? 'ASD child profile added successfully!' 
              : 'Control child profile added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AgeSelectScreen(childId: childId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateChild() async {
    final childId = widget.child?['id'] as String?;
    if (childId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing child reference'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Determine diagnosis source and clinician info based on group
    String diagnosisSource;
    String? clinicianId;
    String? hospitalId;
    
    if (_selectedGroup == ChildGroup.asd) {
      // Automatically use hospital from registered account
      diagnosisSource = _registeredHospital ?? 'Unknown Hospital';
      hospitalId = _registeredHospital ?? widget.child?['hospital_id'] as String?;
      // Use manually entered Clinician Medical ID
      clinicianId = _clinicianIdCtrl.text.trim();
      debugPrint('✅ Updating ASD child with:');
      debugPrint('   Hospital: $diagnosisSource (auto-filled from account)');
      debugPrint('   Clinician ID: $clinicianId (manual entry)');
    } else {
      diagnosisSource = 'Preschool screening';
      clinicianId = null;
      hospitalId = widget.child?['hospital_id'] as String?;
    }

    try {
      await StorageService.updateChild(
        id: childId,
        childCode: _childCodeCtrl.text.trim(),
        name: _nameCtrl.text.trim().isNotEmpty 
            ? _nameCtrl.text.trim() 
            : _childCodeCtrl.text.trim(),
        dateOfBirth: _selectedDate!,
        ageInMonths: _calculatedAgeInMonths!,
        gender: _selectedGender!,
        language: _selectedLanguage!,
        age: _calculatedAge,
        hospitalId: hospitalId, // Auto-filled from logged clinician's hospital
        group: _selectedGroup,
        asdLevel: _selectedGroup == ChildGroup.asd ? _selectedAsdLevel : null,
        diagnosisSource: diagnosisSource, // Auto-filled from logged clinician's hospital
        clinicianId: clinicianId, // Manual entry (Clinician Medical ID)
        clinicianName: null, // Not needed
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Child profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color get _primaryColor => _selectedGroup == ChildGroup.asd 
      ? const Color(0xFF6366F1) // Indigo for ASD
      : const Color(0xFF10B981); // Emerald for TD

  Color get _lightColor => _selectedGroup == ChildGroup.asd 
      ? const Color(0xFFE0E7FF) // Light indigo
      : const Color(0xFFD1FAE5); // Light emerald

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Child Profile' : 'Add Child Profile'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _lightColor,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Study Group Selector (Most Important - First)
                  _buildGroupSelector(),
                  const SizedBox(height: 24),
                  
                  // Info Banner
                  _buildInfoBanner(),
                  const SizedBox(height: 24),
                  
                  // Child Code Field
                  _buildTextField(
                    controller: _childCodeCtrl,
                    label: 'Child Code',
                    hint: _selectedGroup == ChildGroup.asd 
                        ? 'Auto-generated (e.g., LRH-001)' 
                        : 'e.g., PRE-112',
                    icon: Icons.badge_outlined,
                    readOnly: _selectedGroup == ChildGroup.asd && !_isEditing, // Auto-generated for new ASD children
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Child code is required';
                      }
                      // Validate LRH format for ASD children
                      if (_selectedGroup == ChildGroup.asd && !_isEditing) {
                        final lrhPattern = RegExp(r'^LRH-\d{3}$', caseSensitive: false);
                        if (!lrhPattern.hasMatch(v.trim())) {
                          return 'ASD child code must be in format LRH-###';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Optional Name Field
                  _buildTextField(
                    controller: _nameCtrl,
                    label: 'Child Name (Optional)',
                    hint: 'For your reference only',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  
                  // Date of Birth
                  _buildDateField(),
                  const SizedBox(height: 16),
                  
                  // Age Display (in months and years)
                  if (_calculatedAgeInMonths != null) _buildAgeDisplay(),
                  const SizedBox(height: 16),
                  
                  // Gender
                  _buildGenderSelector(),
                  const SizedBox(height: 16),
                  
                  // ASD Level (only shown for ASD group)
                  if (_selectedGroup == ChildGroup.asd) ...[
                    _buildAsdLevelSelector(),
                    const SizedBox(height: 16),
                  ],
                  
                  // Diagnosis Source
                  _buildDiagnosisSourceField(),
                  const SizedBox(height: 16),
                  
                  // Language
                  _buildLanguageSelector(),
                  const SizedBox(height: 32),
                  
                  // Summary Card
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  
                  // Save Button
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Study Group',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGroupOption(
                group: ChildGroup.asd,
                title: 'ASD Group',
                subtitle: 'Clinical diagnosis',
                icon: Icons.medical_services_outlined,
                color: const Color(0xFF6366F1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGroupOption(
                group: ChildGroup.typicallyDeveloping,
                title: 'Control Group',
                subtitle: 'Typically developing',
                icon: Icons.school_outlined,
                color: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGroupOption({
    required ChildGroup group,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedGroup == group;
    return GestureDetector(
      onTap: () => _onGroupChanged(group),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? color : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? color.withOpacity(0.8) : Colors.grey.shade500,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Selected',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    final isAsd = _selectedGroup == ChildGroup.asd;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _lightColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isAsd ? Icons.local_hospital : Icons.school,
            color: _primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isAsd
                  ? 'For children with existing autism diagnosis from a hospital/clinic'
                  : 'For typically developing children from preschools (no diagnosis)',
              style: TextStyle(
                color: _primaryColor.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
      ),
      validator: validator,
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: Icon(Icons.calendar_today, color: _primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          _dobCtrl.text.isEmpty ? 'Select Date of Birth' : _dobCtrl.text,
          style: TextStyle(
            color:
                _dobCtrl.text.isEmpty ? Colors.grey.shade400 : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildAgeDisplay() {
    final ageYears = _calculatedAge!.floor();
    final ageMonthsRemaining = ((_calculatedAge! - ageYears) * 12).floor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _lightColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.cake, color: _primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Age: ${_calculatedAgeInMonths} months',
                  style: TextStyle(
                    color: _primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '($ageYears years and $ageMonthsRemaining months)',
                  style: TextStyle(
                    color: _primaryColor.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: _genders.map((gender) {
            final isSelected = _selectedGender == gender;
            return ChoiceChip(
              label: Text(gender),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedGender = selected ? gender : null);
              },
              selectedColor: _primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAsdLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ASD Level / Severity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Required for ASD',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...AsdLevel.values.map((level) => _buildAsdLevelOption(level)),
      ],
    );
  }

  Widget _buildAsdLevelOption(AsdLevel level) {
    final isSelected = _selectedAsdLevel == level;
    String description;
    switch (level) {
      case AsdLevel.level1:
        description = 'Requiring support - Mild';
        break;
      case AsdLevel.level2:
        description = 'Requiring substantial support - Moderate';
        break;
      case AsdLevel.level3:
        description = 'Requiring very substantial support - Severe';
        break;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedAsdLevel = level),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<AsdLevel>(
              value: level,
              groupValue: _selectedAsdLevel,
              onChanged: (v) => setState(() => _selectedAsdLevel = v),
              activeColor: _primaryColor,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.shortName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? _primaryColor : Colors.black87,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisSourceField() {
    final isAsd = _selectedGroup == ChildGroup.asd;
    
    if (!isAsd) {
      // For control group, show read-only field
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.school, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Collection Source',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Text(
                    'Preschool screening (no clinician needed)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.check_circle, color: Colors.green.shade600),
          ],
        ),
      );
    }

    // For ASD group, show hospital (from account) and clinician ID input
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hospital (from registered account - read only, auto-filled)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _primaryColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.local_hospital, color: _primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hospital / Clinic',
                      style: TextStyle(
                        fontSize: 12,
                        color: _primaryColor.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      _registeredHospital ?? 'Loading...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                    Text(
                      'Automatically set from your account',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.verified, color: _primaryColor),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Clinician Medical ID (manual input required)
        Text(
          'Clinician Medical ID',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter the clinician ID who diagnosed this child',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _clinicianIdCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'e.g., 10552',
            prefixIcon: Icon(Icons.badge, color: _primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (v) {
            if (_selectedGroup == ChildGroup.asd && 
                (v == null || v.trim().isEmpty)) {
              return 'Please enter Clinician Medical ID';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Language',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedLanguage,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.language, color: _primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: _languages.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedLanguage = value);
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    if (_childCodeCtrl.text.isEmpty || _calculatedAgeInMonths == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: _primaryColor),
              const SizedBox(width: 8),
              Text(
                'Profile Preview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildSummaryRow('Child Code', _childCodeCtrl.text),
          _buildSummaryRow('Age', '${_calculatedAgeInMonths} months'),
          _buildSummaryRow('Gender', _selectedGender ?? '-'),
          _buildSummaryRow('Group', _selectedGroup.displayName),
          if (_selectedGroup == ChildGroup.asd) ...[
            _buildSummaryRow('ASD Level', _selectedAsdLevel?.shortName ?? '-'),
            _buildSummaryRow('Clinician ID', _clinicianIdCtrl.text.isNotEmpty ? _clinicianIdCtrl.text : '-'),
            _buildSummaryRow('Hospital', _registeredHospital ?? '-'),
          ] else
            _buildSummaryRow('Source', 'Preschool screening'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _saveChild,
        icon: const Icon(Icons.save),
        label: Text(
          _isEditing ? 'Update & Continue' : 'Save & Start Assessment',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
