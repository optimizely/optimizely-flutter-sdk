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

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/base_response.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/decision_listener_response.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/track_listener_response.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/logevent_listener_response.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/optimizely_config_response.dart';
import 'package:optimizely_flutter_sdk/src/user_context/optimizely_user_context.dart';
import 'package:optimizely_flutter_sdk/src/utils/constants.dart';
import 'package:optimizely_flutter_sdk/src/utils/utils.dart';

enum ListenerType { track, decision, logEvent, projectConfigUpdate }

typedef MultiUseCallback = void Function(dynamic msg);
typedef DecisionNotificationCallback = void Function(
    DecisionListenerResponse msg);
typedef TrackNotificationCallback = void Function(TrackListenerResponse msg);
typedef LogEventNotificationCallback = void Function(
    LogEventListenerResponse msg);
typedef CancelListening = void Function();

/// The internal client class for the Optimizely Flutter SDK used by the main OptimizelyFlutterSdk class.
class OptimizelyClientWrapper {
  static const MethodChannel _channel = MethodChannel('optimizely_flutter_sdk');
  static int nextCallbackId = 0;
  static Map<int, DecisionNotificationCallback> decisionCallbacksById = {};
  static Map<int, TrackNotificationCallback> trackCallbacksById = {};
  static Map<int, LogEventNotificationCallback> logEventCallbacksById = {};
  static Map<int, MultiUseCallback> configUpdateCallbacksById = {};

  /// Starts Optimizely SDK (Synchronous) with provided sdkKey.
  static Future<BaseResponse> initializeClient(String sdkKey) async {
    _channel.setMethodCallHandler(methodCallHandler);
    final result = Map<String, dynamic>.from(await _channel
        .invokeMethod(Constants.initializeMethod, {Constants.sdkKey: sdkKey}));
    return BaseResponse(result);
  }

  /// Returns a snapshot of the current project configuration.
  static Future<OptimizelyConfigResponse> getOptimizelyConfig(
      String sdkKey) async {
    final result = Map<String, dynamic>.from(await _channel.invokeMethod(
        Constants.getOptimizelyConfigMethod, {Constants.sdkKey: sdkKey}));
    return OptimizelyConfigResponse(result);
  }

  /// Returns a success true if optimizely client closed successfully.
  static Future<BaseResponse> close(
      String sdkKey) async {
    final result = Map<String, dynamic>.from(await _channel.invokeMethod(
        Constants.close, {Constants.sdkKey: sdkKey}));
    return BaseResponse(result);
  }

