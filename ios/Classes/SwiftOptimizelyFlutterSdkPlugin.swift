import Flutter
import UIKit
import Optimizely
import Foundation

struct ErrorMessage {
    static let parameters = "no parameters defined."
}

public class SwiftOptimizelyFlutterSdkPlugin: NSObject, FlutterPlugin {
    
    var instances = [String: OptimizelyClient]()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "optimizely_flutter_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftOptimizelyFlutterSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func createResponse(result: Any, message: String) -> [String: Any] {
        return ["success": result, "reason": message]
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            guard let parameter = call.arguments as? Dictionary<String, Any?>, let sdkKey = parameter["sdk_key"] as? String else {
                result(createResponse(result: false, message: ErrorMessage.parameters))
                return
            }
            if instances[sdkKey] == nil {
                result(createResponse(result: true, message: ""))
                return
            }
            
            let optimizelyClient = OptimizelyClient(sdkKey:sdkKey)
            instances[sdkKey] = optimizelyClient
            optimizelyClient.start{ [weak self] res in
                switch res {
                case .success(_):
                    result(self?.createResponse(result: true, message: ""))
                    return
                case .failure(let err):
                    result(self?.createResponse(result: false, message: err.localizedDescription))
                    return
                }
            }
            break
        case "decide":
            let optimizelyClient = OptimizelyClient(sdkKey:"KZbunNn9bVfBWLpZPq2XC4")
            optimizelyClient.start{ res in
                do {
                    if let optimizelyConfig = try? optimizelyClient.getOptimizelyConfig() {
                        result(optimizelyConfig.dict)
                    }
                } catch {
                    print(error)
                }
            }
            break
        default:
            break
        }
    }
}

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
