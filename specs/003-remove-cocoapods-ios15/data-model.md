# Data Model: Remove CocoaPods Support and Raise Minimum iOS to 15.0

No runtime data, persistence or Dart types change. The "entities" are build-time declarations.

| Entity | Location | Before | After |
|---|---|---|---|
| iOS SPM manifest | `ios/optimizely_flutter_sdk/Package.swift` | `.iOS("10.0")`; excludes ObjC files | `.iOS("15.0")`; no `exclude` |
| iOS CocoaPods spec | `ios/optimizely_flutter_sdk.podspec` | `OptimizelySwiftSDK 5.4.2`, `:ios, '10.0'` | Deleted |
| ObjC registration shim | `ios/.../OptimizelyFlutterSdkPlugin.m`, `include/` | Used by CocoaPods only | Deleted |
| Plugin registration | `pubspec.yaml` `flutter.plugin.platforms.ios.pluginClass` | `SwiftOptimizelyFlutterSdkPlugin` | Unchanged |
| Flutter constraint | `pubspec.yaml` `environment.flutter` | `>=2.5.0` | `>=3.44.0` |
| Native SDK pin | `Package.swift` `exact:` | `5.4.2` | `5.4.2` (Ticket 2 moves to 6.0.0) |
| Version-parity gate | `.github/scripts/check-version-drift.sh` + `flutter.yml` job | Compares podspec vs SPM | Deleted |
| Example app iOS project | `example/ios` | CocoaPods + SPM ref, target 10.0 | SPM only, target 15.0 |
| Testapp iOS project | testapp `ios/` | CocoaPods only, Podfile 13.0, target 10.0 | SPM only, target 15.0 |
| Testapp CI Flutter | testapp `ios.yml`, `android.yml` | `3.16.0` | `3.44.0` |

**Invariant after change**: exactly one place declares the iOS native dependency (`Package.swift`).
