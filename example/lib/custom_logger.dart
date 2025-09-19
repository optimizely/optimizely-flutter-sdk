import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';

class CustomLogger implements OptimizelyLogger {
  @override
  OptimizelyLogLevel logLevel = OptimizelyLogLevel.debug;

  @override
  void log(OptimizelyLogLevel level, String message) {
    print('[Flutter LOGGER] ${level.name}: $message');
  }
}
