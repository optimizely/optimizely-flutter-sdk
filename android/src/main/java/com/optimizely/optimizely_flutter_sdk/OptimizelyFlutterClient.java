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
import com.optimizely.ab.android.sdk.OptimizelyClient;

import java.util.HashMap;
import java.util.Map;

import android.app.Activity;
import android.content.Context;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.optimizely.ab.android.sdk.OptimizelyManager;
import com.optimizely.ab.optimizelyconfig.OptimizelyConfig;
import com.optimizely.ab.optimizelydecision.OptimizelyDecideOption;
import com.optimizely.ab.optimizelydecision.OptimizelyDecision;
import static com.optimizely.optimizely_flutter_sdk.helper_classes.Constants.*;

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


    protected void initializeOptimizely(@NonNull String sdkKey, @NonNull Result result) {
        // Delete old user context
        userContextsTracker.remove(sdkKey);
        // Creating new instance
        OptimizelyManager optimizelyManager = OptimizelyManager.builder()
                .withEventDispatchInterval(60L, TimeUnit.SECONDS)
                .withDatafileDownloadInterval(15, TimeUnit.MINUTES)
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

    protected void createUserContext(String sdkKey, String userId, Map<String, Object> attributes, @NonNull Result result) {
        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);
        if (optimizelyClient == null) {
            result.success(createResponse(false, ErrorMessage.OPTIMIZELY_CLIENT_NOT_FOUND));
            return;
        }
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

    protected void decide(String sdkKey, List<String> decideKeys, List<OptimizelyDecideOption> decideOptions, @NonNull Result result) {
        OptimizelyUserContext userContext = getUserContext(sdkKey);
        if (userContext == null) {
            result.success(createResponse(false, ErrorMessage.USER_CONTEXT_NOT_FOUND));
            return;
        }

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
        result.success(createResponse(true, s, ""));
    }

    protected void setForcedDecision(String sdkKey, String flagKey, String ruleKey, String variationKey, @NonNull Result result) {
        OptimizelyUserContext userContext = getUserContext(sdkKey);
        if (userContext == null) {
            result.success(createResponse(false, ErrorMessage.USER_CONTEXT_NOT_FOUND));
            return;
        }

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

    protected void getForcedDecision(String sdkKey, String flagKey, String ruleKey, @NonNull Result result) {
        OptimizelyUserContext userContext = getUserContext(sdkKey);
        if (userContext == null) {
            result.success(createResponse(false, ErrorMessage.USER_CONTEXT_NOT_FOUND));
            return;
        }

        if (flagKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        
        OptimizelyDecisionContext optimizelyDecisionContext = new OptimizelyDecisionContext(flagKey, ruleKey);
        OptimizelyForcedDecision forcedDecision = userContext.getForcedDecision(optimizelyDecisionContext);
        if (forcedDecision != null) {
            result.success(createResponse(true, forcedDecision.getVariationKey(), ""));
        }

        result.success(createResponse(false, ""));
    }

    protected void removeForcedDecision(String sdkKey, String flagKey, String ruleKey, @NonNull Result result) {
        OptimizelyUserContext userContext = getUserContext(sdkKey);
        if (userContext == null) {
            result.success(createResponse(false, ErrorMessage.USER_CONTEXT_NOT_FOUND));
            return;
        }

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

    protected void removeAllForcedDecisions(String sdkKey, @NonNull Result result) {
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

    protected void trackEvent(String sdkKey, String eventKey, Map<String, Object> eventTags, @NonNull Result result) {
        OptimizelyUserContext userContext = getUserContext(sdkKey);
        if (userContext == null) {
            result.success(createResponse(false, ErrorMessage.USER_CONTEXT_NOT_FOUND));
            return;
        }
        if (eventKey == null) {
            result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
            return;
        }
        if (eventTags == null) {
            eventTags = Collections.emptyMap();
        }
        try {
            userContext.trackEvent(eventKey, eventTags);
            result.success(createResponse(true, SuccessMessage.EVENT_TRACKED));
        } catch (Exception ex) {
            result.success(createResponse(false, ex.getMessage()));
        }
    }

    protected void setAttribute(String sdkKey, Map<String, Object> attributes, @NonNull Result result) {
        OptimizelyUserContext userContext = getUserContext(sdkKey);
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

    protected void removeNotificationListener(String sdkKey, Integer id, String type, @NonNull Result result) {
        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);
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

    protected void getOptimizelyConfig(String sdkKey, @NonNull Result result) {
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
        result.success(createResponse(true, SuccessMessage.OPTIMIZELY_CONFIG_FOUND));
    }

    public Map<String, ?> createResponse(Boolean success, Object result, String reason) {
        Map<String, Object> response = new HashMap<>();
        response.put(ResponseKey.SUCCESS, success);
        response.put(ResponseKey.RESULT"result", result);
        response.put(ResponseKey.REASON, reason);

        return response;
    }

    public Map<String, ?> createResponse(Boolean success, String reason) {
        return createResponse(success, null, reason);
    }

    public OptimizelyClient getOptimizelyClient(String SDKKey) {
        return optimizelyManagerTracker.get(SDKKey).getOptimizely();
    }

    public OptimizelyUserContext getUserContext(String SDKKey) {
        return userContextsTracker.get(SDKKey);
    }
}