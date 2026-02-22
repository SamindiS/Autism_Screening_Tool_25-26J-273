import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:senseai/l10n/app_localizations.dart';

import '../../core/providers/language_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/services/language_preference_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _backendController = TextEditingController();
  bool _isTesting = false;
  bool? _lastTestResult;
  String? _statusMessage;
  bool _autoDetect = true;

  @override
  void initState() {
    super.initState();
    _loadBackendUrl();
    _loadAutoDetectSetting();
  }

  Future<void> _loadBackendUrl() async {
    final url = await ApiService.getBackendUrl();
    if (!mounted) return;
    setState(() {
      _backendController.text = url;
    });
  }

  Future<void> _loadAutoDetectSetting() async {
    final autoDetect = await LanguagePreferenceService.isAutoDetectEnabled();
    if (!mounted) return;
    setState(() {
      _autoDetect = autoDetect;
    });
  }

  Future<void> _testConnection() async {
    final url = _backendController.text.trim();
    if (url.isEmpty) {
      _showSnack('Please enter a backend URL');
      return;
    }

    setState(() {
      _isTesting = true;
      _statusMessage = null;
      _lastTestResult = null;
    });

    final cleanUrl = url.replaceAll(RegExp(r'/$'), '');
    try {
      final healthy = await _pingBackend(cleanUrl);
      if (!mounted) return;
      setState(() {
        _isTesting = false;
        _lastTestResult = healthy;
        _statusMessage =
            healthy ? 'Backend is reachable.' : 'Backend did not respond.';
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isTesting = false;
        _lastTestResult = false;
        _statusMessage = 'Connection timed out. Check Wi-Fi and firewall.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTesting = false;
        _lastTestResult = false;
        _statusMessage = 'Request failed: $e';
      });
    }
  }

  Future<void> _saveUrl() async {
    final url = _backendController.text.trim();
    if (url.isEmpty) {
      _showSnack('Please enter a backend URL');
      return;
    }

    final cleanUrl = url.replaceAll(RegExp(r'/$'), '');
    await ApiService.setBackendUrl(cleanUrl);
    if (!mounted) return;
    _showSnack('Backend URL saved. Try logging in again.');
  }

  Future<void> _resetUrl() async {
    await ApiService.resetBackendUrl();
    await _loadBackendUrl();
    if (!mounted) return;
    _showSnack('Backend URL reset to default (10.0.2.2:3000).');
  }

  Future<bool> _pingBackend(String baseUrl) async {
    final response = await http
        .get(Uri.parse('$baseUrl/health'))
        .timeout(const Duration(seconds: 10));
    return response.statusCode == 200;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleLanguageChange(Locale newLocale) async {
    final languageProvider = context.read<LanguageProvider>();
    await languageProvider.setLocale(newLocale);
    if (!mounted) return;
    _showSnack(
      'Language changed to ${LanguagePreferenceService.getLanguageName(newLocale.languageCode)}',
    );
  }

  Future<void> _handleAutoDetectChange(bool value) async {
    await LanguagePreferenceService.setAutoDetect(value);
    if (!mounted) return;
    setState(() {
      _autoDetect = value;
    });

    if (value) {
      final deviceLocale = await LanguagePreferenceService.getLocale();
      if (mounted) {
        _handleLanguageChange(deviceLocale);
      }
    }
  }

  @override
  void dispose() {
    _backendController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageProvider = context.watch<LanguageProvider>();
    final supportedLanguages = languageProvider.supportedLanguages;
    final currentLocale = languageProvider.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settingsTitle ?? 'Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBackendCard(l10n),
          const SizedBox(height: 16),
          _buildNetworkTipsCard(l10n),
          const SizedBox(height: 16),
          _buildLanguageCard(supportedLanguages, currentLocale),
          const SizedBox(height: 16),
          _buildLanguageInfoCard(),
          const SizedBox(height: 16),
          _buildAboutCard(l10n),
        ],
      ),
    );
  }

  Widget _buildBackendCard(AppLocalizations? l10n) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  l10n?.backendConfiguration ?? 'Backend Configuration',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _backendController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: l10n?.backendUrl ?? 'Backend URL',
                hintText: 'http://192.168.x.x:3000',
                helperText: l10n?.backendHelper ??
                    'Use your laptop IP from ipconfig (Wi-Fi adapter) for real devices.',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isTesting ? null : _testConnection,
                  icon: _isTesting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_tethering),
                  label: Text(
                    _isTesting
                        ? (l10n?.testing ?? 'Testing...')
                        : (l10n?.testConnection ?? 'Test connection'),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isTesting ? null : _saveUrl,
                  icon: const Icon(Icons.save),
                  label: Text(l10n?.save ?? 'Save'),
                ),
                TextButton(
                  onPressed: _isTesting ? null : _resetUrl,
                  child: Text(l10n?.resetToDefault ?? 'Reset to default'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_statusMessage != null)
              Row(
                children: [
                  Icon(
                    _lastTestResult == true
                        ? Icons.check_circle
                        : Icons.error_outline,
                    color: _lastTestResult == true
                        ? Colors.green
                        : theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusMessage!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkTipsCard(AppLocalizations? l10n) {
    final theme = Theme.of(context);
    final tips = [
      l10n?.networkTipSameWifi ??
          'Laptop and tablet must be on the same Wi-Fi network.',
      l10n?.networkTipBackend ??
          'Run `npm start` (backend) before opening the app.',
      l10n?.networkTipBrowser ??
          'Open http://<your-ip>:3000/health in a mobile browser to verify access.',
      l10n?.networkTipFirewall ??
          'Allow inbound TCP port 3000 in Windows Defender Firewall.',
      l10n?.networkTipUpdate ??
          'Update the URL here whenever your laptop IP changes.',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  l10n?.networkChecklist ?? 'Network checklist',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final tip in tips) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('- '),
                  Expanded(child: Text(tip)),
                ],
              ),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    List<Map<String, String>> supportedLanguages,
    Locale currentLocale,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.translate, color: Colors.teal),
                const SizedBox(width: 12),
                Text(
                  'App language',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-detect from device'),
              subtitle:
                  const Text('Use the tablet/phone language automatically'),
              value: _autoDetect,
              onChanged: _handleAutoDetectChange,
            ),
            const Divider(),
            ...supportedLanguages.map((lang) {
              final isSelected = currentLocale.languageCode == lang['code'];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      isSelected ? Colors.teal.shade100 : Colors.grey.shade200,
                  child: Text(
                    lang['native']!,
                    style: TextStyle(
                      color: isSelected ? Colors.teal.shade700 : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(lang['name']!),
                subtitle: Text(lang['native']!),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: Colors.teal.shade600)
                    : const Icon(Icons.radio_button_unchecked),
                enabled: !_autoDetect,
                onTap: _autoDetect
                    ? null
                    : () => _handleLanguageChange(Locale(lang['code']!)),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _autoDetect
                    ? 'Language is automatically detected from device settings.'
                    : 'Select your preferred language above. Enable auto-detect to follow the device language.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(AppLocalizations? l10n) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.app_settings_alt, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  l10n?.aboutThisBuild ?? 'About this build',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(l10n?.version ?? 'Version', '1.0.0 (pilot)'),
            const SizedBox(height: 8),
            _infoRow(l10n?.dataMode ?? 'Data mode', 'Local backend + SQLite'),
            const SizedBox(height: 8),
            _infoRow('Firebase', 'Disabled (backend handles cloud sync)'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final style = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: style.bodyMedium)),
        const SizedBox(width: 12),
        Text(value, style: style.labelLarge),
      ],
    );
  }
}
