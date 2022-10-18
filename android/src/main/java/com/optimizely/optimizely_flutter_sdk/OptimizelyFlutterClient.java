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
import com.optimizely.ab.android.event_handler.DefaultEventHandler;
import com.optimizely.ab.android.sdk.OptimizelyClient;

import java.util.HashMap;
import java.util.Map;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.optimizely.ab.android.sdk.OptimizelyManager;
import com.optimizely.ab.android.shared.DatafileConfig;
import com.optimizely.ab.config.Variation;
import com.optimizely.ab.error.RaiseExceptionErrorHandler;
import com.optimizely.ab.event.BatchEventProcessor;
import com.optimizely.ab.event.EventProcessor;
import com.optimizely.ab.event.LogEvent;
import com.optimizely.ab.notification.ActivateNotification;
import com.optimizely.ab.notification.DecisionNotification;
import com.optimizely.ab.notification.NotificationCenter;
import com.optimizely.ab.notification.TrackNotification;
import com.optimizely.ab.notification.UpdateConfigNotification;
import com.optimizely.ab.optimizelyconfig.OptimizelyConfig;
import com.optimizely.ab.optimizelydecision.OptimizelyDecideOption;
import com.optimizely.ab.optimizelydecision.OptimizelyDecision;
import com.optimizely.optimizely_flutter_sdk.helper_classes.ArgumentsParser;
import com.optimizely.optimizely_flutter_sdk.helper_classes.Utils;

import static com.optimizely.optimizely_flutter_sdk.helper_classes.Constants.*;
import static com.optimizely.optimizely_flutter_sdk.helper_classes.Utils.getNotificationType;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.TimeUnit;

public class OptimizelyFlutterClient {
    protected Context context;
    protected Activity activity;

    protected static final Map<String, OptimizelyManager> optimizelyManagerTracker = new HashMap<>();
    protected static final Map<String, Map<String, OptimizelyUserContext>> userContextsTracker = new HashMap<>();
    protected static final Map<Integer, Integer> notificationIdsTracker = new HashMap<>();


    protected void initializeOptimizely(@NonNull ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        if (sdkKey == null) {
            result.success(createResponse(ErrorMessage.INVALID_PARAMS));
            return;
        }
        // EventDispatcher Default Values
        Integer batchSize = 10;
        long timeInterval = TimeUnit.MINUTES.toMillis(1L); // Minutes
        Integer maxQueueSize = 10000;

        if (argumentsParser.getEventBatchSize() != null) {
            batchSize = argumentsParser.getEventBatchSize();
        }
        if (argumentsParser.getEventTimeInterval() != null) {
            timeInterval = TimeUnit.SECONDS.toMillis(argumentsParser.getEventTimeInterval());
        }
        if (argumentsParser.getEventMaxQueueSize() != null) {
            maxQueueSize = argumentsParser.getEventMaxQueueSize();
        }

        DefaultEventHandler eventHandler = DefaultEventHandler.getInstance(context);
        eventHandler.setDispatchInterval(-1L);
        NotificationCenter notificationCenter = new NotificationCenter();
        // Here we are using the builder options to set batch size
        // to 5 events and flush interval to a minute.
        EventProcessor batchProcessor = BatchEventProcessor.builder()
                .withNotificationCenter(notificationCenter)
                .withEventHandler(eventHandler)
                .withBatchSize(batchSize)
                .withEventQueue(new ArrayBlockingQueue<>(maxQueueSize))
                .withFlushInterval(timeInterval)
                .build();

        // Datafile Download Interval
        long datafilePeriodicDownloadInterval = 10 * 60; // seconds

        if (argumentsParser.getDatafilePeriodicDownloadInterval() != null) {
            datafilePeriodicDownloadInterval = argumentsParser.getDatafilePeriodicDownloadInterval();
        }

        // String default datafile host
        String defaultDatafileHost = "https://cdn.optimizely.com";
        String environmentUrlSuffix = "/datafiles/%s.json";

        DatafileConfig.defaultHost = argumentsParser.getDatafileHostPrefix() != null ? argumentsParser.getDatafileHostPrefix() : defaultDatafileHost;
        DatafileConfig.environmentUrlSuffix = argumentsParser.getDatafileHostSuffix() != null ? argumentsParser.getDatafileHostSuffix() : environmentUrlSuffix;

        // Delete old user context
        userContextsTracker.remove(sdkKey);
        if (getOptimizelyClient(sdkKey) != null) {
            getOptimizelyClient(sdkKey).close();
        }
        optimizelyManagerTracker.remove(sdkKey);

        // Creating new instance
        OptimizelyManager optimizelyManager = OptimizelyManager.builder()
                .withEventProcessor(batchProcessor)
                .withEventHandler(eventHandler)
                .withNotificationCenter(notificationCenter)
                .withDatafileDownloadInterval(datafilePeriodicDownloadInterval, TimeUnit.SECONDS)
                .withErrorHandler(new RaiseExceptionErrorHandler())
                .withSDKKey(sdkKey)
                .build(context);

        optimizelyManager.initialize(context, null, (OptimizelyClient client) -> {
            if (client.isValid()) {
                optimizelyManagerTracker.put(sdkKey, optimizelyManager);
                result.success(createResponse());
            } else {
                result.success(createResponse(ErrorMessage.INVALID_OPTIMIZELY_CLIENT));
            }
        });
    }

