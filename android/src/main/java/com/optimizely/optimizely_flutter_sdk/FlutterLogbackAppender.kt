package com.optimizely.optimizely_flutter_sdk

import ch.qos.logback.classic.Level
import ch.qos.logback.classic.spi.ILoggingEvent
import ch.qos.logback.core.AppenderBase
import io.flutter.plugin.common.MethodChannel
import android.os.Handler
import android.os.Looper

class FlutterLogbackAppender : AppenderBase<ILoggingEvent>() {

    companion object {
        @JvmField
        val CHANNEL_NAME = "optimizely_flutter_sdk/logs"

        @JvmStatic
        var channel: MethodChannel? = null

        private val mainThreadHandler = Handler(Looper.getMainLooper())
    }

    override fun append(event: ILoggingEvent) {
        if (channel == null) {
            return
        }

        val message = event.formattedMessage
        val level = event.level.toInt()

        val logData = mapOf(
            "level" to level,
            "message" to message
        )

        mainThreadHandler.post {
            channel?.invokeMethod("log", logData)
        }
    }
}

