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

import android.os.Handler;
import android.os.Looper;

import java.util.Map;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;

import org.slf4j.LoggerFactory;

import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.LoggerContext;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.Appender;


/** OptimizelyFlutterSdkPlugin */
public class OptimizelyFlutterSdkPlugin extends OptimizelyFlutterClient implements FlutterPlugin, ActivityAware, MethodCallHandler {

  public static MethodChannel channel;
  private Appender<ILoggingEvent> flutterLogbackAppender;

  /**
   * Wraps a {@link Result} so that all callbacks ({@code success}, {@code error},
   * {@code notImplemented}) are guaranteed to run on the Android main thread.
   *
   * <p>Flutter's {@code MethodChannel.Result} must be called from the main thread.
   * Native SDK callbacks (e.g. {@code decideAsync}, {@code initialize}) may fire on
   * background threads. Wrapping {@code result} here once in {@code onMethodCall}
   * protects every handler automatically — current and future.
   */
  private Result safeResult(@NonNull Result result) {
    Handler mainHandler = new Handler(Looper.getMainLooper());
    return new Result() {
      @Override
      public void success(Object o) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
          result.success(o);
        } else {
          mainHandler.post(() -> result.success(o));
        }
      }

      @Override
      public void error(@NonNull String code, String message, Object details) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
          result.error(code, message, details);
        } else {
          mainHandler.post(() -> result.error(code, message, details));
        }
      }

      @Override
      public void notImplemented() {
        if (Looper.myLooper() == Looper.getMainLooper()) {
          result.notImplemented();
        } else {
          mainHandler.post(result::notImplemented);
        }
      }
    };
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Result safeResult = safeResult(result);
    Map<String, ?> arguments = call.arguments();
    ArgumentsParser argumentsParser = new ArgumentsParser(arguments);
    switch (call.method) {
      case APIs.INITIALIZE: {
        initializeOptimizely(argumentsParser, safeResult);
        break;
      }
      case APIs.ACTIVATE: {
        activate(argumentsParser, safeResult);
        break;
      }
      case APIs.GET_VARIATION: {
        getVariation(argumentsParser, safeResult);
        break;
      }
      case APIs.GET_FORCED_VARIATION: {
        getForcedVariation(argumentsParser, safeResult);
        break;
      }
      case APIs.SET_FORCED_VARIATION: {
        setForcedVariation(argumentsParser, safeResult);
        break;
      }
      case APIs.ADD_NOTIFICATION_LISTENER: {
        addNotificationListener(argumentsParser, safeResult);
        break;
      }
      case APIs.REMOVE_NOTIFICATION_LISTENER: {
        removeNotificationListener(argumentsParser, safeResult);
        break;
      }
      case APIs.CLEAR_NOTIFICATION_LISTENERS:
      case APIs.CLEAR_ALL_NOTIFICATION_LISTENERS: {
        clearAllNotificationListeners(argumentsParser, safeResult);
        break;
      }
      case APIs.GET_OPTIMIZELY_CONFIG: {
        getOptimizelyConfig(argumentsParser, safeResult);
        break;
      }
      case APIs.CREATE_USER_CONTEXT: {
        createUserContext(argumentsParser, safeResult);
        break;
      }
      case APIs.GET_USER_ID: {
        getUserId(argumentsParser, safeResult);
        break;
      }
      case APIs.GET_ATTRIBUTES: {
        getAttributes(argumentsParser, safeResult);
        break;
      }
      case APIs.SET_ATTRIBUTES: {
        setAttribute(argumentsParser, safeResult);
        break;
      }
      case APIs.TRACK_EVENT: {
        trackEvent(argumentsParser, safeResult);
        break;
      }
      case APIs.DECIDE: {
        decide(argumentsParser, safeResult);
        break;
      }
      case APIs.DECIDE_ASYNC: {
        decideAsync(argumentsParser, safeResult);
        break;
      }
      case APIs.SET_FORCED_DECISION: {
        setForcedDecision(argumentsParser, safeResult);
        break;
      }
      case APIs.GET_FORCED_DECISION: {
        getForcedDecision(argumentsParser, safeResult);
        break;
      }
      case APIs.REMOVE_FORCED_DECISION: {
        removeForcedDecision(argumentsParser, safeResult);
        break;
      }
      case APIs.REMOVE_ALL_FORCED_DECISIONS: {
        removeAllForcedDecisions(argumentsParser, safeResult);
        break;
      }
      case APIs.GET_QUALIFIED_SEGMENTS: {
        getQualifiedSegments(argumentsParser, safeResult);
        break;
      }
      case APIs.SET_QUALIFIED_SEGMENTS: {
        setQualifiedSegments(argumentsParser, safeResult);
        break;
      }
      case APIs.GET_VUID: {
        getVuid(argumentsParser, safeResult);
        break;
      }
      case APIs.IS_QUALIFIED_FOR: {
        isQualifiedFor(argumentsParser, safeResult);
        break;
      }
      case APIs.SEND_ODP_EVENT: {
        sendODPEvent(argumentsParser, safeResult);
        break;
      }
      case APIs.FETCH_QUALIFIED_SEGMENTS: {
        fetchQualifiedSegments(argumentsParser, safeResult);
        break;
      }
      case APIs.CLOSE: {
        close(argumentsParser, safeResult);
        break;
      }
      default:
        safeResult.notImplemented();
    }
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    if (channel != null) {
      return;
    }
    channel = new MethodChannel(binding.getBinaryMessenger(), "optimizely_flutter_sdk");
    channel.setMethodCallHandler(this);
    context = binding.getApplicationContext();

    MethodChannel loggerChannel = new MethodChannel(binding.getBinaryMessenger(), FlutterLogbackAppender.CHANNEL_NAME);
    FlutterLogbackAppender.setChannel(loggerChannel);

    // Add appender to logback
    flutterLogbackAppender = new FlutterLogbackAppender();
    LoggerContext lc = (LoggerContext) LoggerFactory.getILoggerFactory();
    flutterLogbackAppender.setContext(lc);
    flutterLogbackAppender.start();
    Logger rootLogger = (Logger) LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME);
    rootLogger.setLevel(ch.qos.logback.classic.Level.ALL);
    rootLogger.addAppender(flutterLogbackAppender);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;
    // Stop and detach the appender
    if (flutterLogbackAppender != null) {
        Logger rootLogger = (Logger) LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME);
        rootLogger.detachAppender(flutterLogbackAppender);
        flutterLogbackAppender.stop();
        flutterLogbackAppender = null;
    }
    // Clean up the logger channel
    FlutterLogbackAppender.clearChannel();
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
