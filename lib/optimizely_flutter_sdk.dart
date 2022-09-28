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

library optimizely_flutter_sdk;

import 'dart:async';
import 'package:optimizely_flutter_sdk/src/data_objects/activate_response.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/base_response.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/datafile_options.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/event_options.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/get_variation_response.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/optimizely_config_response.dart';
import 'package:optimizely_flutter_sdk/src/optimizely_client_wrapper.dart';
import 'package:optimizely_flutter_sdk/src/user_context/optimizely_user_context.dart';

export 'package:optimizely_flutter_sdk/src/optimizely_client_wrapper.dart'
    show ClientPlatform;
export 'package:optimizely_flutter_sdk/src/user_context/optimizely_forced_decision.dart'
    show OptimizelyForcedDecision;
export 'package:optimizely_flutter_sdk/src/user_context/optimizely_decision_context.dart'
    show OptimizelyDecisionContext;
export 'package:optimizely_flutter_sdk/src/user_context/optimizely_user_context.dart'
    show OptimizelyUserContext, OptimizelyDecideOption;
export 'package:optimizely_flutter_sdk/src/data_objects/decide_response.dart'
    show Decision;
export 'package:optimizely_flutter_sdk/src/data_objects/track_listener_response.dart'
    show TrackListenerResponse;
export 'package:optimizely_flutter_sdk/src/data_objects/decision_listener_response.dart'
    show DecisionListenerResponse;
export 'package:optimizely_flutter_sdk/src/data_objects/logevent_listener_response.dart'
    show LogEventListenerResponse;
export 'package:optimizely_flutter_sdk/src/data_objects/event_options.dart'
    show EventOptions;
export 'package:optimizely_flutter_sdk/src/data_objects/datafile_options.dart'
    show DatafileHostOptions;

/// The main client class for the Optimizely Flutter SDK.
///
/// To use, create an instance of OptimizelyFlutterSdk class with a valid sdkKey, datafilePeriodicDownloadInterval (optional), eventOptions (optional) and
/// call initializeClient method.
/// If successfull, call createUserContext to setup user context.
/// Once done, all API's should be available.
class OptimizelyFlutterSdk {
  final String _sdkKey;
  final EventOptions _eventOptions;
  final int _datafilePeriodicDownloadInterval;
  final Map<ClientPlatform, DatafileHostOptions> _datafileHostOptions;

  OptimizelyFlutterSdk(
    this._sdkKey, {
    EventOptions eventOptions = const EventOptions(),
    int datafilePeriodicDownloadInterval =
        10 * 60, // Default time interval in seconds
    Map<ClientPlatform, DatafileHostOptions> datafileHostOptions = const {},
  })  : _eventOptions = eventOptions,
        _datafilePeriodicDownloadInterval = datafilePeriodicDownloadInterval,
        _datafileHostOptions = datafileHostOptions;

  /// Starts Optimizely SDK (Synchronous) with provided sdkKey.
  Future<BaseResponse> initializeClient() async {
    return await OptimizelyClientWrapper.initializeClient(_sdkKey,
        _eventOptions, _datafilePeriodicDownloadInterval, _datafileHostOptions);
  }

  /// Use the activate method to start an experiment.
  ///  The activate call will conditionally activate an experiment for a user based on the provided experiment key and a randomized hash of the provided user ID.
  ///  If the user satisfies audience conditions for the experiment and the experiment is valid and running, the function returns the variation the user is bucketed into.
  ///  Otherwise, activate returns empty variationKey. Make sure that your code adequately deals with the case when the experiment is not activated (e.g. execute the default variation).
  ///
  /// Takes [experimentKey] The key of the experiment to set with the forced variation.
  /// Takes [userId] The ID of the user to force into the variation.
  /// Takes [attributes] A [Map] of custom key-value string pairs specifying attributes for the user.
  /// Returns [ActivateResponse] The key of the variation where the user is bucketed, or `empty variationKey` if the user
  ///                        doesn't qualify for the experiment.
  Future<ActivateResponse> activate(String experimentKey, String userId,
      [Map<String, dynamic> attributes = const {}]) async {
    return await OptimizelyClientWrapper.activate(
        _sdkKey, experimentKey, userId, attributes);
  }

  /// Get variation for experiment and user ID with user attributes.
  ///
  /// Takes [experimentKey] The key of the experiment to set with the forced variation.
  /// Takes [userId] The ID of the user to force into the variation.
  /// Takes [attributes] A [Map] of custom key-value string pairs specifying attributes for the user.
  /// Returns [GetVariationResponse] The key of the variation where the user is bucketed, or `empty variationKey` if the user
  ///                        doesn't qualify for the experiment.
  Future<GetVariationResponse> getVariation(String experimentKey, String userId,
      [Map<String, dynamic> attributes = const {}]) async {
    return await OptimizelyClientWrapper.getVariation(
        _sdkKey, experimentKey, userId, attributes);
  }

  /// Get forced variation for experiment and user ID.
  ///
  /// Takes [experimentKey] The key of the experiment to set with the forced variation.
  /// Takes [userId] The ID of the user to force into the variation.
  /// Returns [GetVariationResponse] The key of the variation where the user is bucketed, or `empty variationKey` if the user
  ///                        doesn't qualify for the experiment.
  Future<GetVariationResponse> getForcedVariation(
      String experimentKey, String userId) async {
    return await OptimizelyClientWrapper.getForcedVariation(
        _sdkKey, experimentKey, userId);
  }

