/// **************************************************************************
/// Copyright 2022-2023, Optimizely, Inc. and contributors                   *
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

import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart";
import 'package:optimizely_flutter_sdk/src/optimizely_client_wrapper.dart';
import 'package:optimizely_flutter_sdk/src/utils/constants.dart';
import 'package:optimizely_flutter_sdk/src/utils/utils.dart';
import 'test_utils.dart';

void main() {
  const String testSDKKey = "KZbunNn9bVfBWLpZPq2XC4";
  const String userId = "uid-351ea8";
  const String flagKey = "flag_1";
  const String userContextId = "123";
  const Map<String, dynamic> attributes = {"abc": 123};

  const MethodChannel channel = MethodChannel("optimizely_flutter_sdk");
  TestDefaultBinaryMessenger? tester;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    OptimizelyClientWrapper.decisionCallbacksById = {};
    OptimizelyClientWrapper.trackCallbacksById = {};
    OptimizelyClientWrapper.configUpdateCallbacksById = {};
    OptimizelyClientWrapper.logEventCallbacksById = {};
    OptimizelyClientWrapper.nextCallbackId = 0;
    tester = TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger;
  });

  tearDown(() {
    tester?.setMockMethodCallHandler(channel, null);
  });

  group('CmabConfig', () {
    test('creates CmabConfig with default values', () {
      const config = CmabConfig();

      expect(config.cacheSize, equals(100));
      expect(config.cacheTimeoutInSecs, equals(1800));
      expect(config.predictionEndpoint, isNull);
    });

    test('creates CmabConfig with custom values', () {
      const config = CmabConfig(
        cacheSize: 200,
        cacheTimeoutInSecs: 3600,
        predictionEndpoint: "https://custom-endpoint.com/predict/{ruleId}",
      );

      expect(config.cacheSize, equals(200));
      expect(config.cacheTimeoutInSecs, equals(3600));
      expect(config.predictionEndpoint, equals("https://custom-endpoint.com/predict/{ruleId}"));
    });

    test('creates CmabConfig with null predictionEndpoint', () {
      const config = CmabConfig(
        cacheSize: 150,
        cacheTimeoutInSecs: 2400,
      );

      expect(config.cacheSize, equals(150));
      expect(config.cacheTimeoutInSecs, equals(2400));
      expect(config.predictionEndpoint, isNull);
    });

    test('CmabConfig with same values are equal', () {
      const config1 = CmabConfig(cacheSize: 100, cacheTimeoutInSecs: 1800);
      const config2 = CmabConfig(cacheSize: 100, cacheTimeoutInSecs: 1800);

      expect(config1.cacheSize, equals(config2.cacheSize));
      expect(config1.cacheTimeoutInSecs, equals(config2.cacheTimeoutInSecs));
      expect(config1.predictionEndpoint, equals(config2.predictionEndpoint));
    });
  });

  group('OptimizelyFlutterSdk initialization with CmabConfig', () {
    test('initializes SDK with default CmabConfig', () async {
      Map<String, dynamic>? receivedCmabConfig;
      const defaultConfig = CmabConfig();

      tester?.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == Constants.initializeMethod) {
          var cmabArg = methodCall.arguments[Constants.cmabConfig];
          if (cmabArg != null) {
            receivedCmabConfig = Map<String, dynamic>.from(cmabArg as Map);
          }
          return {Constants.responseSuccess: true};
        }
        return null;
      });

      var sdk = OptimizelyFlutterSdk(testSDKKey, cmabConfig: defaultConfig);
      await sdk.initializeClient();

      expect(receivedCmabConfig, isNotNull);
      expect(receivedCmabConfig![Constants.cmabCacheSize], equals(100));
      expect(receivedCmabConfig![Constants.cmabCacheTimeoutInSecs], equals(1800));
      expect(receivedCmabConfig!.containsKey(Constants.cmabPredictionEndpoint), isFalse);
    });

    test('initializes SDK with custom CmabConfig', () async {
      Map<String, dynamic>? receivedCmabConfig;
      const customConfig = CmabConfig(
        cacheSize: 250,
        cacheTimeoutInSecs: 3000,
        predictionEndpoint: "https://test.com/predict/{ruleId}",
      );

      tester?.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == Constants.initializeMethod) {
          var cmabArg = methodCall.arguments[Constants.cmabConfig];
          if (cmabArg != null) {
            receivedCmabConfig = Map<String, dynamic>.from(cmabArg as Map);
          }
          return {Constants.responseSuccess: true};
        }
        return null;
      });

      var sdk = OptimizelyFlutterSdk(testSDKKey, cmabConfig: customConfig);
      await sdk.initializeClient();

      expect(receivedCmabConfig, isNotNull);
      expect(receivedCmabConfig![Constants.cmabCacheSize], equals(250));
      expect(receivedCmabConfig![Constants.cmabCacheTimeoutInSecs], equals(3000));
      expect(receivedCmabConfig![Constants.cmabPredictionEndpoint], equals("https://test.com/predict/{ruleId}"));
    });

    test('initializes SDK with CmabConfig without predictionEndpoint', () async {
      Map<String, dynamic>? receivedCmabConfig;
      const customConfig = CmabConfig(
        cacheSize: 300,
        cacheTimeoutInSecs: 2500,
      );

      tester?.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == Constants.initializeMethod) {
          var cmabArg = methodCall.arguments[Constants.cmabConfig];
          if (cmabArg != null) {
            receivedCmabConfig = Map<String, dynamic>.from(cmabArg as Map);
          }
          return {Constants.responseSuccess: true};
        }
        return null;
      });

      var sdk = OptimizelyFlutterSdk(testSDKKey, cmabConfig: customConfig);
      await sdk.initializeClient();

      expect(receivedCmabConfig, isNotNull);
      expect(receivedCmabConfig![Constants.cmabCacheSize], equals(300));
      expect(receivedCmabConfig![Constants.cmabCacheTimeoutInSecs], equals(2500));
      expect(receivedCmabConfig!.containsKey(Constants.cmabPredictionEndpoint), isFalse);
    });

    test('CmabConfig is serialized correctly in initialization', () async {
      Map<String, dynamic>? receivedCmabConfig;
      const customConfig = CmabConfig(
        cacheSize: 500,
        cacheTimeoutInSecs: 4000,
        predictionEndpoint: "https://production.com/ml/{ruleId}",
      );

      tester?.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == Constants.initializeMethod) {
          expect(methodCall.arguments[Constants.sdkKey], equals(testSDKKey));
          var cmabArg = methodCall.arguments[Constants.cmabConfig];
          if (cmabArg != null) {
            receivedCmabConfig = Map<String, dynamic>.from(cmabArg as Map);
          }
          return {Constants.responseSuccess: true};
        }
        return null;
      });

      var sdk = OptimizelyFlutterSdk(testSDKKey, cmabConfig: customConfig);
      await sdk.initializeClient();

      expect(receivedCmabConfig, isNotNull);
      expect(receivedCmabConfig, isA<Map<String, dynamic>>());
      expect(receivedCmabConfig!.keys.length, equals(3));
    });

    test('multiple SDKs can have different CmabConfigs', () async {
      const config1 = CmabConfig(cacheSize: 100);
      const config2 = CmabConfig(cacheSize: 200);

      var sdk1 = OptimizelyFlutterSdk(testSDKKey, cmabConfig: config1);
      var sdk2 = OptimizelyFlutterSdk("different_key", cmabConfig: config2);

      expect(sdk1, isNotNull);
      expect(sdk2, isNotNull);
    });

  group('decideAsync methods', () {
    test('decideAsync single flag sends correct method call', () async {
      List<String>? receivedKeys;
      List<String>? receivedOptions;

      tester?.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == Constants.initializeMethod) {
          return {Constants.responseSuccess: true};
        }
        if (methodCall.method == Constants.createUserContextMethod) {
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {Constants.userContextId: userContextId},
          };
        }
        if (methodCall.method == Constants.decideAsyncMethod) {
          receivedKeys = List<String>.from(methodCall.arguments[Constants.keys]);
          receivedOptions = List<String>.from(methodCall.arguments[Constants.optimizelyDecideOption]);
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {flagKey: TestUtils.decideResponseMap},
          };
        }
        return null;
      });

      var sdk = OptimizelyFlutterSdk(testSDKKey);
      await sdk.initializeClient();
      var userContext = await sdk.createUserContext(userId: userId, attributes: attributes);

      await userContext!.decideAsync(flagKey);

      expect(receivedKeys, equals([flagKey]));
      expect(receivedOptions, isNotNull);
    });

    test('decideAsync returns correct DecideResponse', () async {
      tester?.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == Constants.initializeMethod) {
          return {Constants.responseSuccess: true};
        }
        if (methodCall.method == Constants.createUserContextMethod) {
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {Constants.userContextId: userContextId},
          };
        }
        if (methodCall.method == Constants.decideAsyncMethod) {
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {flagKey: TestUtils.decideResponseMap},
          };
        }
        return null;
      });

      var sdk = OptimizelyFlutterSdk(testSDKKey);
      await sdk.initializeClient();
      var userContext = await sdk.createUserContext(userId: userId, attributes: attributes);

      var response = await userContext!.decideAsync(flagKey);

      expect(response.success, isTrue);
      expect(response.decision, isNotNull);
      expect(response.decision!.flagKey, equals("feature_1")); // From TestUtils.decideResponseMap
      expect(response.decision!.variationKey, isNotNull);
      expect(response.decision!.enabled, isTrue);
    });

    test('decideForKeysAsync sends multiple keys', () async {
      List<String>? receivedKeys;
      const keys = ["flag_1", "flag_2", "flag_3"];

      tester?.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == Constants.initializeMethod) {
          return {Constants.responseSuccess: true};
        }
        if (methodCall.method == Constants.createUserContextMethod) {
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {Constants.userContextId: userContextId},
          };
        }
        if (methodCall.method == Constants.decideAsyncMethod) {
          receivedKeys = List<String>.from(methodCall.arguments[Constants.keys]);
          Map<String, dynamic> results = {};
          for (var key in keys) {
            results[key] = TestUtils.decideResponseMap;
          }
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: results,
          };
        }
        return null;
      });

      var sdk = OptimizelyFlutterSdk(testSDKKey);
      await sdk.initializeClient();
      var userContext = await sdk.createUserContext(userId: userId, attributes: attributes);

      await userContext!.decideForKeysAsync(keys);

      expect(receivedKeys, equals(keys));
    });

    test('decideAllAsync sends empty keys array', () async {
      List<String>? receivedKeys;

      tester?.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == Constants.initializeMethod) {
          return {Constants.responseSuccess: true};
        }
        if (methodCall.method == Constants.createUserContextMethod) {
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {Constants.userContextId: userContextId},
          };
        }
        if (methodCall.method == Constants.decideAsyncMethod) {
          receivedKeys = List<String>.from(methodCall.arguments[Constants.keys]);
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {
              "flag_1": TestUtils.decideResponseMap,
              "flag_2": TestUtils.decideResponseMap,
            },
          };
        }
        return null;
      });

      var sdk = OptimizelyFlutterSdk(testSDKKey);
      await sdk.initializeClient();
      var userContext = await sdk.createUserContext(userId: userId, attributes: attributes);

      await userContext!.decideAllAsync();

      expect(receivedKeys, equals([]));
    });

    test('decideAsync methods accept OptimizelyDecideOption', () async {
      List<String>? receivedOptions;
      const options = {OptimizelyDecideOption.includeReasons};

      tester?.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == Constants.initializeMethod) {
          return {Constants.responseSuccess: true};
        }
        if (methodCall.method == Constants.createUserContextMethod) {
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {Constants.userContextId: userContextId},
          };
        }
        if (methodCall.method == Constants.decideAsyncMethod) {
          receivedOptions = List<String>.from(methodCall.arguments[Constants.optimizelyDecideOption]);
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {flagKey: TestUtils.decideResponseMap},
          };
        }
        return null;
      });

      var sdk = OptimizelyFlutterSdk(testSDKKey);
      await sdk.initializeClient();
      var userContext = await sdk.createUserContext(userId: userId, attributes: attributes);

      await userContext!.decideAsync(flagKey, options);

      expect(receivedOptions, contains(OptimizelyDecideOption.includeReasons.name));
    });

    test('decideAllAsync returns DecideForKeysResponse', () async {
      tester?.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == Constants.initializeMethod) {
          return {Constants.responseSuccess: true};
        }
        if (methodCall.method == Constants.createUserContextMethod) {
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {Constants.userContextId: userContextId},
          };
        }
        if (methodCall.method == Constants.decideAsyncMethod) {
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {
              "flag_1": TestUtils.decideResponseMap,
              "flag_2": TestUtils.decideResponseMap,
              "flag_3": TestUtils.decideResponseMap,
            },
          };
        }
        return null;
      });

      var sdk = OptimizelyFlutterSdk(testSDKKey);
      await sdk.initializeClient();
      var userContext = await sdk.createUserContext(userId: userId, attributes: attributes);

      var response = await userContext!.decideAllAsync();

      expect(response.success, isTrue);
      expect(response.decisions.length, equals(3));
    });
  });

  group('CMAB DecideOptions', () {
    test('ignoreCmabCache option is converted correctly', () {
      final options = {OptimizelyDecideOption.ignoreCmabCache};
      final converted = Utils.convertDecideOptions(options);

      expect(converted, contains(OptimizelyDecideOption.ignoreCmabCache.name));
    });

    test('resetCmabCache option is converted correctly', () {
      final options = {OptimizelyDecideOption.resetCmabCache};
      final converted = Utils.convertDecideOptions(options);

      expect(converted, contains(OptimizelyDecideOption.resetCmabCache.name));
    });

    test('invalidateUserCmabCache option is converted correctly', () {
      final options = {OptimizelyDecideOption.invalidateUserCmabCache};
      final converted = Utils.convertDecideOptions(options);

      expect(converted, contains(OptimizelyDecideOption.invalidateUserCmabCache.name));
    });

    test('multiple CMAB options are converted correctly', () {
      final options = {
        OptimizelyDecideOption.ignoreCmabCache,
        OptimizelyDecideOption.resetCmabCache,
        OptimizelyDecideOption.includeReasons,
      };
      final converted = Utils.convertDecideOptions(options);

      expect(converted.length, equals(3));
      expect(converted, contains(OptimizelyDecideOption.ignoreCmabCache.name));
      expect(converted, contains(OptimizelyDecideOption.resetCmabCache.name));
      expect(converted, contains(OptimizelyDecideOption.includeReasons.name));
    });

    test('CMAB options work with standard options', () {
      final options = {
        OptimizelyDecideOption.ignoreCmabCache,
        OptimizelyDecideOption.disableDecisionEvent,
        OptimizelyDecideOption.excludeVariables,
      };
      final converted = Utils.convertDecideOptions(options);

      expect(converted.length, equals(3));
      expect(converted, contains(OptimizelyDecideOption.ignoreCmabCache.name));
      expect(converted, contains(OptimizelyDecideOption.disableDecisionEvent.name));
      expect(converted, contains(OptimizelyDecideOption.excludeVariables.name));
    });

    test('all three CMAB cache options can be used together', () {
      final options = {
        OptimizelyDecideOption.ignoreCmabCache,
        OptimizelyDecideOption.resetCmabCache,
        OptimizelyDecideOption.invalidateUserCmabCache,
      };
      final converted = Utils.convertDecideOptions(options);

      expect(converted.length, equals(3));
      expect(converted, contains(OptimizelyDecideOption.ignoreCmabCache.name));
      expect(converted, contains(OptimizelyDecideOption.resetCmabCache.name));
      expect(converted, contains(OptimizelyDecideOption.invalidateUserCmabCache.name));
    });
  });

  group('CMAB Constants', () {
    test('CMAB constants are defined correctly', () {
      expect(Constants.cmabConfig, equals("cmabConfig"));
      expect(Constants.cmabCacheSize, equals("cmabCacheSize"));
      expect(Constants.cmabCacheTimeoutInSecs, equals("cmabCacheTimeoutInSecs"));
      expect(Constants.cmabPredictionEndpoint, equals("cmabPredictionEndpoint"));
      expect(Constants.decideAsyncMethod, equals("decideAsync"));
    });
  });
}