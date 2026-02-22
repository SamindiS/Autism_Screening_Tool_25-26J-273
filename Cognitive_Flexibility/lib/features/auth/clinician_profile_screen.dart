import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/language_selector.dart';
import 'login_screen.dart';

class ClinicianProfileScreen extends StatefulWidget {
  const ClinicianProfileScreen({Key? key}) : super(key: key);

  @override
  State<ClinicianProfileScreen> createState() => _ClinicianProfileScreenState();
}

class _ClinicianProfileScreenState extends State<ClinicianProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _isEditing = false;
  bool _loading = false;
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;
  
  Map<String, dynamic>? _clinicianData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadClinicianData();
  }

  Future<void> _loadClinicianData() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('📋 Loading clinician profile data...');
      final clinician = await ApiService.getClinicianInfo();
      debugPrint('✅ Clinician data loaded: ${clinician['name']} (ID: ${clinician['id']})');
      
      setState(() {
        _clinicianData = clinician;
        _nameController.text = clinician['name']?.toString() ?? '';
        _hospitalController.text = clinician['hospital']?.toString() ?? '';
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading clinician data: $e');
      setState(() {
        _errorMessage = 'Failed to load clinician data. Please check your connection and try again.\n\nError: ${e.toString()}';
        _loading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pinController.text != _confirmPinController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PINs do not match!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final clinicianId = _clinicianData?['id']?.toString();
      if (clinicianId == null) {
        throw Exception('Clinician ID not found');
      }

      await ApiService.updateClinician(
        id: clinicianId,
        name: _nameController.text.trim(),
        hospital: _hospitalController.text.trim(),
        pin: _pinController.text,
      );

      // Reload data
      await _loadClinicianData();

      setState(() {
        _isEditing = false;
        _pinController.clear();
        _confirmPinController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteProfile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: const Text(
          'Are you sure you want to delete your profile? This action cannot be undone. You will need to register again to use the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _loading = true);

    try {
      final clinicianId = _clinicianData?['id']?.toString();
      if (clinicianId == null) {
        throw Exception('Clinician ID not found');
      }

      await ApiService.deleteClinician(clinicianId);
      await AuthService.logout();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile deleted. Please register again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hospitalController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.clinicianProfile),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const LanguageSelector(),
          ),
        ],
      ),
      body: _loading && _clinicianData == null
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadClinicianData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header Card
                        _buildHeaderCard(),
                        const SizedBox(height: 24),
                        // Profile Details
                        _buildDetailsCard(),
                        const SizedBox(height: 24),
                        // Action Buttons
                        _buildActionButtons(),
                      ],
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
          colors: [Colors.teal.shade600, Colors.teal.shade400],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Clinician Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                if (_clinicianData != null)
                  Text(
                    _clinicianData!['name']?.toString() ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Field
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline,
            enabled: _isEditing,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Name is required';
              }
              if (v.trim().length < 3) {
                return 'Name must be at least 3 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Hospital Field
          _buildTextField(
            controller: _hospitalController,
            label: 'Hospital / Clinic Name',
            icon: Icons.local_hospital_outlined,
            enabled: _isEditing,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Hospital name is required';
              }
              if (v.trim().length < 3) {
                return 'Hospital name must be at least 3 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // PIN Field (only when editing)
          if (_isEditing) ...[
            _buildTextField(
              controller: _pinController,
              label: 'New PIN (4 digits)',
              icon: Icons.lock_outline,
              enabled: _isEditing,
              obscureText: _obscurePin,
              suffixIcon: IconButton(
                icon: Icon(_obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscurePin = !_obscurePin),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'PIN is required';
                }
                if (v.length != 4) {
                  return 'PIN must be exactly 4 digits';
                }
                if (!RegExp(r'^\d{4}$').hasMatch(v)) {
                  return 'PIN must contain only numbers';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Confirm PIN Field
            _buildTextField(
              controller: _confirmPinController,
              label: 'Confirm New PIN',
              icon: Icons.lock_outline,
              enabled: _isEditing,
              obscureText: _obscureConfirmPin,
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPin ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscureConfirmPin = !_obscureConfirmPin),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Please confirm your PIN';
                }
                if (v != _pinController.text) {
                  return 'PINs do not match';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 20),
          // Additional Info
          if (!_isEditing && _clinicianData != null) ...[
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 16),
            _buildInfoRow('Clinician ID', _clinicianData!['id']?.toString() ?? 'N/A'),
            const SizedBox(height: 12),
            _buildInfoRow('Registered', _formatDate(_clinicianData!['created_at'])),
            if (_clinicianData!['updated_at'] != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Last Updated', _formatDate(_clinicianData!['updated_at'])),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade50,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_isEditing) ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _loading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: _loading
                  ? null
                  : () {
                      setState(() {
                        _isEditing = false;
                        _pinController.clear();
                        _confirmPinController.clear();
                        _loadClinicianData();
                      });
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal,
                side: const BorderSide(color: Colors.teal, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
              label: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _deleteProfile,
              icon: const Icon(Icons.delete_outline),
              label: const Text(
                'Delete Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'N/A';
    try {
      if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue).toString().split(' ')[0];
      } else if (dateValue is String) {
        return dateValue.split(' ')[0];
      }
      return dateValue.toString();
    } catch (e) {
      return dateValue.toString();
    }
  }
}

