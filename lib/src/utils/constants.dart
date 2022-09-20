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
  static const String close = "close";
  static const String getOptimizelyConfigMethod = "getOptimizelyConfig";
  static const String createUserContextMethod = "createUserContext";
  static const String getUserIdMethod = "getUserId";
  static const String setAttributesMethod = "setAttributes";
  static const String getAttributesMethod = "getAttributes";
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
  static const String id = "id";
  static const String sdkKey = "sdkKey";
  static const String userContextId = "userContextId";
  static const String userContext = "userContext";
  static const String userID = "userID";
  static const String attributes = "attributes";
  static const String decisionInfo = "decisionInfo";
  static const String variables = "variables";
  static const String reasons = "reasons";
  static const String eventKey = "eventKey";
  static const String url = "url";
  static const String params = "params";
  static const String eventTags = "eventTags";
  static const String keys = "keys";
  static const String variationKey = "variationKey";
  static const String flagKey = "flagKey";
  static const String ruleKey = "ruleKey";
  static const String enabled = "enabled";
  static const String optimizelyDecideOption = "optimizelyDecideOption";
  static const String payload = "payload";
  static const String value = "value";
  static const String type = "type";
  static const String eventBatchSize = "eventBatchSize";
  static const String eventTimeInterval = "eventTimeInterval";
  static const String eventMaxQueueSize = "eventMaxQueueSize";
  static const String datafilePeriodicDownloadInterval =
      "datafilePeriodicDownloadInterval";
  static const String datafileHostPrefix = "datafileHostPrefix";
  static const String datafileHostSuffix = "datafileHostSuffix";
  static const String trackCallBackListener = "trackCallbackListener";
  static const String decisionCallBackListener = "decisionCallbackListener";
  static const String logEventCallbackListener = "logEventCallbackListener";
  static const String configUpdateCallBackListener =
      "projectConfigUpdateCallBackListener";

  // OptimizelyConfig Request params
  static const String audiences = "audiences";
  static const String conditions = "conditions";
  static const String datafile = "datafile";
  static const String deliveryRules = "deliveryRules";
  static const String events = "events";
  static const String experimentIds = "experimentIds";
  static const String experimentRules = "experimentRules";
  static const String experimentsMap = "experimentsMap";
  static const String environmentKey = "environmentKey";
  static const String featuresMap = "featuresMap";
  static const String featureEnabled = "featureEnabled";
  static const String key = "key";
  static const String name = "name";
  static const String revision = "revision";
  static const String variationsMap = "variationsMap";
  static const String variablesMap = "variablesMap";

  // Response keys
  static const String responseSuccess = "success";
  static const String responseResult = "result";
  static const String responseReason = "reason";

  // SuccessMessage from ios/Classes/SwiftOptimizelyFlutterSdkPlugin.swift
  // These are unique only to flutter SDK. This helps in testing if correct native code was called.
  static const String instanceCreated =
      "Optimizely instance created successfully.";
  static const String optimizelyConfigFound = "Optimizely config found.";
  static const String optimizelyClientClosed =
      "Optimizely client closed successfully.";
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
