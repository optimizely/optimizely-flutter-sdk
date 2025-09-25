import 'package:optimizely_flutter_sdk/src/data_objects/log_level.dart';

abstract class OptimizelyLogger {
  /// Log a message at a certain level
  void log(OptimizelyLogLevel level, String message);
}

class DefaultOptimizelyLogger implements OptimizelyLogger {
  @override
  void log(OptimizelyLogLevel level, String message) {
    print('[OPTIMIZELY] [${level.name.toUpperCase()}]: $message');
  }
}

/// App logger instance
final _appLogger = DefaultOptimizelyLogger();

/// App logging functions
void logError(String message) =>
    _appLogger.log(OptimizelyLogLevel.error, message);
void logWarning(String message) =>
    _appLogger.log(OptimizelyLogLevel.warning, message);
void logInfo(String message) =>
    _appLogger.log(OptimizelyLogLevel.info, message);
void logDebug(String message) =>
    _appLogger.log(OptimizelyLogLevel.debug, message);
