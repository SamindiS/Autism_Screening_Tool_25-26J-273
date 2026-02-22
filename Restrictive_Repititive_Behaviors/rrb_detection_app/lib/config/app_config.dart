/// Application Configuration
class AppConfig {
  // API Configuration
  // For Android Device: Use computer's IP address (192.168.8.152)
  // For Web/Desktop: Use localhost
  static const String apiBaseUrl =
      'http://localhost:3000/api'; // Node.js Backend
  static const String mlServiceUrl =
      'http://localhost:5000/api/v1'; // ML Service

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String uploadVideoEndpoint = '/videos/upload';
  static const String detectRRBEndpoint = '/detect';
  static const String getResultsEndpoint = '/results';

  // App Configuration
  static const String appName = 'RRB Detection';
  static const String appVersion = '1.0.0';

  // Video Configuration
  static const int maxVideoDurationSeconds = 300; // 5 minutes
  static const int minVideoDurationSeconds = 10; // 10 seconds
  static const int videoQuality = 720; // 720p
  static const int videoFPS = 30;

  // Detection Configuration
  static const double confidenceThreshold = 0.70;
  static const double minDetectionDuration = 3.0; // seconds

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';

  // RRB Categories
  static const List<String> rrbCategories = [
    'Hand Flapping',
    'Head Banging',
    'Head Nodding',
    'Spinning',
    'Atypical Hand Movements',
    'Normal',
  ];

  // Colors
  static const Map<String, int> categoryColors = {
    'Hand Flapping': 0xFFE74C3C,
    'Head Banging': 0xFFE67E22,
    'Head Nodding': 0xFFF39C12,
    'Spinning': 0xFF9B59B6,
    'Atypical Hand Movements': 0xFF3498DB,
    'Normal': 0xFF2ECC71,
  };
}
