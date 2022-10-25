/// **************************************************************************
/// Copyright 2022, Optimizely, Inc. and contributors                        *
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

import 'package:flutter/foundation.dart';
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart";
import 'package:optimizely_flutter_sdk/src/optimizely_client_wrapper.dart';
import 'package:optimizely_flutter_sdk/src/utils/constants.dart';
import 'package:optimizely_flutter_sdk/src/utils/utils.dart';
import 'dart:io';
import 'dart:convert';

import 'test_utils.dart';

void main() {
  const String testSDKKey = "KZbunNn9bVfBWLpZPq2XC4";
  const String testSDKKey2 = "KZbunNn9bVfBWLpZPq2XC12";
  const String userId = "uid-351ea8";
  const String experimentKey = "exp_1";
  const String flagKey = "flag_1";
  const String ruleKey = "rule_1";
  const String variationKey = "var_1";
  const String eventKey = "event-key";
  const Map<String, dynamic> attributes = {"abc": 123};
  const Map<String, dynamic> attributes1 = {"abc": 1234};
  const Map<String, dynamic> eventTags = {"abcd": 1234};
  const String userContextId = "123";
  // To check if decide options properly reached the native sdk through channel
  List<String> decideOptions = [];
  // To check if event options and datafileOptions reached the native sdk through channel
  EventOptions eventOptions = const EventOptions();
  DatafileHostOptions datafileHostOptions = const DatafileHostOptions("", "");
  int datafilePeriodicDownloadInterval = 0;

  const MethodChannel channel = MethodChannel("optimizely_flutter_sdk");
  dynamic mockOptimizelyConfig;

  TestDefaultBinaryMessenger? tester;

  setUp(() async {
    final optimizelyConfigJsonFile =
        File('test_resources/OptimizelyConfig.json');
    mockOptimizelyConfig =
        jsonDecode(await optimizelyConfigJsonFile.readAsString());

    TestWidgetsFlutterBinding.ensureInitialized();
    OptimizelyClientWrapper.decisionCallbacksById = {};
    OptimizelyClientWrapper.trackCallbacksById = {};
    OptimizelyClientWrapper.configUpdateCallbacksById = {};
    OptimizelyClientWrapper.logEventCallbacksById = {};
    OptimizelyClientWrapper.nextCallbackId = 0;
    tester = TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger;

    tester?.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      // log.add(methodCall);
      // reason from ios/Classes/SwiftOptimizelyFlutterSdkPlugin.swift
      switch (methodCall.method) {
        case Constants.initializeMethod:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId], isNull);
          // To Check if eventOptions were received
          eventOptions = EventOptions(
              batchSize: methodCall.arguments[Constants.eventBatchSize],
              maxQueueSize: methodCall.arguments[Constants.eventMaxQueueSize],
              timeInterval: methodCall.arguments[Constants.eventTimeInterval]);
          datafilePeriodicDownloadInterval =
              methodCall.arguments[Constants.datafilePeriodicDownloadInterval];

          // Resetting to default for every test
          datafileHostOptions = const DatafileHostOptions("", "");
          if (methodCall.arguments[Constants.datafileHostPrefix] != null &&
              methodCall.arguments[Constants.datafileHostSuffix] != null) {
            datafileHostOptions = DatafileHostOptions(
                methodCall.arguments[Constants.datafileHostPrefix],
                methodCall.arguments[Constants.datafileHostSuffix]);
          }

          return {
            Constants.responseSuccess: true,
          };
        case Constants.activate:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId], isNull);
          expect(methodCall.arguments[Constants.experimentKey],
              equals(experimentKey));
          expect(methodCall.arguments[Constants.userId], equals(userId));
          expect(methodCall.arguments[Constants.attributes]["abc"],
              equals(attributes["abc"]));
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {Constants.variationKey: variationKey},
          };
        case Constants.getVariation:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId], isNull);
          expect(methodCall.arguments[Constants.experimentKey],
              equals(experimentKey));
          expect(methodCall.arguments[Constants.userId], equals(userId));
          expect(methodCall.arguments[Constants.attributes]["abc"],
              equals(attributes["abc"]));
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {Constants.variationKey: variationKey},
          };
        case Constants.setForcedVariation:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId], isNull);
          expect(methodCall.arguments[Constants.experimentKey],
              equals(experimentKey));
          expect(methodCall.arguments[Constants.userId], equals(userId));
          expect(methodCall.arguments[Constants.variationKey],
              equals(variationKey));
          return {
            Constants.responseSuccess: true,
          };
        case Constants.getForcedVariation:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId], isNull);
          expect(methodCall.arguments[Constants.experimentKey],
              equals(experimentKey));
          expect(methodCall.arguments[Constants.userId], equals(userId));
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {Constants.variationKey: variationKey},
          };
        case Constants.getOptimizelyConfigMethod:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId], isNull);
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: mockOptimizelyConfig,
          };
        case Constants.createUserContextMethod:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userId], equals(userId));
          expect(methodCall.arguments[Constants.attributes]["abc"],
              equals(attributes["abc"]));
          expect(methodCall.arguments[Constants.userContextId], isNull);
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {Constants.userContextId: userContextId},
          };
        case Constants.getUserIdMethod:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId],
              equals(userContextId));
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {
              Constants.userId: userId,
            },
          };
        case Constants.getAttributesMethod:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId],
              equals(userContextId));
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {
              Constants.attributes: attributes,
            },
          };
        case Constants.setAttributesMethod:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId],
              equals(userContextId));
          expect(methodCall.arguments[Constants.attributes]["abc"],
              equals(attributes1["abc"]));
          return {
            Constants.responseSuccess: true,
          };
        case Constants.trackEventMethod:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId],
              equals(userContextId));
          expect(methodCall.arguments[Constants.eventKey], equals(eventKey));
          expect(methodCall.arguments[Constants.eventTags]["abcd"],
              equals(eventTags["abcd"]));
          return {
            Constants.responseSuccess: true,
          };
        case Constants.decideMethod:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId],
              equals(userContextId));
          var keys = List<String>.from(methodCall.arguments[Constants.keys]);
          decideOptions.addAll(List<String>.from(
              methodCall.arguments[Constants.optimizelyDecideOption]));
          // for decideAll
          if (keys.isEmpty) {
            keys = ["123", "456", "789"];
          }
          Map<String, dynamic> result = {};
          for (final key in keys) {
            result[key] = TestUtils.decideResponseMap;
          }
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: result,
          };
        case Constants.setForcedDecision:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId],
              equals(userContextId));
          expect(methodCall.arguments[Constants.flagKey], equals(flagKey));
          expect(methodCall.arguments[Constants.ruleKey], equals(ruleKey));
          expect(methodCall.arguments[Constants.variationKey],
              equals(variationKey));
          return {
            Constants.responseSuccess: true,
          };
        case Constants.getForcedDecision:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId],
              equals(userContextId));
          expect(methodCall.arguments[Constants.flagKey], equals(flagKey));
          expect(methodCall.arguments[Constants.ruleKey], equals(ruleKey));
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {Constants.variationKey: variationKey},
          };
        case Constants.removeForcedDecision:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId],
              equals(userContextId));
          expect(methodCall.arguments[Constants.flagKey], equals(flagKey));
          expect(methodCall.arguments[Constants.ruleKey], equals(ruleKey));
          return {
            Constants.responseSuccess: true,
            Constants.responseReason: Constants.removeForcedDecision,
          };
        case Constants.removeAllForcedDecisions:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId],
              equals(userContextId));
          return {
            Constants.responseSuccess: true,
            Constants.responseReason: Constants.removeAllForcedDecisions,
          };
        case Constants.addNotificationListenerMethod:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId], isNull);
          return {
            Constants.responseSuccess: true,
          };
        case Constants.removeNotificationListenerMethod:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId], isNull);
          return {
            Constants.responseSuccess: true,
          };
        case Constants.clearNotificationListenersMethod:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId], isNull);
          return {
            Constants.responseSuccess: true,
          };
        case Constants.clearAllNotificationListenersMethod:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId], isNull);
          return {
            Constants.responseSuccess: true,
          };
        case Constants.close:
          expect(methodCall.arguments[Constants.sdkKey], isNotEmpty);
          expect(methodCall.arguments[Constants.userContextId], isNull);
          return {
            Constants.responseSuccess: true,
          };
        default:
          return null;
      }
    });
  });

  tearDown(() {
    tester?.setMockMethodCallHandler(channel, null);
  });

  group("Integration: OptimizelyFlutterSdk MethodChannel", () {
    group("constructor", () {
      test("with empty string SDK Key should instantiate successfully",
          () async {
        const String emptyStringSdkKey = "";
        var sdk = OptimizelyFlutterSdk(emptyStringSdkKey);

        expect(sdk.runtimeType == OptimizelyFlutterSdk, isTrue);
      });
    });

    group("initializeClient()", () {
      test("with valid SDK Key should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        var response = await sdk.initializeClient();

        expect(response.success, isTrue);
      });

      test("with no eventOptions and no datafileOptions", () async {
        // default values
        const expectedEventOptions =
            EventOptions(batchSize: 10, timeInterval: 60, maxQueueSize: 10000);
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        const expectedDatafileHostOptions = DatafileHostOptions("", "");
        const expectedDatafilePeriodicDownloadInterval = 10 * 60;
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var response = await sdk.initializeClient();

        expect(response.success, isTrue);
        expect(eventOptions.batchSize, equals(expectedEventOptions.batchSize));
        expect(eventOptions.maxQueueSize,
            equals(expectedEventOptions.maxQueueSize));
        expect(eventOptions.timeInterval,
            equals(expectedEventOptions.timeInterval));
        expect(datafilePeriodicDownloadInterval,
            equals(expectedDatafilePeriodicDownloadInterval));
        expect(datafileHostOptions.datafileHostPrefix,
            equals(expectedDatafileHostOptions.datafileHostPrefix));
        expect(datafileHostOptions.datafileHostSuffix,
            equals(expectedDatafileHostOptions.datafileHostSuffix));
        debugDefaultTargetPlatformOverride = null;
      });

      test("with eventOptions and datafileOptions", () async {
        const expectedEventOptions =
            EventOptions(batchSize: 20, timeInterval: 30, maxQueueSize: 200);
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        const expectedDatafileHostOptions = DatafileHostOptions("123", "456");
        const expectedDatafilePeriodicDownloadInterval = 40;
        var sdk = OptimizelyFlutterSdk(testSDKKey,
            eventOptions: expectedEventOptions,
            datafilePeriodicDownloadInterval:
                expectedDatafilePeriodicDownloadInterval,
            datafileHostOptions: {
              ClientPlatform.iOS: expectedDatafileHostOptions
            });
        var response = await sdk.initializeClient();

        expect(response.success, isTrue);
        expect(eventOptions.batchSize, equals(expectedEventOptions.batchSize));
        expect(eventOptions.maxQueueSize,
            equals(expectedEventOptions.maxQueueSize));
        expect(eventOptions.timeInterval,
            equals(expectedEventOptions.timeInterval));
        expect(datafilePeriodicDownloadInterval,
            equals(expectedDatafilePeriodicDownloadInterval));
        expect(datafileHostOptions.datafileHostPrefix,
            equals(expectedDatafileHostOptions.datafileHostPrefix));
        expect(datafileHostOptions.datafileHostSuffix,
            equals(expectedDatafileHostOptions.datafileHostSuffix));
        debugDefaultTargetPlatformOverride = null;
      });

      test("with no eventOptions and datafileOptions", () async {
        // default values
        const expectedEventOptions =
            EventOptions(batchSize: 10, timeInterval: 60, maxQueueSize: 10000);
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        const expectedDatafileHostOptions = DatafileHostOptions("123", "456");
        const expectedDatafilePeriodicDownloadInterval = 500;
        var sdk = OptimizelyFlutterSdk(testSDKKey,
            datafilePeriodicDownloadInterval:
                expectedDatafilePeriodicDownloadInterval,
            datafileHostOptions: {
              ClientPlatform.iOS: expectedDatafileHostOptions
            });
        var response = await sdk.initializeClient();

        expect(response.success, isTrue);
        expect(eventOptions.batchSize, equals(expectedEventOptions.batchSize));
        expect(eventOptions.maxQueueSize,
            equals(expectedEventOptions.maxQueueSize));
        expect(eventOptions.timeInterval,
            equals(expectedEventOptions.timeInterval));
        expect(datafilePeriodicDownloadInterval,
            equals(expectedDatafilePeriodicDownloadInterval));
        expect(datafileHostOptions.datafileHostPrefix,
            equals(expectedDatafileHostOptions.datafileHostPrefix));
        expect(datafileHostOptions.datafileHostSuffix,
            equals(expectedDatafileHostOptions.datafileHostSuffix));
        debugDefaultTargetPlatformOverride = null;
      });

      test("with eventOptions and no datafileOptions", () async {
        // default values
        const expectedEventOptions =
            EventOptions(batchSize: 50, timeInterval: 80, maxQueueSize: 20000);
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        const expectedDatafileHostOptions = DatafileHostOptions("", "");
        const expectedDatafilePeriodicDownloadInterval = 10 * 60;
        var sdk = OptimizelyFlutterSdk(testSDKKey,
            eventOptions: expectedEventOptions);
        var response = await sdk.initializeClient();

        expect(response.success, isTrue);
        expect(eventOptions.batchSize, equals(expectedEventOptions.batchSize));
        expect(eventOptions.maxQueueSize,
            equals(expectedEventOptions.maxQueueSize));
        expect(eventOptions.timeInterval,
            equals(expectedEventOptions.timeInterval));
        expect(datafilePeriodicDownloadInterval,
            equals(expectedDatafilePeriodicDownloadInterval));
        expect(datafileHostOptions.datafileHostPrefix,
            equals(expectedDatafileHostOptions.datafileHostPrefix));
        expect(datafileHostOptions.datafileHostSuffix,
            equals(expectedDatafileHostOptions.datafileHostSuffix));
        debugDefaultTargetPlatformOverride = null;
      });
    });

    group("close()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var response = await sdk.close();
        expect(response.success, isTrue);
      });
    });

    group("activate()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        var result = await sdk.activate(experimentKey, userId, attributes);
        expect(result.success, isTrue);
        expect(result.variationKey, equals(variationKey));
      });
    });

    group("getVariation()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        var result = await sdk.getVariation(experimentKey, userId, attributes);
        expect(result.success, isTrue);
        expect(result.variationKey, equals(variationKey));
      });
    });

    group("getForcedVariation()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        var result = await sdk.getForcedVariation(experimentKey, userId);
        expect(result.success, isTrue);
        expect(result.variationKey, equals(variationKey));
      });
    });

    group("setForcedVariation()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        var result =
            await sdk.setForcedVariation(experimentKey, userId, variationKey);
        expect(result.success, isTrue);
      });
    });

    group("getOptimizelyConfig()", () {
      test("returns valid digested OptimizelyConfig should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        var result = await sdk.getOptimizelyConfig();

        expect(result.success, isTrue);
        expect(result.optimizelyConfig, isNotNull);

        expect(result.optimizelyConfig?.sdkKey, isNotNull);
        expect(result.optimizelyConfig?.sdkKey, equals(testSDKKey));
        expect(result.optimizelyConfig?.environmentKey, equals("production"));
        expect(result.optimizelyConfig?.attributes.length, equals(1));
        expect(result.optimizelyConfig?.events.length, equals(1));
        expect(result.optimizelyConfig?.revision, equals("130"));
        expect(result.optimizelyConfig?.experimentsMap, isNotNull);
        expect(result.optimizelyConfig?.featuresMap, isNotNull);
        expect(result.optimizelyConfig?.datafile, isNotNull);
      });
    });

    group("createUserContext()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId, attributes);
        expect(userContext, isNotNull);
      });
    });

    group("getUserId()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId, attributes);
        var response = await userContext!.getUserId();

        expect(response.success, isTrue);
        expect(response.userId, equals(userId));
      });
    });
    group("getAttributes()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId, attributes);
        var response = await userContext!.getAttributes();

        expect(response.success, isTrue);
        expect(response.attributes["abc"], equals(attributes["abc"]));
      });
    });

    group("setAttributes()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId, attributes);
        var response = await userContext!.setAttributes(attributes1);

        expect(response.success, isTrue);
      });
    });

    group("trackEvent()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId, attributes);
        var response = await userContext!.trackEvent(eventKey, eventTags);

        expect(response.success, isTrue);
      });
    });

    group("decide()", () {
      bool assertDecideOptions(
          Set<OptimizelyDecideOption> options, List<String> convertedOptions) {
        for (var option in options) {
          if (!convertedOptions.contains(option.name)) {
            return false;
          }
        }
        return true;
      }

      Set<OptimizelyDecideOption> options = {
        OptimizelyDecideOption.disableDecisionEvent,
        OptimizelyDecideOption.enabledFlagsOnly,
        OptimizelyDecideOption.ignoreUserProfileService,
        OptimizelyDecideOption.includeReasons,
        OptimizelyDecideOption.excludeVariables,
      };

      test("decide() should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId, attributes);
        var decideKey = "decide-key";

        var response = await userContext!.decide(decideKey, options);

        expect(response.success, isTrue);
        expect(response.decision, isNotNull);
        expect(
            TestUtils.compareDecisions(
                {response.decision!.flagKey: response.decision!}),
            equals(true));
        expect(decideOptions.length == 5, isTrue);
        expect(assertDecideOptions(options, decideOptions), isTrue);
        decideOptions = [];
      });

      test("decideForKeys should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId, attributes);
        var decideKeys = ["decide-key-1", "decide-key-2"];

        var response = await userContext!.decideForKeys(decideKeys, options);

        expect(response.success, isTrue);
        expect(response.decisions.length, equals(2));
        expect(TestUtils.compareDecisions(response.decisions), isTrue);
        expect(decideOptions.length == 5, isTrue);
        expect(assertDecideOptions(options, decideOptions), isTrue);
        decideOptions = [];
      });

      test("decideAll() should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId, attributes);

        var response = await userContext!.decideAll(options);

        expect(response.success, isTrue);
        expect(response.decisions.length, equals(3));
        expect(TestUtils.compareDecisions(response.decisions), isTrue);
        expect(decideOptions.length == 5, isTrue);
        expect(assertDecideOptions(options, decideOptions), isTrue);
        decideOptions = [];
      });

      test("should convert decide options to list", () async {
        final convertedOptions = Utils.convertDecideOptions(
          options,
        );
        expect(convertedOptions.length == 5, isTrue);
        expect(assertDecideOptions(options, convertedOptions), isTrue);
      });
    });

    group("setForcedDecision()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId, attributes);

        var response = await userContext!.setForcedDecision(
            OptimizelyDecisionContext(flagKey, ruleKey),
            OptimizelyForcedDecision(variationKey));

        expect(response.success, isTrue);
      });
    });

    group("getForcedDecision()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId, attributes);

        var response = await userContext!
            .getForcedDecision(OptimizelyDecisionContext(flagKey, ruleKey));

        expect(response.success, isTrue);
        expect(response.variationKey, equals(variationKey));
      });
    });

    group("removeForcedDecision()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId, attributes);

        var response = await userContext!
            .removeForcedDecision(OptimizelyDecisionContext(flagKey, ruleKey));

        expect(response.success, isTrue);
        expect(response.reason, equals(Constants.removeForcedDecision));
      });
    });

    test("removeAllForcedDecisions() should succeed", () async {
      var sdk = OptimizelyFlutterSdk(testSDKKey);
      var userContext = await sdk.createUserContext(userId, attributes);

      var response = await userContext!.removeAllForcedDecisions();

      expect(response.success, isTrue);
      expect(response.reason, equals(Constants.removeAllForcedDecisions));
    });
    group("NotificationListeners", () {
      test("should receive 1 notification due to same callback used", () async {
        var notifications = [];
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        // ignore: prefer_function_declarations_over_variables
        void Function(dynamic) callback = (msg) {
          notifications.add(msg);
        };
        await sdk.addDecisionNotificationListener(callback);
        await sdk.addLogEventNotificationListener(callback);
        await sdk.addUpdateConfigNotificationListener(callback);
        await sdk.addTrackNotificationListener(callback);
        await sdk.addActivateNotificationListener(callback);
        var callHandler = OptimizelyClientWrapper.methodCallHandler;
        tester?.setMockMethodCallHandler(channel, callHandler);
        TestUtils.sendTestDecisionNotifications(callHandler, 0, testSDKKey);
        TestUtils.sendTestLogEventNotifications(callHandler, 1, testSDKKey);
        TestUtils.sendTestTrackNotifications(callHandler, 2, testSDKKey);
        TestUtils.sendTestUpdateConfigNotifications(callHandler, 3, testSDKKey);
        TestUtils.sendTestActivateNotifications(callHandler, 4, testSDKKey);
        expect(notifications.length, equals(1));
        expect(TestUtils.testDecisionNotificationPayload(notifications, 0, 0),
            true);
      });

      test("should receive 4 notification due to different callbacks used",
          () async {
        var notifications = [];
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        await sdk.addDecisionNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addLogEventNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addUpdateConfigNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addTrackNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addActivateNotificationListener((msg) {
          notifications.add(msg);
        });
        var callHandler = OptimizelyClientWrapper.methodCallHandler;
        tester?.setMockMethodCallHandler(channel, callHandler);
        TestUtils.sendTestDecisionNotifications(callHandler, 0, testSDKKey);
        TestUtils.sendTestLogEventNotifications(callHandler, 1, testSDKKey);
        TestUtils.sendTestUpdateConfigNotifications(callHandler, 2, testSDKKey);
        TestUtils.sendTestTrackNotifications(callHandler, 3, testSDKKey);
        TestUtils.sendTestActivateNotifications(callHandler, 4, testSDKKey);
        expect(notifications.length, equals(5));
        expect(TestUtils.testDecisionNotificationPayload(notifications, 0, 0),
            true);
        expect(TestUtils.testLogEventNotificationPayload(notifications, 1, 1),
            true);
        expect(
            TestUtils.testUpdateConfigNotificationPayload(notifications, 2, 2),
            true);
        expect(
            TestUtils.testTrackNotificationPayload(notifications, 3, 3), true);
        expect(TestUtils.testActivateNotificationPayload(notifications, 4, 4),
            true);
      });

      test("should receive notifications with several ListenerTypes", () async {
        var notifications = [];
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        await sdk.addDecisionNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addDecisionNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addLogEventNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addLogEventNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addTrackNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addTrackNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addUpdateConfigNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addUpdateConfigNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addActivateNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addActivateNotificationListener((msg) {
          notifications.add(msg);
        });
        var callHandler = OptimizelyClientWrapper.methodCallHandler;
        tester?.setMockMethodCallHandler(channel, callHandler);
        TestUtils.sendTestDecisionNotifications(callHandler, 0, testSDKKey);
        TestUtils.sendTestDecisionNotifications(callHandler, 1, testSDKKey);
        TestUtils.sendTestLogEventNotifications(callHandler, 2, testSDKKey);
        TestUtils.sendTestLogEventNotifications(callHandler, 3, testSDKKey);
        TestUtils.sendTestTrackNotifications(callHandler, 4, testSDKKey);
        TestUtils.sendTestTrackNotifications(callHandler, 5, testSDKKey);
        TestUtils.sendTestUpdateConfigNotifications(callHandler, 6, testSDKKey);
        TestUtils.sendTestUpdateConfigNotifications(callHandler, 7, testSDKKey);
        TestUtils.sendTestActivateNotifications(callHandler, 8, testSDKKey);
        TestUtils.sendTestActivateNotifications(callHandler, 9, testSDKKey);
        expect(notifications.length, equals(10));
        expect(TestUtils.testDecisionNotificationPayload(notifications, 0, 0),
            true);
        expect(TestUtils.testDecisionNotificationPayload(notifications, 1, 1),
            true);
        expect(TestUtils.testLogEventNotificationPayload(notifications, 2, 2),
            true);
        expect(TestUtils.testLogEventNotificationPayload(notifications, 3, 3),
            true);
        expect(
            TestUtils.testTrackNotificationPayload(notifications, 4, 4), true);
        expect(
            TestUtils.testTrackNotificationPayload(notifications, 5, 5), true);
        expect(
            TestUtils.testUpdateConfigNotificationPayload(notifications, 6, 6),
            true);
        expect(
            TestUtils.testUpdateConfigNotificationPayload(notifications, 7, 7),
            true);
        expect(TestUtils.testActivateNotificationPayload(notifications, 8, 8),
            true);
        expect(TestUtils.testActivateNotificationPayload(notifications, 9, 9),
            true);
      });

      test("should receive notifications with multiple sdkKeys", () async {
        var notifications = [];
        var sdk1 = OptimizelyFlutterSdk(testSDKKey);
        var sdk2 = OptimizelyFlutterSdk(testSDKKey2);

        await sdk1.addDecisionNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk1.addLogEventNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk1.addTrackNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk1.addUpdateConfigNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk1.addActivateNotificationListener((msg) {
          notifications.add(msg);
        });

        await sdk2.addDecisionNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk2.addLogEventNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk2.addTrackNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk2.addUpdateConfigNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk2.addActivateNotificationListener((msg) {
          notifications.add(msg);
        });

        var callHandler = OptimizelyClientWrapper.methodCallHandler;
        tester?.setMockMethodCallHandler(channel, callHandler);
        TestUtils.sendTestDecisionNotifications(callHandler, 0, testSDKKey);
        TestUtils.sendTestLogEventNotifications(callHandler, 1, testSDKKey);
        TestUtils.sendTestTrackNotifications(callHandler, 2, testSDKKey);
        TestUtils.sendTestUpdateConfigNotifications(callHandler, 3, testSDKKey);
        TestUtils.sendTestActivateNotifications(callHandler, 4, testSDKKey);
        TestUtils.sendTestDecisionNotifications(callHandler, 5, testSDKKey2);
        TestUtils.sendTestLogEventNotifications(callHandler, 6, testSDKKey2);
        TestUtils.sendTestTrackNotifications(callHandler, 7, testSDKKey2);
        TestUtils.sendTestUpdateConfigNotifications(
            callHandler, 8, testSDKKey2);
        TestUtils.sendTestActivateNotifications(callHandler, 9, testSDKKey2);
        expect(notifications.length, equals(10));
        expect(TestUtils.testDecisionNotificationPayload(notifications, 0, 0),
            true);
        expect(TestUtils.testLogEventNotificationPayload(notifications, 1, 1),
            true);
        expect(
            TestUtils.testTrackNotificationPayload(notifications, 2, 2), true);
        expect(
            TestUtils.testUpdateConfigNotificationPayload(notifications, 3, 3),
            true);
        expect(TestUtils.testActivateNotificationPayload(notifications, 4, 4),
            true);
        expect(TestUtils.testDecisionNotificationPayload(notifications, 5, 5),
            true);
        expect(TestUtils.testLogEventNotificationPayload(notifications, 6, 6),
            true);
        expect(
            TestUtils.testTrackNotificationPayload(notifications, 7, 7), true);
        expect(
            TestUtils.testUpdateConfigNotificationPayload(notifications, 8, 8),
            true);
        expect(TestUtils.testActivateNotificationPayload(notifications, 9, 9),
            true);
      });

      test("should receive 4 notification because of listener removals",
          () async {
        var notifications = [];
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        await sdk.addDecisionNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addLogEventNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addTrackNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addUpdateConfigNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addActivateNotificationListener((msg) {
          notifications.add(msg);
        });

        var id = await sdk.addDecisionNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.removeNotificationListener(id);
        id = await sdk.addLogEventNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.removeNotificationListener(id);
        id = await sdk.addUpdateConfigNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.removeNotificationListener(id);
        id = await sdk.addTrackNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.removeNotificationListener(id);
        id = await sdk.addActivateNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.removeNotificationListener(id);

        var callHandler = OptimizelyClientWrapper.methodCallHandler;
        tester?.setMockMethodCallHandler(channel, callHandler);
        TestUtils.sendTestDecisionNotifications(callHandler, 0, testSDKKey);
        TestUtils.sendTestLogEventNotifications(callHandler, 1, testSDKKey);
        TestUtils.sendTestTrackNotifications(callHandler, 2, testSDKKey);
        TestUtils.sendTestUpdateConfigNotifications(callHandler, 3, testSDKKey);
        TestUtils.sendTestActivateNotifications(callHandler, 4, testSDKKey);
        TestUtils.sendTestDecisionNotifications(callHandler, 5, testSDKKey);
        TestUtils.sendTestLogEventNotifications(callHandler, 6, testSDKKey);
        TestUtils.sendTestTrackNotifications(callHandler, 7, testSDKKey);
        TestUtils.sendTestUpdateConfigNotifications(callHandler, 8, testSDKKey);
        TestUtils.sendTestActivateNotifications(callHandler, 9, testSDKKey);
        expect(notifications.length, equals(5));
        expect(TestUtils.testDecisionNotificationPayload(notifications, 0, 0),
            true);
        expect(TestUtils.testLogEventNotificationPayload(notifications, 1, 1),
            true);
        expect(
            TestUtils.testTrackNotificationPayload(notifications, 2, 2), true);
        expect(
            TestUtils.testUpdateConfigNotificationPayload(notifications, 3, 3),
            true);
        expect(TestUtils.testActivateNotificationPayload(notifications, 4, 4),
            true);
      });

      test(
          "should receive 4 notification because of all listener removals of decision type",
          () async {
        var notifications = [];
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        await sdk.addDecisionNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addLogEventNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addTrackNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addUpdateConfigNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addActivateNotificationListener((msg) {
          notifications.add(msg);
        });

        await sdk.clearNotificationListeners(ListenerType.decision);
        var callHandler = OptimizelyClientWrapper.methodCallHandler;
        tester?.setMockMethodCallHandler(channel, callHandler);
        TestUtils.sendTestDecisionNotifications(callHandler, 0, testSDKKey);
        TestUtils.sendTestLogEventNotifications(callHandler, 1, testSDKKey);
        TestUtils.sendTestTrackNotifications(callHandler, 2, testSDKKey);
        TestUtils.sendTestUpdateConfigNotifications(callHandler, 3, testSDKKey);
        TestUtils.sendTestActivateNotifications(callHandler, 4, testSDKKey);
        expect(notifications.length, equals(4));
        expect(TestUtils.testLogEventNotificationPayload(notifications, 0, 1),
            true);
        expect(
            TestUtils.testTrackNotificationPayload(notifications, 1, 2), true);
        expect(
            TestUtils.testUpdateConfigNotificationPayload(notifications, 2, 3),
            true);
        expect(TestUtils.testActivateNotificationPayload(notifications, 3, 4),
            true);
      });

      test(
          "should receive 4 notification because of all listener removals of LogEvent type",
          () async {
        var notifications = [];
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        await sdk.addDecisionNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addLogEventNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addTrackNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addUpdateConfigNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addActivateNotificationListener((msg) {
          notifications.add(msg);
        });

        await sdk.clearNotificationListeners(ListenerType.logEvent);
        var callHandler = OptimizelyClientWrapper.methodCallHandler;
        tester?.setMockMethodCallHandler(channel, callHandler);
        TestUtils.sendTestDecisionNotifications(callHandler, 0, testSDKKey);
        TestUtils.sendTestLogEventNotifications(callHandler, 1, testSDKKey);
        TestUtils.sendTestTrackNotifications(callHandler, 2, testSDKKey);
        TestUtils.sendTestUpdateConfigNotifications(callHandler, 3, testSDKKey);
        TestUtils.sendTestActivateNotifications(callHandler, 4, testSDKKey);
        expect(notifications.length, equals(4));
        expect(TestUtils.testDecisionNotificationPayload(notifications, 0, 0),
            true);
        expect(
            TestUtils.testTrackNotificationPayload(notifications, 1, 2), true);
        expect(
            TestUtils.testUpdateConfigNotificationPayload(notifications, 2, 3),
            true);
        expect(TestUtils.testActivateNotificationPayload(notifications, 3, 4),
            true);
      });

      test(
          "should receive 4 notification because of all listener removals of Track Listener type",
          () async {
        var notifications = [];
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        await sdk.addDecisionNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addLogEventNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addTrackNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addUpdateConfigNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addActivateNotificationListener((msg) {
          notifications.add(msg);
        });

        await sdk.clearNotificationListeners(ListenerType.track);
        var callHandler = OptimizelyClientWrapper.methodCallHandler;
        tester?.setMockMethodCallHandler(channel, callHandler);
        TestUtils.sendTestDecisionNotifications(callHandler, 0, testSDKKey);
        TestUtils.sendTestLogEventNotifications(callHandler, 1, testSDKKey);
        TestUtils.sendTestTrackNotifications(callHandler, 2, testSDKKey);
        TestUtils.sendTestUpdateConfigNotifications(callHandler, 3, testSDKKey);
        TestUtils.sendTestActivateNotifications(callHandler, 4, testSDKKey);
        expect(notifications.length, equals(4));
        expect(TestUtils.testDecisionNotificationPayload(notifications, 0, 0),
            true);
        expect(TestUtils.testLogEventNotificationPayload(notifications, 1, 1),
            true);
        expect(
            TestUtils.testUpdateConfigNotificationPayload(notifications, 2, 3),
            true);
        expect(TestUtils.testActivateNotificationPayload(notifications, 3, 4),
            true);
      });

      test(
          "should receive 4 notification because of all listener removals of UpdateConfig Listener type",
          () async {
        var notifications = [];
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        await sdk.addDecisionNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addLogEventNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addTrackNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addUpdateConfigNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addActivateNotificationListener((msg) {
          notifications.add(msg);
        });

        await sdk.clearNotificationListeners(ListenerType.projectConfigUpdate);
        var callHandler = OptimizelyClientWrapper.methodCallHandler;
        tester?.setMockMethodCallHandler(channel, callHandler);
        TestUtils.sendTestDecisionNotifications(callHandler, 0, testSDKKey);
        TestUtils.sendTestLogEventNotifications(callHandler, 1, testSDKKey);
        TestUtils.sendTestTrackNotifications(callHandler, 2, testSDKKey);
        TestUtils.sendTestUpdateConfigNotifications(callHandler, 3, testSDKKey);
        TestUtils.sendTestActivateNotifications(callHandler, 4, testSDKKey);
        expect(notifications.length, equals(4));
        expect(TestUtils.testDecisionNotificationPayload(notifications, 0, 0),
            true);
        expect(TestUtils.testLogEventNotificationPayload(notifications, 1, 1),
            true);
        expect(
            TestUtils.testTrackNotificationPayload(notifications, 2, 2), true);
        expect(TestUtils.testActivateNotificationPayload(notifications, 3, 4),
            true);
      });

      test(
          "should receive 4 notification because of all listener removals of activate Listener type",
          () async {
        var notifications = [];
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        await sdk.addDecisionNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addLogEventNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addTrackNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addUpdateConfigNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addActivateNotificationListener((msg) {
          notifications.add(msg);
        });

        await sdk.clearNotificationListeners(ListenerType.activate);
        var callHandler = OptimizelyClientWrapper.methodCallHandler;
        tester?.setMockMethodCallHandler(channel, callHandler);
        TestUtils.sendTestDecisionNotifications(callHandler, 0, testSDKKey);
        TestUtils.sendTestLogEventNotifications(callHandler, 1, testSDKKey);
        TestUtils.sendTestTrackNotifications(callHandler, 2, testSDKKey);
        TestUtils.sendTestUpdateConfigNotifications(callHandler, 3, testSDKKey);
        TestUtils.sendTestActivateNotifications(callHandler, 4, testSDKKey);
        expect(notifications.length, equals(4));
        expect(TestUtils.testDecisionNotificationPayload(notifications, 0, 0),
            true);
        expect(TestUtils.testLogEventNotificationPayload(notifications, 1, 1),
            true);
        expect(
            TestUtils.testTrackNotificationPayload(notifications, 2, 2), true);
        expect(
            TestUtils.testUpdateConfigNotificationPayload(notifications, 3, 3),
            true);
      });

      test("should receive 0 notification because of all listener removals.",
          () async {
        var notifications = [];
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        await sdk.addDecisionNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addLogEventNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addTrackNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addUpdateConfigNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk.addActivateNotificationListener((msg) {
          notifications.add(msg);
        });

        await sdk.clearAllNotificationListeners();
        var callHandler = OptimizelyClientWrapper.methodCallHandler;
        tester?.setMockMethodCallHandler(channel, callHandler);
        TestUtils.sendTestDecisionNotifications(callHandler, 0, testSDKKey);
        TestUtils.sendTestLogEventNotifications(callHandler, 1, testSDKKey);
        TestUtils.sendTestTrackNotifications(callHandler, 2, testSDKKey);
        TestUtils.sendTestUpdateConfigNotifications(callHandler, 3, testSDKKey);
        TestUtils.sendTestActivateNotifications(callHandler, 4, testSDKKey);
        expect(notifications.length, equals(0));
      });

      test(
          "Remove all notification listeners when no listener was added of type decision.",
          () async {
        var notifications = [];
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        await sdk.addTrackNotificationListener((msg) {
          notifications.add(msg);
        });
        var baseResponse =
            await sdk.clearNotificationListeners(ListenerType.decision);
        var callHandler = OptimizelyClientWrapper.methodCallHandler;
        tester?.setMockMethodCallHandler(channel, callHandler);
        expect(baseResponse.success, true);
        TestUtils.sendTestTrackNotifications(callHandler, 0, testSDKKey);
        expect(notifications.length, equals(1));
        expect(
            TestUtils.testTrackNotificationPayload(notifications, 0, 0), true);
      });

      test("Remove all notification listeners when no listener was added.",
          () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        var baseResponse = await sdk.clearAllNotificationListeners();
        var callHandler = OptimizelyClientWrapper.methodCallHandler;
        tester?.setMockMethodCallHandler(channel, callHandler);
        expect(baseResponse.success, true);
      });

      test(
          "Test with multiple sdkKeys removing all listeners from one sdk is not effecting the other SDK listeners",
          () async {
        var notifications = [];
        var sdk1 = OptimizelyFlutterSdk(testSDKKey);
        var sdk2 = OptimizelyFlutterSdk(testSDKKey2);

        await sdk1.addDecisionNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk1.addLogEventNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk1.addTrackNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk1.addUpdateConfigNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk1.addActivateNotificationListener((msg) {
          notifications.add(msg);
        });

        await sdk2.addDecisionNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk2.addLogEventNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk2.addTrackNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk2.addUpdateConfigNotificationListener((msg) {
          notifications.add(msg);
        });
        await sdk2.addActivateNotificationListener((msg) {
          notifications.add(msg);
        });

        await sdk1.clearAllNotificationListeners();

        var callHandler = OptimizelyClientWrapper.methodCallHandler;
        tester?.setMockMethodCallHandler(channel, callHandler);
        TestUtils.sendTestDecisionNotifications(callHandler, 0, testSDKKey);
        TestUtils.sendTestLogEventNotifications(callHandler, 1, testSDKKey);
        TestUtils.sendTestTrackNotifications(callHandler, 2, testSDKKey);
        TestUtils.sendTestUpdateConfigNotifications(callHandler, 3, testSDKKey);
        TestUtils.sendTestActivateNotifications(callHandler, 4, testSDKKey);
        TestUtils.sendTestDecisionNotifications(callHandler, 5, testSDKKey2);
        TestUtils.sendTestLogEventNotifications(callHandler, 6, testSDKKey2);
        TestUtils.sendTestTrackNotifications(callHandler, 7, testSDKKey2);
        TestUtils.sendTestUpdateConfigNotifications(
            callHandler, 8, testSDKKey2);
        TestUtils.sendTestActivateNotifications(callHandler, 9, testSDKKey2);
        expect(notifications.length, equals(5));

        expect(TestUtils.testDecisionNotificationPayload(notifications, 0, 5),
            true);
        expect(TestUtils.testLogEventNotificationPayload(notifications, 1, 6),
            true);
        expect(
            TestUtils.testTrackNotificationPayload(notifications, 2, 7), true);
        expect(
            TestUtils.testUpdateConfigNotificationPayload(notifications, 3, 8),
            true);
        expect(TestUtils.testActivateNotificationPayload(notifications, 4, 9),
            true);
      });
    });
  });
}
