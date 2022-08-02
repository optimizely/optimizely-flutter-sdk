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

class Constants {
  // Supported data types for attributes and eventTags
  static const String stringType = "string";
  static const String intType = "int";
  static const String doubleType = "double";
  static const String boolType = "bool";

  // Supported Method Names
  static const String initializeMethod = "initialize";
  static const String getOptimizelyConfigMethod = "getOptimizelyConfig";
  static const String createUserContextMethod = "createUserContext";
  static const String setAttributesMethod = "setAttributes";
  static const String trackEventMethod = "trackEvent";
  static const String decideMethod = "decide";
  static const String setForcedDecision = "setForcedDecision";
  static const String getForcedDecision = "getForcedDecision";
  static const String removeForcedDecision = "removeForcedDecision";
  static const String removeAllForcedDecisions = "removeAllForcedDecisions";
  static const String addNotificationListenerMethod = "addNotificationListener";
  static const String removeNotificationListenerMethod =
      "removeNotificationListener";

  // Request parameter keys
  static const String requestID = "id";
  static const String requestSDKKey = "sdk_key";
  static const String requestUserContext = "user_context";
  static const String requestUserID = "user_id";
  static const String requestAttributes = "attributes";
  static const String requestVariables = "variables";
  static const String requestReasons = "reasons";
  static const String requestEventKey = "event_key";
  static const String requestEventTags = "event_tags";
  static const String requestKeys = "keys";
  static const String requestVariationKey = "variation_key";
  static const String requestFlagKey = "flag_key";
  static const String requestRuleKey = "rule_key";
  static const String requestEnabled = "enabled";
  static const String requestOptimizelyDecideOption =
      "optimizely_decide_option";
  static const String requestPayload = "payload";
  static const String requestValue = "value";
  static const String requestType = "type";
  static const String requestCallBackListener = "callbackListener";

  // Response keys
  static const String responseSuccess = "success";
  static const String responseResult = "result";
  static const String responseReason = "reason";
  static const String responseVariationKey = "variationKey";

  // SuccessMessage from ios/Classes/SwiftOptimizelyFlutterSdkPlugin.swift
  // These are unique only to flutter SDK. This helps in testing if correct native code was called.
  static const String instanceCreated =
      "Optimizely instance created successfully.";
  static const String optimizelyConfigFound = "Optimizely config found.";
  static const String userContextCreated = "User context created successfully.";
  static const String attributesAdded = "Attributes added successfully.";
  static const String listenerAdded = "Listener added successfully.";
  static const String listenerRemoved = "Listener removed successfully.";
  static const String decideCalled = "Decide called successfully.";
  static const String forcedDecisionSet = "Forced decision set successfully.";
  static const String forcedDecisionRemoved =
      "Forced decision removed successfully.";
  static const String allForcedDecisionsRemoved =
      "All Forced decisions removed successfully.";
}
