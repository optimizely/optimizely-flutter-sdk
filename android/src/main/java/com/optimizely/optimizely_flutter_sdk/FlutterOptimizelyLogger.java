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

import android.os.Handler;
import android.os.Looper;
import io.flutter.plugin.common.MethodChannel;
import org.slf4j.Logger;
import org.slf4j.Marker;
import java.util.HashMap;
import java.util.Map;

public class FlutterOptimizelyLogger implements Logger { 
    static final String LOGGER_CHANNEL = "optimizely_flutter_sdk_logger";
    private static MethodChannel loggerChannel;
    private final String tag;

    public FlutterOptimizelyLogger(String name) {
        tag = name;
    }

    public static void setChannel(MethodChannel channel) {
        loggerChannel = channel;
    }

    @Override
    public String getName() {
        return "OptimizelyLogger";
    }

    // Trace methods
    @Override
    public boolean isTraceEnabled() {
        return false;
    }

    @Override
    public void trace(String msg) {
        // Not implemented
    }

    @Override
    public void trace(String format, Object arg) {
        // Not implemented
    }

    @Override
    public void trace(String format, Object arg1, Object arg2) {
        // Not implemented
    }

    @Override
    public void trace(String format, Object... arguments) {
        // Not implemented
    }

    @Override
    public void trace(String msg, Throwable t) {
        // Not implemented
    }

    @Override
    public boolean isTraceEnabled(Marker marker) {
        return false;
    }

    @Override
    public void trace(Marker marker, String msg) {
        // Not implemented
    }

    @Override
    public void trace(Marker marker, String format, Object arg) {
        // Not implemented
    }

    @Override
    public void trace(Marker marker, String format, Object arg1, Object arg2) {
        // Not implemented
    }

    @Override
    public void trace(Marker marker, String format, Object... argArray) {
        // Not implemented
    }

    @Override
    public void trace(Marker marker, String msg, Throwable t) {
        // Not implemented
    }

    // Debug methods
    @Override
    public boolean isDebugEnabled() {
        return true;
    }

    @Override
    public void debug(String msg) {
        sendLogToFlutter(4, msg);
    }

    @Override
    public void debug(String format, Object arg) {
        debug(formatMessage(format, arg));
    }

    @Override
    public void debug(String format, Object arg1, Object arg2) {
        debug(formatMessage(format, arg1, arg2));
    }

    @Override
    public void debug(String format, Object... arguments) {
        debug(formatMessage(format, arguments));
    }

    @Override
    public void debug(String msg, Throwable t) {
        debug(formatThrowable(msg, t));
    }

    @Override
    public boolean isDebugEnabled(Marker marker) {
        return true;
    }

    @Override
    public void debug(Marker marker, String msg) {
        debug(msg);
    }

    @Override
    public void debug(Marker marker, String format, Object arg) {
        debug(format, arg);
    }

    @Override
    public void debug(Marker marker, String format, Object arg1, Object arg2) {
        debug(format, arg1, arg2);
    }

    @Override
    public void debug(Marker marker, String format, Object... arguments) {
        debug(format, arguments);
    }

    @Override
    public void debug(Marker marker, String msg, Throwable t) {
        debug(msg, t);
    }

    // Info methods
    @Override
    public boolean isInfoEnabled() {
        return true;
    }

    @Override
    public void info(String msg) {
        sendLogToFlutter(3, msg);
    }

    @Override
    public void info(String format, Object arg) {
        info(formatMessage(format, arg));
    }

    @Override
    public void info(String format, Object arg1, Object arg2) {
        info(formatMessage(format, arg1, arg2));
    }

    @Override
    public void info(String format, Object... arguments) {
        info(formatMessage(format, arguments));
    }

    @Override
    public void info(String msg, Throwable t) {
        info(formatThrowable(msg, t));
    }

    @Override
    public boolean isInfoEnabled(Marker marker) {
        return true;
    }

