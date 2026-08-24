# Research: Add SPM Support with CocoaPods Backward Compatibility

**Date**: 2026-08-20 (Revised) | **Feature**: [spec.md](spec.md)

## 1. Flutter Plugin Dual SPM + CocoaPods Support

**Decision**: Add SPM support via Package.swift while retaining the podspec with updated source paths. Follow Flutter's official recommendation for dual support.

**Rationale**: Flutter explicitly states: "Flutter plugins should support both Swift Package Manager and CocoaPods until further notice." The official guide provides a migration path that preserves CocoaPods compatibility.

**Key Findings**:

- **Package.swift location**: `ios/optimizely-flutter-sdk/Package.swift` (hyphens — matches SPM normalized identity)
- **Source files location**: `ios/optimizely-flutter-sdk/Classes/` (simplified from SPM default `Sources/<target>/` using `path: "Classes"` override)
- **Symlink**: `ios/optimizely_flutter_sdk` → `ios/optimizely-flutter-sdk/` (underscores → hyphens, required for Flutter's plugin discovery)
- Source files move from `ios/Classes/` to `ios/optimizely-flutter-sdk/Classes/`
- Library product name replaces underscores with hyphens: `optimizely-flutter-sdk`
- `FlutterFramework` dependency with `path: "../FlutterFramework"` is mandatory — Flutter tooling provides this at build time (same as CocoaPods' `s.dependency 'Flutter'`)
- **Podspec stays**: Update `s.source_files` from `'Classes/**/*'` to `'optimizely-flutter-sdk/Classes/**/*'`
- Both Package.swift and podspec reference the same files in the new location
- **SPM identity normalization** (SE-0292): SPM 5.6+ normalizes underscores to hyphens in package identity. Directory must use hyphens to match.
- **Mixed Swift/ObjC limitation**: SPM cannot have Swift and ObjC in the same target. ObjC files are excluded from the SPM target via `exclude` but kept on disk for CocoaPods.
- **pluginClass change**: Changed from `OptimizelyFlutterSdkPlugin` (ObjC) to `SwiftOptimizelyFlutterSdkPlugin` (Swift) in `pubspec.yaml` for direct SPM registration.

**Package.swift (actual)**:
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
            ],
            path: "Classes",
            exclude: ["OptimizelyFlutterSdkPlugin.m", "include"]
        )
    ]
)
```

**Updated Podspec Changes**:
```ruby
# Before: s.source_files = 'Classes/**/*'
# After:
s.source_files = 'optimizely-flutter-sdk/Classes/**/*'
```

**Alternatives Considered**:
- Clean cut (remove CocoaPods entirely): Rejected by user — backward compatibility required
- Keep source files in `ios/Classes/` and symlink for SPM: Rejected — fragile, not recommended by Flutter
- Use `Sources/optimizely_flutter_sdk/` (SPM default layout): Rejected — `Classes/` is simpler and SPM's `path` parameter officially supports it (Apple docs: `Target.path`)

## 2. OptimizelySwiftSDK SPM Compatibility

**Decision**: Use `https://github.com/optimizely/swift-sdk.git` with `.exact("5.4.2")` version pinning in Package.swift. Keep `OptimizelySwiftSDK`, `5.4.2` in podspec.

**Rationale**: The OptimizelySwiftSDK has first-class SPM support. Both dependency mechanisms must pin the same version to prevent drift (FR-006).

**Key Findings**:
- SPM repo URL: `https://github.com/optimizely/swift-sdk.git`
- Package name: `swift-sdk`
- Product/library name: `Optimizely`
- Supported platforms: iOS 10.0+, tvOS 10.0+, macOS 10.14+, watchOS 3.0+
- CocoaPods pod name: `OptimizelySwiftSDK`

**Verification Required**: Confirm that git tag `5.4.2` exists on the `swift-sdk` repo. If the tag format is `v5.4.2`, the exact version string may need adjustment.

## 3. Source File Migration (Dual Support Layout)

**Decision**: Move all source files from `ios/Classes/` to `ios/optimizely-flutter-sdk/Classes/`. ObjC files are excluded from the SPM target but kept on disk for CocoaPods. Update podspec paths to match.

**Rationale**: The `Classes/` directory name is simpler than SPM's default `Sources/<target>/` convention. SPM's `path` parameter officially supports custom source paths. The hyphenated directory name is required because SPM normalizes package identity by replacing underscores with hyphens (SE-0292).

