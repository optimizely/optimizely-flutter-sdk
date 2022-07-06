import 'dart:convert';
import 'dart:io';

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
          return {'mockBdd': 'valueNeeded'};
        case 'getOptimizelyConfig':
          final file = new File('test_resources/mockOptimizelyConfig.json');
          final json = jsonDecode(await file.readAsString());
          return json;
        case 'createUserContext':
          return {'mockBdd': 'valueNeeded'};
        case 'set_attributes':
          return {'mockBdd': 'valueNeeded'};
        case 'track_event':
          return {'mockBdd': 'valueNeeded'};
        case 'decide':
          return {'mockBdd': 'valueNeeded'};
        case 'addListener':
          return {'mockBdd': 'valueNeeded'};
        case 'addListener':
          return {'mockBdd': 'valueNeeded'};
        case 'removeListener':
          return {'mockBdd': 'valueNeeded'};
        default:
          return null;
      }
    });
  });

  tearDown(() {
    //tester?.setMockMethodCallHandler(channel, null);
  });

  group('Mocked OptimizelyFlutterSdk', () {
    group('constructor', () {
      test('with empty string SDK Key should instantiate successfully',
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
    group('getOptimizelyConfig()', () {
      test('returns valid digested OptimizelyConfig should succeed', () async {
        var sdk = new OptimizelyFlutterSdk(testSDKKey);

        var config = await sdk.getOptimizelyConfig();

        expect(config['sdkKey'], equals(testSDKKey));
        expect(config['environmentKey'], equals('production'));
        expect(config['attributes'].length, equals(1));
        expect(config['events'].length, equals(1));
        expect(config['revision'], equals('130'));
        expect(config['experimentsMap'], isNotNull);
        expect(config['featuresMap'], isNotNull);
        expect(config['datafile'], isNotNull);
      });
    });
    group('createUserContext()', () {
      test('___ should succeed', () async {
        // arrange

        // act

        // assert
      });
    });
    group('setAttributes()', () {
      test('___ should succeed', () async {
        // arrange

        // act

        // assert
      });
    });
    group('trackEvent()', () {
      test('___ should succeed', () async {
        // arrange

        // act

        // assert
      });
    });
    group('decide()', () {
      test('___ should succeed', () async {
        // arrange

        // act

        // assert
      });
    });
    group('decideForKeys()', () {
      test('___ should succeed', () async {
        // arrange

        // act

        // assert
      });
    });
    group('decideAll()', () {
      test('___ should succeed', () async {
        // arrange

        // act

        // assert
      });
    });
    group('addNotificationListener()', () {
      test('___ should succeed', () async {
        // arrange

        // act

        // assert
      });
    });
  });
}
