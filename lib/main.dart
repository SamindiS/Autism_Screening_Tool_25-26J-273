// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/localization/l10n.dart';
import 'core/services/storage_service.dart';
import 'core/services/localization_service.dart';
import 'core/providers/language_provider.dart';
import 'features/common/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize database
  await StorageService.database;
  // Load default locale
  await LocalizationService.load(const Locale('en'));
  runApp(const SenseAIApp());
}

class SenseAIApp extends StatelessWidget {
  const SenseAIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return MaterialApp(
            title: 'SenseAI',
            theme: ThemeData(
              primarySwatch: Colors.teal,
              scaffoldBackgroundColor: Colors.white,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              fontFamily: _getFontFamily(languageProvider.locale.languageCode),
            ),
            locale: languageProvider.locale,
            supportedLocales: L10n.supportedLocales,
            localizationsDelegates: L10n.localizationsDelegates,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  String? _getFontFamily(String languageCode) {
    switch (languageCode) {
      case 'si':
        return 'IskoolaPota';
      case 'ta':
        return 'Bamini';
      default:
        return null; // Use system default for English
    }
  }
}