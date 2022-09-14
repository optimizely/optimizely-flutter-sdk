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
            Constants.responseReason: Constants.instanceCreated,
          };
        case Constants.getOptimizelyConfigMethod:
          return {
            Constants.responseSuccess: true,
            Constants.responseReason: Constants.optimizelyConfigFound,
            Constants.responseResult: mockOptimizelyConfig,
          };
        case Constants.createUserContextMethod:
          return {
            Constants.responseSuccess: true,
            Constants.responseReason: Constants.userContextCreated,
            Constants.responseResult: {Constants.userContextId: "123"},
          };
        case Constants.setAttributesMethod:
          return {
            Constants.responseSuccess: true,
            Constants.responseReason: Constants.attributesAdded,
          };
        case Constants.trackEventMethod:
          return {
            Constants.responseSuccess: true,
          };
        case Constants.decideMethod:
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
            Constants.responseReason: Constants.decideCalled,
            Constants.responseResult: result,
          };
        case Constants.setForcedDecision:
          return {
            Constants.responseSuccess: true,
            Constants.responseReason: Constants.forcedDecisionSet,
          };
        case Constants.getForcedDecision:
          return {
            Constants.responseSuccess: true,
            Constants.responseResult: {Constants.variationKey: "123"},
          };
        case Constants.removeForcedDecision:
          return {
            Constants.responseSuccess: true,
            Constants.responseReason: Constants.removeForcedDecision,
          };
        case Constants.removeAllForcedDecisions:
          return {
            Constants.responseSuccess: true,
            Constants.responseReason: Constants.removeAllForcedDecisions,
          };
        case Constants.addNotificationListenerMethod:
          return {
            Constants.responseSuccess: true,
            Constants.responseReason: Constants.listenerAdded,
          };
        case Constants.removeNotificationListenerMethod:
          return {
            Constants.responseSuccess: true,
            Constants.responseReason: Constants.listenerRemoved,
          };
        case Constants.close:
          return {
            Constants.responseSuccess: true,
            Constants.responseReason: Constants.optimizelyClientClosed,
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

        expect(response.success, equals(true));
        expect(response.reason, equals(Constants.instanceCreated));
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

        expect(response.success, equals(true));
        expect(response.reason, equals(Constants.instanceCreated));
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

        expect(response.success, equals(true));
        expect(response.reason, equals(Constants.instanceCreated));
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

        expect(response.success, equals(true));
        expect(response.reason, equals(Constants.instanceCreated));
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

        expect(response.success, equals(true));
        expect(response.reason, equals(Constants.instanceCreated));
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
        expect(response.success, equals(true));
        expect(response.reason, equals(Constants.optimizelyClientClosed));
      });
    });
    group("getOptimizelyConfig()", () {
      test("returns valid digested OptimizelyConfig should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        var result = await sdk.getOptimizelyConfig();
        var config = result.optimizelyConfig;

        expect(result.success, equals(true));
        expect(result.optimizelyConfig, isNotNull);
        expect(result.reason, equals(Constants.optimizelyConfigFound));

        expect(config["sdkKey"], equals(testSDKKey));
        expect(config["environmentKey"], equals("production"));
        expect(config["attributes"].length, equals(1));
        expect(config["events"].length, equals(1));
        expect(config["revision"], equals("130"));
        expect(config["experimentsMap"], isNotNull);
        expect(config["featuresMap"], isNotNull);
        expect(config["datafile"], isNotNull);
      });
    });
    group("createUserContext()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId);
        expect(userContext, isNotNull);
      });
    });
    group("setAttributes()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId);
        var attributes = <String, dynamic>{};

        var response = await userContext!.setAttributes(attributes);

        expect(response.success, equals(true));
        expect(response.reason, equals(Constants.attributesAdded));
      });
    });
    group("trackEvent()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId);
        var eventKey = "event-key";

        var response = await userContext!.trackEvent(eventKey);

        expect(response.success, equals(true));
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
        var userContext = await sdk.createUserContext(userId);
        var decideKey = "decide-key";

        var response = await userContext!.decide(decideKey, options);

        expect(response.success, equals(true));
        expect(response.decision != null, equals(true));
        expect(response.reason, Constants.decideCalled);
        expect(
            TestUtils.compareDecisions(
                {response.decision!.flagKey: response.decision!}),
            equals(true));
        expect(decideOptions.length == 5, equals(true));
        expect(assertDecideOptions(options, decideOptions), equals(true));
        decideOptions = [];
      });

      test("decideForKeys should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId);
        var decideKeys = ["decide-key-1", "decide-key-2"];

        var response = await userContext!.decideForKeys(decideKeys, options);

        expect(response.success, equals(true));
        expect(response.decisions.length, equals(2));
        expect(response.reason, Constants.decideCalled);
        expect(TestUtils.compareDecisions(response.decisions), equals(true));
        expect(decideOptions.length == 5, equals(true));
        expect(assertDecideOptions(options, decideOptions), equals(true));
        decideOptions = [];
      });

      test("decideAll() should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId);

        var response = await userContext!.decideAll(options);

        expect(response.success, equals(true));
        expect(response.decisions.length, equals(3));
        expect(response.reason, Constants.decideCalled);
        expect(TestUtils.compareDecisions(response.decisions), equals(true));
        expect(decideOptions.length == 5, equals(true));
        expect(assertDecideOptions(options, decideOptions), equals(true));
        decideOptions = [];
      });

      test("should convert decide options to list", () async {
        final convertedOptions = Utils.convertDecideOptions(
          options,
        );
        expect(convertedOptions.length == 5, equals(true));
        expect(assertDecideOptions(options, convertedOptions), equals(true));
      });
    });

    group("setForcedDecision()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId);

        var response = await userContext!.setForcedDecision(
            OptimizelyDecisionContext("flagKey", "ruleKey"),
            OptimizelyForcedDecision("123"));

        expect(response.success, equals(true));
        expect(response.reason, equals(Constants.forcedDecisionSet));
      });
    });
    group("getForcedDecision()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId);

        var response = await userContext!
            .getForcedDecision(OptimizelyDecisionContext("flagKey", "ruleKey"));

        expect(response.success, equals(true));
        expect(response.variationKey, equals("123"));
      });
    });
    group("removeForcedDecision()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId);

        var response = await userContext!.removeForcedDecision(
            OptimizelyDecisionContext("flagKey", "ruleKey"));

        expect(response.success, equals(true));
        expect(response.reason, equals(Constants.removeForcedDecision));
      });
    });

    test("removeAllForcedDecisions() should succeed", () async {
      var sdk = OptimizelyFlutterSdk(testSDKKey);
      var userContext = await sdk.createUserContext(userId);

      var response = await userContext!.removeAllForcedDecisions();

      expect(response.success, equals(true));
      expect(response.reason, equals(Constants.removeAllForcedDecisions));
    });

    test("addNotificationListener() should succeed", () async {
      var sdk = OptimizelyFlutterSdk(testSDKKey);
      expect(sdk.addDecisionNotificationListener((_) => {}), completes);
    });

    test("removeNotificationListener() should succeed", () async {
      var sdk = OptimizelyFlutterSdk(testSDKKey);
      var cancelListener = sdk.addDecisionNotificationListener((_) => {});
      expect(cancelListener, completes);
    });

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
      var callHandler = OptimizelyClientWrapper.methodCallHandler;
      tester?.setMockMethodCallHandler(channel, callHandler);
      TestUtils.sendTestDecisionNotifications(callHandler, 0);
      TestUtils.sendTestLogEventNotifications(callHandler, 1);
      TestUtils.sendTestTrackNotifications(callHandler, 2);
      TestUtils.sendTestUpdateConfigNotifications(callHandler, 3);
      expect(notifications.length, equals(1));
      expect(TestUtils.testDecisionNotificationPayload(notifications, 0), true);
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
      var callHandler = OptimizelyClientWrapper.methodCallHandler;
      tester?.setMockMethodCallHandler(channel, callHandler);
      TestUtils.sendTestDecisionNotifications(callHandler, 0);
      TestUtils.sendTestLogEventNotifications(callHandler, 1);
      TestUtils.sendTestUpdateConfigNotifications(callHandler, 2);
      TestUtils.sendTestTrackNotifications(callHandler, 3);
      expect(notifications.length, equals(4));
      expect(TestUtils.testDecisionNotificationPayload(notifications, 0), true);
      expect(TestUtils.testLogEventNotificationPayload(notifications, 1), true);
      expect(TestUtils.testUpdateConfigNotificationPayload(notifications, 2),
          true);
      expect(TestUtils.testTrackNotificationPayload(notifications, 3), true);
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
      var callHandler = OptimizelyClientWrapper.methodCallHandler;
      tester?.setMockMethodCallHandler(channel, callHandler);
      TestUtils.sendTestDecisionNotifications(callHandler, 0);
      TestUtils.sendTestDecisionNotifications(callHandler, 1);
      TestUtils.sendTestLogEventNotifications(callHandler, 2);
      TestUtils.sendTestLogEventNotifications(callHandler, 3);
      TestUtils.sendTestTrackNotifications(callHandler, 4);
      TestUtils.sendTestTrackNotifications(callHandler, 5);
      TestUtils.sendTestUpdateConfigNotifications(callHandler, 6);
      TestUtils.sendTestUpdateConfigNotifications(callHandler, 7);
      expect(notifications.length, equals(8));
      expect(TestUtils.testDecisionNotificationPayload(notifications, 0), true);
      expect(TestUtils.testDecisionNotificationPayload(notifications, 1), true);
      expect(TestUtils.testLogEventNotificationPayload(notifications, 2), true);
      expect(TestUtils.testLogEventNotificationPayload(notifications, 3), true);
      expect(TestUtils.testTrackNotificationPayload(notifications, 4), true);
      expect(TestUtils.testTrackNotificationPayload(notifications, 5), true);
      expect(TestUtils.testUpdateConfigNotificationPayload(notifications, 6),
          true);
      expect(TestUtils.testUpdateConfigNotificationPayload(notifications, 7),
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

      var callHandler = OptimizelyClientWrapper.methodCallHandler;
      tester?.setMockMethodCallHandler(channel, callHandler);
      TestUtils.sendTestDecisionNotifications(callHandler, 0);
      TestUtils.sendTestLogEventNotifications(callHandler, 1);
      TestUtils.sendTestTrackNotifications(callHandler, 2);
      TestUtils.sendTestUpdateConfigNotifications(callHandler, 3);
      TestUtils.sendTestDecisionNotifications(callHandler, 4);
      TestUtils.sendTestLogEventNotifications(callHandler, 5);
      TestUtils.sendTestTrackNotifications(callHandler, 6);
      TestUtils.sendTestUpdateConfigNotifications(callHandler, 7);
      expect(notifications.length, equals(8));
      expect(TestUtils.testDecisionNotificationPayload(notifications, 0), true);
      expect(TestUtils.testLogEventNotificationPayload(notifications, 1), true);
      expect(TestUtils.testTrackNotificationPayload(notifications, 2), true);
      expect(TestUtils.testUpdateConfigNotificationPayload(notifications, 3),
          true);
      expect(TestUtils.testDecisionNotificationPayload(notifications, 4), true);
      expect(TestUtils.testLogEventNotificationPayload(notifications, 5), true);
      expect(TestUtils.testTrackNotificationPayload(notifications, 6), true);
      expect(TestUtils.testUpdateConfigNotificationPayload(notifications, 7),
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

      var cancel = await sdk.addDecisionNotificationListener((msg) {
        notifications.add(msg);
      });
      cancel();
      cancel = await sdk.addLogEventNotificationListener((msg) {
        notifications.add(msg);
      });
      cancel();
      cancel = await sdk.addUpdateConfigNotificationListener((msg) {
        notifications.add(msg);
      });
      cancel();
      cancel = await sdk.addTrackNotificationListener((msg) {
        notifications.add(msg);
      });
      cancel();

      var callHandler = OptimizelyClientWrapper.methodCallHandler;
      tester?.setMockMethodCallHandler(channel, callHandler);
      TestUtils.sendTestDecisionNotifications(callHandler, 0);
      TestUtils.sendTestLogEventNotifications(callHandler, 1);
      TestUtils.sendTestTrackNotifications(callHandler, 2);
      TestUtils.sendTestUpdateConfigNotifications(callHandler, 3);
      TestUtils.sendTestDecisionNotifications(callHandler, 4);
      TestUtils.sendTestLogEventNotifications(callHandler, 5);
      TestUtils.sendTestTrackNotifications(callHandler, 6);
      TestUtils.sendTestUpdateConfigNotifications(callHandler, 7);
      expect(notifications.length, equals(4));
      expect(TestUtils.testDecisionNotificationPayload(notifications, 0), true);
      expect(TestUtils.testLogEventNotificationPayload(notifications, 1), true);
      expect(TestUtils.testTrackNotificationPayload(notifications, 2), true);
      expect(TestUtils.testUpdateConfigNotificationPayload(notifications, 3),
          true);
    });
  });
}
