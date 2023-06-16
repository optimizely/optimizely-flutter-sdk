/****************************************************************************
 * Copyright 2022-2023, Optimizely, Inc. and contributors                        *
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
        public static final String CLOSE = "close";
        public static final String ACTIVATE = "activate";
        public static final String GET_VARIATION = "getVariation";
        public static final String GET_FORCED_VARIATION = "getForcedVariation";
        public static final String SET_FORCED_VARIATION = "setForcedVariation";
        public static final String INITIALIZE = "initialize";
        public static final String GET_OPTIMIZELY_CONFIG = "getOptimizelyConfig";
        public static final String CREATE_USER_CONTEXT = "createUserContext";
        public static final String GET_USER_ID = "getUserId";
        public static final String GET_ATTRIBUTES = "getAttributes";
        public static final String SET_ATTRIBUTES="setAttributes";
        public static final String GET_FORCED_DECISION = "getForcedDecision";
        public static final String REMOVE_FORCED_DECISION = "removeForcedDecision";
        public static final String REMOVE_ALL_FORCED_DECISIONS = "removeAllForcedDecisions";
        public static final String SET_FORCED_DECISION = "setForcedDecision";
        public static final String TRACK_EVENT = "trackEvent";
        public static final String DECIDE = "decide";
        public static final String ADD_NOTIFICATION_LISTENER = "addNotificationListener";
        public static final String REMOVE_NOTIFICATION_LISTENER = "removeNotificationListener";
        public static final String CLEAR_ALL_NOTIFICATION_LISTENERS = "clearAllNotificationListeners";
        public static final String CLEAR_NOTIFICATION_LISTENERS = "clearNotificationListeners";

        // ODP APIs constants
        public static final String SEND_ODP_EVENT = "sendOdpEvent";
        public static final String GET_VUID = "getVuid";
        public static final String GET_QUALIFIED_SEGMENTS = "getQualifiedSegments";
        public static final String SET_QUALIFIED_SEGMENTS = "setQualifiedSegments";
        public static final String IS_QUALIFIED_FOR = "isQualifiedFor";
        public static final String FETCH_QUALIFIED_SEGMENTS = "fetchQualifiedSegments";
    }

    public static class NotificationType {
        public static final String ACTIVATE="activate";
        public static final String TRACK="track";
        public static final String DECISION = "decision";
        public static final String LOG_EVENT = "logEvent";
        public static final String CONFIG_UPDATE = "projectConfigUpdate";
    }

    public static class RequestParameterKey {
        public static final String SDK_KEY = "sdkKey";
        public static final String USER_ID = "userId";
        public static final String USER_CONTEXT_ID = "userContextId";
        public static final String NOTIFICATION_ID = "id";
        public static final String NOTIFICATION_TYPE = "type";
        public static final String CALLBACK_IDS = "callbackIds";
        public static final String NOTIFICATION_PAYLOAD = "payload";
        public static final String ATTRIBUTES = "attributes";
        public static final String DECIDE_KEYS = "keys";
        public static final String DECIDE_OPTIONS = "optimizelyDecideOption";
        public static final String DEFAULT_LOG_LEVEL = "defaultLogLevel";
        public static final String EVENT_BATCH_SIZE = "eventBatchSize";
        public static final String EVENT_TIME_INTERVAL = "eventTimeInterval";
        public static final String EVENT_MAX_QUEUE_SIZE = "eventMaxQueueSize";
        public static final String DATAFILE_PERIODIC_DOWNLOAD_INTERVAL = "datafilePeriodicDownloadInterval";
        public static final String EVENT_KEY = "eventKey";
        public static final String EVENT_TAGS = "eventTags";
        public static final String FLAG_KEY = "flagKey";
        public static final String RULE_KEY = "ruleKey";
        public static final String EXPERIMENT_KEY = "experimentKey";
        public static final String VARIATION_KEY = "variationKey";
        public static final String DATAFILE_HOST_PREFIX = "datafileHostPrefix";
        public static final String DATAFILE_HOST_SUFFIX = "datafileHostSuffix";

        public static final String VUID = "vuid";
        public static final String QUALIFIED_SEGMENTS = "qualifiedSegments";
        public static final String SEGMENT = "segment";
        public static final String ACTION = "action";
        public static final String IDENTIFIERS = "identifiers";
        public static final String DATA = "data";
        public static final String ODP_EVENT_TYPE = "type";
        public static final String OPTIMIZELY_SEGMENT_OPTION = "optimizelySegmentOption";
        public static final String OPTIMIZELY_SDK_SETTINGS = "optimizelySdkSettings";
        public static final String SEGMENTS_CACHE_SIZE = "segmentsCacheSize";
        public static final String SEGMENTS_CACHE_TIMEOUT_IN_SECONDS = "segmentsCacheTimeoutInSecs";
        public static final String TIMEOUT_FOR_SEGMENT_FETCH_IN_SECONDS = "timeoutForSegmentFetchInSecs";
        public static final String TIMEOUT_FOR_ODP_EVENT_IN_SECONDS = "timeoutForOdpEventInSecs";
        public static final String DISABLE_ODP = "disableOdp";
    }

    public static class ErrorMessage {
        public static final String INVALID_PARAMS = "Invalid parameters provided.";
        public static final String INVALID_OPTIMIZELY_CLIENT = "Optimizely client is invalid.";
        public static final String OPTIMIZELY_CONFIG_NOT_FOUND = "No optimizely config found.";
        public static final String OPTIMIZELY_CLIENT_NOT_FOUND = "Optimizely client not found.";
        public static final String USER_CONTEXT_NOT_FOUND = "User context not found.";
        public static final String USER_CONTEXT_NOT_CREATED = "User context not created.";
        public static final String QUALIFIED_SEGMENTS_NOT_FOUND = "Qualified Segments not found.";
    }

    public static class DecisionListenerKeys {
        public static final String TYPE = "type";
        public static final String USER_ID = "userId";
        public static final String ATTRIBUTES = "attributes";
        public static final String DECISION_INFO = "decisionInfo";
    }

    public static class ActivateListenerKeys {
        public static final String ID = "id";
        public static final String KEY = "key";
        public static final String EXPERIMENT = "experiment";
        public static final String USER_ID = "userId";
        public static final String ATTRIBUTES = "attributes";
        public static final String VARIATION = "variation";
    }

    public static class TrackListenerKeys {
        public static final String EVENT_KEY = "eventKey";
        public static final String USER_ID = "userId";
        public static final String ATTRIBUTES = "attributes";
        public static final String EVENT_TAGS = "eventTags";
    }

    public static class LogEventListenerKeys {
        public static final String URL = "url";
        public static final String HTTP_VERB = "http_verb";
        public static final String PARAMS = "params";
    }

    public static class ResponseKey {
        public static final String RESULT = "result";
        public static final String REASON = "reason";
        public static final String SUCCESS = "success";
    }

    public static class DecideOption {
        public static final String DISABLE_DECISION_EVENT = "disableDecisionEvent";
        public static final String ENABLED_FLAGS_ONLY = "enabledFlagsOnly";
        public static final String IGNORE_USER_PROFILE_SERVICE = "ignoreUserProfileService";
        public static final String INCLUDE_REASONS = "includeReasons";
        public static final String EXCLUDE_VARIABLES = "excludeVariables";
    }

    public static class SegmentOption {
        public static final String IGNORE_CACHE = "ignoreCache";
        public static final String RESET_CACHE = "resetCache";
    }

    public static class LogLevel {
        public static final String ERROR = "error";
        public static final String WARNING = "warning";
        public static final String INFO = "info";
        public static final String DEBUG = "debug";
    }
}
