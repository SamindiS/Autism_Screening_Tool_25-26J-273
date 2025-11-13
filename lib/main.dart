// lib/main.dart
import 'package:flutter/material.dart';
import 'core/localization/l10n.dart';
import 'core/services/storage_service.dart';
import 'features/common/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize database
  await StorageService.database;
  runApp(const SenseAIApp());
}

class SenseAIApp extends StatelessWidget {
  const SenseAIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SenseAI',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: L10n.localizationsDelegates,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}