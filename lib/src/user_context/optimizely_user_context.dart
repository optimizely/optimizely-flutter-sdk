/// **************************************************************************
/// Copyright 2022-2023, Optimizely, Inc. and contributors                   *
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
import 'package:optimizely_flutter_sdk/optimizely_flutter_sdk.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/base_response.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/decide_response.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/get_attributes_response.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/get_forced_decision_response.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/get_user_id_response.dart';
import 'package:optimizely_flutter_sdk/src/data_objects/get_qualified_segments_response.dart';
import 'package:optimizely_flutter_sdk/src/utils/constants.dart';
import 'package:optimizely_flutter_sdk/src/utils/utils.dart';

/// Options controlling flag decisions.
///
enum OptimizelyDecideOption {
  /// disable decision event tracking.
  disableDecisionEvent,

  /// return decisions only for flags which are enabled (decideAll only).
  enabledFlagsOnly,

  /// skip user profile service for decision.
  ignoreUserProfileService,

  /// include info and debug messages in the decision reasons.
  includeReasons,

  /// exclude variable values from the decision result.
  excludeVariables
}

/// Options controlling audience segments.
///
enum OptimizelySegmentOption {
  /// ignore odp cache (save/lookup)
  ignoreCache,

  /// resets odp cache
  resetCache,
}

/// An object for user contexts that the SDK will use to make decisions for.
///
class OptimizelyUserContext {
  final String _sdkKey;
  final String _userContextId;
  final MethodChannel _channel;

  OptimizelyUserContext(this._sdkKey, this._userContextId, this._channel);

