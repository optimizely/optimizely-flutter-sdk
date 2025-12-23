/****************************************************************************
 * Copyright 2022, Optimizely, Inc. and contributors                        *
 *                                                                          *
 * Licensed under the Apache License, Version 2.0 (the "License");          *
 * you may not use this file except in compliance with the License.         *
 * You may obtain a copy of the License at                                  *
 *                                                                          *
 *    http://www.apache.org/licenses/LICENSE-2.0                            *
 *                                                                          *
 * Unless required by applicable law or agreed to in writing, software      *
 * distributed under the License is distributed on an "AS IS" BASIS,        *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 * See the License for the specific language governing permissions and      *
 * limitations under the License.                                           *
 ***************************************************************************/

import Foundation
import Optimizely

public class Utils: NSObject {
    static var sdkName = "flutter/swift-sdk"
    /// Converts and returns dart map to native map
    static func getTypedMap(arguments: Any?) -> [String: Any]? {
        guard let args = arguments as? Dictionary<String, Any?> else {
            return nil
        }
        var typedDictionary = [String: Any]()
        for (k,v) in args {
            if let processedValue = processTypedValue(v) {
                typedDictionary[k] = processedValue
            }
        }
        return typedDictionary
    }

    /// Recursively processes typed values from Flutter to native Swift types
    private static func processTypedValue(_ value: Any?) -> Any? {
        guard let typedValue = value as? Dictionary<String, Any?>,
              let val = typedValue["value"],
              let type = typedValue["type"] as? String else {
            return nil
        }

        switch type {
        case TypeValue.string:
            return val as? String
        case TypeValue.int:
            if let intValue = val as? Int {
                return NSNumber(value: intValue).intValue
            }
            return nil
        case TypeValue.double:
            if let doubleValue = val as? Double {
                return NSNumber(value: doubleValue).doubleValue
            }
            return nil
        case TypeValue.bool:
            if let booleanValue = val as? Bool {
                return NSNumber(value: booleanValue).boolValue
            }
            return nil
        case TypeValue.map:
            guard let nestedMap = val as? Dictionary<String, Any?> else {
                return nil
            }
            var result = [String: Any]()
            for (k, v) in nestedMap {
                if let processedValue = processTypedValue(v) {
                    result[k] = processedValue
                }
            }
            return result
        case TypeValue.list:
            guard let nestedArray = val as? [Any?] else {
                return nil
            }
            return nestedArray.compactMap { processTypedValue($0) }
        default:
            return nil
        }
    }
    
    /// Returns callback required for LogEventListener
    static func getLogEventCallback(id: Int, sdkKey: String) -> LogEventListener {
        
        let listener : LogEventListener = {(url, logEvent) in
            let listenerDict : [String : Any] = [
                "url"       : url,
                "params"    : logEvent as Any
            ]
            SwiftOptimizelyFlutterSdkPlugin.channel.invokeMethod("\(NotificationType.logEvent)CallbackListener", arguments: [RequestParameterKey.sdkKey: sdkKey, RequestParameterKey.notificationId: id, RequestParameterKey.notificationType: NotificationType.logEvent, RequestParameterKey.notificationPayload: listenerDict])
        }
        
        return listener
    }
    
    /// Returns callback required for DatafileChangeListener
    static func getProjectConfigUpdateCallback(id: Int, sdkKey: String) -> DatafileChangeListener {
        
        let listener : DatafileChangeListener = { datafile in
            var listenerDict = [String : Any]()
            if let datafileMap = try? JSONSerialization.jsonObject(with: datafile, options: []) as? [String: Any] {
                listenerDict["datafile"] = datafileMap
            }
            SwiftOptimizelyFlutterSdkPlugin.channel.invokeMethod("\(NotificationType.projectConfigUpdate)CallbackListener", arguments: [RequestParameterKey.sdkKey: sdkKey, RequestParameterKey.notificationId: id, RequestParameterKey.notificationType: NotificationType.projectConfigUpdate, RequestParameterKey.notificationPayload: listenerDict])
        }
        
        return listener
    }
    
    /// Returns callback required for ActivateListener
    static func getActivateCallback(id: Int, sdkKey: String) -> ActivateListener {
        let listener : ActivateListener = {(experiment, userId, attributes, variation, logEvents) in
            let listenerDict : [String : Any] = [
                "experiment"   : experiment,
                "userId"       : userId,
                "attributes"   : attributes as Any,
                "variation"    : variation
            ]
            SwiftOptimizelyFlutterSdkPlugin.channel.invokeMethod("\(NotificationType.activate)CallbackListener", arguments: [RequestParameterKey.sdkKey: sdkKey, RequestParameterKey.notificationId: id, RequestParameterKey.notificationType: NotificationType.activate, RequestParameterKey.notificationPayload: listenerDict])
        }
        return listener
    }
    
