import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';

void main() {
  // const String testSDKKey = "KZbunNn9bVfBWLpZPq2XC4";
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

  group('API Tests', () {
    // test('test initialization', () async {
    //   final response = Map<String, dynamic>.from(await channel
    //       .invokeMockMethod('initialize', {'sdk_key': testSDKKey}));
    //   expect(response["success"], "true");
    // });
  });
}
