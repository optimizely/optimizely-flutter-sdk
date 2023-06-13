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
    var notificationIdsTracker = [String: [Int: Int]]()
    // to keep track of optimizely clients against their sdkKeys
    var optimizelyClientsTracker = [String: OptimizelyClient?]()
    // to keep track of optimizely user contexts against their sdkKeys
    var userContextsTracker = [String: [String: OptimizelyUserContext?]]()
    
    // to communicate with optimizely flutter sdk
    static var channel: FlutterMethodChannel!
    
    // to track each unique userContext
    var uuid: String {
        return UUID().uuidString
    }
    
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
        case API.clearNotificationListeners, API.clearAllNotificationListeners: clearAllNotificationListeners(call, result: result)
        case API.getOptimizelyConfig: getOptimizelyConfig(call, result: result)
        case API.activate: activate(call, result: result)
        case API.getVariation: getVariation(call, result: result)
        case API.getForcedVariation: getForcedVariation(call, result: result)
        case API.setForcedVariation: setForcedVariation(call, result: result)
        case API.createUserContext: createUserContext(call, result: result)
        case API.getUserId: getUserId(call, result: result)
        case API.getAttributes: getAttributes(call, result: result)
        case API.setAttributes: setAttributes(call, result: result)
        case API.trackEvent: trackEvent(call, result: result)
        case API.decide: decide(call, result: result)
        case API.setForcedDecision: setForcedDecision(call, result: result)
        case API.getForcedDecision: getForcedDecision(call, result: result)
        case API.removeForcedDecision: removeForcedDecision(call, result: result)
        case API.removeAllForcedDecisions: removeAllForcedDecisions(call, result: result)
        case API.close: close(call, result: result)
            
        // ODP
        case API.getQualifiedSegments: getQualifiedSegments(call, result: result)
        case API.setQualifiedSegments: setQualifiedSegments(call, result: result)
        case API.getVuid: getVuid(call, result: result)
        case API.isQualifiedFor: isQualifiedFor(call, result: result)
        case API.sendOdpEvent: sendOdpEvent(call, result: result)
        case API.fetchQualifiedSegments: fetchQualifiedSegments(call, result: result)
        default: result(FlutterMethodNotImplemented)
        }
    }
    
    /// Initializes optimizely client with the provided sdkKey
    func initialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, sdkKey) = getParametersAndSdkKey(arguments: call.arguments, result: result) else {
            return
        }
        
        // EventDispatcher Default Values
        var batchSize = 10
        var timeInterval: TimeInterval = 60 // Seconds
        var maxQueueSize = 10000
        
        if let _batchSize = parameters[RequestParameterKey.eventBatchSize] as? Int {
            batchSize = _batchSize
        }
        if let _timeInterval = parameters[RequestParameterKey.eventTimeInterval] as? Int {
            timeInterval = TimeInterval(_timeInterval)
        }
        if let _maxQueueSize = parameters[RequestParameterKey.eventMaxQueueSize] as? Int {
            maxQueueSize = _maxQueueSize
        }
        let eventDispatcher = DefaultEventDispatcher(batchSize: batchSize, backingStore: .file, dataStoreName: "OPTEventQueue", timerInterval: timeInterval, maxQueueSize: maxQueueSize)
        
        var decideOptions: [String]?
        if let options = parameters[RequestParameterKey.decideOptions] as? [String] {
            decideOptions = options
        }
        let defaultDecideOptions = Utils.getDecideOptions(options: decideOptions)

        var defaultLogLevel = OptimizelyLogLevel.info
        if let logLevel = parameters[RequestParameterKey.defaultLogLevel] as? String {
            defaultLogLevel = Utils.getDefaultLogLevel(logLevel)
        }

        // SDK Settings Default Values
        var segmentsCacheSize: Int = 100
        var segmentsCacheTimeoutInSecs: Int = 600
        var timeoutForSegmentFetchInSecs: Int = 10
        var timeoutForOdpEventInSecs: Int = 10
        var disableOdp: Bool = false
        if let sdkSettings = parameters[RequestParameterKey.optimizelySdkSettings] as? Dictionary<String, Any?> {
            if let cacheSize = sdkSettings[RequestParameterKey.segmentsCacheSize] as? Int {
                segmentsCacheSize = cacheSize
            }
            if let segmentsCacheTimeout = sdkSettings[RequestParameterKey.segmentsCacheTimeoutInSecs] as? Int {
                segmentsCacheTimeoutInSecs = segmentsCacheTimeout
            }
            if let timeoutForSegmentFetch = sdkSettings[RequestParameterKey.timeoutForSegmentFetchInSecs] as? Int {
                timeoutForSegmentFetchInSecs = timeoutForSegmentFetch
            }
            if let timeoutForOdpEvent = sdkSettings[RequestParameterKey.timeoutForOdpEventInSecs] as? Int {
                timeoutForOdpEventInSecs = timeoutForOdpEvent
            }
            if let isOdpDisabled = sdkSettings[RequestParameterKey.disableOdp] as? Bool {
                disableOdp = isOdpDisabled
            }
        }
        let optimizelySdkSettings = OptimizelySdkSettings(segmentsCacheSize: segmentsCacheSize, segmentsCacheTimeoutInSecs: segmentsCacheTimeoutInSecs, timeoutForSegmentFetchInSecs: timeoutForSegmentFetchInSecs, timeoutForOdpEventInSecs: timeoutForOdpEventInSecs, disableOdp: disableOdp)
        
        // Datafile Download Interval
        var datafilePeriodicDownloadInterval = 10 * 60 // seconds
        
        if let _datafilePeriodicDownloadInterval = parameters[RequestParameterKey.datafilePeriodicDownloadInterval] as? Int {
            datafilePeriodicDownloadInterval = _datafilePeriodicDownloadInterval
        }
        
        let datafileHandler = DefaultDatafileHandler()
        if let datafileHostPrefix = parameters[RequestParameterKey.datafileHostPrefix] as? String, let datafileHostSuffix = parameters[RequestParameterKey.datafileHostSuffix] as? String {
            datafileHandler.endPointStringFormat = String(format: "\(datafileHostPrefix)\(datafileHostSuffix)", sdkKey)
        }
        
        // Delete old user context
        userContextsTracker.removeValue(forKey: sdkKey)
        // Close and remove old client
        getOptimizelyClient(sdkKey: sdkKey)?.close()
        notificationIdsTracker.removeValue(forKey: sdkKey)
        optimizelyClientsTracker.removeValue(forKey: sdkKey)
        
        // Creating new instance
        let optimizelyInstance = OptimizelyClient(
            sdkKey:sdkKey, 
            eventDispatcher: eventDispatcher, 
            datafileHandler: datafileHandler, 
            periodicDownloadInterval: datafilePeriodicDownloadInterval, 
            defaultLogLevel: defaultLogLevel,
            defaultDecideOptions: defaultDecideOptions, 
            settings: optimizelySdkSettings)
        
        optimizelyInstance.start{ [weak self] res in
            switch res {
            case .success(_):
                self?.optimizelyClientsTracker[sdkKey] = optimizelyInstance
                result(self?.createResponse(success: true))
            case .failure(let err):
                result(self?.createResponse(success: false, reason: err.localizedDescription))
            }
        }
    }
    
    /// Adds notification listeners to the optimizely client as requested
    func addNotificationListener(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, sdkKey) = getParametersAndSdkKey(arguments: call.arguments, result: result) else {
            return
        }
        guard let optimizelyClient = getOptimizelyClient(sdkKey: sdkKey, result: result) else {
            return
        }
        guard let id = parameters[RequestParameterKey.notificationId] as? Int, let type = parameters[RequestParameterKey.notificationType] as? String else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        var notificationId = 0
        switch type {
        case NotificationType.activate:
            notificationId = (optimizelyClient.notificationCenter?.addActivateNotificationListener(activateListener: Utils.getActivateCallback(id: id, sdkKey: sdkKey)))!
        case NotificationType.decision:
            notificationId = (optimizelyClient.notificationCenter?.addDecisionNotificationListener(decisionListener: Utils.getDecisionCallback(id: id, sdkKey: sdkKey)))!
            break
        case NotificationType.track:
            notificationId = (optimizelyClient.notificationCenter?.addTrackNotificationListener(trackListener: Utils.getTrackCallback(id: id, sdkKey: sdkKey)))!
            break
        case NotificationType.logEvent:
            notificationId = (optimizelyClient.notificationCenter?.addLogEventNotificationListener(logEventListener: Utils.getLogEventCallback(id: id, sdkKey: sdkKey)))!
            break
        case NotificationType.projectConfigUpdate:
            let notificationId = optimizelyClient.notificationCenter?.addDatafileChangeNotificationListener(datafileListener:  Utils.getProjectConfigUpdateCallback(id: id, sdkKey: sdkKey))
            break
        default:
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        if notificationIdsTracker[sdkKey] == nil {
            notificationIdsTracker[sdkKey] = [Int: Int]()
        }
        notificationIdsTracker[sdkKey]![id] = notificationId
        result(self.createResponse(success: true))
    }
    
    /// Removes notification listeners from the optimizely client as requested
    func removeNotificationListener(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, sdkKey) = getParametersAndSdkKey(arguments: call.arguments, result: result) else {
            return
        }
        guard let optimizelyClient = getOptimizelyClient(sdkKey: sdkKey, result: result) else {
            return
        }
        guard let notificationID = parameters[RequestParameterKey.notificationId] as? Int else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        optimizelyClient.notificationCenter?.removeNotificationListener(notificationId: notificationID)
        if notificationIdsTracker[sdkKey] != nil {
            notificationIdsTracker[sdkKey]?.removeValue(forKey: notificationID)
        }
        result(self.createResponse(success: true))
    }
    
    /// Removes all notification listeners from the optimizely client as requested
    func clearAllNotificationListeners(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, sdkKey) = getParametersAndSdkKey(arguments: call.arguments, result: result) else {
            return
        }
        guard let optimizelyClient = getOptimizelyClient(sdkKey: sdkKey, result: result) else {
            return
        }
        
        if let type = parameters[RequestParameterKey.notificationType] as? String, let convertedNotificationType = Utils.getNotificationType(type: type) {
            // Remove listeners only for the provided type
            optimizelyClient.notificationCenter?.clearNotificationListeners(type: convertedNotificationType)
        } else {
            // Remove all listeners if type is not provided
            optimizelyClient.notificationCenter?.clearAllNotificationListeners()
        }
        
        if let callBackIds = parameters[RequestParameterKey.callbackIds] as? [Int] {
            if notificationIdsTracker[sdkKey] != nil {
                for callbackId in callBackIds {
                    notificationIdsTracker[sdkKey]?.removeValue(forKey: callbackId)
                }
            }
        }
        result(self.createResponse(success: true))
    }
    
    /// Returns a snapshot of the current project configuration.
    func getOptimizelyConfig(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (_, optimizelyClient) = getParametersAndOptimizelyClient(arguments: call.arguments, result: result) else {
            return
        }
        guard let optimizelyConfig = try? optimizelyClient.getOptimizelyConfig(), let optlyConfigDict = optimizelyConfig.dict else {
            result(self.createResponse(success: false, reason: ErrorMessage.optimizelyConfigNotFound))
            return
        }
        result(self.createResponse(success: true, result: optlyConfigDict))
    }
    
    /**
     * Use the activate method to start an experiment.
     *
     * The activate call will conditionally activate an experiment for a user based on the provided experiment key and a randomized hash of the provided user ID.
     * If the user satisfies audience conditions for the experiment and the experiment is valid and running, the function returns the variation the user is bucketed into.
     * Otherwise, activate returns nil. Make sure that your code adequately deals with the case when the experiment is not activated (e.g. execute the default variation).
     */
    func activate(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, optimizelyClient) = getParametersAndOptimizelyClient(arguments: call.arguments, result: result) else {
            return
        }
        guard let experimentKey = parameters[RequestParameterKey.experimentKey] as? String, let userId = parameters[RequestParameterKey.userId] as? String else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        
        do {
            let variationKey = try optimizelyClient.activate(experimentKey: experimentKey, userId: userId, attributes: Utils.getTypedMap(arguments: parameters[RequestParameterKey.attributes] as? Any))
            result(self.createResponse(success: true, result: [RequestParameterKey.variationKey: variationKey]))
        } catch {
            result(self.createResponse(success: false, reason: error.localizedDescription))
        }
    }
    
    /// Get variation for experiment and user ID with user attributes.
    func getVariation(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, optimizelyClient) = getParametersAndOptimizelyClient(arguments: call.arguments, result: result) else {
            return
        }
        guard let experimentKey = parameters[RequestParameterKey.experimentKey] as? String, let userId = parameters[RequestParameterKey.userId] as? String else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        
        do {
            let variationKey = try optimizelyClient.getVariationKey(experimentKey: experimentKey, userId: userId, attributes: Utils.getTypedMap(arguments: parameters[RequestParameterKey.attributes] as? Any))
            result(self.createResponse(success: true, result: [RequestParameterKey.variationKey: variationKey]))
        } catch {
            result(self.createResponse(success: false, reason: error.localizedDescription))
        }
    }
    
    /// Get forced variation for experiment and user ID.
    func getForcedVariation(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, optimizelyClient) = getParametersAndOptimizelyClient(arguments: call.arguments, result: result) else {
            return
        }
        guard let experimentKey = parameters[RequestParameterKey.experimentKey] as? String, let userId = parameters[RequestParameterKey.userId] as? String else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        
        if let variationKey = optimizelyClient.getForcedVariation(experimentKey: experimentKey, userId: userId) {
            result(self.createResponse(success: true, result: [RequestParameterKey.variationKey: variationKey]))
            return
        }
        result(self.createResponse(success: true))
    }
    
    /// Set forced variation for experiment and user ID to variationKey.
    func setForcedVariation(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, optimizelyClient) = getParametersAndOptimizelyClient(arguments: call.arguments, result: result) else {
            return
        }
        guard let experimentKey = parameters[RequestParameterKey.experimentKey] as? String, let userId = parameters[RequestParameterKey.userId] as? String else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        
        let variationKey = parameters[RequestParameterKey.variationKey] as? String
        let success = optimizelyClient.setForcedVariation(experimentKey: experimentKey, userId: userId, variationKey: variationKey)
        result(self.createResponse(success: success))
    }
    
    /// Creates a context of the user for which decision APIs will be called.
    /// A user context will only be created successfully when the SDK is fully configured using initializeClient.
    func createUserContext(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, sdkKey) = getParametersAndSdkKey(arguments: call.arguments, result: result) else {
            return
        }
        guard let optimizelyClient = getOptimizelyClient(sdkKey: sdkKey, result: result) else {
            return
        }
        
        let userContextId = uuid
        var userContext: OptimizelyUserContext!
        
        if let userId = parameters[RequestParameterKey.userId] as? String {
            userContext = optimizelyClient.createUserContext(userId: userId, attributes: Utils.getTypedMap(arguments: parameters[RequestParameterKey.attributes] as? Any))
        } else {
            userContext = optimizelyClient.createUserContext(attributes: Utils.getTypedMap(arguments: parameters[RequestParameterKey.attributes] as? Any))
        }
        if userContextsTracker[sdkKey] != nil {
            userContextsTracker[sdkKey]![userContextId] = userContext
        } else {
            userContextsTracker[sdkKey] = [userContextId: userContext]
        }
        result(self.createResponse(success: true, result: [RequestParameterKey.userContextId: userContextId]))
    }
    
    /// Returns userId for the user context.
    func getUserId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (_, userContext) = getParametersAndUserContext(arguments: call.arguments, result: result) else {
            return
        }
        result(createResponse(success: true, result: [RequestParameterKey.userId: userContext.userId]))
    }
    
    /// Returns attributes for the user context.
    func getAttributes(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (_, userContext) = getParametersAndUserContext(arguments: call.arguments, result: result) else {
            return
        }
        result(createResponse(success: true, result: [RequestParameterKey.attributes: userContext.attributes]))
    }
    
    /// Sets attributes for the user context.
    func setAttributes(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, userContext) = getParametersAndUserContext(arguments: call.arguments, result: result) else {
            return
        }
        guard let attributes = Utils.getTypedMap(arguments: parameters[RequestParameterKey.attributes] as? Any) else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        
        for (k,v) in attributes {
            userContext.setAttribute(key: k, value: v)
        }
        result(createResponse(success: true))
    }
    
    /// Returns an array of segments that the user is qualified for.
    func getQualifiedSegments(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (_, userContext) = getParametersAndUserContext(arguments: call.arguments, result: result) else {
            return
        }
        guard let qualifiedSegments = userContext.qualifiedSegments else {
            result(createResponse(success: false, reason: ErrorMessage.qualifiedSegmentsNotFound))
            return
        }
        result(createResponse(success: true, result: [RequestParameterKey.qualifiedSegments: qualifiedSegments]))
    }
    
    /// Sets qualified segments for the user context.
    func setQualifiedSegments(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, userContext) = getParametersAndUserContext(arguments: call.arguments, result: result) else {
            return
        }
        guard let qualifiedSegments = parameters[RequestParameterKey.qualifiedSegments] as? [String] else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        userContext.qualifiedSegments = qualifiedSegments
        result(createResponse(success: true))
    }
    
    /// Returns the device vuid.
    func getVuid(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (_, sdkKey) = getParametersAndSdkKey(arguments: call.arguments, result: result) else {
            return
        }
        guard let optimizelyClient = getOptimizelyClient(sdkKey: sdkKey, result: result) else {
            return
        }
        result(self.createResponse(success: true, result: [RequestParameterKey.vuid: optimizelyClient.vuid]))
    }
    
    /// Checks if the user is qualified for the given segment.
    func isQualifiedFor(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, userContext) = getParametersAndUserContext(arguments: call.arguments, result: result) else {
            return
        }
        guard let segment = parameters[RequestParameterKey.segment] as? String else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        result(self.createResponse(success: userContext.isQualifiedFor(segment: segment)))
    }
    
    /// Send an event to the ODP server.
    func sendOdpEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, sdkKey) = getParametersAndSdkKey(arguments: call.arguments, result: result) else {
            return
        }
        guard let optimizelyClient = getOptimizelyClient(sdkKey: sdkKey, result: result) else {
            return
        }
        guard let action = parameters[RequestParameterKey.action] as? String, action != "" else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        
        var type: String?
        var identifiers: [String: String] = [:]
        var data: [String: Any?] = [:]
        
        if let _type = parameters[RequestParameterKey.type] as? String {
            type = _type
        }
        if let _identifiers = parameters[RequestParameterKey.identifiers] as? Dictionary<String, String> {
            identifiers = _identifiers
        }
        if let _data = Utils.getTypedMap(arguments: parameters[RequestParameterKey.data] as? Any) {
            data = _data
        }
        
        do {
            try optimizelyClient.sendOdpEvent(type: type, action: action, identifiers: identifiers, data: data)
        } catch {
            print(error.localizedDescription)
        }
        result(self.createResponse(success: true))
    }
    
    /// Fetch all qualified segments for the user context.
    func fetchQualifiedSegments(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, userContext) = getParametersAndUserContext(arguments: call.arguments, result: result) else {
            return
        }
        var segmentOptions: [String]?
        if let options = parameters[RequestParameterKey.optimizelySegmentOption] as? [String] {
            segmentOptions = options
        }
        
        let options = Utils.getSegmentOptions(options: segmentOptions)
        do {
            try userContext.fetchQualifiedSegments(options: options ?? [])
            result(createResponse(success: true))
        } catch {
            result(self.createResponse(success: false, reason: error.localizedDescription))
        }
    }
    
    /// Tracks an event.
    func trackEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, userContext) = getParametersAndUserContext(arguments: call.arguments, result: result) else {
            return
        }
        guard let eventKey = parameters[RequestParameterKey.eventKey] as? String else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        
        let eventTags = Utils.getTypedMap(arguments: parameters[RequestParameterKey.eventTags] as? Any)
        do {
            try userContext.trackEvent(eventKey: eventKey, eventTags: eventTags)
            result(self.createResponse(success: true))
        } catch {
            result(self.createResponse(success: false, reason: error.localizedDescription))
        }
    }
    
    /// Returns a key-map of decision results for multiple flag keys and a user context.
    func decide(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, userContext) = getParametersAndUserContext(arguments: call.arguments, result: result) else {
            return
        }
        
        var decideKeys: [String]?
        if let keys = parameters[RequestParameterKey.decideKeys] as? [String] {
            decideKeys = keys
        }
        
        var decideOptions: [String]?
        if let options = parameters[RequestParameterKey.decideOptions] as? [String] {
            decideOptions = options
        }
        
        let options = Utils.getDecideOptions(options: decideOptions)
        var decisions = [String: OptimizelyDecision]()
        var resultMap = [String: Any]()
        
        if let keys = decideKeys, keys.count > 0 {
            decisions = userContext.decide(keys: keys, options: options)
        } else {
            decisions = userContext.decideAll(options: options)
        }
        
        for (key, decision) in decisions {
            resultMap[key] = Utils.convertDecisionToDictionary(decision: decision)
        }
        
        result(self.createResponse(success: true, result: resultMap))
    }
    
    /// Sets the forced decision for a given decision context.
    func setForcedDecision(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, userContext) = getParametersAndUserContext(arguments: call.arguments, result: result) else {
            return
        }
        guard let flagKey = parameters[RequestParameterKey.flagKey] as? String, let variationKey = parameters[RequestParameterKey.variationKey] as? String else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        
        let success = userContext.setForcedDecision(context: OptimizelyDecisionContext(flagKey: flagKey, ruleKey: parameters[RequestParameterKey.ruleKey] as? String), decision: OptimizelyForcedDecision(variationKey: variationKey))
        result(self.createResponse(success: success))
    }
    
    /// Returns the forced decision for a given decision context.
    func getForcedDecision(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, userContext) = getParametersAndUserContext(arguments: call.arguments, result: result) else {
            return
        }
        guard let flagKey = parameters[RequestParameterKey.flagKey] as? String else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        
        if let variationKey = userContext.getForcedDecision(context: OptimizelyDecisionContext(flagKey: flagKey, ruleKey: parameters[RequestParameterKey.ruleKey] as? String))?.variationKey {
            result(self.createResponse(success: true, result: [ResponseKey.variationKey: variationKey]))
            return
        }
        result(self.createResponse(success: true))
    }
    
    /// Removes the forced decision for a given decision context.
    func removeForcedDecision(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (parameters, userContext) = getParametersAndUserContext(arguments: call.arguments, result: result) else {
            return
        }
        guard let flagKey = parameters[RequestParameterKey.flagKey] as? String else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return
        }
        
        let success = userContext.removeForcedDecision(context: OptimizelyDecisionContext(flagKey: flagKey, ruleKey: parameters[RequestParameterKey.ruleKey] as? String))
        result(self.createResponse(success: success))
    }
    
    /// Removes all forced decisions bound to this user context.
    func removeAllForcedDecisions(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (_, userContext) = getParametersAndUserContext(arguments: call.arguments, result: result) else {
            return
        }
        
        let success = userContext.removeAllForcedDecisions()
        result(self.createResponse(success: success))
    }
    
    /// Closes optimizely client after Flushing/batching all events
    func close(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let (_, sdkKey) = getParametersAndSdkKey(arguments: call.arguments, result: result) else {
            return
        }
        guard let optimizelyClient = getOptimizelyClient(sdkKey: sdkKey, result: result) else {
            return
        }
        
        optimizelyClient.close()
        optimizelyClientsTracker.removeValue(forKey: sdkKey)
        userContextsTracker.removeValue(forKey: sdkKey)
        result(self.createResponse(success: true))
    }
    
    /// Returns saved optimizely client
    func getOptimizelyClient(sdkKey: String, result: FlutterResult? = nil) -> OptimizelyClient? {
        guard let optimizelyClient = optimizelyClientsTracker[sdkKey] as? OptimizelyClient else {
            if let _result = result {
                _result(self.createResponse(success: false, reason: ErrorMessage.optlyClientNotFound))
            }
            return nil
        }
        return optimizelyClient
    }
    
    /// Returns parsed parameters and sdkKey
    func getParametersAndSdkKey(arguments: Any?, result: @escaping FlutterResult) -> (Dictionary<String, Any?>, String)? {
        guard let parameters = arguments as? Dictionary<String, Any?>, let sdkKey = parameters[RequestParameterKey.sdkKey] as? String else {
            result(createResponse(success: false, reason: ErrorMessage.invalidParameters))
            return nil
        }
        return (parameters, sdkKey)
    }
    
    /// Returns saved user context with parameters
    func getParametersAndUserContext(arguments: Any?, result: @escaping FlutterResult) -> (Dictionary<String, Any?>, OptimizelyUserContext)? {
        guard let (parameters, sdkKey) = getParametersAndSdkKey(arguments: arguments, result: result) else {
            return nil
        }
        guard let userContextId = parameters[RequestParameterKey.userContextId] as? String, let userContext = userContextsTracker[sdkKey]?[userContextId] as? OptimizelyUserContext else {
            result(self.createResponse(success: false, reason: ErrorMessage.userContextNotFound))
            return nil
        }
        return (parameters, userContext)
    }
    
    /// Returns saved optimizely client with parameters
    func getParametersAndOptimizelyClient(arguments: Any?, result: @escaping FlutterResult) -> (Dictionary<String, Any?>, OptimizelyClient)? {
        guard let (parameters, sdkKey) = getParametersAndSdkKey(arguments: arguments, result: result) else {
            return nil
        }
        guard let optimizelyClient = getOptimizelyClient(sdkKey: sdkKey, result: result) else {
            return nil
        }
        return (parameters, optimizelyClient)
    }
    
    func createResponse(success: Bool, result: Any? = nil, reason: String? = nil) -> [String: Any] {
        var response: [String: Any] = [ResponseKey.success: success]
        if let result = result {
            response[ResponseKey.result] = result
        }
        if let reason = reason {
            response[ResponseKey.reason] = reason
        }
        return response
    }
}
