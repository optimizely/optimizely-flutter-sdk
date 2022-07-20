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

import 'test_utils.dart';

void main() {
  const String testSDKKey = "KZbunNn9bVfBWLpZPq2XC4";
  const String testSDKKey2 = "KZbunNn9bVfBWLpZPq2XC12";
  const String userId = "uid-351ea8";
  const String successKey = "success";
  const String resultKey = "result";
  const String reasonKey = "reason";
  const MethodChannel channel = MethodChannel("optimizely_flutter_sdk");
  const mockOptimizelyConfig = {
    "sdkKey": testSDKKey,
    "environmentKey": "production",
    "attributes": [
      {"id": "16921322086", "key": "attr_1"}
    ],
    "audiences": [
      {
        "id": "16902921321",
        "conditions":
            "[\"and\",[\"or\",[\"or\",{\"match\":\"exact\",\"name\":\"attr_1\",\"type\":\"custom_attribute\",\"value\":\"hola\"}]]]",
        "name": "Audience1"
      }
    ],
    "events": [
      {
        "experimentIds": ["16910084756", "16911963060"],
        "id": "16911532385",
        "key": "myevent"
      }
    ],
    "revision": "130",
    "experimentsMap": {
      "ab_test1": {
        "id": "16911963060",
        "key": "ab_test1",
        "audiences": "\"Audience1\"",
        "variationsMap": {
          "variation_1": {
            "id": "16905941566",
            "key": "variation_1",
            "featureEnabled": true,
            "variablesMap": {}
          },
          "variation_2": {
            "id": "16927770169",
            "key": "variation_2",
            "featureEnabled": true,
            "variablesMap": {}
          }
        }
      },
      "feature_2_test": {
        "id": "16910084756",
        "key": "feature_2_test",
        "audiences": "\"Audience1\"",
        "variationsMap": {
          "variation_1": {
            "id": "16925360560",
            "key": "variation_1",
            "featureEnabled": true,
            "variablesMap": {}
          },
          "variation_2": {
            "id": "16915611472",
            "key": "variation_2",
            "featureEnabled": true,
            "variablesMap": {}
          }
        }
      }
    },
    "featuresMap": {
      "flag_ab_test1": {
        "id": "12672",
        "key": "flag_ab_test1",
        "experimentRules": [
          {
            "id": "16911963060",
            "key": "ab_test1",
            "audiences": "\"Audience1\"",
            "variationsMap": {
              "variation_1": {
                "id": "16905941566",
                "key": "variation_1",
                "featureEnabled": true,
                "variablesMap": {}
              },
              "variation_2": {
                "id": "16927770169",
                "key": "variation_2",
                "featureEnabled": true,
                "variablesMap": {}
              }
            }
          }
        ],
        "deliveryRules": [
          {
            "id": "default-rollout-12672-16935023792",
            "key": "default-rollout-12672-16935023792",
            "audiences": "",
            "variationsMap": {
              "off": {
                "id": "35771",
                "key": "off",
                "featureEnabled": false,
                "variablesMap": {}
              }
            }
          }
        ],
        "experimentsMap": {
          "ab_test1": {
            "id": "16911963060",
            "key": "ab_test1",
            "audiences": "\"Audience1\"",
            "variationsMap": {
              "variation_1": {
                "id": "16905941566",
                "key": "variation_1",
                "featureEnabled": true,
                "variablesMap": {}
              },
              "variation_2": {
                "id": "16927770169",
                "key": "variation_2",
                "featureEnabled": true,
                "variablesMap": {}
              }
            }
          }
        },
        "variablesMap": {}
      },
      "feature_2": {
        "id": "16928980973",
        "key": "feature_2",
        "experimentRules": [
          {
            "id": "16910084756",
            "key": "feature_2_test",
            "audiences": "\"Audience1\"",
            "variationsMap": {
              "variation_1": {
                "id": "16925360560",
                "key": "variation_1",
                "featureEnabled": true,
                "variablesMap": {}
              },
              "variation_2": {
                "id": "16915611472",
                "key": "variation_2",
                "featureEnabled": true,
                "variablesMap": {}
              }
            }
          }
        ],
        "deliveryRules": [
          {
            "id": "16924931120",
            "key": "16924931120",
            "audiences": "\"Audience1\"",
            "variationsMap": {
              "16931381940": {
                "id": "16931381940",
                "key": "16931381940",
                "featureEnabled": true,
                "variablesMap": {}
              }
            }
          },
          {
            "id": "18234756110",
            "key": "18234756110",
            "audiences": "",
            "variationsMap": {
              "18244927831": {
                "id": "18244927831",
                "key": "18244927831",
                "featureEnabled": true,
                "variablesMap": {}
              }
            }
          },
          {
            "id": "default-16917900798",
            "key": "default-16917900798",
            "audiences": "",
            "variationsMap": {
              "off": {
                "id": "35770",
                "key": "off",
                "featureEnabled": false,
                "variablesMap": {}
              }
            }
          }
        ],
        "experimentsMap": {
          "feature_2_test": {
            "id": "16910084756",
            "key": "feature_2_test",
            "audiences": "\"Audience1\"",
            "variationsMap": {
              "variation_1": {
                "id": "16925360560",
                "key": "variation_1",
                "featureEnabled": true,
                "variablesMap": {}
              },
              "variation_2": {
                "id": "16915611472",
                "key": "variation_2",
                "featureEnabled": true,
                "variablesMap": {}
              }
            }
          }
        },
        "variablesMap": {}
      },
    },
    "datafile": "<JSON stringified version of datafile here>"
  };

  TestDefaultBinaryMessenger? tester;

  setUp(() async {
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
            "success": true,
            "reason": Constants.instanceCreated,
          };
        case Constants.getOptimizelyConfigMethod:
          return {
            "success": true,
            "reason": Constants.optimizelyConfigFound,
            "result": mockOptimizelyConfig,
          };
        case Constants.createUserContextMethod:
          return {
            "success": true,
            "reason": Constants.userContextCreated,
          };
        case Constants.setAttributesMethod:
          return {
            "success": true,
            "reason": Constants.attributesAdded,
          };
        case Constants.trackEventMethod:
          return {
            "success": true,
          };
        case Constants.decideMethod:
          return {
            "success": true,
            "reason": Constants.decideCalled,
          };
        case Constants.addNotificationListenerMethod:
          return {
            "success": true,
            "reason": Constants.listenerAdded,
          };
        case Constants.removeNotificationListenerMethod:
          return {
            "success": true,
            "reason": Constants.listenerRemoved,
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

        expect(result[successKey], equals(true));
        expect(result[resultKey], isNull);
        expect(result[reasonKey], equals(Constants.instanceCreated));
      });
    });
    group("getOptimizelyConfig()", () {
      test("returns valid digested OptimizelyConfig should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        var result = await sdk.getOptimizelyConfig();
        var config = result[resultKey];

        expect(result[successKey], equals(true));
        expect(result[resultKey], isNotNull);
        expect(result[reasonKey], equals(Constants.optimizelyConfigFound));

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

        var result = await sdk.createUserContext(userId);

        expect(result[successKey], equals(true));
        expect(result[resultKey], isNull);
        expect(result[reasonKey], equals(Constants.userContextCreated));
      });
    });
    group("setAttributes()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var attributes = Map<String, dynamic>();

        var result = await sdk.setAttributes(attributes);

        expect(result[successKey], equals(true));
        expect(result[resultKey], isNull);
        expect(result[reasonKey], equals(Constants.attributesAdded));
      });
    });
    group("trackEvent()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var eventKey = "event-key";

        var result = await sdk.trackEvent(eventKey);

        expect(result[successKey], equals(true));
        expect(result[resultKey], isNull);
        expect(result[reasonKey], isNull);
      });
    });
    group("decide()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var decideKey = "decide-key";

        var result = await sdk.decide(decideKey);

        expect(result[successKey], equals(true));
        expect(result[resultKey], isNull);
        expect(result[reasonKey], Constants.decideCalled);
      });
    });
    group("decideForKeys()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var decideKeys = ["decide-key-1", "decide-key-2"];

        var result = await sdk.decideForKeys(decideKeys);

        expect(result[successKey], equals(true));
        expect(result[resultKey], isNull);
        expect(result[reasonKey], equals(Constants.decideCalled));
      });
    });
    group("decideAll()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        var result = await sdk.decideAll();

        expect(result[successKey], equals(true));
        expect(result[resultKey], isNull);
        expect(result[reasonKey], equals(Constants.decideCalled));
      });
    });
    group("addNotificationListener()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);

        expect(sdk.addNotificationListener((_) => {}, ListenerType.decision),
            completes);
      });
    });
    group("removeNotificationListener()", () {
      test("should succeed", () async {
        var sdk = OptimizelyFlutterSdk(testSDKKey);
        var cancelListener =
            sdk.addNotificationListener((_) => {}, ListenerType.decision);
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
      sdk.addNotificationListener(callback, ListenerType.decision);
      sdk.addNotificationListener(callback, ListenerType.logEvent);
      sdk.addNotificationListener(callback, ListenerType.projectConfigUpdate);
      sdk.addNotificationListener(callback, ListenerType.track);
      TestUtils.sendTestNotifications(callHandler, 4);
      expect(notifications.length, equals(1));
      expect(TestUtils.testNotificationPayload(notifications), true);
    });

    test("should receive 4 notification due to different callbacks used",
        () async {
      var notifications = [];
      var sdk = OptimizelyFlutterSdk(testSDKKey);
      sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.decision);
      sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.logEvent);
      sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.projectConfigUpdate);
      sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.track);
      var callHandler = OptimizelyClientWrapper.methodCallHandler;
      tester?.setMockMethodCallHandler(channel, callHandler);
      TestUtils.sendTestNotifications(callHandler, 4);
      expect(notifications.length, equals(4));
      expect(TestUtils.testNotificationPayload(notifications), true);
    });

    test("should receive notifications with several ListenerTypes", () async {
      var notifications = [];
      var sdk = OptimizelyFlutterSdk(testSDKKey);
      sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.decision);
      sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.decision);
      sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.logEvent);
      sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.logEvent);
      sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.projectConfigUpdate);
      sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.projectConfigUpdate);
      sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.track);
      sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.track);
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

      sdk1.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.decision);
      sdk1.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.logEvent);
      sdk1.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.projectConfigUpdate);
      sdk1.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.track);

      sdk2.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.decision);
      sdk2.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.logEvent);
      sdk2.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.projectConfigUpdate);
      sdk2.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.track);

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

      sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.decision);
      sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.logEvent);
      sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.projectConfigUpdate);
      sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.track);

      var cancel = await sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.decision);
      cancel();
      cancel = await sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.logEvent);
      cancel();
      cancel = await sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.projectConfigUpdate);
      cancel();
      cancel = await sdk.addNotificationListener((msg) {
        notifications.add(msg);
      }, ListenerType.track);
      cancel();

      var callHandler = OptimizelyClientWrapper.methodCallHandler;
      tester?.setMockMethodCallHandler(channel, callHandler);
      TestUtils.sendTestNotifications(callHandler, 8);
      expect(notifications.length, equals(4));
      expect(TestUtils.testNotificationPayload(notifications), true);
    });
  });
}
