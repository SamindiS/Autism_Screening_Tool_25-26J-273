import 'dart:convert';

class LoggerService {
  LoggerService._();

  static void logSession(Map<String, dynamic> data) {
    final payload = Map<String, dynamic>.from(data)
      ..putIfAbsent('logged_at', () => DateTime.now().toIso8601String());

    const startTag = '===ASD_LOG_START===';
    const endTag = '===ASD_LOG_END===';

    // ignore: avoid_print
    print(startTag);
    // ignore: avoid_print
    print(const JsonEncoder.withIndent('  ').convert(payload));
    // ignore: avoid_print
    print(endTag);
  }
}