    /// Returns callback required for DecisionListener
    static func getDecisionCallback(id: Int, sdkKey: String) -> DecisionListener {
        let listener : DecisionListener = {(type, userId, attributes, decisionInfo) in
            let listenerDict : [String : Any] = [
                "type"        : type,
                "userId"      : userId,
                "attributes"  : attributes as Any,
                "decisionInfo": decisionInfo
            ]
            SwiftOptimizelyFlutterSdkPlugin.channel.invokeMethod("\(NotificationType.decision)CallbackListener", arguments: [RequestParameterKey.sdkKey: sdkKey, RequestParameterKey.notificationId: id, RequestParameterKey.notificationType: NotificationType.decision, RequestParameterKey.notificationPayload: listenerDict])
        }
        return listener
    }
    
    /// Returns callback required for TrackListener
    static func getTrackCallback(id: Int, sdkKey: String) -> TrackListener {
        let listener : TrackListener = {(eventKey, userId, attributes, eventTags, event) in
            let listenerDict : [String : Any] = [
                "attributes"   : attributes as Any,
                "eventKey"     : eventKey,
                "eventTags"    : eventTags as Any,
                "userId"       : userId,
                //                "event": event as Any, This is causing codec related exceptions on flutter side, need to debug
            ]
            SwiftOptimizelyFlutterSdkPlugin.channel.invokeMethod("\(NotificationType.track)CallbackListener", arguments: [RequestParameterKey.sdkKey: sdkKey, RequestParameterKey.notificationId: id, RequestParameterKey.notificationType: NotificationType.track, RequestParameterKey.notificationPayload: listenerDict])
        }
        return listener
    }
    
    /// Converts and returns string decide options to array of OptimizelyDecideOption
    static func getDecideOptions(options: [String]?) -> [OptimizelyDecideOption]? {
        guard let finalOptions = options else {
            return nil
        }
        var convertedOptions = [OptimizelyDecideOption]()
        for option in finalOptions {
            switch option {
            case DecideOption.disableDecisionEvent:
                convertedOptions.append(OptimizelyDecideOption.disableDecisionEvent)
            case DecideOption.enabledFlagsOnly:
                convertedOptions.append(OptimizelyDecideOption.enabledFlagsOnly)
            case DecideOption.ignoreUserProfileService:
                convertedOptions.append(OptimizelyDecideOption.ignoreUserProfileService)
            case DecideOption.excludeVariables:
                convertedOptions.append(OptimizelyDecideOption.excludeVariables)
            case DecideOption.includeReasons:
                convertedOptions.append(OptimizelyDecideOption.includeReasons)
            default: break
            }
        }
        return convertedOptions
    }
    
    /// Converts and returns string segment options to array of OptimizelySegmentOption
    static func getSegmentOptions(options: [String]?) -> [OptimizelySegmentOption]? {
        guard let finalOptions = options else {
            return nil
        }
        var convertedOptions = [OptimizelySegmentOption]()
        for option in finalOptions {
            switch option {
            case SegmentOption.ignoreCache:
                convertedOptions.append(OptimizelySegmentOption.ignoreCache)
            case SegmentOption.resetCache:
                convertedOptions.append(OptimizelySegmentOption.resetCache)
            default: break
            }
        }
        return convertedOptions
    }
    
    static func convertDecisionToDictionary(decision: OptimizelyDecision?) -> [String: Any?] {
        let userContext: [String: Any?] =
        [RequestParameterKey.userId : decision?.userContext.userId,
         RequestParameterKey.attributes : decision?.userContext.attributes]
        
        let decisionMap: [String: Any?] =
        [RequestParameterKey.variationKey: decision?.variationKey,
         RequestParameterKey.ruleKey: decision?.ruleKey,
         RequestParameterKey.enabled: decision?.enabled,
         RequestParameterKey.flagKey: decision?.flagKey,
         RequestParameterKey.userContext: userContext,
         RequestParameterKey.variables: decision?.variables.toMap(),
         RequestParameterKey.reasons: decision?.reasons]
        return decisionMap
    }
    
    static func getNotificationType(type: String) -> Optimizely.NotificationType? {
        switch type {
        case NotificationType.activate:
            return Optimizely.NotificationType.activate
        case NotificationType.decision:
            return Optimizely.NotificationType.decision
        case NotificationType.track:
            return Optimizely.NotificationType.track
        case NotificationType.logEvent:
            return Optimizely.NotificationType.logEvent
        case NotificationType.projectConfigUpdate:
            return Optimizely.NotificationType.datafileChange
        default:
            return nil
        }
    }

    static func getDefaultLogLevel(_ logLevel: String) -> OptimizelyLogLevel {
        var defaultLogLevel: OptimizelyLogLevel
        switch logLevel {
            case "error": defaultLogLevel = OptimizelyLogLevel.error
            case "warning": defaultLogLevel = OptimizelyLogLevel.warning
            case "info": defaultLogLevel = OptimizelyLogLevel.info
            case "debug": defaultLogLevel = OptimizelyLogLevel.debug
            default: defaultLogLevel = OptimizelyLogLevel.info
        }
        return defaultLogLevel;
    }

}
