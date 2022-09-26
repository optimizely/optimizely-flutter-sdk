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

import com.optimizely.optimizely_flutter_sdk.helper_classes.ArgumentsParser;

import static com.optimizely.optimizely_flutter_sdk.helper_classes.Constants.*;

import java.util.Map;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;

/** OptimizelyFlutterSdkPlugin */
public class OptimizelyFlutterSdkPlugin extends OptimizelyFlutterClient implements FlutterPlugin, ActivityAware, MethodCallHandler {

  public static MethodChannel channel;

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Map<String, ?> arguments = call.arguments();
    ArgumentsParser argumentsParser = new ArgumentsParser(arguments);
    switch (call.method) {
      case APIs.INITIALIZE: {
        initializeOptimizely(argumentsParser, result);
        break;
      }
      case APIs.ACTIVATE: {
        activate(argumentsParser, result);
        break;
      }
      case APIs.GET_VARIATION: {
        getVariation(argumentsParser, result);
        break;
      }
      case APIs.GET_FORCED_VARIATION: {
        getForcedVariation(argumentsParser, result);
        break;
      }
      case APIs.SET_FORCED_VARIATION: {
        setForcedVariation(argumentsParser, result);
        break;
      }
      case APIs.ADD_NOTIFICATION_LISTENER: {
        addNotificationListener(argumentsParser, result);
        break;
      }
      case APIs.REMOVE_NOTIFICATION_LISTENER: {
        removeNotificationListener(argumentsParser, result);
        break;
      }
      case APIs.GET_OPTIMIZELY_CONFIG: {
        getOptimizelyConfig(argumentsParser, result);
        break;
      }
      case APIs.CREATE_USER_CONTEXT: {
        createUserContext(argumentsParser, result);
        break;
      }
      case APIs.GET_USER_ID: {
        getUserId(argumentsParser, result);
        break;
      }
      case APIs.GET_ATTRIBUTES: {
        getAttributes(argumentsParser, result);
        break;
      }
      case APIs.SET_ATTRIBUTES: {
        setAttribute(argumentsParser, result);
        break;
      }
      case APIs.TRACK_EVENT: {
        trackEvent(argumentsParser, result);
        break;
      }
      case APIs.DECIDE: {
        decide(argumentsParser, result);
        break;
      }
      case APIs.SET_FORCED_DECISION: {
        setForcedDecision(argumentsParser, result);
        break;
      }
      case APIs.GET_FORCED_DECISION: {
        getForcedDecision(argumentsParser, result);
        break;
      }
      case APIs.REMOVE_FORCED_DECISION: {
        removeForcedDecision(argumentsParser, result);
        break;
      }
      case APIs.REMOVE_ALL_FORCED_DECISIONS: {
        removeAllForcedDecisions(argumentsParser, result);
        break;
      }
      case APIs.CLOSE: {
        close(argumentsParser, result);
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
}
