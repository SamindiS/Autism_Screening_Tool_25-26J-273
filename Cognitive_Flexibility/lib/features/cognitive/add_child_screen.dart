import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/child.dart';
import 'age_select_screen.dart';

/// Child Profile Screen for clinical ASD screening
/// 
/// Captures:
/// - Child code (e.g., LRH-027, PRE-112)
/// - Age (in months)
/// - Gender
/// - Prior diagnosis status (existing ASD diagnosis vs screening)
/// - Diagnosis source (hospital / clinic or screening context)
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

  // Diagnosis type: existing diagnosis vs new (suspected) case
  String _diagnosisType = 'new'; // 'existing' or 'new'
  
  // Clinical fields
  // ChildGroup is kept for backward compatibility and analytics,
  // but the form itself does not branch by group.
  ChildGroup _selectedGroup = ChildGroup.typicallyDeveloping;

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

  // LRH auto-ID generator kept in history; not used in the current clinical flow.

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

    _diagnosisSourceCtrl.text = child['diagnosis_source'] as String? ?? '';
    
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

    // Clinical system: clinician ID is always required.
    if (_clinicianIdCtrl.text.trim().isEmpty) {
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
      
      // Attach hospital and clinician info for this clinical system.
      diagnosisSource = _diagnosisSourceCtrl.text.trim().isNotEmpty
          ? _diagnosisSourceCtrl.text.trim()
          : (_registeredHospital ?? 'Unknown Hospital');
      hospitalId = _registeredHospital;
      clinicianId = _clinicianIdCtrl.text.trim();

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
        // Clinical version: we no longer capture ASD severity level
        // in the app; this was only needed for pilot data collection.
        asdLevel: null,
        diagnosisSource: diagnosisSource, // Auto-filled from logged clinician's hospital
        clinicianId: clinicianId, // Manual entry (Clinician Medical ID)
        clinicianName: null, // Not needed
        diagnosisType: _diagnosisType,
      );

      final childId = (childData?['id'] as String?) ??
          (await StorageService.getAllChildren()).first['id'] as String;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Child profile added successfully!'),
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
    
    diagnosisSource = _diagnosisSourceCtrl.text.trim().isNotEmpty
        ? _diagnosisSourceCtrl.text.trim()
        : (_registeredHospital ?? widget.child?['diagnosis_source'] as String? ?? 'Unknown Hospital');
    hospitalId = _registeredHospital ?? widget.child?['hospital_id'] as String?;
    clinicianId = _clinicianIdCtrl.text.trim();

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
        // Clinical version: we no longer capture ASD severity level
        asdLevel: null,
        diagnosisSource: diagnosisSource, // Auto-filled from logged clinician's hospital
        clinicianId: clinicianId, // Manual entry (Clinician Medical ID)
        clinicianName: null, // Not needed
        diagnosisType: _diagnosisType,
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

  // prior ASD diagnosis is now inferred from clinician/hospital fields, so no explicit selector UI

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
                  ? 'For children with a confirmed autism diagnosis from a hospital/clinic'
                  : 'For children referred for ASD screening (no prior diagnosis)',
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

  Widget _buildDiagnosisSourceField() {
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
            if (v == null || v.trim().isEmpty) {
              return 'Please enter Clinician Medical ID';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        Text(
          'Diagnosis / Referral context (optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _diagnosisSourceCtrl,
          decoration: InputDecoration(
            hintText: 'e.g., LRH Neurology Clinic, school referral, parent concern',
            prefixIcon: Icon(Icons.notes, color: _primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Diagnosis type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ChoiceChip(
              label: const Text('Diagnosis before'),
              selected: _diagnosisType == 'existing',
              selectedColor: _primaryColor,
              onSelected: (_) {
                setState(() {
                  _diagnosisType = 'existing';
                });
              },
              labelStyle: TextStyle(
                color: _diagnosisType == 'existing' ? Colors.white : Colors.black87,
                fontWeight: _diagnosisType == 'existing'
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 12),
            ChoiceChip(
              label: const Text('New diagnosis'),
              selected: _diagnosisType == 'new',
              selectedColor: _primaryColor,
              onSelected: (_) {
                setState(() {
                  _diagnosisType = 'new';
                });
              },
              labelStyle: TextStyle(
                color: _diagnosisType == 'new' ? Colors.white : Colors.black87,
                fontWeight: _diagnosisType == 'new'
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
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
            _buildSummaryRow('Clinician ID', _clinicianIdCtrl.text.isNotEmpty ? _clinicianIdCtrl.text : '-'),
            _buildSummaryRow('Hospital', _registeredHospital ?? '-'),
          ] else
            _buildSummaryRow('Screening Context', 'No prior ASD diagnosis reported'),
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
