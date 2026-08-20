# Implementation Plan: CocoaPods to SPM Migration

**Branch**: `001-cocoapods-to-spm-migration` | **Date**: 2026-08-20 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-cocoapods-to-spm-migration/spec.md`

## Summary

Migrate the Optimizely Flutter SDK's iOS dependency management from CocoaPods to Swift Package Manager. This is a clean cut — no dual-support period. The SDK plugin will declare its OptimizelySwiftSDK dependency via a `Package.swift` file following Flutter's official SPM plugin structure. Source files move from `ios/Classes/` to the SPM-standard layout. The example app, test app, CI workflows, and documentation are all updated to remove CocoaPods references.

## Technical Context

**Language/Version**: Dart >=2.16.2 <4.0.0, Swift 5.0+, Java/Kotlin 2.1.0

**Primary Dependencies**: Flutter SDK (stable), OptimizelySwiftSDK 5.4.2 (via SPM), android-sdk (unchanged via Gradle)

**Storage**: N/A

**Testing**: `flutter test` (Dart unit tests), `flutter test integration_test` (e2e via test app)

**Target Platform**: iOS 10.0+ (SDK), iOS 13.0 (test app), Android API 21+ (unchanged)

**Project Type**: Flutter plugin (cross-platform library wrapping native SDKs)

**Performance Goals**: N/A — infrastructure migration, no behavioral changes

**Constraints**: Must be backward compatible at the Dart API level. iOS minimum stays at 10.0. All existing tests must pass.

**Scale/Scope**: 2 repositories (SDK + test app), ~7 Swift source files to move, 2 CI workflows to update

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Bridge Pattern Integrity | PASS | No changes to the three-layer architecture. Only the dependency resolution mechanism changes. |
| II. Response Object Pattern | PASS | No API changes — all methods continue returning BaseResponse derivatives. |
| III. Platform Parity | PASS | Android layer is completely unaffected. iOS functionality is preserved. |
| IV. Type Safety Across Bridge | PASS | No changes to type encoding or `Utils.convertToTypedMap()`. |
| V. Thread Safety | PASS | No changes to main-thread dispatch patterns. |
| VI. Multi-Instance State Isolation | PASS | No changes to state management. |
| VII. Version Synchronisation | PASS | No version bump in this migration (infra change). |
| VIII. Native SDK Version Pinning | PASS | Version pinning preserved: `.exact("5.4.2")` in Package.swift matches podspec. |
| IX. CMAB & Async Decide | PASS | No changes to CMAB functionality. |
| X. ODP Integration | PASS | No changes to ODP functionality. |
| XI. Event Batching Configuration | PASS | No changes to event batching. |
| XII. Logger Bridge Architecture | PASS | Logger channel and bridge files are moved but unchanged. |

**Gate Result**: ALL PASS — no violations.

## Project Structure

### Documentation (this feature)

```text
specs/001-cocoapods-to-spm-migration/
├── plan.md              # This file
├── research.md          # Phase 0 output — SPM integration research
├── data-model.md        # Phase 1 output — file structure changes
├── quickstart.md        # Phase 1 output — validation guide
└── tasks.md             # Phase 2 output (created by /speckit-tasks)
```

### Source Code (repository root)

```text
# SDK repo — iOS layer changes
ios/
├── optimizely_flutter_sdk/                          # NEW: SPM package directory
│   ├── Package.swift                                # NEW: SPM manifest
│   └── Sources/
│       └── optimizely_flutter_sdk/                  # NEW: SPM sources
│           ├── SwiftOptimizelyFlutterSdkPlugin.swift # MOVED from Classes/
│           ├── OptimizelyFlutterLogger.swift          # MOVED from Classes/
│           ├── Constants.swift                        # MOVED from Classes/HelperClasses/
│           ├── OptimizelyConfig+Extension.swift       # MOVED from Classes/HelperClasses/
│           └── Utils.swift                            # MOVED from Classes/HelperClasses/
├── Classes/                                          # REMOVED (files moved to SPM layout)
├── Assets/                                           # REMOVED (empty)
└── optimizely_flutter_sdk.podspec                   # REMOVED (replaced by Package.swift)

# SDK repo — example app
example/ios/
├── Podfile                                          # REMOVED
├── Podfile.lock                                     # REMOVED
└── Pods/                                            # REMOVED

# Test app repo
optimizely-flutter-testapp/ios/
├── Podfile                                          # REMOVED
├── Podfile.lock                                     # REMOVED
└── Pods/                                            # REMOVED

# Test app CI
optimizely-flutter-testapp/.github/workflows/
└── ios.yml                                          # MODIFIED: remove cocoapods install step

# SDK CI
.github/workflows/
└── flutter.yml                                      # NO CHANGES needed (no pod commands)

# Dart layer — NO CHANGES
# Android layer — NO CHANGES
```

**Structure Decision**: Only the `ios/` directory structure changes. All files move from the CocoaPods-style `ios/Classes/` to the SPM-style `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/`. The Dart and Android layers are untouched.

### ObjC Bridging Files Decision

The ObjC files (`OptimizelyFlutterSdkPlugin.h`, `OptimizelyFlutterSdkPlugin.m`) are a thin bridge for CocoaPods-style plugin registration. During implementation, determine if:
1. They can be removed entirely (pure Swift SPM registration) — preferred
2. They need to be kept in a separate clang target within Package.swift

This is an implementation detail to resolve during the task execution phase.

## Complexity Tracking

No constitution violations — this section is empty.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| (none)    | —          | —                                    |

## Research Artifacts

See [research.md](research.md) for detailed findings on:
- Flutter plugin SPM integration structure
- OptimizelySwiftSDK SPM compatibility
- Source file migration approach
- Example and test app migration
- CI impact analysis

## Key Risks

1. **SPM version tag**: The podspec pins OptimizelySwiftSDK 5.4.2, but the git tag format on `swift-sdk` repo needs verification (could be `5.4.2` or `v5.4.2`).
2. **ObjC/Swift mixed target**: SPM doesn't support mixed ObjC/Swift in a single target. The ObjC bridging files need special handling.
3. **Flutter version requirement**: SPM plugin support requires Flutter 3.44+. Consumers on older Flutter versions will not be able to use this version of the SDK.
