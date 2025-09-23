import 'package:optimizely_flutter_sdk/src/data_objects/log_level.dart';

abstract class OptimizelyLogger {
  /// Log a message at a certain level
  void log(OptimizelyLogLevel level, String message);
}

class DefaultOptimizelyLogger implements OptimizelyLogger {
  @override
  void log(OptimizelyLogLevel level, String message) {
    print('[Optimizely ${level.name}] $message');
  }
}
