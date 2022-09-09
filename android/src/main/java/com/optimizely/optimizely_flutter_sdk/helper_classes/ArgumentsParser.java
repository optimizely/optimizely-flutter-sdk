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
package com.optimizely.optimizely_flutter_sdk.helper_classes;

import com.optimizely.ab.optimizelydecision.OptimizelyDecideOption;

import java.util.List;
import java.util.Map;

public class ArgumentsParser {
    private final Map<String, ?> arguments;

    public ArgumentsParser(Map<String, ?> arguments) {
        this.arguments = arguments;
    }

    public String getSdkKey() {
        return (String) arguments.get(Constants.RequestParameterKey.SDK_KEY);
    }

    public Integer getNotificaitonID() {
        return (Integer) arguments.get(Constants.RequestParameterKey.NOTIFICATION_ID);
    }

    public String getNotificationType() {
        return (String) arguments.get(Constants.RequestParameterKey.NOTIFICATION_TYPE);
    }

    public String getUserID() {
        return (String) arguments.get(Constants.RequestParameterKey.USER_ID);
    }

    public Map<String, Object> getAttributes() {
        return (Map<String, Object>) arguments.get(Constants.RequestParameterKey.ATTRIBUTES);
    }

    public String getEventKey() {
        return (String) arguments.get(Constants.RequestParameterKey.EVENT_KEY);
    }

    public Map<String, Object> getEventTags() {
        return (Map<String, Object>) arguments.get(Constants.RequestParameterKey.EVENT_TAGS);
    }

    public List<String> getDecideKeys() {
        return (List<String>) arguments.get(Constants.RequestParameterKey.DECIDE_KEYS);
    }

    public List<OptimizelyDecideOption> getDecideOptions() {
        return Utils.getDecideOptions((List<String>) arguments.get(Constants.RequestParameterKey.DECIDE_OPTIONS));
    }

    public String getFlagKey() {
        return (String) arguments.get(Constants.RequestParameterKey.FLAG_KEY);
    }

    public String getRuleKey() {
        return (String) arguments.get(Constants.RequestParameterKey.RULE_KEY);
    }

    public String getVariationKey() {
        return (String) arguments.get(Constants.RequestParameterKey.VARIATION_KEY);
    }

    public Integer getEventBatchSize() {
        return (Integer) arguments.get(Constants.RequestParameterKey.EVENT_BATCH_SIZE);
    }

    public Long getEventTimeInterval() {
        return (Long) arguments.get(Constants.RequestParameterKey.EVENT_TIME_INTERVAL);
    }

    public Integer getEventMaxQueueSize() {
        return (Integer) arguments.get(Constants.RequestParameterKey.EVENT_MAX_QUEUE_SIZE);
    }

    public Long getDatafilePeriodicDownloadInterval() {
        return (Long) arguments.get(Constants.RequestParameterKey.DATAFILE_PERIODIC_DOWNLOAD_INTERVAL);
    }
}
