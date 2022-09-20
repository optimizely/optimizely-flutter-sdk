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
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/base_response.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/optimizely_config_response.dart';
import 'package:optimizely_flutter_sdk/src/user_context/optimizely_user_context.dart';
import 'package:optimizely_flutter_sdk/src/utils/constants.dart';
import 'package:optimizely_flutter_sdk/src/utils/utils.dart';

enum ListenerType { track, decision, logEvent, projectConfigUpdate }

enum ClientPlatform { iOS, android }

typedef DecisionNotificationCallback = void Function(
    DecisionListenerResponse msg);
typedef TrackNotificationCallback = void Function(TrackListenerResponse msg);
typedef LogEventNotificationCallback = void Function(
    LogEventListenerResponse msg);
typedef MultiUseCallback = void Function(dynamic msg);
typedef CancelListening = void Function();

/// The internal client class for the Optimizely Flutter SDK used by the main OptimizelyFlutterSdk class.
class OptimizelyClientWrapper {
  static const MethodChannel _channel = MethodChannel('optimizely_flutter_sdk');
  static int nextCallbackId = 0;
  static Map<int, DecisionNotificationCallback> decisionCallbacksById = {};
  static Map<int, TrackNotificationCallback> trackCallbacksById = {};
  static Map<int, LogEventNotificationCallback> logEventCallbacksById = {};
  static Map<int, MultiUseCallback> configUpdateCallbacksById = {};

  /// Starts Optimizely SDK (Synchronous) with provided sdkKey and options.
  static Future<BaseResponse> initializeClient(
      String sdkKey,
      EventOptions eventOptions,
      int datafilePeriodicDownloadInterval,
      Map<ClientPlatform, DatafileHostOptions> datafileHostOptions) async {
    _channel.setMethodCallHandler(methodCallHandler);
    Map<String, dynamic> requestDict = {
      Constants.sdkKey: sdkKey,
      Constants.datafilePeriodicDownloadInterval:
          datafilePeriodicDownloadInterval,
      Constants.eventBatchSize: eventOptions.batchSize,
      Constants.eventTimeInterval: eventOptions.timeInterval,
      Constants.eventMaxQueueSize: eventOptions.maxQueueSize,
    };

    datafileHostOptions.forEach((platform, datafileoptions) {
      // Pass datafile host only if non empty value for current platform is provided
      if (platform.name == defaultTargetPlatform.name &&
          datafileoptions.datafileHostPrefix.isNotEmpty &&
          datafileoptions.datafileHostSuffix.isNotEmpty) {
        requestDict[Constants.datafileHostPrefix] =
            datafileoptions.datafileHostPrefix;
        requestDict[Constants.datafileHostSuffix] =
            datafileoptions.datafileHostSuffix;
      }
    });

    final result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.initializeMethod, requestDict));
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
  static Future<BaseResponse> close(String sdkKey) async {
    final result = Map<String, dynamic>.from(await _channel
        .invokeMethod(Constants.close, {Constants.sdkKey: sdkKey}));
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
      final response =
          Map<String, dynamic>.from(result[Constants.responseResult]);
      return OptimizelyUserContext(
          sdkKey, response[Constants.userContextId], _channel);
    }
    return null;
  }

  static bool checkCallBackExist(dynamic callback) {
    for (var k in decisionCallbacksById.keys) {
      if (decisionCallbacksById[k] == callback) {
        return true;
      }
    }
    for (var k in trackCallbacksById.keys) {
      if (trackCallbacksById[k] == callback) {
        return true;
      }
    }
    for (var k in logEventCallbacksById.keys) {
      if (logEventCallbacksById[k] == callback) {
        return true;
      }
    }
    for (var k in configUpdateCallbacksById.keys) {
      if (configUpdateCallbacksById[k] == callback) {
        return true;
      }
    }
    return false;
  }

  static Future<CancelListening> addDecisionNotificationListener(
      String sdkKey, DecisionNotificationCallback callback) async {
    _channel.setMethodCallHandler(methodCallHandler);

    if (checkCallBackExist(callback)) {
      // ignore: avoid_print
      print("callback already exists.");
      return () {};
    }

    int currentListenerId = nextCallbackId++;
    decisionCallbacksById[currentListenerId] = callback;
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

    if (checkCallBackExist(callback)) {
      // ignore: avoid_print
      print("callback already exists.");
      return () {};
    }

    int currentListenerId = nextCallbackId++;
    trackCallbacksById[currentListenerId] = callback;
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

    if (checkCallBackExist(callback)) {
      // ignore: avoid_print
      print("callback already exists.");
      return () {};
    }

    int currentListenerId = nextCallbackId++;
    logEventCallbacksById[currentListenerId] = callback;
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

    if (checkCallBackExist(callback)) {
      // ignore: avoid_print
      print("callback already exists.");
      return () {};
    }

    int currentListenerId = nextCallbackId++;
    configUpdateCallbacksById[currentListenerId] = callback;
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
    final id = call.arguments[Constants.id];
    final payload = call.arguments[Constants.payload];
    if (id is int && payload != null) {
      switch (call.method) {
        case Constants.decisionCallBackListener:
          final response =
              DecisionListenerResponse(Map<String, dynamic>.from(payload));
          if (decisionCallbacksById.containsKey(id)) {
            decisionCallbacksById[id]!(response);
          }
          break;
        case Constants.trackCallBackListener:
          final response =
              TrackListenerResponse(Map<String, dynamic>.from(payload));
          if (trackCallbacksById.containsKey(id)) {
            trackCallbacksById[id]!(response);
          }
          break;
        case Constants.logEventCallbackListener:
          final response =
              LogEventListenerResponse(Map<String, dynamic>.from(payload));
          if (logEventCallbacksById.containsKey(id)) {
            logEventCallbacksById[id]!(response);
          }
          break;
        case Constants.configUpdateCallBackListener:
          if (configUpdateCallbacksById.containsKey(id)) {
            configUpdateCallbacksById[id]!(payload);
          }
          break;
        default:
          // ignore: avoid_print
          print('Method ${call.method} not implemented.');
      }
    }
  }
}
