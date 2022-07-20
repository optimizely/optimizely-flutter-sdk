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
    static let addNotificationListener = "addNotificationListener"
    static let removeNotificationListener = "removeNotificationListener"
}

struct NotificationType {
    static let track = "track"
    static let decision = "decision"
    static let logEvent = "logEvent"
    static let projectConfigUpdate = "projectConfigUpdate"
}

struct RequestParameterKey {
    static let sdkKey = "sdk_key"
    static let userId = "user_id"
    static let notificationId = "id"
    static let notificationType = "type"
    static let notificationPayload = "payload"
    static let attributes = "attributes"
    static let decideKeys = "keys"
    static let decideOptions = "optimizely_decide_option"
    static let eventKey = "event_key"
    static let eventTags = "event_tags"
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
}

//Sohail: There is one issue, can we make sure the types remain same, probably we will need to write unit test separately for type.
struct TypeValue {
    static let string = "string"
    static let int = "int"
    static let double = "double"
    static let bool = "bool"
}
