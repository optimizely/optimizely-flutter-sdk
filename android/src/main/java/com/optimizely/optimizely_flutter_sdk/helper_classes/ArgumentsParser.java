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
package com.optimizely.optimizely_flutter_sdk.helper_classes;

import com.optimizely.ab.odp.ODPSegmentOption;
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
    
    public String getSdkVersion() {
        return (String) arguments.get(Constants.RequestParameterKey.SDK_VERSION);
    }

    public Integer getNotificationID() {
        return (Integer) arguments.get(Constants.RequestParameterKey.NOTIFICATION_ID);
    }

    public String getNotificationType() {
        return (String) arguments.get(Constants.RequestParameterKey.NOTIFICATION_TYPE);
    }

    public List<Integer> getCallBackIds() {
        return (List<Integer>) arguments.get(Constants.RequestParameterKey.CALLBACK_IDS);
    }

    public String getUserId() {
        return (String) arguments.get(Constants.RequestParameterKey.USER_ID);
    }

    public String getUserContextId() {
        return (String) arguments.get(Constants.RequestParameterKey.USER_CONTEXT_ID);
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

    public String getDefaultLogLevel() {
        return (String) arguments.get(Constants.RequestParameterKey.DEFAULT_LOG_LEVEL);
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

    public Integer getEventTimeInterval() {
        return (Integer) arguments.get(Constants.RequestParameterKey.EVENT_TIME_INTERVAL);
    }

    public Integer getEventMaxQueueSize() {
        return (Integer) arguments.get(Constants.RequestParameterKey.EVENT_MAX_QUEUE_SIZE);
    }

    public Integer getDatafilePeriodicDownloadInterval() {
        return (Integer) arguments.get(Constants.RequestParameterKey.DATAFILE_PERIODIC_DOWNLOAD_INTERVAL);
    }

    public String getDatafileHostSuffix() {
        return (String) arguments.get(Constants.RequestParameterKey.DATAFILE_HOST_SUFFIX);
    }

    public String getDatafileHostPrefix() {
        return (String) arguments.get(Constants.RequestParameterKey.DATAFILE_HOST_PREFIX);
    }

    public String getExperimentKey() {
        return (String) arguments.get(Constants.RequestParameterKey.EXPERIMENT_KEY);
    }

    public List<String> getQualifiedSegments() {
        return (List<String>) arguments.get(Constants.RequestParameterKey.QUALIFIED_SEGMENTS);
    }

    public String getSegment() {
        return (String) arguments.get(Constants.RequestParameterKey.SEGMENT);
    }

    public String getAction() {
        return (String) arguments.get(Constants.RequestParameterKey.ACTION);
    }

    public String getType() {
        return (String) arguments.get(Constants.RequestParameterKey.ODP_EVENT_TYPE);
    }

    public Map<String, String> getIdentifiers() {
        return (Map<String, String>) arguments.get(Constants.RequestParameterKey.IDENTIFIERS);
    }

    public Map<String, Object> getData() {
        return (Map<String, Object>) arguments.get(Constants.RequestParameterKey.DATA);
    }

    public List<ODPSegmentOption> getSegmentOptions() {
        return Utils.getSegmentOptions((List<String>) arguments.get(Constants.RequestParameterKey.OPTIMIZELY_SEGMENT_OPTION));
    }

    public Map<String, Object> getOptimizelySdkSettings() {
        return (Map<String, Object>) arguments.get(Constants.RequestParameterKey.OPTIMIZELY_SDK_SETTINGS);
    }
}
