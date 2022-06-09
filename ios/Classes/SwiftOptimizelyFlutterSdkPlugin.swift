import Flutter
import UIKit
import Optimizely
import Foundation

struct RequestParameterKeys {
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
    
    func createResponse(success: Bool, result: Any?, reason: String) -> [String: Any] {
        var response: [String: Any] = ["success": success, "reason": reason]
        if let result = result {
            response["result"] = result
        }
        return response
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
            
        case "initialize":
            guard let parameters = call.arguments as? Dictionary<String, Any?>, let sdkKey = parameters[RequestParameterKeys.sdkKey] as? String else {
                result(createResponse(success: false, result: nil, reason: ErrorMessage.invalidParameters))
                return
            }
            
            // Delete old user context
            userContext = nil
            // Creating new instance
            optimizelyInstance = OptimizelyClient(sdkKey:sdkKey)
            
            optimizelyInstance?.start{ [weak self] res in
                switch res {
                case .success(_):
                    result(self?.createResponse(success: true, result: nil, reason: SuccessMessage.instanceCreated))
                case .failure(let err):
                    result(self?.createResponse(success: false, result: nil, reason: err.localizedDescription))
                }
            }
            
        case "getOptimizelyConfig":
            guard let optimizelyConfig = try? optimizelyInstance?.getOptimizelyConfig(), let optlyConfigDict = optimizelyConfig.dict else {
                result(self.createResponse(success: false, result: nil, reason: ErrorMessage.optimizelyConfigNotFound))
                return
            }
            result(self.createResponse(success: true, result: optlyConfigDict, reason: SuccessMessage.optimizelyConfigFound))
            
        case "createUserContext":
            guard let parameters = call.arguments as? Dictionary<String, Any?>, let userId = parameters[RequestParameterKeys.userId] as? String else {
                result(createResponse(success: false, result: nil, reason: ErrorMessage.invalidParameters))
                return
            }
            
            if let attributes = parameters[RequestParameterKeys.attributes] as? [String: Any] {
                userContext = optimizelyInstance?.createUserContext(userId: userId, attributes: attributes)
            } else {
                userContext = optimizelyInstance?.createUserContext(userId: userId)
            }
            result(self.createResponse(success: true, result: nil, reason: SuccessMessage.userContextCreated))
            
        case "set_attributes":
            guard let usrContext = userContext else  {
                result(self.createResponse(success: false, result: nil, reason: ErrorMessage.userContextNotFound))
                return
            }
            
            guard let parameters = call.arguments as? Dictionary<String, Any?>, let attributes = parameters[RequestParameterKeys.attributes] as? [String: Any] else {
                result(createResponse(success: false, result: nil, reason: ErrorMessage.invalidParameters))
                return
            }
            
            for (k,v) in attributes {
                usrContext.setAttribute(key: k, value: v)
            }
            
        case "track_event":
            
            guard let usrContext = userContext else  {
                result(self.createResponse(success: false, result: nil, reason: ErrorMessage.userContextNotFound))
                return
            }
            
            guard let parameters = call.arguments as? Dictionary<String, Any?>, let eventKey = parameters[RequestParameterKeys.eventKey] as? String else {
                result(createResponse(success: false, result: nil, reason: ErrorMessage.invalidParameters))
                return
            }
            
            let eventTags = parameters[RequestParameterKeys.eventTags] as? [String: Any]
            do {
                try usrContext.trackEvent(eventKey: eventKey, eventTags: eventTags)
                result(self.createResponse(success: true, result: nil, reason: ""))
            } catch {
                result(self.createResponse(success: false, result: nil, reason: error.localizedDescription))
            }
            
        case "decide":
            guard let usrContext = userContext else  {
                result(self.createResponse(success: false, result: nil, reason: ErrorMessage.userContextNotFound))
                return
            }
            
            var parameters: Dictionary<String, Any?>?
            if let params = call.arguments as? Dictionary<String, Any?> {
                parameters = params
            }
            
            var decideKeys: [String]?
            if let keys = parameters?[RequestParameterKeys.decideKeys] as? [String] {
                decideKeys = keys
            }
            
            var decideOptions: [String]?
            if let options = parameters?[RequestParameterKeys.decideOptions] as? [String] {
                decideOptions = options
            }
            
            let options = getDecideOptions(options: decideOptions)
            var resultMap = [String: Any]()
            
            let decisions = (decideKeys != nil) ? usrContext.decide(keys: decideKeys!, options: options) : usrContext.decideAll(options: options)
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
