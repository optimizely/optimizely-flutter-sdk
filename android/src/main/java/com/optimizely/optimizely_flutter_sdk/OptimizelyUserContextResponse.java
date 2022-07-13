package com.optimizely.optimizely_flutter_sdk;

import com.optimizely.ab.OptimizelyUserContext;

import java.util.Map;

public class OptimizelyUserContextResponse {
    private final String userId;

    private final Map<String, Object> attributes;

    public OptimizelyUserContextResponse(OptimizelyUserContext optimizelyUserContext) {
        this.userId = optimizelyUserContext.getUserId();
        this.attributes = optimizelyUserContext.getAttributes();
    }

    public String getUserId() {
        return userId;
    }

    public Map<String, Object> getAttributes() {
        return attributes;
    }
}
