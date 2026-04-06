import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senseai/core/localization/app_localizations.dart';

import 'core/providers/language_provider.dart';
import 'core/services/offline_sync_service.dart';
import 'core/services/storage_service.dart';
import 'features/common/splash_screen.dart' as common; // Existing splash screen
import 'visual_attention/screens/splash_screen.dart'
    as visual; // From your friend's code
import 'visual_attention/theme.dart'; // From your friend's code

/// Custom [HttpOverrides] to handle SSL certification for development.
/// 
/// In debug mode, this allows the app to communicate with servers using
/// self-signed certificates or when there is a hostname mismatch.
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

/// The entry point of the SenseAI application.
/// 
/// Initializes core services and sets up the root widget.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow self-signed or mismatched certs in debug mode (fixes Vercel mismatch)
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }

  // Initialize services
  // sqflite (SQLite) is not supported on Web — skip on Chrome, runs normally on mobile/desktop
  if (!kIsWeb) {
    // Initializing offline synchronization and local storage
    await OfflineSyncService.init();
    OfflineSyncService.startSyncLoop();
    await StorageService.database;
  }

  runApp(const SenseAIApp());
}

/// The root widget of the SenseAI application.
/// 
/// Sets up the [ChangeNotifierProvider] for language management and
/// configures the [MaterialApp] with theme and localization.
class SenseAIApp extends StatelessWidget {
  const SenseAIApp({super.key});

  /// Global navigator key for accessing the [NavigatorState] without a context.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child:
          Consumer<LanguageProvider>(builder: (context, languageProvider, _) {
        return MaterialApp(
          title: 'SenseAI',
          navigatorKey: navigatorKey,
          theme: ThemeData(
            primaryColor: SenseAIColors.primaryBlue, // From friend's theme
            colorScheme: ColorScheme.fromSeed(
              seedColor: SenseAIColors.primaryBlue,
              primary: SenseAIColors.primaryBlue,
              secondary: SenseAIColors.puzzleTeal,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: SenseAIColors.appBarColor,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: SenseAIColors.softTeal,
                foregroundColor: SenseAIColors.primaryBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            scaffoldBackgroundColor:
                Colors.white, // Maintain your background color
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: _getFontFamily(languageProvider.locale.languageCode),
          ),
          locale: languageProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          // Initial screen of the application
          home: const common
              .SplashScreen(), // You can decide which SplashScreen to use
          debugShowCheckedModeBanner: false,
        );
      }),
    );
  }

  /// Determines the appropriate font family based on the [languageCode].
  String? _getFontFamily(String languageCode) {
    switch (languageCode) {
      case 'si':
        return 'IskoolaPota';
      case 'ta':
        return 'Bamini';
      default:
        return null;
    }
  }
}
