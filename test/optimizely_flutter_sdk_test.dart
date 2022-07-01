import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';

void main() {
  const String testSDKKey = "KZbunNn9bVfBWLpZPq2XC4";
  // const MethodChannel channel = MethodChannel('optimizely_flutter_sdk');

  // setUpAll(() async {
  //   TestWidgetsFlutterBinding.ensureInitialized();

  //   channel.setMockMethodCallHandler((MethodCall methodCall) async {
  //     log.add(methodCall);
  //     switch (methodCall.method) {
  //       case 'start':
  //         isRecording = true;
  //         return null;
  //       case 'stop':
  //         isRecording = false;
  //         return {
  //           'duration': duration,
  //           'path': path,
  //           'audioOutputFormat': extension,
  //         };
  //       case 'isRecording':
  //         return isRecording;
  //       case 'hasPermissions':
  //         return true;
  //       default:
  //         return null;
  //     }
  //   });
  // });

  tearDown(() {
    // channel.setMockMethodCallHandler(null);
  });

  group('Flutter SDK', () {
    test('should initialize Optimizely client successfully', () async {
      // Arrange
      var sdk = new OptimizelyFlutterSdk(testSDKKey);

      // Act
      var client = sdk.initializeClient();

      // Assert
      expect(client, isNotNull);
    });
  });
}
