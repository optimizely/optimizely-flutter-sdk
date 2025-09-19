import 'dart:async';
import 'package:flutter/services.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/log_level.dart';

import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';

class LoggerBridge {
  static const MethodChannel _loggerChannel =
      MethodChannel('optimizely_flutter_sdk_logger');

  static void initialize() {
    _loggerChannel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'log':
        final args = call.arguments as Map<String, dynamic>;
        final level = OptimizelyLogLevel.values[args['level'] as int];
        final message = args['message'] as String;

        OptimizelyFlutterSdk.logger?.log(level, message);
        break;
    }
  }
}
