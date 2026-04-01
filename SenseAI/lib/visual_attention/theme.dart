/// SenseAI theme and API configuration
/// Shared across all screens.

import 'package:flutter/material.dart';

/// Backend API base URL - MUST match your setup for online mode:
/// - Physical device on WiFi: http://YOUR_PC_IP:8000 (find PC IP: ipconfig)
/// - Android emulator: http://10.0.2.2:8000
/// - Same machine: http://127.0.0.1:8000
/// Backend must run with: uvicorn main:app --host 0.0.0.0 --port 8000
const String API_BASE = 'http://172.28.5.240:8000';

// =============================================================================
// SENSEAI BRAND COLORS (extracted from logo)
// =============================================================================
class SenseAIColors {
  // Primary brand colors from logo
  static const Color primaryOrange = Color(0xFFF5A623);
  static const Color primaryBlue = Color(0xFF2C3E7B);
  static const Color puzzleTeal = Color(0xFF4ECDC4);
  static const Color puzzlePink = Color(0xFFE88B9C);
  static const Color puzzleBlue = Color(0xFF5B7DB1);
  static const Color nodeOrange = Color(0xFFE86B4A);
  static const Color nodeTeal = Color(0xFF4ECDC4);

  // Soft clinical variations (for children)
  static const Color softTeal = Color(0xFF88D8D8);
  static const Color softPink = Color(0xFFF7CAC9);
  static const Color softBlue = Color(0xFF87CEEB);
  static const Color softOrange = Color(0xFFFFDAB9);

  // Background colors
  static const Color bgLight = Color(0xFFF5F5F5);
  static const Color bgDark = Color(0xFF2C3E50);

  // App bar color - softer teal that matches the palette
  static const Color appBarColor = Color(0xFF4ECDC4);
}
