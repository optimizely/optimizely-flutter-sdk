/****************************************************************************
 * Copyright 2022, Optimizely, Inc. and contributors                        *
 *                                                                          *
 * Licensed under the Apache License, Version 2.0 (the "License");          *
 * you may not use this file except in compliance with the License.         *
 * You may obtain a copy of the License at                                  *
 *                                                                          *
 *    http://www.apache.org/licenses/LICENSE-2.0                            *
 *                                                                          *
 * Unless required by applicable law or agreed to in writing, software      *
 * distributed under the License is distributed on an "AS IS" BASIS,        *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 * See the License for the specific language governing permissions and      *
 * limitations under the License.                                           *
 ***************************************************************************/

import Foundation

struct API {
    static let initialize = "initialize"
    static let getOptimizelyConfig = "getOptimizelyConfig"
    static let createUserContext = "createUserContext"
    static let setAttributes = "setAttributes"
    static let trackEvent = "trackEvent"
    static let decide = "decide"
    static let setForcedDecision = "setForcedDecision"
    static let getForcedDecision = "getForcedDecision"
    static let removeForcedDecision = "removeForcedDecision"
    static let removeAllForcedDecisions = "removeAllForcedDecisions"
    static let addNotificationListener = "addNotificationListener"
    static let removeNotificationListener = "removeNotificationListener"
}

struct NotificationType {
    static let track = "track"
    static let decision = "decision"
    static let logEvent = "logEvent"
    static let projectConfigUpdate = "projectConfigUpdate"
}

struct DecideOption {
    static let disableDecisionEvent = "disableDecisionEvent"
    static let enabledFlagsOnly = "enabledFlagsOnly"
    static let ignoreUserProfileService = "ignoreUserProfileService"
    static let includeReasons = "includeReasons"
    static let excludeVariables = "excludeVariables"
}

struct RequestParameterKey {
    static let sdkKey = "sdkKey"
    static let userId = "userID"
    static let notificationId = "id"
    static let notificationType = "type"
    static let notificationPayload = "payload"
    static let attributes = "attributes"
    static let decideKeys = "keys"
    static let variationKey = "variationKey"
    static let flagKey = "flagKey"
    static let ruleKey = "ruleKey"
    static let enabled = "enabled"
    static let userContext = "userContext"
    static let variables = "variables"
    static let eventKey = "eventKey"
    static let eventTags = "eventTags"
    static let reasons = "reasons"
    static let decideOptions = "optimizelyDecideOption"
}

struct ResponseKey {
    static let success = "success"
    static let result = "result"
    static let reason = "reason"
    static let variationKey = "variationKey"
}

struct ErrorMessage {
    static let invalidParameters = "Invalid parameters provided."
    static let optimizelyConfigNotFound = "No optimizely config found."
    static let optlyClientNotFound = "Optimizely client not found."
    static let userContextNotFound = "User context not found."
}

struct SuccessMessage {
    static let instanceCreated = "Optimizely instance created successfully."
    static let optimizelyConfigFound = "Optimizely config found."
    static let userContextCreated = "User context created successfully."
    static let attributesAdded = "Attributes added successfully."
    static let listenerAdded = "Listener added successfully."
    static let listenerRemoved = "Listener removed successfully."
    static let decideCalled = "Decide called successfully."
    static let forcedDecisionSet = "Forced decision set successfully."
    static let forcedDecisionRemoved = "Forced decision removed successfully."
    static let allForcedDecisionsRemoved = "All Forced decisions removed successfully."
}

//Sohail: There is one issue, can we make sure the types remain same, probably we will need to write unit test separately for type.
struct TypeValue {
    static let string = "string"
    static let int = "int"
    static let double = "double"
    static let bool = "bool"
}