  /// Set forced variation for experiment and user ID to variationKey.
  ///
  /// Takes [experimentKey] The key of the experiment to set with the forced variation.
  /// Takes [userId] The ID of the user to force into the variation.
  /// Takes [variationKey] The key of the forced variation.
  /// Returns [BaseResponse] success as `true` if the user was successfully forced into a variation, `false` if the `experimentKey`
  ///                        isn't in the project file or the `variationKey` isn't in the experiment.
  Future<BaseResponse> setForcedVariation(String experimentKey, String userId,
      [String variationKey = ""]) async {
    return await OptimizelyClientWrapper.setForcedVariation(
        _sdkKey, experimentKey, userId, variationKey);
  }

  /// Returns [OptimizelyConfigResponse] a snapshot of the current project configuration.
  Future<OptimizelyConfigResponse> getOptimizelyConfig() async {
    return await OptimizelyClientWrapper.getOptimizelyConfig(_sdkKey);
  }

  /// Creates a context of the user for which decision APIs will be called.
  ///
  /// NOTE: A user context will only be created successfully when the SDK is fully configured using initializeClient.
  ///
  /// Takes [userId] the [String] user ID to be used for bucketing.
  /// Takes [attributes] An Optional [Map] of attribute names to current user attribute values.
  /// Returns An [OptimizelyUserContext] associated with this OptimizelyClient.
  Future<OptimizelyUserContext?> createUserContext(String userId,
      [Map<String, dynamic> attributes = const {}]) async {
    return await OptimizelyClientWrapper.createUserContext(
        _sdkKey, userId, attributes);
  }

  /// Checks if eventHandler are Closeable and calls close on them.
  /// Returns [BaseResponse] A object containing success result or reason of failure.
  Future<BaseResponse> close() async {
    return await OptimizelyClientWrapper.close(_sdkKey);
  }

  /// Allows user to listen to supported Activate notifications.
  /// Takes [callback] A [ActivateNotificationCallback] notification handler to be added.
  /// Returns [CancelListening] A callback function that allows the user to remove the added notification listener.
  Future<CancelListening> addActivateNotificationListener(
      ActivateNotificationCallback callback) async {
    return await _addActivateNotificationListener(callback);
  }

  /// Allows user to listen to supported Decision notifications.
  /// Takes [callback] A [DecisionNotificationCallback] notification handler to be added.
  /// Returns [CancelListening] A callback function that allows the user to remove the added notification listener.
  Future<CancelListening> addDecisionNotificationListener(
      DecisionNotificationCallback callback) async {
    return await _addDecisionNotificationListener(callback);
  }

  /// Allows user to listen to supported Track notifications.
  /// Takes [callback] A [TrackNotificationCallback] notification handler to be added.
  /// Returns [CancelListening] A callback function that allows the user to remove the added notification listener.
  Future<CancelListening> addTrackNotificationListener(
      TrackNotificationCallback callback) async {
    return await _addTrackNotificationListener(callback);
  }

  /// Allows user to listen to supported LogEvent notifications.
  /// Takes [callback] A [LogEventNotificationCallback] notification handler to be added.
  /// Returns [CancelListening] A callback function that allows the user to remove the added notification listener.
  Future<CancelListening> addLogEventNotificationListener(
      LogEventNotificationCallback callback) async {
    return await _addLogEventNotificationListener(callback);
  }

  /// Allows user to listen to supported Project Config Update notifications.
  /// Takes [callback] A [MultiUseCallback] notification handler to be added.
  /// Returns [CancelListening] A callback function that allows the user to remove the added notification listener.
  Future<CancelListening> addUpdateConfigNotificationListener(
      MultiUseCallback callback) async {
    return await _addConfigUpdateNotificationListener(callback);
  }

  /// Allows user to listen to supported Activate notifications.
  /// Takes [callback] A [ActivateNotificationCallback] notification handler to be added.
  /// Returns [CancelListening] A callback function that allows the user to remove the added notification listener.
  Future<CancelListening> _addActivateNotificationListener(
      ActivateNotificationCallback callback) async {
    return await OptimizelyClientWrapper.addActivateNotificationListener(
        _sdkKey, callback);
  }

  /// Allows user to listen to supported Decision notifications.
  /// Takes [callback] A [DecisionNotificationCallback] notification handler to be added.
  /// Returns [CancelListening] A callback function that allows the user to remove the added notification listener.
  Future<CancelListening> _addDecisionNotificationListener(
      DecisionNotificationCallback callback) async {
    return await OptimizelyClientWrapper.addDecisionNotificationListener(
        _sdkKey, callback);
  }

  /// Allows user to listen to supported Track notifications.
  /// Takes [callback] A [TrackNotificationCallback] notification handler to be added.
  /// Returns [CancelListening] A callback function that allows the user to remove the added notification listener.
  Future<CancelListening> _addTrackNotificationListener(
      TrackNotificationCallback callback) async {
    return await OptimizelyClientWrapper.addTrackNotificationListener(
        _sdkKey, callback);
  }

  /// Allows user to listen to supported LogEvent notifications.
  /// Takes [callback] A [LogEventNotificationCallback] notification handler to be added.
  /// Returns [CancelListening] A callback function that allows the user to remove the added notification listener.
  Future<CancelListening> _addLogEventNotificationListener(
      LogEventNotificationCallback callback) async {
    return await OptimizelyClientWrapper.addLogEventNotificationListener(
        _sdkKey, callback);
  }

  /// Allows user to listen to supported Project Config Update notifications.
  /// Takes [callback] A [MultiUseCallback] notification handler to be added.
  /// Returns [CancelListening] A callback function that allows the user to remove the added notification listener.
  Future<CancelListening> _addConfigUpdateNotificationListener(
      MultiUseCallback callback) async {
    return await OptimizelyClientWrapper.addConfigUpdateNotificationListener(
        _sdkKey, callback);
  }
}
