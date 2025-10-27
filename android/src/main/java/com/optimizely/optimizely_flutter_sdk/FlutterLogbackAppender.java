package com.optimizely.optimizely_flutter_sdk;

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
        int level = event.getLevel().toInt();

        Map<String, Object> logData = new HashMap<>();
        logData.put("level", level);
        logData.put("message", message);

        mainThreadHandler.post(() -> {
            if (channel != null) {
                channel.invokeMethod("log", logData);
            }
        });
    }
}
