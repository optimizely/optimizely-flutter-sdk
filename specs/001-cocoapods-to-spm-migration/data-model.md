# Data Model: Add SPM Support with CocoaPods Backward Compatibility

**Date**: 2026-08-20 (Revised) | **Feature**: [spec.md](spec.md)

This is an infrastructure change — no new data entities, attributes, or state transitions are introduced. The SDK's existing data models (`lib/src/data_objects/`) are unchanged.

## File Structure Changes

The migration changes the physical layout of iOS source files. Both CocoaPods and SPM reference the same files in the new location.

### Before

| Path | Role |
|------|------|
| `ios/optimizely_flutter_sdk.podspec` | Dependency manifest (CocoaPods) |
| `ios/Classes/*.swift` | Plugin Swift sources |
| `ios/Classes/HelperClasses/*.swift` | Helper Swift sources |
| `ios/Classes/*.h`, `*.m` | ObjC bridging for plugin registration |
| `ios/Assets/` | Empty assets directory |

### After

| Path | Role |
|------|------|
| `ios/optimizely_flutter_sdk.podspec` | Dependency manifest (CocoaPods) — **updated `source_files` path** |
| `ios/optimizely_flutter_sdk/Package.swift` | Dependency manifest (SPM) — **NEW** |
| `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/*.swift` | All plugin Swift sources (flattened) |
| `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/OptimizelyFlutterSdkPlugin.m` | ObjC bridge implementation |
| `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/include/optimizely_flutter_sdk/OptimizelyFlutterSdkPlugin.h` | ObjC public header |

### Removed

| Path | Reason |
|------|--------|
| `ios/Classes/` | Sources moved to SPM layout |
| `ios/Assets/` | Empty, not needed |

### Retained (Updated)

| Path | Change |
|------|--------|
| `ios/optimizely_flutter_sdk.podspec` | `source_files` path updated to `'optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/**/*'` |

## Configuration Changes

### SDK (`pubspec.yaml`)

No changes needed — Flutter detects SPM support by the presence of Package.swift and falls back to CocoaPods if SPM is not available.

### Example App (`example/`)

No changes — keeps existing Podfile for CocoaPods backward compatibility. Flutter tooling selects the appropriate mechanism.

### Test App

The test app needs CI workflow updates and SPM configuration added to its iOS project. The existing Podfile is kept for CocoaPods fallback. CI workflows (`ios.yml`) are updated for SPM-compatible build steps.

## Dependency Graph

```
SPM Path:    pubspec.yaml → Package.swift → SPM → OptimizelySwiftSDK (SPM package)
CocoaPods:   pubspec.yaml → podspec → CocoaPods → OptimizelySwiftSDK (pod)
```

Both paths coexist. Flutter selects which path to use based on:
- Flutter version (3.44+ defaults to SPM)
- `--enable-swift-package-manager` / `--no-enable-swift-package-manager` flag
- Presence of Package.swift in the plugin

The Dart layer, MethodChannel bridge, and Android layer are completely unaffected.

## Version Synchronization

Two files now declare the OptimizelySwiftSDK version:

| File | Format | Current |
|------|--------|---------|
| `ios/optimizely_flutter_sdk.podspec` | `s.dependency 'OptimizelySwiftSDK', '5.4.2'` | 5.4.2 |
| `ios/optimizely_flutter_sdk/Package.swift` | `.package(url: "...", exact: "5.4.2")` | 5.4.2 (new) |

Both MUST be updated simultaneously when bumping native SDK versions (Constitution Principle VIII).