    protected void createUserContext(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);

        if (!isOptimizelyClientValid(sdkKey, optimizelyClient, result)) {
            return;
        }

        String userId = argumentsParser.getUserId();
        Map<String, Object> attributes = argumentsParser.getAttributes();
        if (userId == null) {
            result.success(createResponse(ErrorMessage.INVALID_PARAMS));
            return;
        }
        try {
            String userContextId = Utils.getRandomUUID();

            OptimizelyUserContext optlyUserContext = optimizelyClient.createUserContext(userId, attributes);
            if (optlyUserContext != null) {
                if (userContextsTracker.containsKey(sdkKey)) {
                    userContextsTracker.get(sdkKey).put(userContextId, optlyUserContext);
                } else {
                    Map<String, OptimizelyUserContext> idContextMap = new HashMap<>();
                    idContextMap.put(userContextId, optlyUserContext);
                    userContextsTracker.put(sdkKey, idContextMap);
                }
                result.success(createResponse(
                        Collections.singletonMap(RequestParameterKey.USER_CONTEXT_ID, userContextId)));
            } else {
                result.success(createResponse(ErrorMessage.USER_CONTEXT_NOT_CREATED));
            }
        } catch (Exception ex) {
            result.success(createResponse(ex.getMessage()));
        }
    }

    protected void activate(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);

        if (!isOptimizelyClientValid(sdkKey, optimizelyClient, result)) {
            return;
        }

        String experimentKey = argumentsParser.getExperimentKey();
        String userId = argumentsParser.getUserId();
        Map<String, Object> attributes = argumentsParser.getAttributes();

        if (userId == null || experimentKey == null) {
            result.success(createResponse(ErrorMessage.INVALID_PARAMS));
            return;
        }

        try {
            Variation variation = optimizelyClient.activate(experimentKey, userId, attributes);
            result.success(createResponse(Collections.singletonMap(RequestParameterKey.VARIATION_KEY, variation.getKey())));
        } catch (Exception ex) {
            result.success(createResponse(ex.getMessage()));
        }
    }

    protected void getVariation(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);

        if (!isOptimizelyClientValid(sdkKey, optimizelyClient, result)) {
            return;
        }

        String experimentKey = argumentsParser.getExperimentKey();
        String userId = argumentsParser.getUserId();
        Map<String, Object> attributes = argumentsParser.getAttributes();

        if (userId == null || experimentKey == null) {
            result.success(createResponse(ErrorMessage.INVALID_PARAMS));
            return;
        }

        try {
            Variation variation = optimizelyClient.getVariation(experimentKey, userId, attributes);
            result.success(createResponse(Collections.singletonMap(RequestParameterKey.VARIATION_KEY, variation.getKey())));
        } catch (Exception ex) {
            result.success(createResponse(ex.getMessage()));
        }

    }

    /// Get forced variation for experiment and user ID.
    protected void getForcedVariation(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);

        if (!isOptimizelyClientValid(sdkKey, optimizelyClient, result)) {
            return;
        }

        String experimentKey = argumentsParser.getExperimentKey();
        String userId = argumentsParser.getUserId();
        if (userId == null || experimentKey == null) {
            result.success(createResponse(ErrorMessage.INVALID_PARAMS));
            return;
        }

        Variation variation = optimizelyClient.getForcedVariation(experimentKey, userId);
        if (variation != null) {
            String variationKey = variation.getKey();
            result.success(createResponse(Collections.singletonMap(RequestParameterKey.VARIATION_KEY, variationKey)));
            return;
        }

        result.success(createResponse());
    }

    /// Set forced variation for experiment and user ID to variationKey.
    protected void setForcedVariation(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);

        if (!isOptimizelyClientValid(sdkKey, optimizelyClient, result)) {
            return;
        }

        String experimentKey = argumentsParser.getExperimentKey();
        String userId = argumentsParser.getUserId();
        if (userId == null || experimentKey == null) {
            result.success(createResponse(ErrorMessage.INVALID_PARAMS));
            return;
        }

        String variationKey = argumentsParser.getVariationKey();
        Boolean success = optimizelyClient.setForcedVariation(experimentKey, userId, variationKey);

        result.success(createResponse(success));
    }

    protected void decide(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        OptimizelyUserContext userContext = getUserContext(argumentsParser);
        if (!isUserContextValid(sdkKey, userContext, result)) {
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
        result.success(createResponse(s));
    }

    protected void setForcedDecision(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        OptimizelyUserContext userContext = getUserContext(argumentsParser);
        if (!isUserContextValid(sdkKey, userContext, result)) {
            return;
        }

        String flagKey = argumentsParser.getFlagKey();
        String ruleKey = argumentsParser.getRuleKey();
        String variationKey = argumentsParser.getVariationKey();

        if (flagKey == null || variationKey == null) {
            result.success(createResponse(ErrorMessage.INVALID_PARAMS));
            return;
        }

        OptimizelyDecisionContext optimizelyDecisionContext = new OptimizelyDecisionContext(flagKey, ruleKey);
        OptimizelyForcedDecision optimizelyForcedDecision = new OptimizelyForcedDecision(variationKey);
        userContext.setForcedDecision(optimizelyDecisionContext, optimizelyForcedDecision);

        result.success(createResponse());
    }

    protected void getForcedDecision(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        OptimizelyUserContext userContext = getUserContext(argumentsParser);
        if (!isUserContextValid(sdkKey, userContext, result)) {
            return;
        }
        String flagKey = argumentsParser.getFlagKey();
        String ruleKey = argumentsParser.getRuleKey();
        if (flagKey == null) {
            result.success(createResponse(ErrorMessage.INVALID_PARAMS));
            return;
        }

        OptimizelyDecisionContext optimizelyDecisionContext = new OptimizelyDecisionContext(flagKey, ruleKey);
        OptimizelyForcedDecision forcedDecision = userContext.getForcedDecision(optimizelyDecisionContext);
        if (forcedDecision != null) {
            result.success(createResponse(Collections.singletonMap(RequestParameterKey.VARIATION_KEY, forcedDecision.getVariationKey())));
            return;
        }

        result.success(createResponse());
    }

    protected void removeForcedDecision(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        OptimizelyUserContext userContext = getUserContext(argumentsParser);
        if (!isUserContextValid(sdkKey, userContext, result)) {
            return;
        }

        String flagKey = argumentsParser.getFlagKey();
        String ruleKey = argumentsParser.getRuleKey();
        if (flagKey == null) {
            result.success(createResponse(ErrorMessage.INVALID_PARAMS));
            return;
        }

        OptimizelyDecisionContext optimizelyDecisionContext = new OptimizelyDecisionContext(flagKey, ruleKey);
        userContext.removeForcedDecision(optimizelyDecisionContext);

        result.success(createResponse());
    }

    protected void removeAllForcedDecisions(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        OptimizelyUserContext userContext = getUserContext(argumentsParser);
        if (!isUserContextValid(sdkKey, userContext, result)) {
            return;
        }
        userContext.removeAllForcedDecisions();

        result.success(createResponse());
    }

    protected void close(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);
        if (!isOptimizelyClientValid(sdkKey, optimizelyClient, result)) {
            return;
        }

        optimizelyClient.close();

        optimizelyManagerTracker.remove(sdkKey);
        userContextsTracker.remove(sdkKey);

        result.success(createResponse());
    }

    protected void trackEvent(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        OptimizelyUserContext userContext = getUserContext(argumentsParser);
        if (!isUserContextValid(sdkKey, userContext, result)) {
            return;
        }

        String eventKey = argumentsParser.getEventKey();
        Map<String, Object> eventTags = argumentsParser.getEventTags();
        if (eventKey == null || eventKey.trim().isEmpty()) {
            result.success(createResponse(ErrorMessage.INVALID_PARAMS));
            return;
        }
        if (eventTags == null) {
            eventTags = Collections.emptyMap();
        }
        try {
            userContext.trackEvent(eventKey, eventTags);
            result.success(createResponse());
        } catch (UnknownEventTypeException ex) {
            result.success(createResponse(ex.getMessage()));
        }
    }

    protected void getUserId(ArgumentsParser argumentsParser, @NonNull Result result) {
        OptimizelyUserContext userContext = getUserContext(argumentsParser);
        if (userContext == null) {
            result.success(createResponse(ErrorMessage.USER_CONTEXT_NOT_FOUND));
            return;
        }
        result.success(createResponse(Collections.singletonMap(RequestParameterKey.USER_ID, userContext.getUserId())));
    }

    protected void getAttributes(ArgumentsParser argumentsParser, @NonNull Result result) {
        OptimizelyUserContext userContext = getUserContext(argumentsParser);
        if (userContext == null) {
            result.success(createResponse(ErrorMessage.USER_CONTEXT_NOT_FOUND));
            return;
        }
        result.success(createResponse(Collections.singletonMap(RequestParameterKey.ATTRIBUTES, userContext.getAttributes())));
    }

    protected void setAttribute(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        OptimizelyUserContext userContext = getUserContext(argumentsParser);
        if (!isUserContextValid(sdkKey, userContext, result)) {
            return;
        }

        Map<String, Object> attributes = argumentsParser.getAttributes();

        if (attributes == null) {
            result.success(createResponse(ErrorMessage.INVALID_PARAMS));
            return;
        }
        for (String attributeKey : attributes.keySet()) {
            userContext.setAttribute(attributeKey, attributes.get(attributeKey));
        }
        userContextsTracker.get(sdkKey).put(argumentsParser.getUserContextId(), userContext);
        result.success(createResponse(userContext.getAttributes()));
    }

    protected void removeNotificationListener(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);
        if (!isOptimizelyClientValid(sdkKey, optimizelyClient, result)) {
            return;
        }

        Integer id = argumentsParser.getNotificationID();
        String type = argumentsParser.getNotificationType();

        if (id == null || type == null) {
            result.success(createResponse(ErrorMessage.INVALID_PARAMS));
            return;
        }
        optimizelyClient.getNotificationCenter().removeNotificationListener(id);
        notificationIdsTracker.remove(id);
        result.success(createResponse());
    }

    protected void removeAllNotificationListeners(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);
        if (!isOptimizelyClientValid(sdkKey, optimizelyClient, result)) {
            return;
        }

        String type = argumentsParser.getNotificationType();
        List<Integer> callBackIds = argumentsParser.getCallBackIds();

        if (type == null) {
            optimizelyClient.getNotificationCenter().clearAllNotificationListeners();
            notificationIdsTracker.clear();
        } else {
            optimizelyClient.getNotificationCenter().clearNotificationListeners(getNotificationType(type));
            for (Integer id: callBackIds) {
                notificationIdsTracker.remove(id);
            }
        }
        result.success(createResponse());
    }

    protected void getOptimizelyConfig(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);
        if (!isOptimizelyClientValid(sdkKey, optimizelyClient, result)) {
            return;
        }

        OptimizelyConfig optimizelyConfig = optimizelyClient.getOptimizelyConfig();
        if (optimizelyConfig == null) {
            result.success(createResponse(ErrorMessage.OPTIMIZELY_CONFIG_NOT_FOUND));
            return;
        }
        ObjectMapper objMapper = new ObjectMapper();
        Map optimizelyConfigMap = objMapper.convertValue(optimizelyConfig, Map.class);
        optimizelyConfigMap.remove("datafile");
        result.success(createResponse(optimizelyConfigMap));
    }

    protected void addNotificationListener(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);
        if (!isOptimizelyClientValid(sdkKey, optimizelyClient, result)) {
            return;
        }

        Integer id = argumentsParser.getNotificationID();
        String type = argumentsParser.getNotificationType();

        if (id == null || type == null) {
            result.success(createResponse(ErrorMessage.INVALID_PARAMS));
            return;
        }
        int notificationId = 0;
        switch (type) {
            case NotificationType.DECISION: {
                notificationId = optimizelyClient.getNotificationCenter().addNotificationHandler(DecisionNotification.class, decisionNotification -> {
                    Map<String, Object> notificationMap = new HashMap<>();
                    notificationMap.put(DecisionListenerKeys.TYPE, decisionNotification.getType());
                    notificationMap.put(DecisionListenerKeys.USER_ID, decisionNotification.getUserId());
                    notificationMap.put(DecisionListenerKeys.ATTRIBUTES, decisionNotification.getAttributes());
                    notificationMap.put(DecisionListenerKeys.DECISION_INFO, decisionNotification.getDecisionInfo());
                    invokeNotification(id, NotificationType.DECISION, notificationMap);
                });
                break;
            }
            case NotificationType.ACTIVATE: {
                notificationId = optimizelyClient.getNotificationCenter().addNotificationHandler(ActivateNotification.class, activateNotification -> {
                    Map<String, Object> notificationMap = new HashMap<>();

                    Map<String, String> experimentMap = new HashMap<>();
                    experimentMap.put(ActivateListenerKeys.ID, activateNotification.getExperiment().getId());
                    experimentMap.put(ActivateListenerKeys.KEY, activateNotification.getExperiment().getKey());

                    Map<String, String> variationMap = new HashMap<>();
                    variationMap.put(ActivateListenerKeys.ID, activateNotification.getVariation().getId());
                    variationMap.put(ActivateListenerKeys.KEY, activateNotification.getVariation().getKey());

                    notificationMap.put(ActivateListenerKeys.EXPERIMENT, experimentMap);
                    notificationMap.put(ActivateListenerKeys.USER_ID, activateNotification.getUserId());
                    notificationMap.put(ActivateListenerKeys.ATTRIBUTES, activateNotification.getAttributes());
                    notificationMap.put(ActivateListenerKeys.VARIATION, variationMap);
                    invokeNotification(id, NotificationType.ACTIVATE, notificationMap);
                });
                break;
            }
            case NotificationType.TRACK: {
                notificationId = optimizelyClient.getNotificationCenter().addNotificationHandler(TrackNotification.class, trackNotification -> {
                    Map<String, Object> notificationMap = new HashMap<>();
                    notificationMap.put(TrackListenerKeys.EVENT_KEY, trackNotification.getEventKey());
                    notificationMap.put(TrackListenerKeys.USER_ID, trackNotification.getUserId());
                    notificationMap.put(TrackListenerKeys.ATTRIBUTES, trackNotification.getAttributes());
                    notificationMap.put(TrackListenerKeys.EVENT_TAGS, trackNotification.getEventTags());
                    invokeNotification(id, NotificationType.TRACK, notificationMap);
                });
                break;
            }
            case NotificationType.LOG_EVENT: {
                notificationId = optimizelyClient.getNotificationCenter().addNotificationHandler(LogEvent.class, logEvent -> {
                    ObjectMapper mapper = new ObjectMapper();
                    Map<String, Object> eventParams = mapper.readValue(logEvent.getBody(), Map.class);
                    Map<String, Object> listenerMap = new HashMap<>();
                    listenerMap.put(LogEventListenerKeys.URL, logEvent.getEndpointUrl());
                    listenerMap.put(LogEventListenerKeys.PARAMS, eventParams);
                    invokeNotification(id, NotificationType.LOG_EVENT, listenerMap);
                });
                break;
            }
            case NotificationType.CONFIG_UPDATE: {
                notificationId = optimizelyClient.getNotificationCenter().addNotificationHandler(UpdateConfigNotification.class, configUpdate -> {
                    Map<String, Object> listenerMap = new HashMap<>();
                    listenerMap.put("Config-update", Collections.emptyMap());
                    invokeNotification(id, NotificationType.CONFIG_UPDATE, listenerMap);
                });
                break;
            }
            default:
                result.success(createResponse(ErrorMessage.INVALID_PARAMS));
        }
        notificationIdsTracker.put(id, notificationId);
        result.success(createResponse());
    }

    private OptimizelyClient getOptimizelyClient(String SDKKey) {
        return optimizelyManagerTracker.get(SDKKey) == null ? null : optimizelyManagerTracker.get(SDKKey).getOptimizely();
    }

    private OptimizelyUserContext getUserContext(ArgumentsParser argumentsParser) {
        String SDKKey = argumentsParser.getSdkKey();
        String userContextId = argumentsParser.getUserContextId();
        if (userContextsTracker.get(SDKKey) == null || !userContextsTracker.get(SDKKey).containsKey(userContextId)) {
            return null;
        }
        return userContextsTracker.get(SDKKey).get(userContextId);
    }

    private Map<String, ?> createResponse(Boolean success, Object result, String reason) {
        Map<String, Object> response = new HashMap<>();
        response.put(ResponseKey.SUCCESS, success);
        response.put(ResponseKey.RESULT, result);
        response.put(ResponseKey.REASON, reason);

        return response;
    }

    // Create response with success, empty reason and null object response
    private Map<String, ?> createResponse(Boolean success) {
        return createResponse(success, null, "");
    }

    // Create response with empty reason and null object response when success is true
    private Map<String, ?> createResponse() {
        return createResponse(true, null, "");
    }

    // Create response with result when success is true
    private Map<String, ?> createResponse(Object result) {
        return createResponse(true, result, "");
    }

    // Create response with reason when success is false
    private Map<String, ?> createResponse(String reason) {
        return createResponse(false, null, reason);
    }

    private boolean isOptimizelyClientValid(String sdkKey, OptimizelyClient optimizelyClient, @NonNull Result result) {
        if (sdkKey == null) {
            result.success(createResponse(ErrorMessage.INVALID_PARAMS));
            return false;
        }
        if (optimizelyClient == null) {
            result.success(createResponse(ErrorMessage.OPTIMIZELY_CLIENT_NOT_FOUND));
            return false;
        }
        return true;
    }

    private boolean isUserContextValid(String sdkKey, OptimizelyUserContext optimizelyUserContext, @NonNull Result result) {
        if (sdkKey == null) {
            result.success(createResponse(ErrorMessage.INVALID_PARAMS));
            return false;
        }
        if (optimizelyUserContext == null) {
            result.success(createResponse(ErrorMessage.USER_CONTEXT_NOT_FOUND));
            return false;
        }
        return true;
    }

    private void invokeNotification(int id, String notificationType, Map notificationMap) {
        Map<String, Object> listenerResponse = new HashMap<>();
        listenerResponse.put(RequestParameterKey.NOTIFICATION_ID, id);
        listenerResponse.put(RequestParameterKey.NOTIFICATION_TYPE, notificationType);
        listenerResponse.put(RequestParameterKey.NOTIFICATION_PAYLOAD, notificationMap);
        Map<String, Object> listenerUnmodifiable = Collections.unmodifiableMap(listenerResponse);
        // Get a handler that can be used to post to the main thread
        Handler mainHandler = new Handler(context.getMainLooper());

        Runnable myRunnable = () -> OptimizelyFlutterSdkPlugin.channel.invokeMethod(notificationType + "CallbackListener", listenerUnmodifiable);
        mainHandler.post(myRunnable);
    }
}
