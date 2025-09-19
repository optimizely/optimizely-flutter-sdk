import Flutter
import Optimizely

public class OptimizelyFlutterLogger: NSObject, OPTLogger {
    public static var logLevel: OptimizelyLogLevel = .info
    
    private static let loggerChannel = FlutterMethodChannel(
        name: "optimizely_flutter_sdk_logger",
        binaryMessenger: SwiftOptimizelyFlutterSdkPlugin.registrar?.messenger() ?? FlutterEngine().binaryMessenger
    )
    
    public required override init() {
        super.init()
    }
    
    public func log(level: OptimizelyLogLevel, message: String) {
        // Ensure we're on the main thread when calling Flutter
        DispatchQueue.main.async {
            Self.loggerChannel.invokeMethod("log", arguments: [
                "level": level.rawValue,
                "message": message
            ])
        }
    }
}
