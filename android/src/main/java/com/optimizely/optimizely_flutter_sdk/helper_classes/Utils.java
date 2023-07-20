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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static com.optimizely.ab.notification.DecisionNotification.FeatureVariableDecisionNotificationBuilder.SOURCE_INFO;

import com.google.common.base.CaseFormat;
import com.optimizely.ab.event.LogEvent;
import com.optimizely.ab.notification.ActivateNotification;
import com.optimizely.ab.notification.DecisionNotification;
import com.optimizely.ab.notification.TrackNotification;
import com.optimizely.ab.notification.UpdateConfigNotification;
import com.optimizely.ab.odp.ODPSegmentOption;
import com.optimizely.ab.optimizelydecision.OptimizelyDecideOption;

public class Utils {

    public static String getRandomUUID() {
        return UUID.randomUUID().toString();
    }

    public static List<OptimizelyDecideOption> getDecideOptions(List<String> options) {
        if(options == null || options.isEmpty()) {
            return null;
        }
        List<OptimizelyDecideOption> convertedOptions = new ArrayList<>();
        for(String option: options) {
            switch(option) {
                case Constants.DecideOption.DISABLE_DECISION_EVENT:
                    convertedOptions.add(OptimizelyDecideOption.DISABLE_DECISION_EVENT);
                    break;
                case Constants.DecideOption.ENABLED_FLAGS_ONLY:
                    convertedOptions.add(OptimizelyDecideOption.ENABLED_FLAGS_ONLY);
                    break;
                case Constants.DecideOption.IGNORE_USER_PROFILE_SERVICE:
                    convertedOptions.add(OptimizelyDecideOption.IGNORE_USER_PROFILE_SERVICE);
                    break;
                case Constants.DecideOption.EXCLUDE_VARIABLES:
                    convertedOptions.add(OptimizelyDecideOption.EXCLUDE_VARIABLES);
                    break;
                case Constants.DecideOption.INCLUDE_REASONS:
                    convertedOptions.add(OptimizelyDecideOption.INCLUDE_REASONS);
                    break;
                default:
                    break;
            }
        }
        return convertedOptions;
    }

    public static List<ODPSegmentOption> getSegmentOptions(List<String> options) {
        if(options == null) {
            return null;
        }
        List<ODPSegmentOption> convertedOptions = new ArrayList<>();
        for(String option: options) {
            switch(option) {
                case Constants.SegmentOption.IGNORE_CACHE:
                    convertedOptions.add(ODPSegmentOption.IGNORE_CACHE);
                    break;
                case Constants.SegmentOption.RESET_CACHE:
                    convertedOptions.add(ODPSegmentOption.RESET_CACHE);
                    break;
                default:
                    break;
            }
        }
        return convertedOptions;
    }

    public static Class getNotificationListenerType(String notificationType) {
        if (notificationType == null || notificationType.isEmpty()) {
            return null;
        }

        Class listenerClass = null;
        switch (notificationType) {
            case Constants.NotificationType.ACTIVATE: listenerClass = ActivateNotification.class; break;
            case Constants.NotificationType.CONFIG_UPDATE: listenerClass = UpdateConfigNotification.class; break;
            case Constants.NotificationType.DECISION: listenerClass = DecisionNotification.class; break;
            case Constants.NotificationType.LOG_EVENT: listenerClass = LogEvent.class; break;
            case Constants.NotificationType.TRACK: listenerClass = TrackNotification.class; break;
            default: {
            }
        }
        return listenerClass;
    }
}
