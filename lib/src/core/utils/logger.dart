import 'package:logger/logger.dart';

class AppLogger {
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // Number of method calls to show in stack trace for non-error logs
      errorMethodCount: 8, // Number of method calls for error logs
      lineLength: 120, // Maximum line length for log messages
      colors: true, // Enable colored output
      printEmojis: true, // Include emojis in logs
      printTime: true, // Include timestamp in logs
    ),
  );

  static void debug(dynamic message) {
    _logger.d(message);
  }

  static void info(dynamic message) {
    _logger.i(message);
  }

  static void warning(dynamic message) {
    _logger.w(message);
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}