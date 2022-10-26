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
import 'package:optimizely_flutter_sdk/src/data_objects/activate_listener_response.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/activate_response.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/base_response.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/get_variation_response.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/optimizely_config_response.dart';
import 'package:optimizely_flutter_sdk/src/utils/constants.dart';
import 'package:optimizely_flutter_sdk/src/utils/utils.dart';

enum ListenerType { activate, track, decision, logEvent, projectConfigUpdate }

enum ClientPlatform { iOS, android }

typedef ActivateNotificationCallback = void Function(
    ActivateListenerResponse msg);
typedef DecisionNotificationCallback = void Function(
    DecisionListenerResponse msg);
typedef TrackNotificationCallback = void Function(TrackListenerResponse msg);
typedef LogEventNotificationCallback = void Function(
    LogEventListenerResponse msg);
typedef MultiUseCallback = void Function(dynamic msg);

/// The internal client class for the Optimizely Flutter SDK used by the main OptimizelyFlutterSdk class.
class OptimizelyClientWrapper {
  static const MethodChannel _channel = MethodChannel('optimizely_flutter_sdk');
  static int nextCallbackId = 0;
  static Map<String, Map<int, ActivateNotificationCallback>>
      activateCallbacksById = {};
  static Map<String, Map<int, DecisionNotificationCallback>>
      decisionCallbacksById = {};
  static Map<String, Map<int, TrackNotificationCallback>> trackCallbacksById =
      {};
  static Map<String, Map<int, LogEventNotificationCallback>>
      logEventCallbacksById = {};
  static Map<String, Map<int, MultiUseCallback>> configUpdateCallbacksById = {};

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

    // clearing notification listeners, if they are mapped to the same sdkKey.
    activateCallbacksById.remove(sdkKey);
    decisionCallbacksById.remove(sdkKey);
    trackCallbacksById.remove(sdkKey);
    logEventCallbacksById.remove(sdkKey);
    configUpdateCallbacksById.remove(sdkKey);

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

