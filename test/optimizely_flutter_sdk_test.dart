import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';

void main() {
  const String testSDKKey = "KZbunNn9bVfBWLpZPq2XC4";
  const MethodChannel channel = MethodChannel('optimizely_flutter_sdk');
  TestDefaultBinaryMessenger? tester;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    tester = TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger;

    tester?.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      // log.add(methodCall);
      switch (methodCall.method) {
        case 'initialize':
          return {'initialized': true, 'mockBdd': 'needed'};
        //   case 'start':
        //     isRecording = true;
        //     return null;
        //   case 'stop':
        //     isRecording = false;
        //     return {
        //       'duration': duration,
        //       'path': path,
        //       'audioOutputFormat': extension,
        //     };
        //   case 'isRecording':
        //     return isRecording;
        //   case 'hasPermissions':
        //     return true;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    tester?.setMockMethodCallHandler(channel, null);
  });

  group('Flutter SDK', () {
    test('should initialize Optimizely client successfully', () async {
      // Arrange
      var sdk = new OptimizelyFlutterSdk(testSDKKey);

      // Act
      var client = await sdk.initializeClient();

      // Assert
      expect(client, isNotNull);
    });
  });
}
