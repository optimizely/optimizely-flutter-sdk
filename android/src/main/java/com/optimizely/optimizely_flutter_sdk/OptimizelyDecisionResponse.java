package com.optimizely.optimizely_flutter_sdk;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.optimizely.ab.optimizelydecision.OptimizelyDecision;

import java.util.List;
import java.util.Map;

public class OptimizelyDecisionResponse {
    @JsonProperty("variation_key")
    private final String variationKey;

    private final boolean enabled;

    private final Map variables;

    private final String ruleKey;

    private final String flagKey;

    private final OptimizelyUserContextResponse userContext;

    private List<String> reasons;

    public OptimizelyDecisionResponse(OptimizelyDecision optimizelyDecision) {
        this.variationKey = optimizelyDecision.getVariationKey();
        this.enabled = optimizelyDecision.getEnabled();
        this.variables = optimizelyDecision.getVariables().toMap();
        this.ruleKey = optimizelyDecision.getRuleKey();
        this.flagKey = optimizelyDecision.getFlagKey();
        this.userContext = new OptimizelyUserContextResponse(optimizelyDecision.getUserContext());
        this.reasons = optimizelyDecision.getReasons();
    }

    public String getVariationKey() {
        return variationKey;
    }

    public boolean getEnabled() {
        return enabled;
    }

    public Map getVariables() {
        return variables;
    }

    public String getRuleKey() {
        return ruleKey;
    }

    public String getFlagKey() {
        return flagKey;
    }

    public OptimizelyUserContextResponse getUserContext() {
        return userContext;
    }

    public List<String> getReasons() {
        return reasons;
    }
}
