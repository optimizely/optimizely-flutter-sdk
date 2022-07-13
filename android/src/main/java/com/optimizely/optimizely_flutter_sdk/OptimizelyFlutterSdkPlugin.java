package com.optimizely.optimizely_flutter_sdk;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import static com.optimizely.ab.notification.DecisionNotification.FeatureVariableDecisionNotificationBuilder.SOURCE_INFO;

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
import com.optimizely.ab.optimizelyconfig.OptimizelyConfig;
import com.optimizely.ab.optimizelydecision.OptimizelyDecideOption;
import com.optimizely.ab.optimizelydecision.OptimizelyDecision;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;

/** OptimizelyFlutterSdkPlugin */
public class OptimizelyFlutterSdkPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler {
  private MethodChannel channel;
  private Context context;
  private Activity activity;

  private static final Map<String, OptimizelyManager> optimizelyManagerTracker = new HashMap<>();
  private static final Map<String, OptimizelyUserContext> userContextsTracker = new HashMap<>();
  private static final Map<String, NotificationListenerCall> notificationListenerCalls = new HashMap<>();

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
        //String datafile = "{\"groups\": [], \"environmentKey\": \"production\", \"rollouts\": [{\"experiments\": [{\"status\": \"Running\", \"audienceConditions\": [\"or\", \"20918242322\"], \"audienceIds\": [\"20918242322\"], \"variations\": [{\"variables\": [], \"id\": \"20606\", \"key\": \"on\", \"featureEnabled\": true}], \"forcedVariations\": {}, \"key\": \"flag1_targeted_delivery\", \"layerId\": \"9300000023916\", \"trafficAllocation\": [{\"entityId\": \"20606\", \"endOfRange\": 10000}], \"id\": \"9300000024086\"}, {\"status\": \"Running\", \"audienceConditions\": [], \"audienceIds\": [], \"variations\": [{\"variables\": [], \"id\": \"20605\", \"key\": \"off\", \"featureEnabled\": false}], \"forcedVariations\": {}, \"key\": \"default-rollout-7371-20896892800\", \"layerId\": \"default-layer-rollout-7371-20896892800\", \"trafficAllocation\": [{\"entityId\": \"20605\", \"endOfRange\": 10000}], \"id\": \"default-rollout-7371-20896892800\"}], \"id\": \"rollout-7371-20896892800\"}], \"typedAudiences\": [{\"id\": \"20912042036\", \"conditions\": [\"and\", [\"or\", [\"or\", {\"value\": 10, \"type\": \"custom_attribute\", \"name\": \"age\", \"match\": \"gt\"}]]], \"name\": \"audience_age\"}], \"projectId\": \"20904553815\", \"variables\": [], \"featureFlags\": [{\"experimentIds\": [\"9300000024085\"], \"rolloutId\": \"rollout-7371-20896892800\", \"variables\": [], \"id\": \"7371\", \"key\": \"flag1\"}], \"experiments\": [{\"status\": \"Running\", \"audienceConditions\": [\"or\", \"20912042036\"], \"audienceIds\": [\"20912042036\"], \"variations\": [{\"variables\": [], \"id\": \"20607\", \"key\": \"variation_a\", \"featureEnabled\": true}, {\"variables\": [], \"id\": \"20608\", \"key\": \"variation_b\", \"featureEnabled\": true}], \"forcedVariations\": {}, \"key\": \"flag1_experiment\", \"layerId\": \"9300000023915\", \"trafficAllocation\": [{\"entityId\": \"20607\", \"endOfRange\": 10000}], \"id\": \"9300000024085\"}], \"version\": \"4\", \"audiences\": [{\"id\": \"20918242322\", \"conditions\": \"[\\\"and\\\", [\\\"or\\\", [\\\"or\\\", {\\\"match\\\": \\\"exact\\\", \\\"name\\\": \\\"country\\\", \\\"type\\\": \\\"custom_attribute\\\", \\\"value\\\": \\\"US\\\"}]]]\", \"name\": \"audience_country\"}, {\"id\": \"20912042036\", \"conditions\": \"[\\\"or\\\", {\\\"match\\\": \\\"exact\\\", \\\"name\\\": \\\"$opt_dummy_attribute\\\", \\\"type\\\": \\\"custom_attribute\\\", \\\"value\\\": \\\"$opt_dummy_value\\\"}]\", \"name\": \"audience_age\"}, {\"conditions\": \"[\\\"or\\\", {\\\"match\\\": \\\"exact\\\", \\\"name\\\": \\\"$opt_dummy_attribute\\\", \\\"type\\\": \\\"custom_attribute\\\", \\\"value\\\": \\\"$opt_dummy_value\\\"}]\", \"id\": \"$opt_dummy_audience\", \"name\": \"Optimizely-Generated Audience for Backwards Compatibility\"}], \"anonymizeIP\": true, \"sdkKey\": \"X9mZd2WDywaUL9hZXyh9A\", \"attributes\": [{\"id\": \"20923112430\", \"key\": \"age\"}, {\"id\": \"20925262364\", \"key\": \"country\"}], \"botFiltering\": false, \"accountId\": \"12133785640\", \"events\": [{\"experimentIds\": [\"9300000024085\"], \"id\": \"20903632979\", \"key\": \"myevent\"}], \"revision\": \"23\"}";

