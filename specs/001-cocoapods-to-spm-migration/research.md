# Research: CocoaPods to SPM Migration

**Date**: 2026-08-20 | **Feature**: [spec.md](spec.md)

## 1. Flutter Plugin SPM Integration

**Decision**: Use Flutter's official SPM plugin structure with `Package.swift` in `ios/<plugin_name>/`.

**Rationale**: Flutter's official documentation defines the canonical directory layout and Package.swift structure for SPM-based plugins. This is the only supported approach for plugins that want to work with Flutter's SPM integration.

**Key Findings**:

- **Package.swift location**: `ios/optimizely_flutter_sdk/Package.swift`
- **Source files location**: `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/`
- Source files must be moved from `ios/Classes/` to the new SPM sources directory
- Library product name replaces underscores with hyphens: `optimizely-flutter-sdk`
- `FlutterFramework` dependency with `path: "../FlutterFramework"` is mandatory — Flutter tooling provides this at build time
- The ObjC bridging files (`.h`, `.m`) are used for CocoaPods plugin registration; SPM plugins may handle registration differently

**Package.swift Template**:
```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "optimizely_flutter_sdk",
    platforms: [.iOS("10.0")],
    products: [
        .library(name: "optimizely-flutter-sdk", targets: ["optimizely_flutter_sdk"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/optimizely/swift-sdk.git", exact: "5.4.2")
    ],
    targets: [
        .target(
            name: "optimizely_flutter_sdk",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Optimizely", package: "swift-sdk")
            ]
        )
    ]
)
```

**Alternatives Considered**:
- Dual CocoaPods+SPM support: Rejected by user (clean cut decision)
- Custom SPM layout: Rejected — must follow Flutter's canonical structure

## 2. OptimizelySwiftSDK SPM Compatibility

**Decision**: Use `https://github.com/optimizely/swift-sdk.git` with `.exact("5.4.2")` version pinning.

**Rationale**: The OptimizelySwiftSDK has first-class SPM support. The SPM product name is `Optimizely` (from the `swift-sdk` package). Exact version pinning matches the current podspec strategy and aligns with Constitution Principle VIII.

**Key Findings**:
- SPM repo URL: `https://github.com/optimizely/swift-sdk.git`
- Package name: `swift-sdk`
- Product/library name: `Optimizely`
- Supported platforms: iOS 10.0+, tvOS 10.0+, macOS 10.14+, watchOS 3.0+
- swift-tools-version: 5.3

**Verification Required**: Confirm that git tag `5.4.2` exists on the `swift-sdk` repo. If the tag format is `v5.4.2`, the exact version string may need adjustment.

**Alternatives Considered**:
- `.upToNextMinor(from: "5.4.2")`: Rejected — user chose exact pinning for stability
- `.upToNextMajor(from: "5.4.2")`: Rejected — too permissive for a bridge SDK

## 3. Source File Migration

**Decision**: Move all Swift source files from `ios/Classes/` to `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/`. Evaluate ObjC bridging files for removal or migration.

**Rationale**: SPM requires sources in a specific directory structure. The current `ios/Classes/` layout is CocoaPods-specific.

**Current Files**:
- `ios/Classes/SwiftOptimizelyFlutterSdkPlugin.swift` — main plugin
- `ios/Classes/OptimizelyFlutterLogger.swift` — logger bridge
- `ios/Classes/HelperClasses/Constants.swift` — constants
- `ios/Classes/HelperClasses/OptimizelyConfig+Extension.swift` — config extension
- `ios/Classes/HelperClasses/Utils.swift` — utilities
- `ios/Classes/OptimizelyFlutterSdkPlugin.h` — ObjC header (bridging)
- `ios/Classes/OptimizelyFlutterSdkPlugin.m` — ObjC implementation (bridging)

**ObjC Bridging Files**: The `.h` and `.m` files are a thin bridge that calls `SwiftOptimizelyFlutterSdkPlugin.registerWithRegistrar()`. SPM does not support mixed ObjC/Swift in a single target without a separate clang target. Options:
1. Convert to pure Swift registration (preferred for clean cut)
2. Use separate SPM targets for ObjC and Swift (adds complexity)

## 4. Example App Migration

**Decision**: Remove CocoaPods artifacts from `example/ios/` (Podfile, Podfile.lock, Pods/). Flutter tooling will resolve the SDK plugin via SPM automatically.

**Rationale**: The example app follows the same pattern as any consuming Flutter app. Once the plugin has a Package.swift, Flutter resolves it via SPM.

**Current State**: Example app has `Podfile` (platform :ios, '11.0'), `Podfile.lock`, and `Pods/` directory.

## 5. Test App Migration

**Decision**: Remove CocoaPods artifacts from `optimizely-flutter-testapp/ios/` and update CI workflow to remove CocoaPods installation step.

**Rationale**: The test app is the SDK's end-to-end validation layer. Its CI (`ios.yml`) currently runs `brew install cocoapods` + `pod repo update` — these steps must be removed.

**Current State**: Test app has `Podfile` (platform :ios, '13.0'), `Podfile.lock`, `Pods/` directory. iOS CI has explicit CocoaPods installation.

**CI Change Required**: In `optimizely-flutter-testapp/.github/workflows/ios.yml`, remove or replace the "Install Xcode Dependencies" step that runs `brew install cocoapods` and `pod repo update`.

## 6. SDK CI Impact

**Decision**: SDK CI workflows (`flutter.yml`) require no changes to CocoaPods steps.

**Rationale**: The SDK CI does not have explicit `pod install` calls — Flutter tooling handles dependency resolution. Integration test jobs just trigger the test app repo. The `build_test_ios` and `unit_test_coverage` jobs only run `flutter pub get` + `flutter test`.

**Note**: While the SDK CI doesn't need CocoaPods step changes, the integration test jobs trigger the test app, which does need changes (covered in section 5).