    @Override
    public void info(Marker marker, String msg) {
        info(msg);
    }

    @Override
    public void info(Marker marker, String format, Object arg) {
        info(format, arg);
    }

    @Override
    public void info(Marker marker, String format, Object arg1, Object arg2) {
        info(format, arg1, arg2);
    }

    @Override
    public void info(Marker marker, String format, Object... arguments) {
        info(format, arguments);
    }

    @Override
    public void info(Marker marker, String msg, Throwable t) {
        info(msg, t);
    }

    // Warn methods
    @Override
    public boolean isWarnEnabled() {
        return true;
    }

    @Override
    public void warn(String msg) {
        sendLogToFlutter(2, msg);
    }

    @Override
    public void warn(String format, Object arg) {
        warn(formatMessage(format, arg));
    }

    @Override
    public void warn(String format, Object... arguments) {
        warn(formatMessage(format, arguments));
    }

    @Override
    public void warn(String format, Object arg1, Object arg2) {
        warn(formatMessage(format, arg1, arg2));
    }

    @Override
    public void warn(String msg, Throwable t) {
        warn(formatThrowable(msg, t));
    }

    @Override
    public boolean isWarnEnabled(Marker marker) {
        return true;
    }

    @Override
    public void warn(Marker marker, String msg) {
        warn(msg);
    }

    @Override
    public void warn(Marker marker, String format, Object arg) {
        warn(format, arg);
    }

    @Override
    public void warn(Marker marker, String format, Object arg1, Object arg2) {
        warn(format, arg1, arg2);
    }

    @Override
    public void warn(Marker marker, String format, Object... arguments) {
        warn(format, arguments);
    }

    @Override
    public void warn(Marker marker, String msg, Throwable t) {
        warn(msg, t);
    }

    // Error methods
    @Override
    public boolean isErrorEnabled() {
        return true;
    }

    @Override
    public void error(String msg) {
        sendLogToFlutter(1, msg); // ERROR level = 1
    }

    @Override
    public void error(String format, Object arg) {
        error(formatMessage(format, arg));
    }

    @Override
    public void error(String format, Object arg1, Object arg2) {
        error(formatMessage(format, arg1, arg2));
    }

    @Override
    public void error(String format, Object... arguments) {
        error(formatMessage(format, arguments));
    }

    @Override
    public void error(String msg, Throwable t) {
        error(formatThrowable(msg, t));
    }

    @Override
    public boolean isErrorEnabled(Marker marker) {
        return true;
    }

    @Override
    public void error(Marker marker, String msg) {
        error(msg);
    }

    @Override
    public void error(Marker marker, String format, Object arg) {
        error(format, arg);
    }

    @Override
    public void error(Marker marker, String format, Object arg1, Object arg2) {
        error(format, arg1, arg2);
    }

    @Override
    public void error(Marker marker, String format, Object... arguments) {
        error(format, arguments);
    }

    @Override
    public void error(Marker marker, String msg, Throwable t) {
        error(msg, t);
    }

    // Helper methods
    private void sendLogToFlutter(int level, String message) {
        if (loggerChannel == null) {
            return;
        }

        // Ensure we're on the main thread when calling Flutter (similar to Swift's DispatchQueue.main.async)
        Handler mainHandler = new Handler(Looper.getMainLooper());
        mainHandler.post(() -> {
            Map<String, Object> arguments = new HashMap<>();
            arguments.put("level", level);
            arguments.put("message", message);
            loggerChannel.invokeMethod("log", arguments);
        });
    }

    private String formatMessage(String format, Object... args) {
        try {
            // SLF4J uses {} placeholders, replace with %s for String.format
            String formatString = format.replace("{}", "%s");
            return String.format(formatString, args);
        } catch (Exception e) {
            return format;
        }
    }

    private String formatThrowable(String msg, Throwable t) {
        return msg + " - " + t.getMessage();
    }
}