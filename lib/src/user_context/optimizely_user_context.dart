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

import 'package:flutter/services.dart';
import '../constants.dart';
import '../utils.dart';
import 'optimizely_decision_context.dart';
import 'optimizely_forced_decision.dart';

/// An object for user contexts that the SDK will use to make decisions for.
///
class OptimizelyUserContext {
  final String _sdkKey;
  final MethodChannel _channel;

  OptimizelyUserContext(this._sdkKey, this._channel);

  /// Sets attributes for the user context.
  Future<Map<String, dynamic>> setAttributes(
      Map<String, dynamic> attributes) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.setAttributesMethod, {
      Constants.requestSDKKey: _sdkKey,
      Constants.requestAttributes: Utils.covertToTypedMap(attributes)
    }));
  }

  /// Tracks an event.
  Future<Map<String, dynamic>> trackEvent(String eventKey,
      [Map<String, dynamic> eventTags = const {}]) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.trackEventMethod, {
      Constants.requestSDKKey: _sdkKey,
      Constants.requestEventKey: eventKey,
      Constants.requestEventTags: Utils.covertToTypedMap(eventTags)
    }));
  }

  /// Returns a decision result for a given flag key and a user context, which contains all data required to deliver the flag or experiment.
  Future<Map<String, dynamic>> decide(String key,
      [List<String> options = const []]) async {
    // passing key as an array since decide has a single generic implementation which takes array of keys as an argument
    return await _decide([key], options);
  }

  /// Returns a key-map of decision results for multiple flag keys and a user context.
  Future<Map<String, dynamic>> decideForKeys(
      [List<String> keys = const [], List<String> options = const []]) async {
    return await _decide(keys, options);
  }

  /// Returns a key-map of decision results for all active flag keys.
  Future<Map<String, dynamic>> decideAll(
      [List<String> options = const []]) async {
    return await _decide(options);
  }

  /// Returns a key-map of decision results for multiple flag keys and a user context.
  Future<Map<String, dynamic>> _decide(
      [List<String> keys = const [], List<String> options = const []]) async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.decideMethod, {
      Constants.requestSDKKey: _sdkKey,
      Constants.requestKeys: keys,
      Constants.requestOptimizelyDecideOption: options
    }));
  }

  /// Sets the forced decision for a given decision context.
  Future<Map<String, dynamic>> setForcedDecision(
      OptimizelyDecisionContext context,
      OptimizelyForcedDecision decision) async {
    Map<String, dynamic> request = {
      Constants.requestSDKKey: _sdkKey,
      Constants.requestFlagKey: context.flagKey,
      Constants.requestVariationKey: decision.variationKey
    };
    if (context.ruleKey != null) {
      request[Constants.requestRuleKey] = context.ruleKey;
    }
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.setForcedDecision, request));
  }

  /// Returns the forced decision for a given decision context.
  Future<Map<String, dynamic>> getForcedDecision() async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.getForcedDecision, {
      Constants.requestSDKKey: _sdkKey,
    }));
  }

  /// Removes the forced decision for a given decision context.
  Future<Map<String, dynamic>> removeForcedDecision(
      OptimizelyDecisionContext context) async {
    Map<String, dynamic> request = {
      Constants.requestSDKKey: _sdkKey,
      Constants.requestFlagKey: context.flagKey,
    };
    if (context.ruleKey != null) {
      request[Constants.requestRuleKey] = context.ruleKey;
    }
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.removeForcedDecision, request));
  }

  /// Removes all forced decisions bound to this user context.
  Future<Map<String, dynamic>> removeAllForcedDecisions() async {
    return Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.removeAllForcedDecisions, {
      Constants.requestSDKKey: _sdkKey,
    }));
  }
}
