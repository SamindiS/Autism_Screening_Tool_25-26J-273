import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/storage_service.dart';
import 'age_select_screen.dart';

class AddChildScreen extends StatefulWidget {
  final Map<String, dynamic>? child;

  const AddChildScreen({Key? key, this.child}) : super(key: key);

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  String? _selectedGender;
  String? _selectedLanguage = 'en';
  DateTime? _selectedDate;
  double? _calculatedAge;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final Map<String, String> _languages = {
    'en': 'English',
    'si': 'Sinhala',
    'ta': 'Tamil',
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.child != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _prefillChildData();
    }
  }

  void _prefillChildData() {
    final child = widget.child!;
    _nameCtrl.text = child['name'] as String? ?? '';

    final dobMillis = child['date_of_birth'];
    if (dobMillis is int) {
      final dob = DateTime.fromMillisecondsSinceEpoch(dobMillis);
      _selectedDate = dob;
      _dobCtrl.text = DateFormat('yyyy-MM-dd').format(dob);
      _calculatedAge = (child['age'] is num)
          ? (child['age'] as num).toDouble()
          : _calculateAgeFromDate(dob);
    }

    final gender = (child['gender'] as String?) ?? '';
    final match = _genders.firstWhere(
      (value) => value.toLowerCase() == gender.toLowerCase(),
      orElse: () => '',
    );
    _selectedGender =
        match.isNotEmpty ? match : (gender.isEmpty ? null : gender);

    _selectedLanguage = (child['language'] as String?) ?? 'en';
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
              primary: Colors.orange,
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
      setState(() {});
    }
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

    if (_isEditing) {
      await _updateChild();
    } else {
      await _createChild();
    }
  }

  Future<void> _createChild() async {
    try {
      final childData = await StorageService.saveChild(
        name: _nameCtrl.text.trim(),
        dateOfBirth: _selectedDate!,
        gender: _selectedGender!,
        language: _selectedLanguage!,
        age: _calculatedAge!,
      );

      final childId = (childData?['id'] as String?) ??
          (await StorageService.getAllChildren()).first['id'] as String;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Child added successfully!'),
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

    try {
      await StorageService.updateChild(
        id: childId,
        name: _nameCtrl.text.trim(),
        dateOfBirth: _selectedDate!,
        gender: _selectedGender!,
        language: _selectedLanguage!,
        age: _calculatedAge,
        hospitalId: widget.child?['hospital_id'] as String?,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Child updated successfully!'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Child' : 'Add New Child'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 32),
                  // Name Field
                  _buildTextField(
                    controller: _nameCtrl,
                    label: 'Child Name',
                    icon: Icons.person_outline,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Date of Birth
                  _buildDateField(),
                  const SizedBox(height: 20),
                  // Age Display
                  if (_calculatedAge != null) _buildAgeDisplay(),
                  const SizedBox(height: 20),
                  // Gender
                  _buildGenderSelector(),
                  const SizedBox(height: 20),
                  // Language
                  _buildLanguageSelector(),
                  const SizedBox(height: 32),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Enter child details to start the assessment',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontSize: 14,
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
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: const Icon(Icons.calendar_today),
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
    final ageMonths = ((_calculatedAge! - ageYears) * 12).floor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.cake, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Text(
            'Age: ${ageYears} years ${ageMonths} months (${_calculatedAge!.toStringAsFixed(2)} years)',
            style: TextStyle(
              color: Colors.orange.shade900,
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
              selectedColor: Colors.orange,
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

  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language',
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
            prefixIcon: const Icon(Icons.language),
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveChild,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Save & Continue',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
