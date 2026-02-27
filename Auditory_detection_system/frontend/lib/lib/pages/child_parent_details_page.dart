import 'package:flutter/material.dart';
import 'video_analysis_page.dart';
import 'mchat_page.dart';
import 'milestone_tracker_page.dart';
import 'prq_page.dart';

class ChildParentDetailsPage extends StatefulWidget {
  const ChildParentDetailsPage({super.key});

  @override
  State<ChildParentDetailsPage> createState() => _ChildParentDetailsPageState();
}

class _ChildParentDetailsPageState extends State<ChildParentDetailsPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _childNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedRelationship = 'Mother';
  bool _isFormValid = false;
  final int _currentStep = 1;
  final int _totalSteps = 3;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _childNameController.dispose();
    _ageController.dispose();
    _parentNameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      // Get child age from the form
      final ageText = _ageController.text.trim();
      final age = int.tryParse(ageText);
      
      // Navigate to Video Analysis page with child name and age
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoAnalysisPage(
            childName: _childNameController.text.trim(),
            childAge: age,
          ),
        ),
      );
    }
  }

  void _handleClear() {
    _formKey.currentState!.reset();
    setState(() {
      _childNameController.clear();
      _ageController.clear();
      _parentNameController.clear();
      _contactNumberController.clear();
      _emailController.clear();
      _selectedGender = 'Male';
      _selectedRelationship = 'Mother';
      _isFormValid = false;
    });
  }

  void _recalculateFormValidity() {
    final childNameValid = _childNameController.text.trim().isNotEmpty;
    final ageText = _ageController.text.trim();
    final age = int.tryParse(ageText);
    final ageValid = age != null && age >= 1 && age <= 6;
    final parentNameValid = _parentNameController.text.trim().isNotEmpty;
    final contactValid = _contactNumberController.text.trim().length >= 10;
    final emailText = _emailController.text.trim();
    final emailValid = emailText.isNotEmpty && emailText.contains('@');

    final isValid =
        childNameValid && ageValid && parentNameValid && contactValid && emailValid;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative background elements
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE3D7).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F2FF).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Hero section with illustration
                        _buildHeroSection(),
                        const SizedBox(height: 24),
                        // Step progress indicator
                        _buildProgressIndicator(),
                        const SizedBox(height: 30),
                        // Child Details Card
                        _buildChildDetailsCard(),
                        const SizedBox(height: 20),
                        // Parent Details Card
                        _buildParentDetailsCard(),
                        const SizedBox(height: 20),
                        // Benchmark Assessments
                        _buildBenchmarkAssessmentsSection(),
                        const SizedBox(height: 30),
                        // Buttons
                        _buildActionButtons(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 450,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background color for image
            Container(
              color: const Color(0xFFC47BE4),
            ),
            // Large hero image - full image display with increased size
            Image.asset(
              'assets/image2.webp',
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFC47BE4),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 64,
                    color: Colors.white,
                  ),
                );
              },
            ),
            // Dark gradient overlay for readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.70),
                  ],
                ),
              ),
            ),
            // Text content aligned towards bottom-left
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Understanding Your Child Better',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A gentle and safe assessment experience designed for parents and children.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
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

  Widget _buildProgressIndicator() {
    final double progress = _currentStep / _totalSteps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildStepChip('1', 'Profile Details', isActive: true),
            const SizedBox(width: 12),
            _buildStepChip('2', 'Detection Mode', isActive: false),
            const SizedBox(width: 12),
            _buildStepChip('3', 'Assessment', isActive: false),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.7),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFBB8ED0)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${(progress * 100).round()}% completed',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildStepChip(
    String step,
    String label, {
    required bool isActive,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFBB8ED0)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActive
              ? const Color(0xFFBB8ED0)
              : Colors.grey[300]!,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFFBB8ED0).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor:
                isActive ? Colors.white : const Color(0xFFBB8ED0).withOpacity(0.1),
            child: Text(
              step,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFFBB8ED0) : const Color(0xFF2C3E50),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD0B5).withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB6C1).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.child_care,
                  color: Color(0xFFFF69B4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Child Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Child Name
          _buildAnimatedTextField(
            controller: _childNameController,
            label: 'Child Name',
            icon: Icons.person_outline,
            hint: 'Enter child\'s full name',
            onChanged: _recalculateFormValidity,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter child\'s name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Age
          _buildAnimatedTextField(
            controller: _ageController,
            label: 'Age',
            icon: Icons.cake_outlined,
            hint: 'Enter child\'s age',
            keyboardType: TextInputType.number,
            onChanged: _recalculateFormValidity,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter child\'s age';
              }
              final age = int.tryParse(value);
              if (age == null) {
                return 'Please enter a valid age';
              }
              if (age < 1 || age > 6) {
                return 'Age must be between 1 and 6 years';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Gender Selection
          _buildGenderSelector(),
        ],
      ),
    );
  }

  Widget _buildParentDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC8DFFF).withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF87CEEB).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people_outline,
                  color: Color(0xFF4682B4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Parent / Guardian Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Parent Name
          _buildAnimatedTextField(
            controller: _parentNameController,
            label: 'Parent Name',
            icon: Icons.person_outline,
            hint: 'Enter parent\'s full name',
            onChanged: _recalculateFormValidity,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter parent\'s name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Relationship Dropdown
          _buildRelationshipDropdown(),
          const SizedBox(height: 20),
          // Contact Number
          _buildAnimatedTextField(
            controller: _contactNumberController,
            label: 'Contact Number',
            icon: Icons.phone_outlined,
            hint: 'Enter contact number',
            keyboardType: TextInputType.phone,
            onChanged: _recalculateFormValidity,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter contact number';
              }
              if (value.length < 10) {
                return 'Please enter a valid contact number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Email Address
          _buildAnimatedTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            hint: 'Enter email address',
            keyboardType: TextInputType.emailAddress,
            onChanged: _recalculateFormValidity,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email address';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          // Trust indicator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF4A6572),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your information is encrypted and used only for research purposes.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    VoidCallback? onChanged,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Focus(
          onFocusChange: (hasFocus) {
            // Focus animation handled by Material
          },
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: (_) {
              onChanged?.call();
            },
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2C3E50),
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              prefixIcon: Icon(icon, color: const Color(0xFFBB8ED0)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFBB8ED0),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGenderButton('Male', Icons.male),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderButton('Female', Icons.female),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderButton('Other', Icons.transgender),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderButton(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return AnimatedScale(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      scale: isSelected ? 1.03 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedGender = gender;
              _recalculateFormValidity();
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFBB8ED0)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFBB8ED0)
                    : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  gender,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRelationshipDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Relationship',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedRelationship,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.family_restroom,
                color: Color(0xFFBB8ED0),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: ['Mother', 'Father', 'Guardian']
                .map((relationship) => DropdownMenuItem(
                      value: relationship,
                      child: Text(
                        relationship,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedRelationship = value!;
                _recalculateFormValidity();
              });
            },
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Color(0xFFBB8ED0),
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildBenchmarkAssessmentsSection() {
    final childName = _childNameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    final childId = childName.isNotEmpty && age != null ? '${childName}_$age' : null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF7132C1).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF7132C1).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assessment, color: Color(0xFF7132C1), size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Benchmark Assessments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Standardized screening and developmental tracking. Compare with AI results.',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _navigateTo(MchatPage(childName: childName.isEmpty ? null : childName, childAge: age, childId: childId)),
                  icon: const Icon(Icons.checklist, size: 20),
                  label: const Text('M-CHAT-R/F'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7132C1),
                    side: const BorderSide(color: Color(0xFF7132C1)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _navigateTo(MilestoneTrackerPage(childName: childName.isEmpty ? null : childName, childAge: age, childId: childId)),
                  icon: const Icon(Icons.timeline, size: 20),
                  label: const Text('Milestones'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7132C1),
                    side: const BorderSide(color: Color(0xFF7132C1)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _navigateTo(PrqPage(childName: childName.isEmpty ? null : childName, childAge: age, childId: childId)),
              icon: const Icon(Icons.assignment, size: 20),
              label: const Text('Parent Report Questionnaire (PRQ)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF7132C1),
                side: const BorderSide(color: Color(0xFF7132C1)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Continue Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // Always allow button press - validation happens in _handleContinue
              _handleContinue();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFormValid 
                  ? const Color(0xFFBB8ED0)
                  : const Color(0xFFBB8ED0).withOpacity(0.6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: _isFormValid ? 8 : 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 22),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Clear Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _handleClear,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFBB8ED0),
              side: const BorderSide(color: Color(0xFFBB8ED0), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text(
              'Clear',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isPrimary;
  final bool enabled;
  final IconData? icon;

  const _AnimatedButton({
    required this.onPressed,
    required this.label,
    required this.isPrimary,
    this.enabled = true,
    this.icon,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = widget.enabled;

    return GestureDetector(
      onTapDown: isInteractive ? (_) => _controller.forward() : null,
      onTapUp: isInteractive
          ? (_) {
              _controller.reverse();
              widget.onPressed();
            }
          : null,
      onTapCancel: isInteractive ? () => _controller.reverse() : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Opacity(
          opacity: isInteractive ? 1.0 : 0.5,
          child: Container(
            decoration: BoxDecoration(
              gradient: widget.isPrimary && isInteractive
                  ? const LinearGradient(
                      colors: [Color(0xFFBB8ED0), Color(0xFFBB8ED0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.isPrimary && !isInteractive
                  ? const Color(0xFFBB8ED0).withOpacity(0.3)
                  : (widget.isPrimary ? null : Colors.white),
              borderRadius: BorderRadius.circular(28),
              border: widget.isPrimary
                  ? null
                  : Border.all(color: const Color(0xFFBB8ED0), width: 2),
              boxShadow: [
                BoxShadow(
                  color: widget.isPrimary
                      ? const Color(0xFFBB8ED0).withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isInteractive ? widget.onPressed : null,
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.isPrimary
                              ? Colors.white
                              : const Color(0xFFBB8ED0),
                        ),
                      ),
                      if (widget.icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          widget.icon,
                          size: 22,
                          color: widget.isPrimary
                              ? Colors.white
                              : const Color(0xFFBB8ED0),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
