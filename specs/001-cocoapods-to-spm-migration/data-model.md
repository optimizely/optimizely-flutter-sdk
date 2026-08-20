# Data Model: CocoaPods to SPM Migration

**Date**: 2026-08-20 | **Feature**: [spec.md](spec.md)

This is an infrastructure migration — no new data entities, attributes, or state transitions are introduced. The SDK's existing data models (`lib/src/data_objects/`) are unchanged.

## File Structure Changes

The migration changes the physical layout of iOS source files, not data models.

### Before (CocoaPods)

| Path | Role |
|------|------|
| `ios/optimizely_flutter_sdk.podspec` | Dependency manifest (CocoaPods) |
| `ios/Classes/*.swift` | Plugin Swift sources |
| `ios/Classes/HelperClasses/*.swift` | Helper Swift sources |
| `ios/Classes/*.h`, `*.m` | ObjC bridging for plugin registration |
| `ios/Assets/` | Empty assets directory |

### After (SPM)

| Path | Role |
|------|------|
| `ios/optimizely_flutter_sdk/Package.swift` | Dependency manifest (SPM) |
| `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/*.swift` | All plugin Swift sources (flattened) |

### Removed

| Path | Reason |
|------|--------|
| `ios/optimizely_flutter_sdk.podspec` | Replaced by Package.swift |
| `ios/Classes/` | Sources moved to SPM layout |
| `ios/Assets/` | Empty, not needed by SPM |
| `ios/Classes/OptimizelyFlutterSdkPlugin.h` | ObjC bridge — evaluate for removal |
| `ios/Classes/OptimizelyFlutterSdkPlugin.m` | ObjC bridge — evaluate for removal |

## Configuration Changes

### SDK (`pubspec.yaml`)

No changes to the `flutter.plugin.platforms.ios` section required — Flutter detects SPM support by the presence of Package.swift.

### Test App

| File | Change |
|------|--------|
| `ios/Podfile` | Remove |
| `ios/Podfile.lock` | Remove |
| `ios/Pods/` | Remove |

### Example App (`example/`)

| File | Change |
|------|--------|
| `example/ios/Podfile` | Remove |
| `example/ios/Podfile.lock` | Remove |
| `example/ios/Pods/` | Remove |

## Dependency Graph Change

```
Before: pubspec.yaml → podspec → CocoaPods → OptimizelySwiftSDK (pod)
After:  pubspec.yaml → Package.swift → SPM → OptimizelySwiftSDK (SPM package)
```

The Dart layer, MethodChannel bridge, and Android layer are completely unaffected.
