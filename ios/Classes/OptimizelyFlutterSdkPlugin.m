// copyright
#import "OptimizelyFlutterSdkPlugin.h"
#if __has_include(<optimizely_flutter_sdk/optimizely_flutter_sdk-Swift.h>)
#import <optimizely_flutter_sdk/optimizely_flutter_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "optimizely_flutter_sdk-Swift.h"
#endif

@implementation OptimizelyFlutterSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftOptimizelyFlutterSdkPlugin registerWithRegistrar:registrar];
}
@end
