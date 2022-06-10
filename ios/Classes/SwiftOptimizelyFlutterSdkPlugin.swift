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

import Flutter
import UIKit
import Optimizely
import Foundation

struct API {
    static let initialize = "initialize"
    static let getOptimizelyConfig = "getOptimizelyConfig"
    static let createUserContext = "createUserContext"
    static let setAttributes = "set_attributes"
    static let trackEvent = "track_event"
    static let decide = "decide"
}

struct RequestParameterKey {
    static let sdkKey = "sdk_key"
    static let userId = "user_id"
    static let attributes = "attributes"
    static let decideKeys = "keys"
    static let decideOptions = "optimizely_decide_option"
    static let eventKey = "event_key"
    static let eventTags = "event_tags"
}

struct ErrorMessage {
    static let invalidParameters = "Invalid parameters provided."
    static let optimizelyConfigNotFound = "No optimizely config found."
    static let userContextNotFound = "User context not found."
}

struct SuccessMessage {
    static let instanceCreated = "Optimizely instance created successfully."
    static let optimizelyConfigFound = "Optimizely config found."
    static let userContextCreated = "User context created successfully."
}

public class SwiftOptimizelyFlutterSdkPlugin: NSObject, FlutterPlugin {
    
    var optimizelyInstance: OptimizelyClient?
    var userContext: OptimizelyUserContext?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "optimizely_flutter_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftOptimizelyFlutterSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func createResponse(success: Bool, result: Any? = nil, reason: String? = nil) -> [String: Any] {
        var response: [String: Any] = ["success": success]
        if let result = result {
            response["result"] = result
        }
        if let reason = reason {
            response["reason"] = reason
        }
        return response
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
            
        case API.initialize:
            guard let parameters = call.arguments as? Dictionary<String, Any?>, let sdkKey = parameters[RequestParameterKey.sdkKey] as? String else {
                result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
                return
            }
            
            // Delete old user context
            userContext = nil
            // Creating new instance
            optimizelyInstance = OptimizelyClient(sdkKey:sdkKey)
            
            optimizelyInstance?.start{ [weak self] res in
                switch res {
                case .success(_):
                    result(self?.createResponse(success: true, reason: SuccessMessage.instanceCreated))
                case .failure(let err):
                    result(self?.createResponse(success: false, reason: err.localizedDescription))
                }
            }
            
        case API.getOptimizelyConfig:
            guard let optimizelyConfig = try? optimizelyInstance?.getOptimizelyConfig(), let optlyConfigDict = optimizelyConfig.dict else {
                result(self.createResponse(success: false, reason: ErrorMessage.optimizelyConfigNotFound))
                return
            }
            result(self.createResponse(success: true, result: optlyConfigDict, reason: SuccessMessage.optimizelyConfigFound))
            
        case API.createUserContext:
            guard let parameters = call.arguments as? Dictionary<String, Any?>, let userId = parameters[RequestParameterKey.userId] as? String else {
                result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
                return
            }
            
            if let attributes = parameters[RequestParameterKey.attributes] as? [String: Any] {
                userContext = optimizelyInstance?.createUserContext(userId: userId, attributes: attributes)
            } else {
                userContext = optimizelyInstance?.createUserContext(userId: userId)
            }
            result(self.createResponse(success: true, reason: SuccessMessage.userContextCreated))
            
        case API.setAttributes:
            guard let usrContext = userContext else  {
                result(self.createResponse(success: false, reason: ErrorMessage.userContextNotFound))
                return
            }
            
            guard let parameters = call.arguments as? Dictionary<String, Any?>, let attributes = parameters[RequestParameterKey.attributes] as? [String: Any] else {
                result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
                return
            }
            
            for (k,v) in attributes {
                usrContext.setAttribute(key: k, value: v)
            }
            
        case API.trackEvent:
            
            guard let usrContext = userContext else  {
                result(self.createResponse(success: false, reason: ErrorMessage.userContextNotFound))
                return
            }
            
            guard let parameters = call.arguments as? Dictionary<String, Any?>, let eventKey = parameters[RequestParameterKey.eventKey] as? String else {
                result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
                return
            }
            
            let eventTags = parameters[RequestParameterKey.eventTags] as? [String: Any]
            do {
                try usrContext.trackEvent(eventKey: eventKey, eventTags: eventTags)
                result(self.createResponse(success: true))
            } catch {
                result(self.createResponse(success: false, reason: error.localizedDescription))
            }
            
        case API.decide:
            guard let usrContext = userContext else  {
                result(self.createResponse(success: false, reason: ErrorMessage.userContextNotFound))
                return
            }
            
            var parameters: Dictionary<String, Any?>?
            if let params = call.arguments as? Dictionary<String, Any?> {
                parameters = params
            }
            
