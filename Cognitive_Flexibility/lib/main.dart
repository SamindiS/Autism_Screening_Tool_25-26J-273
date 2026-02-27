import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senseai/core/localization/app_localizations.dart';

import 'core/providers/language_provider.dart';
import 'core/services/offline_sync_service.dart';
import 'core/services/storage_service.dart';
import 'features/common/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Note: Impeller can cause crashes on emulators with charts
  // If you see rendering crashes, run with: flutter run --no-enable-impeller
  // Or use a real device instead of emulator
  
  await OfflineSyncService.init();
  OfflineSyncService.startSyncLoop();
  await StorageService.database;
  runApp(const SenseAIApp());
}

class SenseAIApp extends StatelessWidget {
  const SenseAIApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
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
        return null;
    }
  }
}
