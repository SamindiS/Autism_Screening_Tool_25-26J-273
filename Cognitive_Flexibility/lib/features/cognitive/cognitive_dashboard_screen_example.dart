// Example: How to use translations in your screens
// This is just an example - your actual cognitive_dashboard_screen.dart should use these patterns

import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/localization_service.dart';

class ExampleUsageScreen extends StatelessWidget {
  const ExampleUsageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Method 1: Using AppLocalizations (Recommended)
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.cognitiveFlexibility ?? 'Cognitive Flexibility'),
      ),
      body: Column(
        children: [
          // Method 1: Using AppLocalizations getters
          Text(l10n?.welcome ?? 'Welcome'),
          Text(l10n?.dashboard ?? 'Dashboard'),
          
          // Method 2: Using translate method
          Text(l10n?.translate('add_child') ?? 'Add Child'),
          
          // Method 3: Using extension (if you import localization_service)
          Text('search_children'.tr),
          
          // Method 4: Direct service call
          Text(LocalizationService.translate('total_children')),
          
          // Example with parameters (using string interpolation)
          Text('${l10n?.question ?? "Question"} 1 ${l10n?.ofText ?? "of"} 10'),
        ],
      ),
    );
  }
}

