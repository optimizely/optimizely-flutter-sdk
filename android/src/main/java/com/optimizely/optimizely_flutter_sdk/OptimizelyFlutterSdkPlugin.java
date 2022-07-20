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

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;


import android.app.Activity;
import android.content.Context;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.base.CaseFormat;

import com.optimizely.ab.OptimizelyUserContext;
import com.optimizely.ab.android.sdk.OptimizelyClient;
import com.optimizely.ab.android.sdk.OptimizelyManager;
import com.optimizely.ab.event.LogEvent;
import com.optimizely.ab.notification.DecisionNotification;
import com.optimizely.ab.notification.TrackNotification;
import com.optimizely.ab.notification.UpdateConfigNotification;
import com.optimizely.ab.optimizelyconfig.OptimizelyConfig;
import com.optimizely.ab.optimizelydecision.OptimizelyDecideOption;
import com.optimizely.ab.optimizelydecision.OptimizelyDecision;
import static com.optimizely.optimizely_flutter_sdk.helper_classes.Constants.*;
import static com.optimizely.optimizely_flutter_sdk.helper_classes.Utils.convertKeysCamelCaseToSnakeCase;

import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;

/** OptimizelyFlutterSdkPlugin */
public class OptimizelyFlutterSdkPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler {
  private static MethodChannel channel;
  private Context context;
  private Activity activity;

  private static final Map<String, OptimizelyManager> optimizelyManagerTracker = new HashMap<>();
  private static final Map<String, OptimizelyUserContext> userContextsTracker = new HashMap<>();
    private static final Map<Integer, Integer> notificationIdsTracker = new HashMap<>();

  public Map<String, ?> createResponse(Boolean success, Object result, String reason) {
    Map<String, Object> response = new HashMap<>();
    response.put("success", success);
    response.put("result", result);
    response.put("reason", reason);

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

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Map<String, ?> arguments = call.arguments();
    String sdkKey = (String) arguments.get(RequestParameterKey.SDK_KEY);
    if (sdkKey == null) {
      result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
      return;
    }
    switch (call.method) {
      case APIs.INITIALIZE: {
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
        break;
      }
      case APIs.ADD_NOTIFICATION_LISTENER: {
        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);
        if (optimizelyClient == null) {
          result.success(createResponse(false, ErrorMessage.OPTIMIZELY_CLIENT_NOT_FOUND));
          return;
        }
        Integer id = (Integer) arguments.get(RequestParameterKey.NOTIFICATION_ID);
        String type = (String) arguments.get(RequestParameterKey.NOTIFICATION_TYPE);
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
            Map<String, Object> notificationMap = new HashMap<>();
            int notificationId = optimizelyClient.getNotificationCenter().addNotificationHandler(TrackNotification.class, trackNotification -> {
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
        break;
      }
      case APIs.REMOVE_NOTIFICATION_LISTENER: {
        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);
        if (optimizelyClient == null) {
          result.success(createResponse(false, ErrorMessage.OPTIMIZELY_CLIENT_NOT_FOUND));
          return;
        }
        Integer id = (Integer) arguments.get(RequestParameterKey.NOTIFICATION_ID);
        String type = (String) arguments.get(RequestParameterKey.NOTIFICATION_TYPE);
        if (id == null || type == null) {
          result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
          return;
        }
        optimizelyClient.getNotificationCenter().removeNotificationListener(id);
        notificationIdsTracker.remove(id);
        result.success(createResponse(true, SuccessMessage.LISTENER_REMOVED));
        break;
      }
      case APIs.GET_OPTIMIZELY_CONFIG: {
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
        break;
      }
      case APIs.CREATE_USER_CONTEXT: {
        OptimizelyClient optimizelyClient = getOptimizelyClient(sdkKey);
        if (optimizelyClient == null) {
          result.success(createResponse(false, ErrorMessage.OPTIMIZELY_CLIENT_NOT_FOUND));
          return;
        }
        String userId = (String) arguments.get(RequestParameterKey.USER_ID);
        if (userId == null) {
          result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
          return;
        }
        Map<String, Object> attributes = (Map<String, Object>) arguments.get(RequestParameterKey.ATTRIBUTES);
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
        } catch (Exception ex1) {
          result.success(createResponse(false, ex1.getMessage()));
        }
        break;
      }
      case APIs.SET_ATTRIBUTES: {
        OptimizelyUserContext userContext = getUserContext(sdkKey);
        if (userContext == null) {
          result.success(createResponse(false, ErrorMessage.USER_CONTEXT_NOT_FOUND));
          return;
        }
        Map<String, Object> attributes = (Map<String, Object>) arguments.get(RequestParameterKey.ATTRIBUTES);
        if (attributes == null) {
          result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
          return;
        }
        for (String attributeKey : attributes.keySet()) {
          userContext.setAttribute(attributeKey, attributes.get(attributeKey));
        }
        userContextsTracker.put(sdkKey, userContext);
        result.success(createResponse(true, userContext.getAttributes(), SuccessMessage.ATTRIBUTES_ADDED));
        break;
      }
      case APIs.TRACK_EVENT: {
        OptimizelyUserContext userContext = getUserContext(sdkKey);
        if (userContext == null) {
          result.success(createResponse(false, ErrorMessage.USER_CONTEXT_NOT_FOUND));
          return;
        }
        String eventKey = (String) arguments.get(RequestParameterKey.EVENT_KEY);
        if (eventKey == null) {
          result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
          return;
        }
        Map<String, Object> eventTags = (Map<String, Object>) arguments.get(RequestParameterKey.EVENT_TAGS);
        if (eventTags == null) {
          result.success(createResponse(false, ErrorMessage.INVALID_PARAMS));
          return;
        }
        try {
          userContext.trackEvent(eventKey, eventTags);
          result.success(createResponse(true, SuccessMessage.EVENT_TRACKED));
        } catch (Exception ex) {
          result.success(createResponse(false, ex.getMessage()));
        }
        break;
      }
      case APIs.DECIDE: {
        OptimizelyUserContext userContext = getUserContext(sdkKey);
        if (userContext == null) {
          result.success(createResponse(false, ErrorMessage.USER_CONTEXT_NOT_FOUND));
          return;
        }

        List<String> decideKeys = (List<String>) arguments.get(RequestParameterKey.DECIDE_KEYS);

        List<OptimizelyDecideOption> decideOptions = (List<OptimizelyDecideOption>) arguments.get(RequestParameterKey.DECIDE_OPTIONS);

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
        break;
      }
      default:
        result.notImplemented();
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

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    channel = new MethodChannel(binding.getBinaryMessenger(), "optimizely_flutter_sdk");
    channel.setMethodCallHandler(this);
    context = binding.getApplicationContext();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }
}
