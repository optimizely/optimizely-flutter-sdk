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

class Constants {
  // Supported data types for attributes and eventTags
  static const String stringType = "string";
  static const String intType = "int";
  static const String doubleType = "double";
  static const String boolType = "bool";

  // Supported Method Names
  static const String initializeMethod = "initialize";
  static const String close = "close";
  static const String activate = "activate";
  static const String getVariation = "getVariation";
  static const String getForcedVariation = "getForcedVariation";
  static const String setForcedVariation = "setForcedVariation";
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
  static const String clearNotificationListenersMethod =
      "clearNotificationListeners";
  static const String clearAllNotificationListenersMethod =
      "clearAllNotificationListeners";

  // Odp Supported Method Names
  static const String sendOdpEventMethod = "sendOdpEvent";
  static const String getVuidMethod = "getVuid";
  static const String getQualifiedSegmentsMethod = "getQualifiedSegments";
  static const String setQualifiedSegmentsMethod = "setQualifiedSegments";
  static const String isQualifiedForMethod = "isQualifiedFor";
  static const String fetchQualifiedSegmentsMethod = "fetchQualifiedSegments";

  // Request parameter keys
  static const String id = "id";
  static const String sdkKey = "sdkKey";
  static const String userContextId = "userContextId";
  static const String userContext = "userContext";
  static const String experiment = "experiment";
  static const String variation = "variation";
  static const String userId = "userId";
  static const String vuid = "vuid";
  static const String experimentKey = "experimentKey";
  static const String attributes = "attributes";
  static const String qualifiedSegments = "qualifiedSegments";
  static const String segment = "segment";
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
  static const String optimizelySegmentOption = "optimizelySegmentOption";
  static const String payload = "payload";
  static const String value = "value";
  static const String type = "type";
  static const String action = "action";
  static const String identifiers = "identifiers";
  static const String data = "data";
  static const String callbackIds = "callbackIds";
  static const String eventBatchSize = "eventBatchSize";
  static const String eventTimeInterval = "eventTimeInterval";
  static const String eventMaxQueueSize = "eventMaxQueueSize";
  static const String datafilePeriodicDownloadInterval =
      "datafilePeriodicDownloadInterval";
  static const String datafileHostPrefix = "datafileHostPrefix";
  static const String datafileHostSuffix = "datafileHostSuffix";
  static const String trackCallBackListener = "trackCallbackListener";
  static const String activateCallBackListener = "activateCallbackListener";
  static const String decisionCallBackListener = "decisionCallbackListener";
  static const String logEventCallbackListener = "logEventCallbackListener";
  static const String configUpdateCallBackListener =
      "projectConfigUpdateCallbackListener";

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

  // Odp Request params
  static const String segmentsCacheSize = "segmentsCacheSize";
  static const String segmentsCacheTimeoutInSecs = "segmentsCacheTimeoutInSecs";
  static const String timeoutForSegmentFetchInSecs =
      "timeoutForSegmentFetchInSecs";
  static const String timeoutForOdpEventInSecs = "timeoutForOdpEventInSecs";
  static const String disableOdp = "disableOdp";

  // Response keys
  static const String responseSuccess = "success";
  static const String responseResult = "result";
  static const String responseReason = "reason";
}