  /// Use the activate method to start an experiment.
  ///  The activate call will conditionally activate an experiment for a user based on the provided experiment key and a randomized hash of the provided user ID.
  ///  If the user satisfies audience conditions for the experiment and the experiment is valid and running, the function returns the variation the user is bucketed into.
  ///  Otherwise, activate returns empty variationKey. Make sure that your code adequately deals with the case when the experiment is not activated (e.g. execute the default variation).
  static Future<ActivateResponse> activate(
      String sdkKey, String experimentKey, String userId,
      [Map<String, dynamic> attributes = const {}]) async {
    final result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.activate, {
      Constants.sdkKey: sdkKey,
      Constants.experimentKey: experimentKey,
      Constants.userId: userId,
      Constants.attributes: Utils.convertToTypedMap(attributes)
    }));
    return ActivateResponse(result);
  }

  /// Get variation for experiment and user ID with user attributes.
  static Future<GetVariationResponse> getVariation(
      String sdkKey, String experimentKey, String userId,
      [Map<String, dynamic> attributes = const {}]) async {
    final result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.getVariation, {
      Constants.sdkKey: sdkKey,
      Constants.experimentKey: experimentKey,
      Constants.userId: userId,
      Constants.attributes: Utils.convertToTypedMap(attributes)
    }));
    return GetVariationResponse(result);
  }

  /// Get forced variation for experiment and user ID.
  static Future<GetVariationResponse> getForcedVariation(
      String sdkKey, String experimentKey, String userId) async {
    final result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.getForcedVariation, {
      Constants.sdkKey: sdkKey,
      Constants.experimentKey: experimentKey,
      Constants.userId: userId,
    }));
    return GetVariationResponse(result);
  }

  /// Set forced variation for experiment and user ID to variationKey.
  static Future<BaseResponse> setForcedVariation(
      String sdkKey, String experimentKey, String userId,
      [String variationKey = ""]) async {
    Map<String, dynamic> request = {
      Constants.sdkKey: sdkKey,
      Constants.experimentKey: experimentKey,
      Constants.userId: userId,
    };
    if (variationKey != "") {
      request[Constants.variationKey] = variationKey;
    }
    final result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.setForcedVariation, request));
    return BaseResponse(result);
  }

  /// Returns a snapshot of the current project configuration.
  static Future<OptimizelyConfigResponse> getOptimizelyConfig(
      String sdkKey) async {
    final result = Map<String, dynamic>.from(await _channel.invokeMethod(
        Constants.getOptimizelyConfigMethod, {Constants.sdkKey: sdkKey}));
    return OptimizelyConfigResponse(result);
  }

  /// Remove notification listener by notification id.
  static Future<BaseResponse> removeNotificationListener(
      String sdkKey, int id) async {
    Map<String, dynamic> request = {Constants.sdkKey: sdkKey, Constants.id: id};

    activateCallbacksById[sdkKey]?.remove(id);
    decisionCallbacksById[sdkKey]?.remove(id);
    logEventCallbacksById[sdkKey]?.remove(id);
    configUpdateCallbacksById[sdkKey]?.remove(id);
    trackCallbacksById[sdkKey]?.remove(id);

    final result = Map<String, dynamic>.from(await _channel.invokeMethod(
        Constants.removeNotificationListenerMethod, request));
    return BaseResponse(result);
  }

  /// Remove notification listeners by notification type.
  static Future<BaseResponse> clearNotificationListeners(
      String sdkKey, ListenerType listenerType) async {
    var callbackIds = _clearAllCallbacks(sdkKey, listenerType);
    Map<String, dynamic> request = {
      Constants.sdkKey: sdkKey,
      Constants.type: listenerType.name,
      Constants.callbackIds: callbackIds
    };
    final result = Map<String, dynamic>.from(await _channel.invokeMethod(
        Constants.clearNotificationListenersMethod, request));
    return BaseResponse(result);
  }

  /// Removes all notification listeners.
  static Future<BaseResponse> clearAllNotificationListeners(
      String sdkKey) async {
    var callbackIds = _clearAllCallbacks(sdkKey);
    Map<String, dynamic> request = {
      Constants.sdkKey: sdkKey,
      Constants.callbackIds: callbackIds
    };
    final result = Map<String, dynamic>.from(await _channel.invokeMethod(
        Constants.clearAllNotificationListenersMethod, request));
    return BaseResponse(result);
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
      Constants.userId: userId,
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

  static List<int> _clearAllCallbacks(String sdkKey,
      [ListenerType? listenerType]) {
    var callbackIds = <int>[];
    if (listenerType == null || listenerType == ListenerType.activate) {
      if (activateCallbacksById.containsKey(sdkKey)) {
        callbackIds.addAll(activateCallbacksById[sdkKey]!.keys);
        activateCallbacksById[sdkKey]!.clear();
      }
    }
    if (listenerType == null || listenerType == ListenerType.decision) {
      if (decisionCallbacksById.containsKey(sdkKey)) {
        callbackIds.addAll(decisionCallbacksById[sdkKey]!.keys);
        decisionCallbacksById[sdkKey]!.clear();
      }
    }
    if (listenerType == null || listenerType == ListenerType.logEvent) {
      if (logEventCallbacksById.containsKey(sdkKey)) {
        callbackIds.addAll(logEventCallbacksById[sdkKey]!.keys);
        logEventCallbacksById[sdkKey]!.clear();
      }
    }
    if (listenerType == null ||
        listenerType == ListenerType.projectConfigUpdate) {
      if (configUpdateCallbacksById.containsKey(sdkKey)) {
        callbackIds.addAll(configUpdateCallbacksById[sdkKey]!.keys);
        configUpdateCallbacksById[sdkKey]!.clear();
      }
    }
    if (listenerType == null || listenerType == ListenerType.track) {
      if (trackCallbacksById.containsKey(sdkKey)) {
        callbackIds.addAll(trackCallbacksById[sdkKey]!.keys);
        trackCallbacksById[sdkKey]!.clear();
      }
    }
    return callbackIds;
  }

  static bool checkCallBackExist(String sdkKey, dynamic callback) {
    if (activateCallbacksById.containsKey(sdkKey)) {
      for (var k in activateCallbacksById[sdkKey]!.keys) {
        if (activateCallbacksById[sdkKey]![k] == callback) {
          return true;
        }
      }
    }
    if (decisionCallbacksById.containsKey(sdkKey)) {
      for (var k in decisionCallbacksById[sdkKey]!.keys) {
        if (decisionCallbacksById[sdkKey]![k] == callback) {
          return true;
        }
      }
    }
    if (trackCallbacksById.containsKey(sdkKey)) {
      for (var k in trackCallbacksById[sdkKey]!.keys) {
        if (trackCallbacksById[sdkKey]![k] == callback) {
          return true;
        }
      }
    }
    if (logEventCallbacksById.containsKey(sdkKey)) {
      for (var k in logEventCallbacksById[sdkKey]!.keys) {
        if (logEventCallbacksById[sdkKey]![k] == callback) {
          return true;
        }
      }
    }
    if (configUpdateCallbacksById.containsKey(sdkKey)) {
      for (var k in configUpdateCallbacksById[sdkKey]!.keys) {
        if (configUpdateCallbacksById[sdkKey]![k] == callback) {
          return true;
        }
      }
    }
    return false;
  }

  static Future<int> addActivateNotificationListener(
      String sdkKey, ActivateNotificationCallback callback) async {
    _channel.setMethodCallHandler(methodCallHandler);

    if (checkCallBackExist(sdkKey, callback)) {
      // ignore: avoid_print
      print("callback already exists.");
      return -1;
    }

    int currentListenerId = nextCallbackId++;
    activateCallbacksById.putIfAbsent(sdkKey, () => {});
    activateCallbacksById[sdkKey]?[currentListenerId] = callback;
    final listenerTypeStr = ListenerType.activate.name;
    await _channel.invokeMethod(Constants.addNotificationListenerMethod, {
      Constants.sdkKey: sdkKey,
      Constants.id: currentListenerId,
      Constants.type: listenerTypeStr
    });
    // Returning an id that allows the user to remove the added notification listener.
    return currentListenerId;
  }

  static Future<int> addDecisionNotificationListener(
      String sdkKey, DecisionNotificationCallback callback) async {
    _channel.setMethodCallHandler(methodCallHandler);

    if (checkCallBackExist(sdkKey, callback)) {
      // ignore: avoid_print
      print("callback already exists.");
      return -1;
    }

    int currentListenerId = nextCallbackId++;
    decisionCallbacksById.putIfAbsent(sdkKey, () => {});
    decisionCallbacksById[sdkKey]?[currentListenerId] = callback;
    final listenerTypeStr = ListenerType.decision.name;
    await _channel.invokeMethod(Constants.addNotificationListenerMethod, {
      Constants.sdkKey: sdkKey,
      Constants.id: currentListenerId,
      Constants.type: listenerTypeStr
    });
    // Returning an id that allows the user to remove the added notification listener
    return currentListenerId;
  }

  static Future<int> addTrackNotificationListener(
      String sdkKey, TrackNotificationCallback callback) async {
    _channel.setMethodCallHandler(methodCallHandler);

    if (checkCallBackExist(sdkKey, callback)) {
      // ignore: avoid_print
      print("callback already exists.");
      return -1;
    }

    int currentListenerId = nextCallbackId++;
    trackCallbacksById.putIfAbsent(sdkKey, () => {});
    trackCallbacksById[sdkKey]?[currentListenerId] = callback;
    final listenerTypeStr = ListenerType.track.name;
    await _channel.invokeMethod(Constants.addNotificationListenerMethod, {
      Constants.sdkKey: sdkKey,
      Constants.id: currentListenerId,
      Constants.type: listenerTypeStr
    });
    // Returning an id that allows the user to remove the added notification listener
    return currentListenerId;
  }

  static Future<int> addLogEventNotificationListener(
      String sdkKey, LogEventNotificationCallback callback) async {
    _channel.setMethodCallHandler(methodCallHandler);

    if (checkCallBackExist(sdkKey, callback)) {
      // ignore: avoid_print
      print("callback already exists.");
      return -1;
    }

    int currentListenerId = nextCallbackId++;
    logEventCallbacksById.putIfAbsent(sdkKey, () => {});
    logEventCallbacksById[sdkKey]?[currentListenerId] = callback;
    final listenerTypeStr = ListenerType.logEvent.name;
    await _channel.invokeMethod(Constants.addNotificationListenerMethod, {
      Constants.sdkKey: sdkKey,
      Constants.id: currentListenerId,
      Constants.type: listenerTypeStr
    });
    // Returning an id that allows the user to remove the added notification listener
    return currentListenerId;
  }

  /// Allows user to listen to supported notifications.
  static Future<int> addConfigUpdateNotificationListener(
      String sdkKey, MultiUseCallback callback) async {
    _channel.setMethodCallHandler(methodCallHandler);

    if (checkCallBackExist(sdkKey, callback)) {
      // ignore: avoid_print
      print("callback already exists.");
      return -1;
    }

    int currentListenerId = nextCallbackId++;
    configUpdateCallbacksById.putIfAbsent(sdkKey, () => {});
    configUpdateCallbacksById[sdkKey]?[currentListenerId] = callback;
    final listenerTypeStr = ListenerType.projectConfigUpdate.name;
    await _channel.invokeMethod(Constants.addNotificationListenerMethod, {
      Constants.sdkKey: sdkKey,
      Constants.id: currentListenerId,
      Constants.type: listenerTypeStr
    });
    // Returning an id that allows the user to remove the added notification listener
    return currentListenerId;
  }

  static Future<void> methodCallHandler(MethodCall call) async {
    final id = call.arguments[Constants.id];
    final sdkKey = call.arguments[Constants.sdkKey];
    final payload = call.arguments[Constants.payload];
    if (id is int && payload != null) {
      switch (call.method) {
        case Constants.activateCallBackListener:
          final response =
              ActivateListenerResponse(Map<String, dynamic>.from(payload));
          if (activateCallbacksById.containsKey(sdkKey) &&
              activateCallbacksById[sdkKey]!.containsKey(id)) {
            activateCallbacksById[sdkKey]![id]!(response);
          }
          break;
        case Constants.decisionCallBackListener:
          final response =
              DecisionListenerResponse(Map<String, dynamic>.from(payload));
          if (decisionCallbacksById.containsKey(sdkKey) &&
              decisionCallbacksById[sdkKey]!.containsKey(id)) {
            decisionCallbacksById[sdkKey]![id]!(response);
          }
          break;
        case Constants.trackCallBackListener:
          final response =
              TrackListenerResponse(Map<String, dynamic>.from(payload));
          if (trackCallbacksById.containsKey(sdkKey) &&
              trackCallbacksById[sdkKey]!.containsKey(id)) {
            trackCallbacksById[sdkKey]![id]!(response);
          }
          break;
        case Constants.logEventCallbackListener:
          final response =
              LogEventListenerResponse(Map<String, dynamic>.from(payload));
          if (logEventCallbacksById.containsKey(sdkKey) &&
              logEventCallbacksById[sdkKey]!.containsKey(id)) {
            logEventCallbacksById[sdkKey]![id]!(response);
          }
          break;
        case Constants.configUpdateCallBackListener:
          if (configUpdateCallbacksById.containsKey(sdkKey) &&
              configUpdateCallbacksById[sdkKey]!.containsKey(id)) {
            configUpdateCallbacksById[sdkKey]![id]!(payload);
          }
          break;
        default:
          // ignore: avoid_print
          print('Method ${call.method} not implemented.');
      }
    }
  }
}
