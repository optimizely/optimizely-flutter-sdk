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
import 'constants.dart';
import 'utils.dart';

enum ListenerType { track, decision, logEvent, projectConfigUpdate }

typedef MultiUseCallback = void Function(dynamic msg);
typedef CancelListening = void Function();

/// The internal client class for the Optimizely Flutter SDK used by the main OptimizelyFlutterSdk class.
class OptimizelyClientWrapper {
  static const MethodChannel _channel = MethodChannel('optimizely_flutter_sdk');
  static int nextCallbackId = 0;
  static Map<int, MultiUseCallback> callbacksById = {};

  /// Starts Optimizely SDK (Synchronous) with provided sdkKey.
  static Future<Map<String, dynamic>> initializeClient(String sdkKey) async {
    _channel.setMethodCallHandler(methodCallHandler);
    return Map<String, dynamic>.from(await _channel
        .invokeMethod(Constants.initializeMethod, {Constants.sdkKey: sdkKey}));
  }

  /// Returns a snapshot of the current project configuration.
  static Future<Map<String, dynamic>> getOptimizelyConfig(String sdkKey) async {
    return Map<String, dynamic>.from(await _channel.invokeMethod(
        Constants.getOptimizelyConfigMethod, {Constants.sdkKey: sdkKey}));
  }

  /// Creates a context of the user for which decision APIs will be called.
  ///
  /// A user context will only be created successfully when the SDK is fully configured using initializeClient.
  static Future<Map<String, dynamic>> createUserContext(
      String sdkKey, String userId,
      [Map<String, dynamic> attributes = const {}]) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.createUserContextMethod, {
      Constants.sdkKey: sdkKey,
      Constants.userID: userId,
      Constants.attributes: Utils.covertToTypedMap(attributes)
    }));
  }

  /// Sets attributes for the user context.
  static Future<Map<String, dynamic>> setAttributes(
      String sdkKey, Map<String, dynamic> attributes) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.setAttributesMethod, {
      Constants.sdkKey: sdkKey,
      Constants.attributes: Utils.covertToTypedMap(attributes)
    }));
  }

  /// Tracks an event.
  static Future<Map<String, dynamic>> trackEvent(String sdkKey, String eventKey,
      [Map<String, dynamic> eventTags = const {}]) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.trackEventMethod, {
      Constants.sdkKey: sdkKey,
      Constants.eventKey: eventKey,
      Constants.eventTags: Utils.covertToTypedMap(eventTags)
    }));
  }

  /// Returns a key-map of decision results for multiple flag keys and a user context.
  static Future<Map<String, dynamic>> decide(String sdkKey,
      [List<String> keys = const [], List<String> options = const []]) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.decideMethod, {
      Constants.sdkKey: sdkKey,
      Constants.keys: keys,
      Constants.optimizelyDecideOption: options
    }));
  }

  /// Sets the forced decision for a given decision context.
  static Future<Map<String, dynamic>> setForcedDecision(String sdkKey,
      String flagKey, String ruleKey, String variationKey) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.setForcedDecision, {
      Constants.sdkKey: sdkKey,
      Constants.flagKey: flagKey,
      Constants.ruleKey: ruleKey,
      Constants.variationKey: variationKey,
    }));
  }

  /// Returns the forced decision for a given decision context.
  static Future<Map<String, dynamic>> getForcedDecision(String sdkKey) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.getForcedDecision, {
      Constants.sdkKey: sdkKey,
    }));
  }

  /// Removes the forced decision for a given decision context.
  static Future<Map<String, dynamic>> removeForcedDecision(
      String sdkKey, String flagKey, String ruleKey) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.removeForcedDecision, {
      Constants.sdkKey: sdkKey,
      Constants.flagKey: flagKey,
      Constants.ruleKey: ruleKey,
    }));
  }

  /// Removes all forced decisions bound to this user context.
  static Future<Map<String, dynamic>> removeAllForcedDecisions(
      String sdkKey) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.removeAllForcedDecisions, {
      Constants.sdkKey: sdkKey,
    }));
  }

  /// Allows user to listen to supported notifications.
  static Future<CancelListening> addNotificationListener(String sdkKey,
      MultiUseCallback callback, ListenerType listenerType) async {
    _channel.setMethodCallHandler(methodCallHandler);

    for (var k in callbacksById.keys) {
      if (callbacksById[k] == callback) {
        // ignore: avoid_print
        print("callback already exists.");
        return () {};
      }
    }

    int currentListenerId = nextCallbackId++;
    callbacksById[currentListenerId] = callback;
    // toString returns listenerType as type.logEvent, the following code explodes the string using `.`
    // and returns the valid string value `logEvent`
    var listenerTypeStr = listenerType
        .toString()
        .substring(listenerType.toString().indexOf('.') + 1);
    await _channel.invokeMethod(Constants.addNotificationListenerMethod, {
      Constants.sdkKey: sdkKey,
      Constants.id: currentListenerId,
      Constants.type: listenerTypeStr
    });
    // Returning a callback function that allows the user to remove the added notification listener
    return () {
      _channel.invokeMethod(Constants.removeNotificationListenerMethod,
          {Constants.sdkKey: sdkKey, Constants.id: currentListenerId});
      callbacksById.remove(currentListenerId);
    };
  }

  static Future<void> methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case Constants.callBackListener:
        var id = call.arguments[Constants.id];
        var payload = call.arguments[Constants.payload];
        if (id is int && payload != null && callbacksById.containsKey(id)) {
          callbacksById[id]!(payload);
        }
        break;
      default:
        // ignore: avoid_print
        print('Method ${call.method} not implemented.');
    }
  }
}
