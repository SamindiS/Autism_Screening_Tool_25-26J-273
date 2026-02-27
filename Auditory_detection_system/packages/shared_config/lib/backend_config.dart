/// Backend API Configuration (single source for root and frontend)
class BackendConfig {
  // Change this to your backend server URL
  // Android emulator: use 10.0.2.2 (emulator's alias for your computer)
  // Physical device on same WiFi: use your computer's IP (e.g. 172.20.10.3)
  static const String baseUrl = 'http://10.0.2.2:5000'; // Android emulator (Pixel Tablet, etc.)
  // static const String baseUrl = 'http://172.20.10.3:5000'; // Physical device - your computer's IP

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
