// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:senseai/l10n/app_localizations.dart';
import 'core/services/storage_service.dart';
import 'core/providers/language_provider.dart';
import 'features/common/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization error: $e');
    debugPrint('⚠️ Make sure google-services.json is in android/app/ directory');
  }
  
  // Initialize database
  await StorageService.database;
  runApp(const SenseAIApp());
}

class SenseAIApp extends StatelessWidget {
  const SenseAIApp({Key? key}) : super(key: key);

  // Global navigator key to access navigation from anywhere
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          // Don't use ValueKey - it resets the app
          // Instead, rely on Flutter's localization system to update widgets
          // when MaterialApp's locale property changes
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'SenseAI',
            theme: ThemeData(
              primarySwatch: Colors.teal,
              scaffoldBackgroundColor: Colors.white,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              fontFamily: _getFontFamily(languageProvider.locale.languageCode),
            ),
            locale: languageProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
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