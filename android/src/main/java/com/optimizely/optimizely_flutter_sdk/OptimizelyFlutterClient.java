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

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Objects;
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
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
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

        String userId = argumentsParser.getUserId();
        Map<String, Object> attributes = argumentsParser.getAttributes();
        if (userId == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        try {
            String userContextId = Utils.getRandomUUID();

            OptimizelyUserContext optlyUserContext = optimizelyClient.createUserContext(userId, attributes);
            if (optlyUserContext != null) {
                if (userContextsTracker.containsKey(sdkKey)) {
                    userContextsTracker.get(sdkKey).put(userContextId, optlyUserContext);
                } else {
                    userContextsTracker.put(sdkKey, Collections.singletonMap(userContextId, optlyUserContext));
                }
                result.success(createResponse(true,
                        Collections.singletonMap(RequestParameterKey.USER_CONTEXT_ID, optlyUserContext),
                        SuccessMessage.USER_CONTEXT_CREATED));
            } else {
                result.success(createResponse(false, "User context not created "));
            }
        } catch (Exception ex) {
            result.success(createResponse(false, ex.getMessage()));
        }
    }

    protected void activate(ArgumentsParser argumentsParser, @NonNull Result result) {
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

        String experimentKey = argumentsParser.getExperimentKey();
        String userId = argumentsParser.getUserID();
        Map<String, Object> attributes = argumentsParser.getAttributes();

        if (userId == null || experimentKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }

        try {
            Variation variation = optimizelyClient.activate(experimentKey, userId, attributes);
            String variationKey = variation != null ? variation.getKey() : null;
            result.success(createResponse(true, Collections.singletonMap(RequestParameterKey.VARIATION_KEY, variationKey), ""));
        } catch (Exception ex) {
            result.success(createResponse(false, ex.getMessage()));
        }
    }

    protected void getVariation(ArgumentsParser argumentsParser, @NonNull Result result) {
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

        String experimentKey = argumentsParser.getExperimentKey();
        String userId = argumentsParser.getUserID();
        Map<String, Object> attributes = argumentsParser.getAttributes();

        if (userId == null || experimentKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }

        try {
            Variation variation = optimizelyClient.getVariation(experimentKey, userId, attributes);
            String variationKey = variation != null ? variation.getKey() : null;
            result.success(createResponse(true, Collections.singletonMap(RequestParameterKey.VARIATION_KEY, variationKey), ""));
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

        OptimizelyUserContext userContext = getUserContext(argumentsParser);
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
        OptimizelyUserContext userContext = getUserContext(argumentsParser);
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
            return;
        }

        result.success(createResponse(false, ""));
    }

    protected void getForcedDecision(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        if (sdkKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        OptimizelyUserContext userContext = getUserContext(argumentsParser);
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
        OptimizelyUserContext userContext = getUserContext(argumentsParser);
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
            return;
        }

        result.success(createResponse(false, ""));
    }

    protected void removeAllForcedDecisions(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        if (sdkKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        OptimizelyUserContext userContext = getUserContext(argumentsParser);
        if (userContext == null) {
            result.success(createResponse(false, ErrorMessage.USER_CONTEXT_NOT_FOUND));
            return;
        }

        if (userContext.removeAllForcedDecisions()) {
            result.success(createResponse(true, SuccessMessage.REMOVED_ALL_FORCED_DECISION));
        }

        result.success(createResponse(false, ""));
    }

    protected void close(ArgumentsParser argumentsParser, @NonNull Result result) {
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
        optimizelyClient.close();

        optimizelyManagerTracker.remove(sdkKey);
        userContextsTracker.remove(sdkKey);

        result.success(createResponse(true, SuccessMessage.OPTIMIZELY_CLIENT_CLOSED));
    }

    protected void trackEvent(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        if (sdkKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        OptimizelyUserContext userContext = getUserContext(argumentsParser);

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

    protected void getUserId(ArgumentsParser argumentsParser, @NonNull Result result) {
        OptimizelyUserContext userContext = getUserContext(argumentsParser);
        if (userContext == null) {
            result.success(createResponse(false, ErrorMessage.USER_CONTEXT_NOT_FOUND));
            return;
        }
        result.success(createResponse(true, Collections.singletonMap(RequestParameterKey.USER_ID, userContext.getUserId()), ""));
    }

    protected void getAttributes(ArgumentsParser argumentsParser, @NonNull Result result) {
        OptimizelyUserContext userContext = getUserContext(argumentsParser);
        if (userContext == null) {
            result.success(createResponse(false, ErrorMessage.USER_CONTEXT_NOT_FOUND));
            return;
        }
        result.success(createResponse(true, Collections.singletonMap(RequestParameterKey.ATTRIBUTES, userContext.getAttributes()), ""));
    }

    protected void setAttribute(ArgumentsParser argumentsParser, @NonNull Result result) {
        String sdkKey = argumentsParser.getSdkKey();
        if (sdkKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        OptimizelyUserContext userContext = getUserContext(argumentsParser);

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
        userContextsTracker.get(sdkKey).put(argumentsParser.getUserContextId(), userContext);
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

    public OptimizelyUserContext getUserContext(ArgumentsParser argumentsParser) {
        String SDKKey = argumentsParser.getSdkKey();
        String userContextId = argumentsParser.getUserContextId();
        if (userContextId == null || !userContextsTracker.get(SDKKey).containsKey(userContextId)) {
            return null;
        }
        return userContextsTracker.get(SDKKey).get(userContextId);
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
                    notificationMap.put(DecisionListenerKeys.DECISION_INFO, decisionNotification.getDecisionInfo());
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
        // Get a handler that can be used to post to the main thread
        Handler mainHandler = new Handler(context.getMainLooper());

        Runnable myRunnable = () -> OptimizelyFlutterSdkPlugin.channel.invokeMethod(notificationType+"CallbackListener", listenerUnmodifiable);
        mainHandler.post(myRunnable);
    }
}
