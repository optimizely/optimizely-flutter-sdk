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

import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart";
import "package:optimizely_flutter_sdk/src/constants.dart";
import 'package:optimizely_flutter_sdk/src/optimizely_client_wrapper.dart';
import 'dart:io';
import 'dart:convert';

import 'test_utils.dart';

void main() {
  const String testSDKKey = "KZbunNn9bVfBWLpZPq2XC4";
  const String testSDKKey2 = "KZbunNn9bVfBWLpZPq2XC12";
  const String userId = "uid-351ea8";
  const MethodChannel channel = MethodChannel("optimizely_flutter_sdk");
  dynamic mockOptimizelyConfig;

  TestDefaultBinaryMessenger? tester;

  setUp(() async {
    final optimizelyConfigJsonFile =
        File('test_resources/OptimizelyConfig.json');
    mockOptimizelyConfig =
        jsonDecode(await optimizelyConfigJsonFile.readAsString());

    TestWidgetsFlutterBinding.ensureInitialized();
    OptimizelyClientWrapper.callbacksById = {};
    OptimizelyClientWrapper.nextCallbackId = 0;
    tester = TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger;

    tester?.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      // log.add(methodCall);
      // reason from ios/Classes/SwiftOptimizelyFlutterSdkPlugin.swift
      switch (methodCall.method) {
        case Constants.initializeMethod:
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
          return {
            Constants.responseSuccess: true,
            Constants.responseReason: Constants.decideCalled,
          };
        case Constants.setForcedDecision:
          return {
            Constants.responseSuccess: true,
            Constants.responseReason: Constants.forcedDecisionSet,
          };
        case Constants.getForcedDecision:
          return {
            Constants.responseSuccess: true,
            Constants.responseVariationKey: "123",
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

        var result = await sdk.initializeClient();

        expect(result[Constants.responseSuccess], equals(true));
        expect(result[Constants.responseResult], isNull);
        expect(result[Constants.responseReason],
            equals(Constants.instanceCreated));
      });
    });
    group("getOptimizelyConfig()", () {
      test("returns valid digested OptimizelyConfig should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        var result = await sdk.getOptimizelyConfig();
        var config = result[Constants.responseResult];

        expect(result[Constants.responseSuccess], equals(true));
        expect(result[Constants.responseResult], isNotNull);
        expect(result[Constants.responseReason],
            equals(Constants.optimizelyConfigFound));

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
        var attributes = Map<String, dynamic>();

        var result = await userContext!.setAttributes(attributes);

        expect(result[Constants.responseSuccess], equals(true));
        expect(result[Constants.responseResult], isNull);
        expect(result[Constants.responseReason],
            equals(Constants.attributesAdded));
      });
    });
    group("trackEvent()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId);
        var eventKey = "event-key";

        var result = await userContext!.trackEvent(eventKey);

        expect(result[Constants.responseSuccess], equals(true));
        expect(result[Constants.responseResult], isNull);
        expect(result[Constants.responseReason], isNull);
      });
    });
    group("decide()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId);
        var decideKey = "decide-key";

        var result = await userContext!.decide(decideKey);

        expect(result[Constants.responseSuccess], equals(true));
        expect(result[Constants.responseResult], isNull);
        expect(result[Constants.responseReason], Constants.decideCalled);
      });
    });
    group("decideForKeys()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId);
        var decideKeys = ["decide-key-1", "decide-key-2"];

        var result = await userContext!.decideForKeys(decideKeys);

        expect(result[Constants.responseSuccess], equals(true));
        expect(result[Constants.responseResult], isNull);
        expect(
            result[Constants.responseReason], equals(Constants.decideCalled));
      });
    });
    group("decideAll()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId);

        var result = await userContext!.decideAll();

        expect(result[Constants.responseSuccess], equals(true));
        expect(result[Constants.responseResult], isNull);
        expect(
            result[Constants.responseReason], equals(Constants.decideCalled));
      });
    });
    group("setForcedDecision()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId);

        var result = await userContext!.setForcedDecision(
            OptimizelyDecisionContext("flagKey", "ruleKey"),
            OptimizelyForcedDecision("123"));

        expect(result[Constants.responseSuccess], equals(true));
        expect(result[Constants.responseResult], isNull);
        expect(result[Constants.responseReason],
            equals(Constants.forcedDecisionSet));
      });
    });
    group("getForcedDecision()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId);

        var result = await userContext!.getForcedDecision();

        expect(result[Constants.responseSuccess], equals(true));
        expect(result[Constants.responseResult], isNull);
        expect(result[Constants.responseVariationKey], equals("123"));
      });
    });
    group("removeForcedDecision()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId);

        var result = await userContext!.removeForcedDecision(
            OptimizelyDecisionContext("flagKey", "ruleKey"));

        expect(result[Constants.responseSuccess], equals(true));
        expect(result[Constants.responseResult], isNull);
        expect(result[Constants.responseReason],
            equals(Constants.removeForcedDecision));
      });
    });
    group("removeAllForcedDecisions()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var userContext = await sdk.createUserContext(userId);

        var result = await userContext!.removeAllForcedDecisions();

        expect(result[Constants.responseSuccess], equals(true));
        expect(result[Constants.responseResult], isNull);
        expect(result[Constants.responseReason],
            equals(Constants.removeAllForcedDecisions));
      });
    });
    group("addNotificationListener()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        expect(sdk.addDecisionNotificationListener((_) => {}), completes);
      });
    });
    group("removeNotificationListener()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var cancelListener = sdk.addDecisionNotificationListener((_) => {});
        expect(cancelListener, completes);
      });
    });

    test("should receive 1 notification due to same callback used", () async {
      var notifications = [];
      var sdk = OptimizelyFlutterSdk(testSDKKey);
      var callHandler = OptimizelyClientWrapper.methodCallHandler;
      tester?.setMockMethodCallHandler(channel, callHandler);
      // ignore: prefer_function_declarations_over_variables
      void Function(dynamic) callback = (msg) {
        notifications.add(msg);
      };
      sdk.addDecisionNotificationListener(callback);
      sdk.addLogEventNotificationListener(callback);
      sdk.addUpdateConfigNotificationListener(callback);
      sdk.addTrackNotificationListener(callback);
      TestUtils.sendTestNotifications(callHandler, 4);
      expect(notifications.length, equals(1));
      expect(TestUtils.testNotificationPayload(notifications), true);
    });

    test("should receive 4 notification due to different callbacks used",
        () async {
      var notifications = [];
      var sdk = OptimizelyFlutterSdk(testSDKKey);
      sdk.addDecisionNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk.addLogEventNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk.addUpdateConfigNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk.addTrackNotificationListener((msg) {
        notifications.add(msg);
      });
      var callHandler = OptimizelyClientWrapper.methodCallHandler;
      tester?.setMockMethodCallHandler(channel, callHandler);
      TestUtils.sendTestNotifications(callHandler, 4);
      expect(notifications.length, equals(4));
      expect(TestUtils.testNotificationPayload(notifications), true);
    });

    test("should receive notifications with several ListenerTypes", () async {
      var notifications = [];
      var sdk = OptimizelyFlutterSdk(testSDKKey);
      sdk.addDecisionNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk.addDecisionNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk.addLogEventNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk.addLogEventNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk.addUpdateConfigNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk.addUpdateConfigNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk.addTrackNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk.addTrackNotificationListener((msg) {
        notifications.add(msg);
      });
      var callHandler = OptimizelyClientWrapper.methodCallHandler;
      tester?.setMockMethodCallHandler(channel, callHandler);
      TestUtils.sendTestNotifications(callHandler, 8);
      expect(notifications.length, equals(8));
      expect(TestUtils.testNotificationPayload(notifications), true);
    });

    test("should receive notifications with multiple sdkKeys", () async {
      var notifications = [];
      var sdk1 = OptimizelyFlutterSdk(testSDKKey);
      var sdk2 = OptimizelyFlutterSdk(testSDKKey2);

      sdk1.addDecisionNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk1.addLogEventNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk1.addUpdateConfigNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk1.addTrackNotificationListener((msg) {
        notifications.add(msg);
      });

      sdk2.addDecisionNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk2.addLogEventNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk2.addUpdateConfigNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk2.addTrackNotificationListener((msg) {
        notifications.add(msg);
      });

      var callHandler = OptimizelyClientWrapper.methodCallHandler;
      tester?.setMockMethodCallHandler(channel, callHandler);
      TestUtils.sendTestNotifications(callHandler, 8);
      expect(notifications.length, equals(8));
      expect(TestUtils.testNotificationPayload(notifications), true);
    });

    test("should receive 4 notification because of listener removals",
        () async {
      var notifications = [];
      var sdk = OptimizelyFlutterSdk(testSDKKey);

      sdk.addDecisionNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk.addLogEventNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk.addUpdateConfigNotificationListener((msg) {
        notifications.add(msg);
      });
      sdk.addTrackNotificationListener((msg) {
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
      TestUtils.sendTestNotifications(callHandler, 8);
      expect(notifications.length, equals(4));
      expect(TestUtils.testNotificationPayload(notifications), true);
    });
  });
}
