import 'package:optimizely_flutter_sdk/src/data_objects/log_level.dart';

abstract class OptimizelyLogger {
  /// The log level for the logger
  OptimizelyLogLevel get logLevel;
  set logLevel(OptimizelyLogLevel level);

  /// Log a message at a certain level
  void log(OptimizelyLogLevel level, String message);
}

// enum OptimizelyLogLevel { error, warning, info, debug }

class DefaultOptimizelyLogger implements OptimizelyLogger {
  @override
  OptimizelyLogLevel logLevel = OptimizelyLogLevel.info;

  @override
  void log(OptimizelyLogLevel level, String message) {
    if (_shouldLog(level)) {
      print('[Optimizely ${level.name.toUpperCase()}] $message');
    }
  }

  bool _shouldLog(OptimizelyLogLevel messageLevel) {
    return messageLevel.index <= logLevel.index;
  }
}
