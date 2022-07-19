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

/// A wrapper around Optimizely Swift SDK that communicates with flutter using a channel
public class SwiftOptimizelyFlutterSdkPlugin: NSObject, FlutterPlugin {
    // to keep track of notification listener id's in-case they are to be removed in future
    var notificationIdsTracker = [Int: Int]()
    // to keep track of optimizely clients against their sdkKeys
    var optimizelyClientsTracker = [String: OptimizelyClient?]()
    // to keep track of optimizely user contexts against their sdkKeys
    var userContextsTracker = [String: OptimizelyUserContext?]()
    
    // to communicate with optimizely flutter sdk
    static var channel: FlutterMethodChannel!
    
    /// Registers optimizely_flutter_sdk channel to communicate with the flutter sdk to receive requests and send responses
    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "optimizely_flutter_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftOptimizelyFlutterSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    /// Part of FlutterPlugin protocol to handle communication with flutter sdk
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        switch call.method {
        case API.initialize: initialize(call, result: result)
        case API.addNotificationListener: addNotificationListener(call, result: result)
        case API.removeNotificationListener: removeNotificationListener(call, result: result)
        case API.getOptimizelyConfig: getOptimizelyConfig(call, result: result)
        case API.createUserContext: createUserContext(call, result: result)
        case API.setAttributes: setAttributes(call, result: result)
        case API.trackEvent: trackEvent(call, result: result)
        case API.decide: decide(call, result: result)
        default: result(FlutterMethodNotImplemented)
        }
    }
    
    /// Initializes optimizely client with the provided sdkKey
    func initialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let parameters = call.arguments as? Dictionary<String, Any?>, let sdkKey = parameters[RequestParameterKey.sdkKey] as? String else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        
        // Delete old user context
        userContextsTracker[sdkKey] = nil
        userContextsTracker.removeValue(forKey: sdkKey)
        
        // Creating new instance
        let optimizelyInstance = OptimizelyClient(sdkKey:sdkKey)
        optimizelyClientsTracker[sdkKey] = optimizelyInstance
        
        optimizelyInstance.start{ [weak self] res in
            switch res {
            case .success(_):
                result(self?.createResponse(success: true, reason: SuccessMessage.instanceCreated))
            case .failure(let err):
                result(self?.createResponse(success: false, reason: err.localizedDescription))
            }
        }
    }
    
    /// Adds notification listeners to the optimizely client as requested
    func addNotificationListener(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let optimizelyClient = getOptimizelyClient(arguments: call.arguments) else {
            result(self.createResponse(success: false, reason: ErrorMessage.optlyClientNotFound))
            return
        }
        guard let parameters = call.arguments as? Dictionary<String, Any?>, let id = parameters[RequestParameterKey.notificationId] as? Int, let type = parameters[RequestParameterKey.notificationType] as? String else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        switch type {
        case NotificationType.decision:
            let notificationId = optimizelyClient.notificationCenter?.addDecisionNotificationListener(decisionListener: Utils.getDecisionCallback(id: id))!
            notificationIdsTracker[id] = notificationId
            result(self.createResponse(success: true, reason: SuccessMessage.listenerAdded))
            break
        case NotificationType.track:
            let notificationId = optimizelyClient.notificationCenter?.addTrackNotificationListener(trackListener: Utils.getTrackCallback(id: id))
            notificationIdsTracker[id] = notificationId
            result(self.createResponse(success: true, reason: SuccessMessage.listenerAdded))
            break
        case NotificationType.logEvent:
            let notificationId = optimizelyClient.notificationCenter?.addLogEventNotificationListener(logEventListener: Utils.getLogEventCallback(id: id))
            notificationIdsTracker[id] = notificationId
            result(self.createResponse(success: true, reason: SuccessMessage.listenerAdded))
            break
        case NotificationType.projectConfigUpdate:
            let notificationId = optimizelyClient.notificationCenter?.addDatafileChangeNotificationListener(datafileListener:  Utils.getProjectConfigUpdateCallback(id: id))
            notificationIdsTracker[id] = notificationId
            result(self.createResponse(success: true, reason: SuccessMessage.listenerAdded))
            break
        default:
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
        }
    }
    
    /// Removes notification listeners to the optimizely client as requested
    func removeNotificationListener(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let optimizelyClient = getOptimizelyClient(arguments: call.arguments) else {
            result(self.createResponse(success: false, reason: ErrorMessage.optlyClientNotFound))
            return
        }
        guard let parameters = call.arguments as? Dictionary<String, Any?>, let id = parameters[RequestParameterKey.notificationId] as? Int else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        if let notificationID = notificationIdsTracker[id] {
            optimizelyClient.notificationCenter?.removeNotificationListener(notificationId: notificationID)
            notificationIdsTracker.removeValue(forKey: id)
            result(self.createResponse(success: true, reason: SuccessMessage.listenerRemoved))
        } else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
        }
    }
    
    /// Returns a snapshot of the current project configuration.
    func getOptimizelyConfig(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let optimizelyClient = getOptimizelyClient(arguments: call.arguments) else {
            result(self.createResponse(success: false, reason: ErrorMessage.optlyClientNotFound))
            return
        }
        
        guard let optimizelyConfig = try? optimizelyClient.getOptimizelyConfig(), let optlyConfigDict = optimizelyConfig.dict else {
            result(self.createResponse(success: false, reason: ErrorMessage.optimizelyConfigNotFound))
            return
        }
        result(self.createResponse(success: true, result: optlyConfigDict, reason: SuccessMessage.optimizelyConfigFound))
    }
    
    /// Creates a context of the user for which decision APIs will be called.
    /// A user context will only be created successfully when the SDK is fully configured using initializeClient.
    func createUserContext(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let optimizelyClient = getOptimizelyClient(arguments: call.arguments) else {
            result(self.createResponse(success: false, reason: ErrorMessage.optlyClientNotFound))
            return
        }
        guard let parameters = call.arguments as? Dictionary<String, Any?>, let userId = parameters[RequestParameterKey.userId] as? String, let sdkKey = parameters[RequestParameterKey.sdkKey] as? String else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        
        if let attributes = Utils.getTypedMap(arguments: parameters[RequestParameterKey.attributes] as? Any) {
            userContextsTracker[sdkKey] = optimizelyClient.createUserContext(userId: userId, attributes: attributes)
        } else {
            userContextsTracker[sdkKey] = optimizelyClient.createUserContext(userId: userId)
        }
        result(self.createResponse(success: true, reason: SuccessMessage.userContextCreated))
    }
    
    /// Sets attributes for the user context.
    func setAttributes(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let usrContext = getUserContext(arguments: call.arguments) else  {
            result(self.createResponse(success: false, reason: ErrorMessage.userContextNotFound))
            return
        }
        
        guard let parameters = call.arguments as? Dictionary<String, Any?>, let attributes = Utils.getTypedMap(arguments: parameters[RequestParameterKey.attributes] as? Any) else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        
        for (k,v) in attributes {
            usrContext.setAttribute(key: k, value: v)
        }
        result(createResponse(success: true, reason: SuccessMessage.attributesAdded))
    }
    
    /// Tracks an event.
    func trackEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let usrContext = getUserContext(arguments: call.arguments) else  {
            result(self.createResponse(success: false, reason: ErrorMessage.userContextNotFound))
            return
        }
        
        guard let parameters = call.arguments as? Dictionary<String, Any?>, let eventKey = parameters[RequestParameterKey.eventKey] as? String else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        
        let eventTags = Utils.getTypedMap(arguments: parameters[RequestParameterKey.eventTags] as? Any)
        do {
            try usrContext.trackEvent(eventKey: eventKey, eventTags: eventTags)
            result(self.createResponse(success: true))
        } catch {
            result(self.createResponse(success: false, reason: error.localizedDescription))
        }
    }
    
    /// Returns a key-map of decision results for multiple flag keys and a user context.
    func decide(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let usrContext = getUserContext(arguments: call.arguments) else  {
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
        
        let options = Utils.getDecideOptions(options: decideOptions)
        var decisions = [String: OptimizelyDecision]()
        var resultMap = [String: Any]()
        
        if let keys = decideKeys, keys.count > 0 {
            decisions = usrContext.decide(keys: keys, options: options)
        } else {
            decisions = usrContext.decideAll(options: options)
        }
        
        for (key, decision) in decisions {
            resultMap[key] = Utils.convertDecisionToDictionary(decision: decision)
        }
        
        result(self.createResponse(success: true, result: resultMap, reason: SuccessMessage.decideCalled))
    }
    
    /// Returns saved optimizely client
    func getOptimizelyClient(arguments: Any?) -> OptimizelyClient? {
        guard let parameters = arguments as? Dictionary<String, Any?>, let sdkKey = parameters[RequestParameterKey.sdkKey] as? String else {
            return nil
        }
        return optimizelyClientsTracker[sdkKey] ?? nil
    }
    
    /// Returns saved user context
    func getUserContext(arguments: Any?) -> OptimizelyUserContext? {
        guard let parameters = arguments as? Dictionary<String, Any?>, let sdkKey = parameters[RequestParameterKey.sdkKey] as? String else {
            return nil
        }
        return userContextsTracker[sdkKey] ?? nil
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
}
