#include "include/optimizely_flutter_sdk/optimizely_flutter_sdk_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "optimizely_flutter_sdk_plugin.h"

void OptimizelyFlutterSdkPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  optimizely_flutter_sdk::OptimizelyFlutterSdkPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