        // Delete old user context
        userContextsTracker.remove(sdkKey);
        //String datafile = (String) arguments.get("datafile");
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
              notificationMap.put("type", decisionNotification.getType());
              notificationMap.put("user_id", decisionNotification.getUserId());
              notificationMap.put("attributes", decisionNotification.getAttributes());
              notificationMap.put("decision_info", convertKeysCamelCaseToSnakeCase(decisionNotification.getDecisionInfo()));
              //TODO fix this
              //AndroidSDKFlutterPlugin.channel.invokeMethod("callbackListener", Collections.unmodifiableMap(): [RequestParameterKey.notificationId: id, RequestParameterKey.notificationType: NotificationType.decision, RequestParameterKey.notificationPayload: listenerDict])
            });

            result.success(createResponse(true, SuccessMessage.LISTENER_ADDED));
            break;
          }
          case NotificationType.TRACK: {
            int notificationId = optimizelyClient.getNotificationCenter().addNotificationHandler(TrackNotification.class, trackNotification -> {
              Map<String, Object> notificationMap = new HashMap<>();
              notificationMap.put("event_key", trackNotification.getEventKey());
              notificationMap.put("user_id", trackNotification.getUserId());
              notificationMap.put("attributes", trackNotification.getAttributes());
              notificationMap.put("event_tags", trackNotification.getEventTags());
            });
            result.success(createResponse(true, SuccessMessage.LISTENER_ADDED));
            break;
          }
          case NotificationType.LOG_EVENT: {
            int notificationIdLog = optimizelyClient.getNotificationCenter().addNotificationHandler(LogEvent.class, logEvent -> {
              ObjectMapper mapper = new ObjectMapper();
              Map<String, Object> eventParams = mapper.readValue(logEvent.getBody(), Map.class);
              Map<String, Object> listenerMap = new HashMap<>();
              listenerMap.put("url", logEvent.getEndpointUrl());
              listenerMap.put("http_verb", logEvent.getRequestMethod());
              listenerMap.put("params", eventParams);

            });
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

        Map<String, OptimizelyDecision> optimizelyDecisionsMap = new HashMap<>();

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

  //TODO: Move these util functions to util class
  public String getSDKKey(Map<String, ?> arguments) {
    return (String) arguments.get(RequestParameterKey.SDK_KEY);
  }
  public void addNotificationListenerCall(String id, NotificationListenerCall notificationListenerCall) {
    notificationListenerCalls.put(id, notificationListenerCall);
  }

  private static Map<String, ?> convertKeysCamelCaseToSnakeCase(Map<String, ?> decisionInfo) {
    Map<String, Object> decisionInfoCopy = new HashMap<>(decisionInfo);

    if (decisionInfo.containsKey(SOURCE_INFO) && decisionInfo.get(SOURCE_INFO) instanceof Map) {
      Map<String, String> sourceInfo = (Map<String, String>) decisionInfoCopy.get(SOURCE_INFO);
      Map<String, String> sourceInfoCopy = new HashMap<>(sourceInfo);

      for (String key : sourceInfo.keySet()) {
        sourceInfoCopy.put(CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, key), sourceInfoCopy.remove(key));
      }
      decisionInfoCopy.remove(SOURCE_INFO);
      decisionInfoCopy.put(SOURCE_INFO, sourceInfoCopy);
    }

    for (String key : decisionInfo.keySet()) {
      decisionInfoCopy.put(CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, key), decisionInfoCopy.remove(key));
    }
    return decisionInfoCopy;
  }

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
}
