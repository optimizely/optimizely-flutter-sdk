import 'package:optimizely_flutter_sdk/src/data_objects/log_level.dart';

abstract class OptimizelyLogger {
  /// Log a message at a certain level
  void log(OptimizelyLogLevel level, String message);
}

class DefaultOptimizelyLogger implements OptimizelyLogger {
  @override
  void log(OptimizelyLogLevel level, String message) {
    print('${level.name} $message');
  }
}

class AppLogger {
  static OptimizelyLogger _instance = DefaultOptimizelyLogger();

  /// Get the current app logger instance
  static OptimizelyLogger get instance => _instance;

  /// Reset to default logger
  static void reset() {
    _instance = DefaultOptimizelyLogger();
  }

  /// Convenience methods for direct logging
  static void error(String message) {
    _instance.log(OptimizelyLogLevel.error, message);
  }

  static void warning(String message) {
    _instance.log(OptimizelyLogLevel.warning, message);
  }

  static void info(String message) {
    _instance.log(OptimizelyLogLevel.info, message);
  }

  static void debug(String message) {
    _instance.log(OptimizelyLogLevel.debug, message);
  }
}
