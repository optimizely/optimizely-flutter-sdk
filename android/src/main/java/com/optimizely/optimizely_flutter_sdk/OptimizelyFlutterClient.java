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
package com.optimizely.optimizely_flutter_sdk;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.MethodChannel.Result;

import com.optimizely.ab.OptimizelyUserContext;
import com.optimizely.ab.OptimizelyDecisionContext;
import com.optimizely.ab.OptimizelyForcedDecision;
import com.optimizely.ab.UnknownEventTypeException;
import com.optimizely.ab.android.sdk.OptimizelyClient;

import java.util.HashMap;
import java.util.Map;

import android.app.Activity;
import android.content.Context;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.optimizely.ab.android.sdk.OptimizelyManager;
import com.optimizely.ab.error.RaiseExceptionErrorHandler;
import com.optimizely.ab.event.LogEvent;
import com.optimizely.ab.notification.DecisionNotification;
import com.optimizely.ab.notification.TrackNotification;
import com.optimizely.ab.notification.UpdateConfigNotification;
import com.optimizely.ab.optimizelyconfig.OptimizelyConfig;
import com.optimizely.ab.optimizelydecision.OptimizelyDecideOption;
import com.optimizely.ab.optimizelydecision.OptimizelyDecision;
import com.optimizely.optimizely_flutter_sdk.helper_classes.ArgumentsParser;

