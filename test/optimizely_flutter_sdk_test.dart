import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';

void main() {
  const String testSDKKey = "KZbunNn9bVfBWLpZPq2XC4";
  const MethodChannel channel = MethodChannel('optimizely_flutter_sdk');

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    var tester =
        TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger;

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
    //tester?.setMockMethodCallHandler(channel, null);
  });

  group('Mocked Flutter SDK', () {
    group('OptimizelyFlutterSdk constructor', () {
      test('with empty string SDK Key should instantiates successfully',
          () async {
        const String emptyStringSdkKey = '';
        var sdk = new OptimizelyFlutterSdk(emptyStringSdkKey);

        expect(sdk.runtimeType == OptimizelyFlutterSdk, isTrue);
      });
    });
    group('initializeClient()', () {
      test('with valid SDK Key should succeed', () async {
        var sdk = new OptimizelyFlutterSdk(testSDKKey);

        var client = await sdk.initializeClient();

        expect(client, isNotNull);
      });
    });
  });
}
