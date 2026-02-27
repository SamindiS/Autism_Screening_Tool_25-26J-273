/// Backend API Configuration
class BackendConfig {
  // Change this to your backend server URL
  // For local development: 'http://localhost:5000'
  // For Android emulator: 'http://10.0.2.2:5000'
  // For physical device: 'http://YOUR_COMPUTER_IP:5000'
  // For Android emulator, use 10.0.2.2 instead of localhost
  // For physical device, use your computer's IP address (e.g., 'http://192.168.1.100:5000')
  static const String baseUrl = 'http://172.20.10.3:5000'; // Physical device - your actual IP
  // static const String baseUrl = 'http://localhost:5000'; // For web/desktop
  
  // API endpoints
  static String get healthEndpoint => '$baseUrl/health';
  static String get analyzeVideoEndpoint => '$baseUrl/api/analyze-video';
  static String get validateVideoEndpoint => '$baseUrl/api/validate-video';
  static String get analyzeAudioEndpoint => '$baseUrl/api/analyze-audio';
  
  // Tap the Sound Game endpoints
  static String get tapGameStartEndpoint => '$baseUrl/tap-game/start';
  static String get tapGameResponseEndpoint => '$baseUrl/tap-game/response';
  static String tapGameResultEndpoint(String childId) => '$baseUrl/tap-game/result/$childId';
  
  // Benchmark Assessment endpoints
  static String get mchatQuestionsEndpoint => '$baseUrl/api/benchmark/mchat/questions';
  static String get mchatSubmitEndpoint => '$baseUrl/api/benchmark/mchat/submit';
  static String get mchatHistoryEndpoint => '$baseUrl/api/benchmark/mchat/history';
  static String compareEndpoint(String childId) => '$baseUrl/api/benchmark/compare?child_id=$childId';
  static String milestonesEndpoint(int ageMonths) => '$baseUrl/api/benchmark/milestones?age_months=$ageMonths';
  static String get milestonesSubmitEndpoint => '$baseUrl/api/benchmark/milestones/submit';
  static String get milestonesHistoryEndpoint => '$baseUrl/api/benchmark/milestones/history';
  static String get prqSchemaEndpoint => '$baseUrl/api/benchmark/prq/schema';
  static String get prqSubmitEndpoint => '$baseUrl/api/benchmark/prq/submit';
  static String get prqHistoryEndpoint => '$baseUrl/api/benchmark/prq/history';
  
  // Timeout settings
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
}