import static com.optimizely.optimizely_flutter_sdk.helper_classes.Constants.*;
import static com.optimizely.optimizely_flutter_sdk.helper_classes.Utils.convertKeysCamelCaseToSnakeCase;
import static com.optimizely.optimizely_flutter_sdk.helper_classes.Utils.isValidAttribute;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class OptimizelyFlutterClient {
    protected Context context;
    protected Activity activity;

    protected static final Map<String, OptimizelyManager> optimizelyManagerTracker = new HashMap<>();
    protected static final Map<String, OptimizelyUserContext> userContextsTracker = new HashMap<>();
    protected static final Map<Integer, Integer> notificationIdsTracker = new HashMap<>();


    protected void initializeOptimizely(@NonNull ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        if (sdkKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        // Delete old user context
        userContextsTracker.remove(sdkKey);
        // Creating new instance
        OptimizelyManager optimizelyManager = OptimizelyManager.builder()
                .withEventDispatchInterval(60L, TimeUnit.SECONDS)
                .withDatafileDownloadInterval(15, TimeUnit.MINUTES)
                .withErrorHandler(new RaiseExceptionErrorHandler())
                .withSDKKey(sdkKey)
                .build(context);
        optimizelyManager.initialize(context, null, (OptimizelyClient client) -> {
            if (client.isValid()) {
                optimizelyManagerTracker.put(sdkKey, optimizelyManager);
                result.success(createResponse(true, SuccessMessage.INSTANCE_CREATED));
            } else {
                result.success(createResponse(false, ErrorMessage.OPTIMIZELY_CLIENT_NOT_FOUND));
            }
        });
    }

    protected void createUserContext(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        if (sdkKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }

        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);
         if (optimizelyClient == null) {
            result.success(createResponse(false, ErrorMessage.OPTIMIZELY_CLIENT_NOT_FOUND));
            return;
        }

        String userId = argumentsParser.getUserID();
        Map<String, Object> attributes = argumentsParser.getAttributes();
        if (userId == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        try {
            OptimizelyUserContext optlyUserContext = null;
            if (attributes != null) {
                optlyUserContext = optimizelyClient.createUserContext(userId, attributes);
                userContextsTracker.put(sdkKey, optlyUserContext);
            } else {
                optlyUserContext = optimizelyClient.createUserContext(userId);
                userContextsTracker.put(sdkKey, optlyUserContext);
            }
            if (optlyUserContext != null)
                result.success(createResponse(true, SuccessMessage.USER_CONTEXT_CREATED));
            else
                result.success(createResponse(false, "User context not created "));
        } catch (Exception ex) {
            result.success(createResponse(false, ex.getMessage()));
        }
    }

    protected void decide(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        if (sdkKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }

        OptimizelyUserContext userContext = getUserContext(sdkKey);
        if (userContext == null) {
            result.success(createResponse(false, ErrorMessage.USER_CONTEXT_NOT_FOUND));
            return;
        }
        List<String> decideKeys = argumentsParser.getDecideKeys();
        List<OptimizelyDecideOption> decideOptions = argumentsParser.getDecideOptions();

        Map<String, OptimizelyDecision> optimizelyDecisionsMap;

        if (decideKeys.size() > 0) {
            optimizelyDecisionsMap = userContext.decideForKeys(decideKeys, decideOptions);
        } else {
            optimizelyDecisionsMap = userContext.decideAll(decideOptions);
        }

        Map<String, OptimizelyDecisionResponse> optimizelyDecisionResponseMap = null;
        if (optimizelyDecisionsMap != null) {
            optimizelyDecisionResponseMap = new HashMap<>();
            for (Map.Entry<String, OptimizelyDecision> entry : optimizelyDecisionsMap.entrySet()) {
                optimizelyDecisionResponseMap.put(entry.getKey(), new OptimizelyDecisionResponse(entry.getValue()));
            }
        }
        ObjectMapper mapper = new ObjectMapper();
        Map<String, Object> s = mapper.convertValue(optimizelyDecisionResponseMap, LinkedHashMap.class);
        result.success(createResponse(true, s, SuccessMessage.DECIDE_CALLED));
    }

    protected void setForcedDecision(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        if (sdkKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        OptimizelyUserContext userContext = getUserContext(sdkKey);
        if (userContext == null) {
            result.success(createResponse(false, ErrorMessage.USER_CONTEXT_NOT_FOUND));
            return;
        }
        String flagKey = argumentsParser.getFlagKey();
        String ruleKey = argumentsParser.getRuleKey();
        String variationKey = argumentsParser.getVariationKey();

        if (flagKey == null || variationKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        
        OptimizelyDecisionContext optimizelyDecisionContext = new OptimizelyDecisionContext(flagKey, ruleKey);
        OptimizelyForcedDecision optimizelyForcedDecision = new OptimizelyForcedDecision(variationKey);
        if (userContext.setForcedDecision(optimizelyDecisionContext, optimizelyForcedDecision)) {
            result.success(createResponse(true, SuccessMessage.FORCED_DECISION_SET));
        }

        result.success(createResponse(false, ""));
    }

    protected void getForcedDecision(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        if (sdkKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        OptimizelyUserContext userContext = getUserContext(sdkKey);
        if (userContext == null) {
            result.success(createResponse(false, ErrorMessage.USER_CONTEXT_NOT_FOUND));
            return;
        }
        String flagKey = argumentsParser.getFlagKey();
        String ruleKey = argumentsParser.getRuleKey();
        if (flagKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        
        OptimizelyDecisionContext optimizelyDecisionContext = new OptimizelyDecisionContext(flagKey, ruleKey);
        OptimizelyForcedDecision forcedDecision = userContext.getForcedDecision(optimizelyDecisionContext);
        if (forcedDecision != null) {
            result.success(createResponse(true, Collections.singletonMap(RequestParameterKey.VARIATION_KEY, forcedDecision.getVariationKey()), ""));
        }

        result.success(createResponse(false, ""));
    }

    protected void removeForcedDecision(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        if (sdkKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        OptimizelyUserContext userContext = getUserContext(sdkKey);
        if (userContext == null) {
            result.success(createResponse(false, ErrorMessage.USER_CONTEXT_NOT_FOUND));
            return;
        }

        String flagKey = argumentsParser.getFlagKey();
        String ruleKey = argumentsParser.getRuleKey();
        if (flagKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        
        OptimizelyDecisionContext optimizelyDecisionContext = new OptimizelyDecisionContext(flagKey, ruleKey);
        if (userContext.removeForcedDecision(optimizelyDecisionContext)) {
            result.success(createResponse(true, SuccessMessage.REMOVED_FORCED_DECISION));
        }

        result.success(createResponse(false, ""));
    }

    protected void removeAllForcedDecisions(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        if (sdkKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        OptimizelyUserContext userContext = getUserContext(sdkKey);
        if (userContext == null) {
            result.success(createResponse(false, ErrorMessage.USER_CONTEXT_NOT_FOUND));
            return;
        }

        if (userContext.removeAllForcedDecisions()) {
            result.success(createResponse(true, SuccessMessage.REMOVED_ALL_FORCED_DECISION));
        }

        result.success(createResponse(false, ""));
    }

    protected void trackEvent(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        if (sdkKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        OptimizelyUserContext userContext = getUserContext(sdkKey);

        String eventKey = argumentsParser.getEventKey();
        Map<String, Object> eventTags = argumentsParser.getEventTags();

        if (userContext == null) {
            result.success(createResponse(false, ErrorMessage.USER_CONTEXT_NOT_FOUND));
            return;
        }
        if (eventKey == null || eventKey.trim().isEmpty()) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        if (eventTags == null) {
            eventTags = Collections.emptyMap();
        }
        try {
            userContext.trackEvent(eventKey, eventTags);
            result.success(createResponse(true, SuccessMessage.EVENT_TRACKED));
        } catch (UnknownEventTypeException ex) {
            result.success(createResponse(false, ex.getMessage()));
        }
    }

    protected void setAttribute(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        if (sdkKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        OptimizelyUserContext userContext = getUserContext(sdkKey);

        Map<String, Object> attributes = argumentsParser.getAttributes();
        if (userContext == null) {
            result.success(createResponse(false, ErrorMessage.USER_CONTEXT_NOT_FOUND));
            return;
        }
        if (attributes == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        for (String attributeKey : attributes.keySet()) {
            userContext.setAttribute(attributeKey, attributes.get(attributeKey));
        }
        userContextsTracker.put(sdkKey, userContext);
        result.success(createResponse(true, userContext.getAttributes(), SuccessMessage.ATTRIBUTES_ADDED));
    }

    protected void removeNotificationListener(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        if (sdkKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }

        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);

        Integer id = argumentsParser.getNotificaitonID();
        String type = argumentsParser.getNotificationType();

        if (optimizelyClient == null) {
            result.success(createResponse(false, ErrorMessage.OPTIMIZELY_CLIENT_NOT_FOUND));
            return;
        }
        if (id == null || type == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        optimizelyClient.getNotificationCenter().removeNotificationListener(id);
        notificationIdsTracker.remove(id);
        result.success(createResponse(true, SuccessMessage.LISTENER_REMOVED));
    }

    protected void getOptimizelyConfig(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        if (sdkKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);
        if (optimizelyClient == null) {
            result.success(createResponse(false, ErrorMessage.OPTIMIZELY_CLIENT_NOT_FOUND));
            return;
        }

        OptimizelyConfig optimizelyConfig = optimizelyClient.getOptimizelyConfig();
        if (optimizelyConfig == null) {
            result.success(createResponse(false, ErrorMessage.OPTIMIZELY_CONFIG_NOT_FOUND));
            return;
        }
        ObjectMapper objMapper = new ObjectMapper();
        Map optimizelyConfigMap = objMapper.convertValue(optimizelyConfig, Map.class);
        optimizelyConfigMap.remove("datafile");
        result.success(createResponse(true, optimizelyConfigMap, SuccessMessage.OPTIMIZELY_CONFIG_FOUND));
    }

    public Map<String, ?> createResponse(Boolean success, Object result, String reason) {
        Map<String, Object> response = new HashMap<>();
        response.put(ResponseKey.SUCCESS, success);
        response.put(ResponseKey.RESULT, result);
        response.put(ResponseKey.REASON, reason);

        return response;
    }

    public Map<String, ?> createResponse(Boolean success, String reason) {
        return createResponse(success, null, reason);
    }

    public OptimizelyClient getOptimizelyClient(String SDKKey) {
        return optimizelyManagerTracker.get(SDKKey) == null? null : optimizelyManagerTracker.get(SDKKey).getOptimizely();
    }

    public OptimizelyUserContext getUserContext(String SDKKey) {
        return userContextsTracker.get(SDKKey);
    }

    protected void addNotificationListener(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        if (sdkKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        Integer id = argumentsParser.getNotificaitonID();
        String type = argumentsParser.getNotificationType();

        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);
        if (optimizelyClient == null) {
            result.success(createResponse(false, ErrorMessage.OPTIMIZELY_CLIENT_NOT_FOUND));
            return;
        }

        if (id == null || type == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        switch (type) {
            case NotificationType.DECISION: {
                int notificationId = optimizelyClient.getNotificationCenter().addNotificationHandler(DecisionNotification.class, decisionNotification -> {
                    Map<String, Object> notificationMap = new HashMap<>();
                    notificationMap.put(DecisionListenerKeys.TYPE, decisionNotification.getType());
                    notificationMap.put(DecisionListenerKeys.USER_ID, decisionNotification.getUserId());
                    notificationMap.put(DecisionListenerKeys.ATTRIBUTES, decisionNotification.getAttributes());
                    notificationMap.put(DecisionListenerKeys.DECISION_INFO, convertKeysCamelCaseToSnakeCase(decisionNotification.getDecisionInfo()));
                    invokeNotification(id, NotificationType.DECISION, notificationMap);
                });
                notificationIdsTracker.put(id, notificationId);
                result.success(createResponse(true, SuccessMessage.LISTENER_ADDED));
                break;
            }
            case NotificationType.TRACK: {
                int notificationId = optimizelyClient.getNotificationCenter().addNotificationHandler(TrackNotification.class, trackNotification -> {
                    Map<String, Object> notificationMap = new HashMap<>();
                    notificationMap.put(TrackListenerKeys.EVENT_KEY, trackNotification.getEventKey());
                    notificationMap.put(TrackListenerKeys.USER_ID, trackNotification.getUserId());
                    notificationMap.put(TrackListenerKeys.ATTRIBUTES, trackNotification.getAttributes());
                    notificationMap.put(TrackListenerKeys.EVENT_TAGS, trackNotification.getEventTags());
                    invokeNotification(id, NotificationType.TRACK, notificationMap);
                });
                notificationIdsTracker.put(id, notificationId);
                result.success(createResponse(true, SuccessMessage.LISTENER_ADDED));
                break;
            }
            case NotificationType.LOG_EVENT: {
                int notificationId = optimizelyClient.getNotificationCenter().addNotificationHandler(LogEvent.class, logEvent -> {
                    ObjectMapper mapper = new ObjectMapper();
                    Map<String, Object> eventParams = mapper.readValue(logEvent.getBody(), Map.class);
                    Map<String, Object> listenerMap = new HashMap<>();
                    listenerMap.put(LogEventListenerKeys.URL, logEvent.getEndpointUrl());
                    listenerMap.put(LogEventListenerKeys.HTTP_VERB, logEvent.getRequestMethod());
                    listenerMap.put(LogEventListenerKeys.PARAMS, eventParams);
                    invokeNotification(id, NotificationType.LOG_EVENT, listenerMap);
                });
                notificationIdsTracker.put(id, notificationId);
                result.success(createResponse(true, SuccessMessage.LISTENER_ADDED));
                break;
            }
            case NotificationType.CONFIG_UPDATE: {
                int notificationId = optimizelyClient.getNotificationCenter().addNotificationHandler(UpdateConfigNotification.class, configUpdate -> {
                    Map<String, Object> listenerMap = new HashMap<>();
                    listenerMap.put("Config-update", Collections.emptyMap());
                    invokeNotification(id, NotificationType.CONFIG_UPDATE, listenerMap);
                });
                notificationIdsTracker.put(id, notificationId);
                result.success(createResponse(true, SuccessMessage.LISTENER_ADDED));
                break;
            }
            default:
                result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
        }
    }

    private void invokeNotification(int id, String notificationType, Map notificationMap) {
        Map<String, Object> listenerResponse = new HashMap<>();
        listenerResponse.put(RequestParameterKey.NOTIFICATION_ID, id);
        listenerResponse.put(RequestParameterKey.NOTIFICATION_TYPE, notificationType);
        listenerResponse.put(RequestParameterKey.NOTIFICATION_PAYLOAD, notificationMap);
        Map<String, Object> listenerUnmodifiable = Collections.unmodifiableMap(listenerResponse);
        OptimizelyFlutterSdkPlugin.channel.invokeMethod("callbackListener", listenerUnmodifiable);
    }
}