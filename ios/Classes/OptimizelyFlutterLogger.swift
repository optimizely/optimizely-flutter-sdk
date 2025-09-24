import Flutter
import Optimizely

public class OptimizelyFlutterLogger: NSObject, OPTLogger {
    static var LOGGER_CHANNEL: String = "optimizely_flutter_sdk_logger";
    
    public static var logLevel: OptimizelyLogLevel = .info
    
    private static var loggerChannel: FlutterMethodChannel?
    
    public required override init() {
        super.init()
    }
    
    public static func setChannel(_ channel: FlutterMethodChannel) {
        loggerChannel = channel
    }
    
    public func log(level: OptimizelyLogLevel, message: String) {
        // Early return if level check fails
        guard level.rawValue <= OptimizelyFlutterLogger.logLevel.rawValue else { 
            return 
        }
        
        // Ensure we have a valid channel
        guard let channel = Self.loggerChannel else {
            print("[OptimizelyFlutterLogger] ERROR: No logger channel available!")
            return
        }
        
        // Ensure logging happens on main thread as FlutterMethodChannel requires it
        if Thread.isMainThread {
            // Already on main thread
            channel.invokeMethod("log", arguments: [
                "level": level.rawValue,
                "message": message
            ])
        } else {
            // Switch to main thread
            DispatchQueue.main.sync {
                channel.invokeMethod("log", arguments: [
                    "level": level.rawValue,
                    "message": message
                ])
            }
        }
    }
}