  /// Returns [GetUserIdResponse] object containing userId for the user context.
  Future<GetUserIdResponse> getUserId() async {
    final result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.getUserIdMethod, {
      Constants.sdkKey: _sdkKey,
      Constants.userContextId: _userContextId,
    }));
    return GetUserIdResponse(result);
  }

  /// Returns [GetAttributesResponse] object containing attributes for the user context.
  Future<GetAttributesResponse> getAttributes() async {
    final result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.getAttributesMethod, {
      Constants.sdkKey: _sdkKey,
      Constants.userContextId: _userContextId,
    }));
    return GetAttributesResponse(result);
  }

  /// Sets attributes for the user context.
  ///
  /// Takes [attributes] A [Map] of custom key-value string pairs specifying attributes for the user.
  /// Returns [BaseResponse]
  Future<BaseResponse> setAttributes(Map<String, dynamic> attributes) async {
    final result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.setAttributesMethod, {
      Constants.sdkKey: _sdkKey,
      Constants.userContextId: _userContextId,
      Constants.attributes: Utils.convertToTypedMap(attributes)
    }));
    return BaseResponse(result);
  }

  /// Returns [GetQualifiedSegmentsResponse] object containing an array of segment names that the user is qualified for.
  Future<GetQualifiedSegmentsResponse> getQualifiedSegments() async {
    final result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.getQualifiedSegmentsMethod, {
      Constants.sdkKey: _sdkKey,
      Constants.userContextId: _userContextId,
    }));
    return GetQualifiedSegmentsResponse(result);
  }

  /// Sets qualified segments for the user context.
  ///
  /// Takes [qualifiedSegments] A [List] of strings specifying qualified segments for the user.
  /// Returns [BaseResponse]
  Future<BaseResponse> setQualifiedSegments(
      List<String> qualifiedSegments) async {
    final result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.setQualifiedSegmentsMethod, {
      Constants.sdkKey: _sdkKey,
      Constants.userContextId: _userContextId,
      Constants.qualifiedSegments: qualifiedSegments
    }));
    return BaseResponse(result);
  }

  /// Checks if the user is qualified for the given segment.
  ///
  /// Takes [segment] The segment name to check qualification for.
  /// Returns [BaseResponse]
  Future<BaseResponse> isQualifiedFor(String segment) async {
    final result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.isQualifiedForMethod, {
      Constants.sdkKey: _sdkKey,
      Constants.userContextId: _userContextId,
      Constants.segment: segment
    }));
    return BaseResponse(result);
  }

  /// Fetch all qualified segments for the user context.
  ///
  /// The segments fetched will be saved in **qualifiedSegments** and can be accessed any time using **getQualifiedSegments**.
  /// On failure, **qualifiedSegments** will be nil and an error will be returned.
  /// Optional [options] A set of [OptimizelySegmentOption] for fetching qualified segments.
  /// Returns [BaseResponse]
  Future<BaseResponse> fetchQualifiedSegments(
      [Set<OptimizelySegmentOption> options = const {}]) async {
    final result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.fetchQualifiedSegmentsMethod, {
      Constants.sdkKey: _sdkKey,
      Constants.userContextId: _userContextId,
      Constants.optimizelySegmentOption: Utils.convertSegmentOptions(options),
    }));
    return BaseResponse(result);
  }

  /// Tracks an event.
  ///
  /// Takes [eventKey] The event name.
  /// Optional [eventTags] A [Map] of event tag names to event tag values.
  /// Returns [BaseResponse]
  Future<BaseResponse> trackEvent(String eventKey,
      [Map<String, dynamic> eventTags = const {}]) async {
    final result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.trackEventMethod, {
      Constants.sdkKey: _sdkKey,
      Constants.userContextId: _userContextId,
      Constants.eventKey: eventKey,
      Constants.eventTags: Utils.convertToTypedMap(eventTags)
    }));
    return BaseResponse(result);
  }

  /// Returns a decision result for a given flag key and a user context, which contains all data required to deliver the flag or experiment.
  ///
  /// Takes [key] A flag key for which a decision will be made.
  /// Optional [options] A set of [OptimizelyDecideOption] for decision-making.
  /// Returns [DecideResponse] A decision result.
  Future<DecideResponse> decide(String key,
      [Set<OptimizelyDecideOption> options = const {}]) async {
    // passing key as an array since decide has a single generic implementation which takes array of keys as an argument
    final result = await _decide([key], options);
    return DecideResponse(result);
  }

  /// Returns a key-map of decision results for multiple flag keys and a user context.
  ///
  /// Takes [keys] A [List] of flag keys for which decisions will be made.
  /// Optional [options] A set of [OptimizelyDecideOption] for decision-making.
  /// Returns [DecideForKeysResponse] All decision results mapped by flag keys.
  Future<DecideForKeysResponse> decideForKeys(List<String> keys,
      [Set<OptimizelyDecideOption> options = const {}]) async {
    final result = await _decide(keys, options);
    return DecideForKeysResponse(result);
  }

  /// Returns a key-map of decision results for all active flag keys.
  ///
  /// Optional [options] A set of [OptimizelyDecideOption] for decision-making.
  /// Returns [DecideForKeysResponse] All decision results mapped by flag keys.
  Future<DecideForKeysResponse> decideAll(
      [Set<OptimizelyDecideOption> options = const {}]) async {
    final result = await _decide([], options);
    return DecideForKeysResponse(result);
  }

  /// Returns a key-map of decision results for multiple flag keys and a user context.
  Future<Map<String, dynamic>> _decide(
      [List<String> keys = const [],
      Set<OptimizelyDecideOption> options = const {}]) async {
    final convertedOptions = Utils.convertDecideOptions(options);
    var result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.decideMethod, {
      Constants.sdkKey: _sdkKey,
      Constants.userContextId: _userContextId,
      Constants.keys: keys,
      Constants.optimizelyDecideOption: convertedOptions,
    }));
    return result;
  }

  /// Sets the forced decision for a given decision context.
  ///
  /// Takes [context] The [OptimizelyDecisionContext] containing flagKey and ruleKey.
  /// Takes [decision] The [OptimizelyForcedDecision] containing the variationKey.
  /// Returns [BaseResponse]
  Future<BaseResponse> setForcedDecision(OptimizelyDecisionContext context,
      OptimizelyForcedDecision decision) async {
    Map<String, dynamic> request = {
      Constants.sdkKey: _sdkKey,
      Constants.userContextId: _userContextId,
      Constants.flagKey: context.flagKey,
      Constants.variationKey: decision.variationKey
    };
    if (context.ruleKey != null) {
      request[Constants.ruleKey] = context.ruleKey;
    }
    final result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.setForcedDecision, request));
    return BaseResponse(result);
  }

  /// Returns the forced decision for a given decision context.
  ///
  /// Takes [context] The [OptimizelyDecisionContext] containing flagKey and ruleKey.
  /// Returns [GetForcedDecisionResponse] containing a variationKey for a given forced decision
  Future<GetForcedDecisionResponse> getForcedDecision(
      OptimizelyDecisionContext context) async {
    Map<String, dynamic> request = {
      Constants.sdkKey: _sdkKey,
      Constants.userContextId: _userContextId,
      Constants.flagKey: context.flagKey,
    };
    if (context.ruleKey != null) {
      request[Constants.ruleKey] = context.ruleKey;
    }

    final result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.getForcedDecision, request));
    return GetForcedDecisionResponse(result);
  }

  /// Removes the forced decision for a given decision context.
  ///
  /// Takes [context] The [OptimizelyDecisionContext] containing flagKey and ruleKey.
  /// Returns [BaseResponse]
  Future<BaseResponse> removeForcedDecision(
      OptimizelyDecisionContext context) async {
    Map<String, dynamic> request = {
      Constants.sdkKey: _sdkKey,
      Constants.userContextId: _userContextId,
      Constants.flagKey: context.flagKey,
    };
    if (context.ruleKey != null) {
      request[Constants.ruleKey] = context.ruleKey;
    }
    final result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.removeForcedDecision, request));
    return BaseResponse(result);
  }

  /// Removes all forced decisions bound to this user context.
  ///
  /// Returns [BaseResponse]
  Future<BaseResponse> removeAllForcedDecisions() async {
    final result = Map<String, dynamic>.from(
        await _channel.invokeMethod(Constants.removeAllForcedDecisions, {
      Constants.sdkKey: _sdkKey,
      Constants.userContextId: _userContextId,
    }));
    return BaseResponse(result);
  }
}
