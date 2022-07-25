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

import com.fasterxml.jackson.databind.ObjectMapper;

import com.optimizely.ab.android.sdk.OptimizelyClient;
import com.optimizely.ab.event.LogEvent;
import com.optimizely.ab.notification.DecisionNotification;
import com.optimizely.ab.notification.TrackNotification;
import com.optimizely.ab.notification.UpdateConfigNotification;
import com.optimizely.ab.optimizelydecision.OptimizelyDecideOption;
import static com.optimizely.optimizely_flutter_sdk.helper_classes.Constants.*;
import static com.optimizely.optimizely_flutter_sdk.helper_classes.Utils.convertKeysCamelCaseToSnakeCase;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;

/** OptimizelyFlutterSdkPlugin */
public class OptimizelyFlutterSdkPlugin extends OptimizelyFlutterClient implements FlutterPlugin, ActivityAware, MethodCallHandler {

  private static MethodChannel channel;

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
        initializeOptimizely(sdkKey, result);
        break;
      }
      case APIs.ADD_NOTIFICATION_LISTENER: {
        Integer id = (Integer) arguments.get(RequestParameterKey.NOTIFICATION_ID);
        String type = (String) arguments.get(RequestParameterKey.NOTIFICATION_TYPE);

        addNotificationListener(sdkKey, id, type, result);
        break;
      }
      case APIs.REMOVE_NOTIFICATION_LISTENER: {
        Integer id = (Integer) arguments.get(RequestParameterKey.NOTIFICATION_ID);
        String type = (String) arguments.get(RequestParameterKey.NOTIFICATION_TYPE);

        removeNotificationListener(sdkKey, id, type, result);
        break;
      }
      case APIs.GET_OPTIMIZELY_CONFIG: {
        getOptimizelyConfig(sdkKey, result);
        break;
      }
      case APIs.CREATE_USER_CONTEXT: {
        String userId = (String) arguments.get(RequestParameterKey.USER_ID);
        Map<String, Object> attributes = (Map<String, Object>) arguments.get(RequestParameterKey.ATTRIBUTES);

        createUserContext(sdkKey, userId, attributes, result);
        break;
      }
      case APIs.SET_ATTRIBUTES: {
        Map<String, Object> attributes = (Map<String, Object>) arguments.get(RequestParameterKey.ATTRIBUTES);

        setAttribute(sdkKey, attributes, result);
        break;
      }
      case APIs.TRACK_EVENT: {
        String eventKey = (String) arguments.get(RequestParameterKey.EVENT_KEY);
        Map<String, Object> eventTags = (Map<String, Object>) arguments.get(RequestParameterKey.EVENT_TAGS);

        trackEvent(sdkKey, eventKey, eventTags, result);
        break;
      }
      case APIs.DECIDE: {
        List<String> decideKeys = (List<String>) arguments.get(RequestParameterKey.DECIDE_KEYS);
        List<OptimizelyDecideOption> decideOptions = (List<OptimizelyDecideOption>) arguments.get(RequestParameterKey.DECIDE_OPTIONS);

        decide(sdkKey, decideKeys, decideOptions, result);
        break;
      }
      default:
        result.notImplemented();
    }
  }

  protected void addNotificationListener(String sdkKey, Integer id, String type, @NonNull Result result) {
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
