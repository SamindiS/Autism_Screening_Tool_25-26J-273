import 'dart:convert';

/// Service for generating formatted logs for sessions and assessment events.
/// 
/// This service uses specific tags (`===ASD_LOG_START===`, etc.) to demarcate 
/// structured JSON data in the console, which can be easily parsed by 
/// external log monitoring tools.
class LoggerService {
  LoggerService._();

  /// Logs a clinical session with a timestamped payload.
  /// 
  /// The [data] is formatted as an indented JSON string.
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

  /// Logs a discrete event (e.g., UI interaction or internal state change).
  static void logEvent(Map<String, dynamic> data) {
    final payload = Map<String, dynamic>.from(data)
      ..putIfAbsent('timestamp', () => DateTime.now().toIso8601String());

    const startTag = '===ASD_EVENT_START===';
    const endTag = '===ASD_EVENT_END===';

    // ignore: avoid_print
    print(startTag);
    // ignore: avoid_print
    print(const JsonEncoder.withIndent('  ').convert(payload));
    // ignore: avoid_print
    print(endTag);
  }
}

