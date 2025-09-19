import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';
import 'package:flutter/foundation.dart';

class CustomLogger implements OptimizelyLogger {
  @override
  OptimizelyLogLevel logLevel = OptimizelyLogLevel.debug;

  @override
  void log(OptimizelyLogLevel level, String message) {
    if (kDebugMode) {
      print('[Flutter LOGGER] ${level.name}: $message');
    }
  }
}
