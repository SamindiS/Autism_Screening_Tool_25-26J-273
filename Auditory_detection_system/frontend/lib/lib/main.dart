import 'package:flutter/material.dart';
import 'pages/auditory_response_to_name_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SenseAI - Autism Auditory Learning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7132C1),
        ),
        useMaterial3: true,
      ),
      home: const AuditoryResponseToNamePage(),
    );
  }
}

