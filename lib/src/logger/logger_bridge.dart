import 'dart:async';
import 'package:flutter/services.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/log_level.dart';
import 'package:optimizely_flutter_sdk/src/logger/flutter_logger.dart';
import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';

class LoggerBridge {
  static const MethodChannel _loggerChannel =
      MethodChannel('optimizely_flutter_sdk_logger');
  static OptimizelyLogger? _customLogger;

  /// Initialize the logger bridge to receive calls from native
  static void initialize(OptimizelyLogger? logger) {
    print('[LoggerBridge] Initializing with logger: ${logger != null}');
    _customLogger = logger;
    _loggerChannel.setMethodCallHandler(_handleMethodCall);
  }

  /// Handle incoming method calls from native Swift/Java code
  static Future<void> _handleMethodCall(MethodCall call) async {
    print('[LoggerBridge] Received method call: ${call.method}');
    try {
      switch (call.method) {
        case 'log':
          await _handleLogCall(call);
          break;
        default:
          print('[LoggerBridge] Unknown method call: ${call.method}');
      }
    } catch (e) {
      print('[LoggerBridge] Error handling method call: $e');
    }
  }

  /// Process the log call from Swift/Java
  static Future<void> _handleLogCall(MethodCall call) async {
    try {
      final args = Map<String, dynamic>.from(call.arguments ?? {});

      final levelRawValue = args['level'] as int?;
      final message = args['message'] as String?;

      if (levelRawValue == null || message == null) {
        print('[LoggerBridge] Warning: Missing level or message in log call');
        return;
      }

      final level = _convertLogLevel(levelRawValue);

      print('[LoggerBridge] Processing log: level=$levelRawValue, message=$message');

      if (_customLogger != null) {
        _customLogger!.log(level, message);
      } else {
        print('[Optimizely ${level.name}] $message');
      }
    } catch (e) {
      print('[LoggerBridge] Error processing log call: $e');
    }
  }

  /// Convert native log level to Flutter enum
  static OptimizelyLogLevel _convertLogLevel(int rawValue) {
    switch (rawValue) {
      case 1:
        return OptimizelyLogLevel.error;
      case 2:
        return OptimizelyLogLevel.warning;
      case 3:
        return OptimizelyLogLevel.info;
      case 4:
        return OptimizelyLogLevel.debug;
      default:
        return OptimizelyLogLevel.info;
    }
  }
  
  /// Expose convertLogLevel 
  static OptimizelyLogLevel convertLogLevel(int rawValue) {
    return _convertLogLevel(rawValue);
  }

  /// Check if a custom logger is set
  static bool hasLogger() {
    return _customLogger != null;
  }

  /// Get the current logger
  static OptimizelyLogger? getCurrentLogger() {
    return _customLogger;
  }

  /// Reset logger state
  static void reset() {
    _customLogger = null;
  }

  /// Simulate method calls
  static Future<void> handleMethodCallForTesting(MethodCall call) async {
    await _handleMethodCall(call);
  }
}
