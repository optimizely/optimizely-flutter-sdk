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
import './src/optimizely_client_wrapper.dart';

export './src/optimizely_client_wrapper.dart' show ListenerType;

/// The main client class for the Optimizely Flutter SDK.
///
/// To use, create an instance of OptimizelyFlutterSdk class with a valid sdkKey and call initializeClient method.
/// If successfull, call createUserContext to setup user context.
/// Once done, all API's should be available.
class OptimizelyFlutterSdk {
  final String _sdkKey;
  OptimizelyFlutterSdk(this._sdkKey);

  /// Starts Optimizely SDK (Synchronous) with provided sdkKey.
  Future<Map<String, dynamic>> initializeClient() async {
    return await OptimizelyClientWrapper.initializeClient(_sdkKey);
  }

  /// Returns a snapshot of the current project configuration.
  Future<Map<String, dynamic>> getOptimizelyConfig() async {
    return await OptimizelyClientWrapper.getOptimizelyConfig(_sdkKey);
  }

  /// Creates a context of the user for which decision APIs will be called.
  ///
  /// A user context will only be created successfully when the SDK is fully configured using initializeClient.
  Future<Map<String, dynamic>> createUserContext(String userId,
      [Map<String, dynamic> attributes = const {}]) async {
    return await OptimizelyClientWrapper.createUserContext(
        _sdkKey, userId, attributes);
  }

  /// Sets attributes for the user context.
  Future<Map<String, dynamic>> setAttributes(
      Map<String, dynamic> attributes) async {
    return await OptimizelyClientWrapper.setAttributes(_sdkKey, attributes);
  }

  /// Tracks an event.
  Future<Map<String, dynamic>> trackEvent(String eventKey,
      [Map<String, dynamic> eventTags = const {}]) async {
    return await OptimizelyClientWrapper.trackEvent(
        _sdkKey, eventKey, eventTags);
  }

  /// Returns a decision result for a given flag key and a user context, which contains all data required to deliver the flag or experiment.
  Future<Map<String, dynamic>> decide(String key,
      [List<String> options = const []]) async {
    // passing key as an array since decide has a single generic implementation which takes array of keys as an argument
    return await OptimizelyClientWrapper.decide(_sdkKey, [key], options);
  }

  /// Returns a key-map of decision results for multiple flag keys and a user context.
  Future<Map<String, dynamic>> decideForKeys(
      [List<String> keys = const [], List<String> options = const []]) async {
    return await OptimizelyClientWrapper.decide(_sdkKey, keys, options);
  }

  /// Returns a key-map of decision results for all active flag keys.
  Future<Map<String, dynamic>> decideAll(
      [List<String> options = const []]) async {
    return await OptimizelyClientWrapper.decide(_sdkKey, [], options);
  }

  /// Allows user to listen to supported notifications.
  Future<CancelListening> addNotificationListener(
      MultiUseCallback callback, ListenerType listenerType) async {
    return await OptimizelyClientWrapper.addNotificationListener(
        _sdkKey, callback, listenerType);
  }
}
