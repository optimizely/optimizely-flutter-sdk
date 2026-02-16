import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import 'package:optimizely_flutter_sdk/src/logger/logger_bridge.dart';
import 'package:optimizely_flutter_sdk/src/logger/flutter_logger.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/log_level.dart';

/// Test implementation of OptimizelyLogger for testing
class TestLogger implements OptimizelyLogger {
  final List<LogEntry> logs = [];

  @override
  void log(OptimizelyLogLevel level, String message) {
    logs.add(LogEntry(level, message));
  }

  void clear() {
    logs.clear();
  }
}

/// Data class for log entries
class LogEntry {
  final OptimizelyLogLevel level;
  final String message;

  LogEntry(this.level, this.message);

  @override
  String toString() => '${level.name}: $message';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("Logger Tests", () {
    setUp(() {
      // Reset logger state before each test
      LoggerBridge.reset();
    });

    test("should handle log method call from native", () async {
      var testLogger = TestLogger();
      LoggerBridge.initialize(testLogger);
      
      // Simulate native log call by directly invoking the method handler
      final methodCall = const MethodCall('log', {
        'level': 3, // INFO
        'message': 'Test log message from native'
      });
      
      await LoggerBridge.handleMethodCallForTesting(methodCall);
      
      expect(testLogger.logs.length, equals(1));
      expect(testLogger.logs.first.level, equals(OptimizelyLogLevel.info));
      expect(testLogger.logs.first.message, equals('Test log message from native'));
    });

    test("should convert log levels correctly", () {
      expect(LoggerBridge.convertLogLevel(1), equals(OptimizelyLogLevel.error));
      expect(LoggerBridge.convertLogLevel(2), equals(OptimizelyLogLevel.warning));
      expect(LoggerBridge.convertLogLevel(3), equals(OptimizelyLogLevel.info));
      expect(LoggerBridge.convertLogLevel(4), equals(OptimizelyLogLevel.debug));
    });

    test("should default to info for invalid log levels", () {
      expect(LoggerBridge.convertLogLevel(0), equals(OptimizelyLogLevel.info));
      expect(LoggerBridge.convertLogLevel(5), equals(OptimizelyLogLevel.info));
      expect(LoggerBridge.convertLogLevel(-1), equals(OptimizelyLogLevel.info));
    });

    test("should reset state correctly", () {
      var testLogger = TestLogger();
      LoggerBridge.initialize(testLogger);
      
      expect(LoggerBridge.hasLogger(), isTrue);
      
      LoggerBridge.reset();
      
      expect(LoggerBridge.hasLogger(), isFalse);
      expect(LoggerBridge.getCurrentLogger(), isNull);
    });

    group("Error Handling", () {
      test("should handle null arguments gracefully", () async {
        var testLogger = TestLogger();
        LoggerBridge.initialize(testLogger);
        
        final methodCall = const MethodCall('log', null);
        await LoggerBridge.handleMethodCallForTesting(methodCall);
        
        expect(testLogger.logs.isEmpty, isTrue);
      });

      test("should handle empty arguments gracefully", () async {
        var testLogger = TestLogger();
        LoggerBridge.initialize(testLogger);
        
        final methodCall = const MethodCall('log', {});
        await LoggerBridge.handleMethodCallForTesting(methodCall);
        
        expect(testLogger.logs.isEmpty, isTrue);
      });

      test("should handle missing level argument", () async {
        var testLogger = TestLogger();
        LoggerBridge.initialize(testLogger);
        
        final methodCall = const MethodCall('log', {
          'message': 'Test message without level'
        });
        await LoggerBridge.handleMethodCallForTesting(methodCall);
        
        expect(testLogger.logs.isEmpty, isTrue);
      });

      test("should handle missing message argument", () async {
        var testLogger = TestLogger();
        LoggerBridge.initialize(testLogger);
        
        final methodCall = const MethodCall('log', {
          'level': 3
        });
        await LoggerBridge.handleMethodCallForTesting(methodCall);
        
        expect(testLogger.logs.isEmpty, isTrue);
      });

      test("should handle invalid level data types", () async {
        var testLogger = TestLogger();
        LoggerBridge.initialize(testLogger);
        
        // Test with string level
        var methodCall = const MethodCall('log', {
          'level': 'invalid',
          'message': 'Test message'
        });
        await LoggerBridge.handleMethodCallForTesting(methodCall);
        
        expect(testLogger.logs.isEmpty, isTrue);
        
        // Test with null level
        methodCall = const MethodCall('log', {
          'level': null,
          'message': 'Test message'
        });
        await LoggerBridge.handleMethodCallForTesting(methodCall);
        
        expect(testLogger.logs.isEmpty, isTrue);
        
        testLogger.clear();
      });

      test("should handle unknown method calls", () async {
        var testLogger = TestLogger();
        LoggerBridge.initialize(testLogger);
        
        final methodCall = const MethodCall('unknownMethod', {
          'level': 3,
          'message': 'Test message'
        });
        
        // Should not throw
        expect(() async {
          await LoggerBridge.handleMethodCallForTesting(methodCall);
        }, returnsNormally);
        
        expect(testLogger.logs.isEmpty, isTrue);
      });
    });

    group("Multiple Log Levels", () {
      test("should handle all log levels in sequence", () async {
        var testLogger = TestLogger();
        LoggerBridge.initialize(testLogger);
        
        final testCases = [
          {'level': 1, 'message': 'Error message', 'expected': OptimizelyLogLevel.error},
          {'level': 2, 'message': 'Warning message', 'expected': OptimizelyLogLevel.warning},
          {'level': 3, 'message': 'Info message', 'expected': OptimizelyLogLevel.info},
          {'level': 4, 'message': 'Debug message', 'expected': OptimizelyLogLevel.debug},
        ];
        
        for (var testCase in testCases) {
          final methodCall = MethodCall('log', {
            'level': testCase['level'],
            'message': testCase['message']
          });
          
          await LoggerBridge.handleMethodCallForTesting(methodCall);
        }
        
        expect(testLogger.logs.length, equals(4));
        
        for (int i = 0; i < testCases.length; i++) {
          expect(testLogger.logs[i].level, equals(testCases[i]['expected']));
          expect(testLogger.logs[i].message, equals(testCases[i]['message']));
        }
      });

      test("should handle mixed valid and invalid log levels", () async {
        var testLogger = TestLogger();
        LoggerBridge.initialize(testLogger);
        
        final testCases = [
          {'level': 1, 'message': 'Valid error', 'shouldLog': true},
          {'level': 'invalid', 'message': 'Invalid level', 'shouldLog': false},
          {'level': 3, 'message': 'Valid info', 'shouldLog': true},
          {'level': 999, 'message': 'Out of range level', 'shouldLog': true}, // Maps to info
          {'level': -1, 'message': 'Negative level', 'shouldLog': true}, // Maps to info
        ];
        
        for (var testCase in testCases) {
          final methodCall = MethodCall('log', {
            'level': testCase['level'],
            'message': testCase['message']
          });
          
          await LoggerBridge.handleMethodCallForTesting(methodCall);
        }
        
        // Should have 4 logs (all except the 'invalid' string level)
        expect(testLogger.logs.length, equals(4));
        expect(testLogger.logs[0].level, equals(OptimizelyLogLevel.error));
        expect(testLogger.logs[1].level, equals(OptimizelyLogLevel.info));
        expect(testLogger.logs[2].level, equals(OptimizelyLogLevel.info)); // 999 maps to info
        expect(testLogger.logs[3].level, equals(OptimizelyLogLevel.info)); // -1 maps to info
      });
    });

    group("DefaultOptimizelyLogger", () {
      test("should create default logger instance", () {
        var defaultLogger = DefaultOptimizelyLogger();
        expect(defaultLogger, isNotNull);
      });

      test("should handle logging without throwing", () {
        var defaultLogger = DefaultOptimizelyLogger();
        
        expect(() {
          defaultLogger.log(OptimizelyLogLevel.error, "Error message");
          defaultLogger.log(OptimizelyLogLevel.warning, "Warning message");
          defaultLogger.log(OptimizelyLogLevel.info, "Info message");
          defaultLogger.log(OptimizelyLogLevel.debug, "Debug message");
        }, returnsNormally);
      });
    });
    group("Global Logging Functions", () {
      test("should call global logging functions without error", () {
        expect(() {
          logError("Global error message");
          logWarning("Global warning message");  
          logInfo("Global info message");
          logDebug("Global debug message");
        }, returnsNormally);
      });

      test("should handle empty messages in global functions", () {
        expect(() {
          logError("");
          logWarning("");
          logInfo("");
          logDebug("");
        }, returnsNormally);
      });

      test("should handle special characters in global functions", () {
        var specialMessage = "Special: 🚀 \n\t 世界";
        
        expect(() {
          logError(specialMessage);
          logWarning(specialMessage);
          logInfo(specialMessage);
          logDebug(specialMessage);
        }, returnsNormally);
      });

      test("should handle rapid calls to global functions", () {
        expect(() {
          for (int i = 0; i < 25; i++) {
            logError("Rapid error $i");
            logWarning("Rapid warning $i");
            logInfo("Rapid info $i");
            logDebug("Rapid debug $i");
          }
        }, returnsNormally);
      });
    });
    group("Concurrent Access", () {
      test("should handle multiple concurrent log calls", () async {
        var testLogger = TestLogger();
        LoggerBridge.initialize(testLogger);
        
        // Create multiple concurrent log calls
        var futures = <Future>[];
        for (int i = 0; i < 25; i++) {
          futures.add(LoggerBridge.handleMethodCallForTesting(
            MethodCall('log', {
              'level': (i % 4) + 1, // Cycle through levels 1-4
              'message': 'Concurrent message $i'
            })
          ));
        }
        
        await Future.wait(futures);
        
        expect(testLogger.logs.length, equals(25));
        
        // Verify all messages are present
        for (int i = 0; i < 25; i++) {
          expect(testLogger.logs.any((log) => log.message == 'Concurrent message $i'), isTrue);
        }
      });

      test("should handle logger reinitialization during concurrent access", () async {
        var testLogger1 = TestLogger();
        var testLogger2 = TestLogger();
        
        LoggerBridge.initialize(testLogger1);
        
        // Start some async operations
        var futures = <Future>[];
        for (int i = 0; i < 5; i++) {
          futures.add(LoggerBridge.handleMethodCallForTesting(
            MethodCall('log', {
              'level': 3,
              'message': 'Message before reinit $i'
            })
          ));
        }
        
        // Reinitialize with a different logger mid-flight
        LoggerBridge.initialize(testLogger2);
        
        // Add more operations
        for (int i = 0; i < 5; i++) {
          futures.add(LoggerBridge.handleMethodCallForTesting(
            MethodCall('log', {
              'level': 3,
              'message': 'Message after reinit $i'
            })
          ));
        }
        
        await Future.wait(futures);
        
        // The total logs should be distributed between the two loggers
        var totalLogs = testLogger1.logs.length + testLogger2.logs.length;
        expect(totalLogs, equals(10));
        expect(LoggerBridge.getCurrentLogger(), equals(testLogger2));
      });
    });

    group("Performance", () {
      test("should handle high volume of logs efficiently", () async {
        var testLogger = TestLogger();
        LoggerBridge.initialize(testLogger);
        
        var stopwatch = Stopwatch()..start();
        
        // Send 100 log messages
        for (int i = 0; i < 100; i++) {
          await LoggerBridge.handleMethodCallForTesting(
            MethodCall('log', {
              'level': (i % 4) + 1,
              'message': 'Performance test log $i'
            })
          );
        }
        
        stopwatch.stop();
        
        expect(testLogger.logs.length, equals(100));
        expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // Should complete in < 2 seconds
        
        // Verify first and last messages
        expect(testLogger.logs.first.message, equals('Performance test log 0'));
        expect(testLogger.logs.last.message, equals('Performance test log 99'));
      });

      test("should handle large message content efficiently", () async {
        var testLogger = TestLogger();
        LoggerBridge.initialize(testLogger);
        
        // Create a large message (10KB)
        var largeMessage = 'X' * 10240;
        
        var stopwatch = Stopwatch()..start();
        
        await LoggerBridge.handleMethodCallForTesting(
          MethodCall('log', {
            'level': 3,
            'message': largeMessage
          })
        );
        
        stopwatch.stop();
        
        expect(testLogger.logs.length, equals(1));
        expect(testLogger.logs.first.message.length, equals(10240));
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be very fast
      });
    });

    group("State Management", () {
      test("should maintain state across multiple operations", () async {
        var testLogger = TestLogger();
        LoggerBridge.initialize(testLogger);
        
        // Perform various operations
        await LoggerBridge.handleMethodCallForTesting(
          const MethodCall('log', {'level': 1, 'message': 'First message'})
        );
        
        expect(LoggerBridge.hasLogger(), isTrue);
        expect(testLogger.logs.length, equals(1));
        
        await LoggerBridge.handleMethodCallForTesting(
          const MethodCall('log', {'level': 2, 'message': 'Second message'})
        );
        
        expect(LoggerBridge.hasLogger(), isTrue);
        expect(testLogger.logs.length, equals(2));
        
        LoggerBridge.reset();
        
        expect(LoggerBridge.hasLogger(), isFalse);
        expect(testLogger.logs.length, equals(2)); // Logger keeps its own state
      });

      test("should handle logger replacement", () async {
        var testLogger1 = TestLogger();
        var testLogger2 = TestLogger();
        
        // Initialize with first logger
        LoggerBridge.initialize(testLogger1);
        await LoggerBridge.handleMethodCallForTesting(
          const MethodCall('log', {'level': 3, 'message': 'Message to logger 1'})
        );
        
        expect(testLogger1.logs.length, equals(1));
        expect(testLogger2.logs.length, equals(0));
        
        // Replace with second logger
        LoggerBridge.initialize(testLogger2);
        await LoggerBridge.handleMethodCallForTesting(
          const MethodCall('log', {'level': 3, 'message': 'Message to logger 2'})
        );
        
        expect(testLogger1.logs.length, equals(1)); // Unchanged
        expect(testLogger2.logs.length, equals(1)); // New message
        expect(LoggerBridge.getCurrentLogger(), equals(testLogger2));
      });
    });

    group("Edge Cases", () {
      test("should handle empty message", () async {
        var testLogger = TestLogger();
        LoggerBridge.initialize(testLogger);
        
        await LoggerBridge.handleMethodCallForTesting(
          const MethodCall('log', {
            'level': 3,
            'message': ''
          })
        );
        
        expect(testLogger.logs.length, equals(1));
        expect(testLogger.logs.first.message, equals(''));
        expect(testLogger.logs.first.level, equals(OptimizelyLogLevel.info));
      });

      test("should handle special characters in message", () async {
        var testLogger = TestLogger();
        LoggerBridge.initialize(testLogger);
        
        var specialMessage = 'Special chars: 🚀 ñáéíóú 中文 \n\t\r\\';
        
        await LoggerBridge.handleMethodCallForTesting(
          MethodCall('log', {
            'level': 3,
            'message': specialMessage
          })
        );
        
        expect(testLogger.logs.length, equals(1));
        expect(testLogger.logs.first.message, equals(specialMessage));
      });

      test("should handle invalid data types gracefully", () async {
        var testLogger = TestLogger();
        LoggerBridge.initialize(testLogger);
        
        // Test with double level - should fail gracefully
        await LoggerBridge.handleMethodCallForTesting(
          const MethodCall('log', {
            'level': 3.0, // Double instead of int
            'message': 'Message with double level'
          })
        );
        
        // Should not log anything due to type casting error
        expect(testLogger.logs.length, equals(0));
      });      
    });
  });
}
