/// **************************************************************************
/// Copyright 2024, Optimizely, Inc. and contributors                        *
///                                                                          *
/// Licensed under the Apache License, Version 2.0 (the "License");          *
/// you may not use this file except in compliance with the License.         *
/// You may obtain a copy of the License at                                  *
///                                                                          *
///    http://www.apache.org/licenses/LICENSE-2.0                            *
///                                                                          *
/// Unless required by applicable law or agreed to in writing, software      *
/// distributed under the License is distributed on an "AS IS" BASIS,        *
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
/// See the License for the specific language governing permissions and      *
/// limitations under the License.                                           *
///**************************************************************************/

// Unit tests for the _invoke() safety wrapper in OptimizelyClientWrapper and
// OptimizelyUserContext.
//
// These tests cover the two error branches that the existing test suite does
// not exercise:
//   1. Native channel returns null  → result has success:false, no TypeError
//   2. Native channel throws PlatformException → result has success:false, no throw
//
// These branches are the core of the iOS 16 threading fix: they prevent
// Map<String, dynamic>.from(null) TypeErrors and unhandled PlatformExceptions
// from surfacing to callers.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';
import 'package:optimizely_flutter_sdk/src/utils/constants.dart';

void main() {
  const channel = MethodChannel('optimizely_flutter_sdk');
  const sdkKey = 'test-sdk-key';

  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessenger? tester;

  setUp(() {
    tester = TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger;
  });

  group('OptimizelyClientWrapper._invoke — null return safety', () {
    setUp(() {
      tester?.setMockMethodCallHandler(channel, (_) async => null);
    });

    tearDown(() {
      tester?.setMockMethodCallHandler(channel, null);
    });

    test('initializeClient returns success:false instead of TypeError', () async {
      final sdk = OptimizelyFlutterSdk(sdkKey);
      final result = await sdk.initializeClient();
      expect(result.success, isFalse);
    });

    test('getOptimizelyConfig returns success:false instead of TypeError',
        () async {
      final sdk = OptimizelyFlutterSdk(sdkKey);
      final result = await sdk.getOptimizelyConfig();
      expect(result.success, isFalse);
    });

    test('getVuid returns success:false instead of TypeError', () async {
      final sdk = OptimizelyFlutterSdk(sdkKey);
      final result = await sdk.getVuid();
      expect(result.success, isFalse);
    });

    test('sendOdpEvent returns success:false instead of TypeError', () async {
      final sdk = OptimizelyFlutterSdk(sdkKey);
      final result = await sdk.sendOdpEvent('test-action');
      expect(result.success, isFalse);
    });

    test('close returns success:false instead of TypeError', () async {
      final sdk = OptimizelyFlutterSdk(sdkKey);
      final result = await sdk.close();
      expect(result.success, isFalse);
    });
  });

  group('OptimizelyClientWrapper._invoke — PlatformException safety', () {
    setUp(() {
      tester?.setMockMethodCallHandler(channel, (_) async {
        throw PlatformException(code: 'ERROR', message: 'native error');
      });
    });

    tearDown(() {
      tester?.setMockMethodCallHandler(channel, null);
    });

    test('initializeClient returns success:false with reason', () async {
      final sdk = OptimizelyFlutterSdk(sdkKey);
      final result = await sdk.initializeClient();
      expect(result.success, isFalse);
      expect(result.reason, isNotEmpty);
    });

    test('getOptimizelyConfig returns success:false with reason', () async {
      final sdk = OptimizelyFlutterSdk(sdkKey);
      final result = await sdk.getOptimizelyConfig();
      expect(result.success, isFalse);
      expect(result.reason, isNotEmpty);
    });

    test('sendOdpEvent returns success:false with reason', () async {
      final sdk = OptimizelyFlutterSdk(sdkKey);
      final result = await sdk.sendOdpEvent('test-action');
      expect(result.success, isFalse);
      expect(result.reason, isNotEmpty);
    });
  });

  group('OptimizelyUserContext._invoke — null return safety', () {
    late OptimizelyUserContext? userContext;

    setUp(() async {
      // First call (createUserContext) returns a valid user context id.
      bool firstCall = true;
      tester?.setMockMethodCallHandler(channel, (_) async {
        if (firstCall) {
          firstCall = false;
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {Constants.userContextId: 'uc-1'},
          };
        }
        return null; // subsequent calls return null
      });

      final sdk = OptimizelyFlutterSdk(sdkKey);
      userContext = await sdk.createUserContext(userId: 'user-1');
    });

    tearDown(() {
      tester?.setMockMethodCallHandler(channel, null);
    });

    test('getUserId returns success:false instead of TypeError', () async {
      expect(userContext, isNotNull);
      final result = await userContext!.getUserId();
      expect(result.success, isFalse);
    });

    test('getAttributes returns success:false instead of TypeError', () async {
      expect(userContext, isNotNull);
      final result = await userContext!.getAttributes();
      expect(result.success, isFalse);
    });

    test('setAttributes returns success:false instead of TypeError', () async {
      expect(userContext, isNotNull);
      final result = await userContext!.setAttributes({'key': 'value'});
      expect(result.success, isFalse);
    });

    test('decide returns success:false instead of TypeError', () async {
      expect(userContext, isNotNull);
      final result = await userContext!.decide('flag-key');
      expect(result.success, isFalse);
    });

    test('decideAll returns success:false instead of TypeError', () async {
      expect(userContext, isNotNull);
      final result = await userContext!.decideAll();
      expect(result.success, isFalse);
    });

    test('trackEvent returns success:false instead of TypeError', () async {
      expect(userContext, isNotNull);
      final result = await userContext!.trackEvent('event-key');
      expect(result.success, isFalse);
    });
  });

  group('OptimizelyUserContext._invoke — PlatformException safety', () {
    late OptimizelyUserContext? userContext;

    setUp(() async {
      bool firstCall = true;
      tester?.setMockMethodCallHandler(channel, (_) async {
        if (firstCall) {
          firstCall = false;
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {Constants.userContextId: 'uc-2'},
          };
        }
        throw PlatformException(code: 'ERROR', message: 'native error');
      });

      final sdk = OptimizelyFlutterSdk(sdkKey);
      userContext = await sdk.createUserContext(userId: 'user-2');
    });

    tearDown(() {
      tester?.setMockMethodCallHandler(channel, null);
    });

    test('getUserId returns success:false with reason', () async {
      expect(userContext, isNotNull);
      final result = await userContext!.getUserId();
      expect(result.success, isFalse);
      expect(result.reason, isNotEmpty);
    });

    test('decide returns success:false with reason', () async {
      expect(userContext, isNotNull);
      final result = await userContext!.decide('flag-key');
      expect(result.success, isFalse);
      expect(result.reason, isNotEmpty);
    });

    test('trackEvent returns success:false with reason', () async {
      expect(userContext, isNotNull);
      final result = await userContext!.trackEvent('event-key');
      expect(result.success, isFalse);
      expect(result.reason, isNotEmpty);
    });
  });
}