            var decideKeys: [String]?
            if let keys = parameters?[RequestParameterKey.decideKeys] as? [String] {
                decideKeys = keys
            }
            
            var decideOptions: [String]?
            if let options = parameters?[RequestParameterKey.decideOptions] as? [String] {
                decideOptions = options
            }
            
            let options = getDecideOptions(options: decideOptions)
            var decisions = [String: OptimizelyDecision]()
            var resultMap = [String: Any]()
            
            if let keys = decideKeys, keys.count > 0 {
                decisions = usrContext.decide(keys: keys, options: options)
            } else {
                decisions = usrContext.decideAll(options: options)
            }
            
            for (key, decision) in decisions {
                resultMap[key] = convertDecisionToDictionary(decision: decision)
            }
            
            result(self.createResponse(success: true, result: resultMap, reason: ""))
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

func getDecideOptions(options: [String]?) -> [OptimizelyDecideOption]? {
    guard let finalOptions = options else {
        return nil
    }
    var convertedOptions = [OptimizelyDecideOption]()
    for option in finalOptions {
        switch option {
        case "DISABLE_DECISION_EVENT":
            convertedOptions.append(OptimizelyDecideOption.disableDecisionEvent)
        case "ENABLED_FLAGS_ONLY":
            convertedOptions.append(OptimizelyDecideOption.enabledFlagsOnly)
        case "IGNORE_USER_PROFILE_SERVICE":
            convertedOptions.append(OptimizelyDecideOption.ignoreUserProfileService)
        case "EXCLUDE_VARIABLES":
            convertedOptions.append(OptimizelyDecideOption.excludeVariables)
        case "INCLUDE_REASONS":
            convertedOptions.append(OptimizelyDecideOption.includeReasons)
        default: break
        }
    }
    return convertedOptions
}

func convertDecisionToDictionary(decision: OptimizelyDecision?) -> [String: Any?] {
    let userContext: [String: Any?] =
        ["user_id" : decision?.userContext.userId,
         "attributes" : decision?.userContext.attributes]
    
    let decisionMap: [String: Any?] =
        ["variation_key": decision?.variationKey,
         "rule_key": decision?.ruleKey,
         "enabled": decision?.enabled,
         "flag_key": decision?.flagKey,
         "user_context": userContext,
         "variables": decision?.variables.toMap(),
         "reasons": decision?.reasons]
    return decisionMap
}

// Extension to convert OptimizelyConfig to Map
extension OptimizelyConfig {
    var dict: [String: Any]? {
        return [
            "revision": self.revision,
            "experimentsMap": self.experimentsMap.mapValues{ $0.dict },
            "featuresMap": self.featuresMap.mapValues{ $0.dict },
            "attributes": self.attributes.map { $0.dict },
            "audiences": self.audiences.map { $0.dict },
            "events": self.events.map { $0.dict },
            "sdkKey": self.sdkKey,
            "environmentKey": self.environmentKey
        ]
    }
}

extension OptimizelyAttribute {
    var dict: [String: Any] {
        return [
            "key": self.key,
            "id": self.id,
        ]
    }
}

extension OptimizelyAudience {
    var dict: [String: Any] {
        return [
            "name": self.name,
            "id": self.id,
            "conditions": self.conditions
        ]
    }
}

extension OptimizelyEvent {
    var dict: [String: Any] {
        return [
            "key": self.key,
            "id": self.id,
            "experimentIds": self.experimentIds
        ]
    }
}

extension OptimizelyExperiment {
    var dict: [String: Any] {
        return [
            "key": self.key,
            "id": self.id,
            "audiences": self.audiences,
            "variationsMap": self.variationsMap.mapValues{ $0.dict }
        ]
    }
}

extension OptimizelyFeature {
    var dict: [String: Any] {
        return [
            "key": self.key,
            "id": self.id,
            "experimentRules": self.experimentRules.map{ $0.dict },
            "deliveryRules": self.deliveryRules.map{ $0.dict },
            "experimentsMap": self.experimentsMap.mapValues{ $0.dict },
            "variablesMap": self.variablesMap.mapValues{ $0.dict }
        ]
    }
}

extension OptimizelyVariation {
    var dict: [String: Any] {
        var expected: [String: Any] = [
            "key": self.key,
            "id": self.id,
            "variablesMap": self.variablesMap.mapValues{ $0.dict }
        ]
        
        if let featureEnabled = self.featureEnabled {
            expected["featureEnabled"] = featureEnabled
        }
        
        return expected
    }
}

extension OptimizelyVariable {
    var dict: [String: Any] {
        return [
            "key": self.key,
            "id": self.id,
            "type": self.type,
            "value": self.value
        ]
    }
}