**Current Files** (before migration):
- `ios/Classes/SwiftOptimizelyFlutterSdkPlugin.swift` — main plugin
- `ios/Classes/OptimizelyFlutterLogger.swift` — logger bridge
- `ios/Classes/HelperClasses/Constants.swift` — constants
- `ios/Classes/HelperClasses/OptimizelyConfig+Extension.swift` — config extension
- `ios/Classes/HelperClasses/Utils.swift` — utilities
- `ios/Classes/OptimizelyFlutterSdkPlugin.h` — ObjC header (bridging)
- `ios/Classes/OptimizelyFlutterSdkPlugin.m` — ObjC implementation (bridging)

**New Layout**:
```
ios/optimizely-flutter-sdk/              # Real directory (hyphens — matches SPM identity)
├── Package.swift                        # SPM manifest
└── Classes/                             # Source files (path override in Package.swift)
    ├── include/
    │   └── optimizely_flutter_sdk/
    │       └── OptimizelyFlutterSdkPlugin.h  # ObjC header (excluded from SPM, used by CocoaPods)
    ├── OptimizelyFlutterSdkPlugin.m          # ObjC bridge (excluded from SPM, used by CocoaPods)
    ├── SwiftOptimizelyFlutterSdkPlugin.swift
    ├── OptimizelyFlutterLogger.swift
    ├── Constants.swift
    ├── OptimizelyConfig+Extension.swift
    └── Utils.swift
ios/optimizely_flutter_sdk -> optimizely-flutter-sdk/  # Symlink (underscores — Flutter discovery)
```

**ObjC Bridging Files**:
- ObjC files (`.m`, `.h`) are excluded from the SPM target because SPM does not support mixed Swift/ObjC in a single target
- They remain on disk for CocoaPods builds, which still compile them
- Package.swift uses `exclude: ["OptimizelyFlutterSdkPlugin.m", "include"]` to skip them

## 4. Podspec Updates

**Decision**: Keep `optimizely_flutter_sdk.podspec` at `ios/optimizely_flutter_sdk.podspec` and update `source_files` to point to the new directory layout.

**Changes Required**:
```ruby
# Before
s.source_files = 'Classes/**/*'

# After
s.source_files = 'optimizely-flutter-sdk/Classes/**/*'
```

**Verification**: Run `pod lib lint optimizely_flutter_sdk.podspec` after changes to ensure CocoaPods can still find and compile all source files.

## 5. Example App

**Decision**: No changes needed to the example app itself. Flutter tooling will use whichever dependency mechanism is available (SPM on 3.44+, CocoaPods on older versions). The example app's Podfile, Podfile.lock, and Pods/ remain as-is for CocoaPods compatibility.

**Rationale**: The example app is a consumer of the plugin. Flutter handles the CocoaPods-to-SPM routing transparently. Removing the Podfile would break builds on older Flutter versions.

## 6. Test App

**Decision**: The test app needs both CI workflow updates and SPM configuration added to its iOS project. The test app's Podfile can be kept for CocoaPods fallback or removed if the CI Flutter version defaults to SPM.

**Rationale**: The test app validates the SDK end-to-end. Per clarification, changes include CI workflow updates + adding SPM configuration to the test app's iOS project. This ensures US-3 acceptance scenarios can be verified.

## 7. SDK CI Impact

**Decision**: SDK CI workflows (`flutter.yml`) are updated to pin Flutter 3.44.0 across all jobs and enable SPM for the `build_test_ios` job. The `build_test_ios` job depends on `version_drift_check` to ensure podspec/Package.swift version parity before building. The test app CI (`ios.yml`) is pinned to Flutter 3.16.0 (pre-SPM) to validate the CocoaPods path.

**Changes**:
- SDK CI: All jobs pin Flutter 3.44.0 for consistent caching. `build_test_ios` enables SPM and depends on `version_drift_check`.
- Test app CI: Pinned to Flutter 3.16.0, SPM enable step removed, CocoaPods steps (`brew install cocoapods`, `pod repo update`) remain.

## 8. Version Synchronization (Critical)

**Decision**: Both Package.swift and podspec MUST declare the same OptimizelySwiftSDK version. When bumping native SDK versions, both files must be updated simultaneously. A CI validation check (FR-014) MUST fail the build if versions diverge.

**Implementation**: Add a CI validation step that extracts and compares the OptimizelySwiftSDK version from both files. Add a note to CLAUDE.md's version management section about the dual-file requirement. Constitution Principle VIII (Native SDK Version Pinning) already covers this — the source-of-truth files now include both `ios/optimizely_flutter_sdk.podspec` AND `ios/optimizely_flutter_sdk/Package.swift`.

**No Deprecation Notices**: Per clarification, this release does not include deprecation notices or migration guides for CocoaPods users. That will be addressed closer to Flutter's actual CocoaPods removal.
