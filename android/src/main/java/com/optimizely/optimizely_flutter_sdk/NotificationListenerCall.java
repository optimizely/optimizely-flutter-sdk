package com.optimizely.optimizely_flutter_sdk;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.Map;

public class NotificationListenerCall {
    @JsonProperty("notification_type")
    public String notificationType;
    @JsonProperty("payload")
    public Map<String, Object> payload;

    public NotificationListenerCall(String notificationType, Map<String, Object> payload) {
        this.notificationType = notificationType;
        this.payload = payload;
    }
}