  /// Creates a context of the user for which decision APIs will be called.
  ///
  /// A user context will only be created successfully when the SDK is fully configured using initializeClient.
  static Future<OptimizelyUserContext?> createUserContext(
      String sdkKey, String userId,
      [Map<String, dynamic> attributes = const {}]) async {
    final result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.createUserContextMethod, {
      Constants.sdkKey: sdkKey,
      Constants.userID: userId,
      Constants.attributes: Utils.convertToTypedMap(attributes)
    }));
    if (result[Constants.responseSuccess] == true) {
      return OptimizelyUserContext(sdkKey, _channel);
    }
    return null;
  }

  static Future<CancelListening> addDecisionNotificationListener(
      String sdkKey, DecisionNotificationCallback callback) async {
    _channel.setMethodCallHandler(methodCallHandler);

    for (var k in decisionCallbacksById.keys) {
      if (decisionCallbacksById[k] == callback) {
        // ignore: avoid_print
        print("callback already exists.");
        return () {};
      }
    }

    int currentListenerId = nextCallbackId++;
    decisionCallbacksById[currentListenerId] = callback;
    // toString returns listenerType as type.logEvent, the following code explodes the string using `.`
    // and returns the valid string value `logEvent`
    final listenerTypeStr = ListenerType.decision.name;
    await _channel.invokeMethod(Constants.addNotificationListenerMethod, {
      Constants.sdkKey: sdkKey,
      Constants.id: currentListenerId,
      Constants.type: listenerTypeStr
    });
    // Returning a callback function that allows the user to remove the added notification listener
    return () {
      _channel.invokeMethod(Constants.removeNotificationListenerMethod,
          {Constants.sdkKey: sdkKey, Constants.id: currentListenerId});
      decisionCallbacksById.remove(currentListenerId);
    };
  }

  static Future<CancelListening> addTrackNotificationListener(
      String sdkKey, TrackNotificationCallback callback) async {
    _channel.setMethodCallHandler(methodCallHandler);

    for (var k in trackCallbacksById.keys) {
      if (trackCallbacksById[k] == callback) {
        // ignore: avoid_print
        print("callback already exists.");
        return () {};
      }
    }

    int currentListenerId = nextCallbackId++;
    trackCallbacksById[currentListenerId] = callback;
    // toString returns listenerType as type.logEvent, the following code explodes the string using `.`
    // and returns the valid string value `logEvent`
    final listenerTypeStr = ListenerType.track.name;
    await _channel.invokeMethod(Constants.addNotificationListenerMethod, {
      Constants.sdkKey: sdkKey,
      Constants.id: currentListenerId,
      Constants.type: listenerTypeStr
    });
    // Returning a callback function that allows the user to remove the added notification listener
    return () {
      _channel.invokeMethod(Constants.removeNotificationListenerMethod,
          {Constants.sdkKey: sdkKey, Constants.id: currentListenerId});
      trackCallbacksById.remove(currentListenerId);
    };
  }

  static Future<CancelListening> addLogEventNotificationListener(
      String sdkKey, LogEventNotificationCallback callback) async {
    _channel.setMethodCallHandler(methodCallHandler);

    for (var k in logEventCallbacksById.keys) {
      if (logEventCallbacksById[k] == callback) {
        // ignore: avoid_print
        print("callback already exists.");
        return () {};
      }
    }

    int currentListenerId = nextCallbackId++;
    logEventCallbacksById[currentListenerId] = callback;
    // toString returns listenerType as type.logEvent, the following code explodes the string using `.`
    // and returns the valid string value `logEvent`
    final listenerTypeStr = ListenerType.logEvent.name;
    await _channel.invokeMethod(Constants.addNotificationListenerMethod, {
      Constants.sdkKey: sdkKey,
      Constants.id: currentListenerId,
      Constants.type: listenerTypeStr
    });
    // Returning a callback function that allows the user to remove the added notification listener
    return () {
      _channel.invokeMethod(Constants.removeNotificationListenerMethod,
          {Constants.sdkKey: sdkKey, Constants.id: currentListenerId});
      logEventCallbacksById.remove(currentListenerId);
    };
  }

  /// Allows user to listen to supported notifications.
  static Future<CancelListening> addConfigUpdateNotificationListener(
      String sdkKey, MultiUseCallback callback) async {
    _channel.setMethodCallHandler(methodCallHandler);

    for (var k in configUpdateCallbacksById.keys) {
      if (configUpdateCallbacksById[k] == callback) {
        // ignore: avoid_print
        print("callback already exists.");
        return () {};
      }
    }

    int currentListenerId = nextCallbackId++;
    configUpdateCallbacksById[currentListenerId] = callback;
    // toString returns listenerType as type.logEvent, the following code explodes the string using `.`
    // and returns the valid string value `logEvent`
    final listenerTypeStr = ListenerType.projectConfigUpdate.name;
    await _channel.invokeMethod(Constants.addNotificationListenerMethod, {
      Constants.sdkKey: sdkKey,
      Constants.id: currentListenerId,
      Constants.type: listenerTypeStr
    });
    // Returning a callback function that allows the user to remove the added notification listener
    return () {
      _channel.invokeMethod(Constants.removeNotificationListenerMethod,
          {Constants.sdkKey: sdkKey, Constants.id: currentListenerId});
      configUpdateCallbacksById.remove(currentListenerId);
    };
  }

  static Future<void> methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case Constants.decisionCallBackListener:
        final id = call.arguments[Constants.id];
        final payload = DecisionListenerResponse(
            Map<String, dynamic>.from(call.arguments[Constants.payload]));
        if (id is int && decisionCallbacksById.containsKey(id)) {
          decisionCallbacksById[id]!(payload);
        }
        break;
      case Constants.trackCallBackListener:
        final id = call.arguments[Constants.id];
        final payload = TrackListenerResponse(
            Map<String, dynamic>.from(call.arguments[Constants.payload]));
        if (id is int && trackCallbacksById.containsKey(id)) {
          trackCallbacksById[id]!(payload);
        }
        break;
      case Constants.logEventCallbackListener:
        final id = call.arguments[Constants.id];
        final payload = LogEventListenerResponse(
            Map<String, dynamic>.from(call.arguments[Constants.payload]));
        if (id is int && logEventCallbacksById.containsKey(id)) {
          logEventCallbacksById[id]!(payload);
        }
        break;
      case Constants.configUpdateCallBackListener:
        final id = call.arguments[Constants.id];
        final payload = call.arguments[Constants.payload];
        if (id is int && configUpdateCallbacksById.containsKey(id)) {
          configUpdateCallbacksById[id]!(payload);
        }
        break;
      default:
        // ignore: avoid_print
        print('Method ${call.method} not implemented.');
    }
  }
}
