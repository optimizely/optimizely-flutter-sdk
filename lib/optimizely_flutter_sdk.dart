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
import 'package:optimizely_flutter_sdk/src/data_objects/base_response.dart';
import 'package:optimizely_flutter_sdk/src/optimizely_client_wrapper.dart';
import 'package:optimizely_flutter_sdk/src/user_context/optimizely_user_context.dart';

export 'package:optimizely_flutter_sdk/src/user_context/optimizely_forced_decision.dart'
    show OptimizelyForcedDecision;
export 'package:optimizely_flutter_sdk/src/user_context/optimizely_decision_context.dart'
    show OptimizelyDecisionContext;
export 'package:optimizely_flutter_sdk/src/user_context/optimizely_user_context.dart'
    show OptimizelyDecideOption;
export 'package:optimizely_flutter_sdk/src/data_objects/decide_response.dart'
    show Decision;

/// The main client class for the Optimizely Flutter SDK.
///
/// To use, create an instance of OptimizelyFlutterSdk class with a valid sdkKey and call initializeClient method.
/// If successfull, call createUserContext to setup user context.
/// Once done, all API's should be available.
class OptimizelyFlutterSdk {
  final String _sdkKey;
  OptimizelyFlutterSdk(this._sdkKey);

  /// Starts Optimizely SDK (Synchronous) with provided sdkKey.
  Future<BaseResponse> initializeClient() async {
    return await OptimizelyClientWrapper.initializeClient(_sdkKey);
  }

  /// Returns a snapshot of the current project configuration.
  Future<Map<String, dynamic>> getOptimizelyConfig() async {
    return await OptimizelyClientWrapper.getOptimizelyConfig(_sdkKey);
  }

  /// Creates a context of the user for which decision APIs will be called.
  ///
  /// A user context will only be created successfully when the SDK is fully configured using initializeClient.
  Future<OptimizelyUserContext?> createUserContext(String userId,
      [Map<String, dynamic> attributes = const {}]) async {
    return await OptimizelyClientWrapper.createUserContext(
        _sdkKey, userId, attributes);
  }

  Future<CancelListening> addDecisionNotificationListener(
      MultiUseCallback callback) async {
    return await _addNotificationListener(callback, ListenerType.decision);
  }

  Future<CancelListening> addTrackNotificationListener(
      MultiUseCallback callback) async {
    return await _addNotificationListener(callback, ListenerType.track);
  }

  Future<CancelListening> addUpdateConfigNotificationListener(
      MultiUseCallback callback) async {
    return await _addNotificationListener(
        callback, ListenerType.projectConfigUpdate);
  }

  Future<CancelListening> addLogEventNotificationListener(
      MultiUseCallback callback) async {
    return await _addNotificationListener(callback, ListenerType.logEvent);
  }

  /// Allows user to listen to supported notifications.
  Future<CancelListening> _addNotificationListener(
      MultiUseCallback callback, ListenerType listenerType) async {
    return await OptimizelyClientWrapper.addNotificationListener(
        _sdkKey, callback, listenerType);
  }
}
