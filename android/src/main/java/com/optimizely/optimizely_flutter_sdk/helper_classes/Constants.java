/****************************************************************************
 * Copyright 2022, Optimizely, Inc. and contributors                        *
 *                                                                          *
 * Licensed under the Apache License, Version 2.0 (the "License");          *
 * you may not use this file except in compliance with the License.         *
 * You may obtain a copy of the License at                                  *
 *                                                                          *
 *    https://www.apache.org/licenses/LICENSE-2.0                            *
 *                                                                          *
 * Unless required by applicable law or agreed to in writing, software      *
 * distributed under the License is distributed on an "AS IS" BASIS,        *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 * See the License for the specific language governing permissions and      *
 * limitations under the License.                                           *
 ***************************************************************************/
package com.optimizely.optimizely_flutter_sdk.helper_classes;

public class Constants {
    public static class APIs {
        public static final String INITIALIZE = "initialize";
        public static final String GET_OPTIMIZELY_CONFIG = "getOptimizelyConfig";
        public static final String CREATE_USER_CONTEXT="createUserContext";
        public static final String SET_ATTRIBUTES="setAttributes";
        public static final String TRACK_EVENT="trackEvent";
        public static final String DECIDE="decide";
        public static final String ADD_NOTIFICATION_LISTENER="addNotificationListener";
        public static final String REMOVE_NOTIFICATION_LISTENER ="removeNotificationListener";
    }

    public static class NotificationType {
        public static final String TRACK="track";
        public static final String DECISION = "decision";
        public static final String LOG_EVENT = "logEvent";
        public static final String CONFIG_UPDATE = "projectConfigUpdate";
    }

    public static class RequestParameterKey {
        public static final String SDK_KEY = "sdk_key";
        public static final String USER_ID = "user_id";
        public static final String NOTIFICATION_ID = "id";
        public static final String NOTIFICATION_TYPE = "type";
        public static final String NOTIFICATION_PAYLOAD = "payload";
        public static final String ATTRIBUTES = "attributes";
        public static final String DECIDE_KEYS = "keys";
        public static final String DECIDE_OPTIONS = "optimizely_decide_option";
        public static final String EVENT_KEY= "event_key";
        public static final String EVENT_TAGS= "event_tags";
    }

    public static class ErrorMessage {
        public static final String INVALID_PARAMS = "Invalid parameters provided.";
        public static final String OPTIMIZELY_CONFIG_NOT_FOUND = "No optimizely config found.";
        public static final String OPTIMIZELY_CLIENT_NOT_FOUND = "Optimizely client not found.";
        public static final String USER_CONTEXT_NOT_FOUND = "User context not found.";
    }

    public static class SuccessMessage {
        public static final String INSTANCE_CREATED = "Optimizely instance created successfully.";
        public static final String OPTIMIZELY_CONFIG_FOUND = "Optimizely config found.";
        public static final String USER_CONTEXT_CREATED = "User context created successfully.";
        public static final String LISTENER_REMOVED = "Listener removed successfully.";
        public static final String LISTENER_ADDED = "Listener added successfully.";
        public static final String ATTRIBUTES_ADDED = "Attributes added successfully.";
        public static final String EVENT_TRACKED = "Event Tracked successfully.";
    }

    public static class DecisionListenerKeys {
        public static final String TYPE = "type";
        public static final String USER_ID = "user_id";
        public static final String ATTRIBUTES = "attributes";
        public static final String DECISION_INFO = "decision_info";
    }

    public static class TrackListenerKeys {
        public static final String EVENT_KEY = "event_key";
        public static final String USER_ID = "user_id";
        public static final String ATTRIBUTES = "attributes";
        public static final String EVENT_TAGS = "event_tags";
    }

    public static class LogEventListenerKeys {
        public static final String URL = "url";
        public static final String HTTP_VERB = "http_verb";
        public static final String PARAMS = "params";
    }
}
