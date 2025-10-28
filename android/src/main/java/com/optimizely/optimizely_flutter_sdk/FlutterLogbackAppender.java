package com.optimizely.optimizely_flutter_sdk;
import com.optimizely.optimizely_flutter_sdk.helper_classes.Constants;

import android.os.Handler;
import android.os.Looper;

import java.util.HashMap;
import java.util.Map;

import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.AppenderBase;
import io.flutter.plugin.common.MethodChannel;

public class FlutterLogbackAppender extends AppenderBase<ILoggingEvent> {

    public static final String CHANNEL_NAME = "optimizely_flutter_sdk_logger";
    public static MethodChannel channel;
    private static final Handler mainThreadHandler = new Handler(Looper.getMainLooper());

    public static void setChannel(MethodChannel channel) {
        FlutterLogbackAppender.channel = channel;
    }

    @Override
    protected void append(ILoggingEvent event) {
        if (channel == null) {
            return;
        }

        String message = event.getFormattedMessage();
        String level = event.getLevel().toString();
        // print level here
        System.out.println("loglevel: " + level);
        int logLevel = convertLogLevel(level);
        Map<String, Object> logData = new HashMap<>();
        logData.put("level", logLevel);
        logData.put("message", message);

        mainThreadHandler.post(() -> {
            if (channel != null) {
                channel.invokeMethod("log", logData);
            }
        });
    }

     int convertLogLevel(String logLevel) {
        int level = 3; // Default to INFO

        if (logLevel == null || logLevel.isEmpty()) {
            return level;
        }
        
        switch (logLevel.toLowerCase()) {
            case Constants.LogLevel.ERROR:
                level = 1;
                break;
            case Constants.LogLevel.WARNING:
                level = 2;
                break;
            case Constants.LogLevel.INFO:
                level = 3;
                break;
            case Constants.LogLevel.DEBUG:
                level = 4;
                break;
            default: {
            }
        }
        return level;
    }
}
