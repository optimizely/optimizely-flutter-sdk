#ifndef FLUTTER_PLUGIN_OPTIMIZELY_FLUTTER_SDK_PLUGIN_H_
#define FLUTTER_PLUGIN_OPTIMIZELY_FLUTTER_SDK_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace optimizely_flutter_sdk {

class OptimizelyFlutterSdkPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  OptimizelyFlutterSdkPlugin();

  virtual ~OptimizelyFlutterSdkPlugin();

  // Disallow copy and assign.
  OptimizelyFlutterSdkPlugin(const OptimizelyFlutterSdkPlugin&) = delete;
  OptimizelyFlutterSdkPlugin& operator=(const OptimizelyFlutterSdkPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace optimizely_flutter_sdk

#endif  // FLUTTER_PLUGIN_OPTIMIZELY_FLUTTER_SDK_PLUGIN_H_
