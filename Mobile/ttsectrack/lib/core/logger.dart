import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

class Logger {
  static bool debugMode = false;

  static void log(String message, {LogLevel level = LogLevel.info, Object? error, StackTrace? stackTrace}) {
    final now = DateTime.now().toIso8601String();
    final levelStr = level.toString().split('.').last.toUpperCase();
    final logMsg = '[$levelStr][$now] $message';

    if (level == LogLevel.error) {
      developer.log(logMsg, level: 1000, error: error, stackTrace: stackTrace);
    } else if (level == LogLevel.warning) {
      developer.log(logMsg, level: 900);
    } else if (level == LogLevel.info) {
      developer.log(logMsg, level: 800);
    } else if (level == LogLevel.debug && debugMode) {
      developer.log(logMsg, level: 700);
    }
  }

  static void info(String message) => log(message, level: LogLevel.info);
  static void warning(String message) => log(message, level: LogLevel.warning);
  static void error(String message, {Object? error, StackTrace? stackTrace}) => log(message, level: LogLevel.error, error: error, stackTrace: stackTrace);
  static void debug(String message) => log(message, level: LogLevel.debug);
}
