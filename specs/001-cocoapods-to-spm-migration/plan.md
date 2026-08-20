# Implementation Plan: Add SPM Support with CocoaPods Backward Compatibility

**Branch**: `001-cocoapods-to-spm-migration` | **Date**: 2026-08-20 (Revised) | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-cocoapods-to-spm-migration/spec.md`

## Summary

Add Swift Package Manager support to the Optimizely Flutter SDK's iOS plugin while retaining CocoaPods backward compatibility. Source files move from `ios/Classes/` to the SPM-standard layout at `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/`. Both the new Package.swift and the existing podspec (with updated source paths) reference the same files. Flutter selects the dependency mechanism based on version and configuration. The Dart and Android layers are unaffected.

## Technical Context

**Language/Version**: Dart >=2.16.2 <4.0.0, Swift 5.0+, Java/Kotlin 2.1.0

**Primary Dependencies**: Flutter SDK (stable), OptimizelySwiftSDK 5.4.2 (via SPM AND CocoaPods), android-sdk (unchanged via Gradle)

**Storage**: N/A

**Testing**: `flutter test` (Dart unit tests), `flutter test integration_test` (e2e via test app)

**Target Platform**: iOS 10.0+ (SDK), iOS 13.0 (test app), Android API 21+ (unchanged)

**Project Type**: Flutter plugin (cross-platform library wrapping native SDKs)

**Performance Goals**: N/A — infrastructure change, no behavioral changes

**Constraints**: Must maintain backward compatibility with CocoaPods. iOS minimum stays at 10.0. All existing tests must pass. Both dependency mechanisms must pin the same OptimizelySwiftSDK version.

**Scale/Scope**: 2 repositories (SDK + test app), ~7 Swift/ObjC source files to move, 1 podspec to update, 1 Package.swift to create

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
| VII. Version Synchronisation | PASS | No version bump for this change (infra). |
| VIII. Native SDK Version Pinning | PASS | Version pinning preserved in BOTH files: `.exact("5.4.2")` in Package.swift AND `'5.4.2'` in podspec. Source-of-truth files now include both. |
| IX. CMAB & Async Decide | PASS | No changes to CMAB functionality. |
| X. ODP Integration | PASS | No changes to ODP functionality. |
| XI. Event Batching Configuration | PASS | No changes to event batching. |
| XII. Logger Bridge Architecture | PASS | Logger channel and bridge files are moved but unchanged. |

**Gate Result**: ALL PASS — no violations.

**Post-Design Re-Check**: ALL PASS — dual support adds a version synchronization requirement across two files, which strengthens Principle VIII rather than violating it. FR-014 (CI version drift check) provides automated enforcement.

## Project Structure

### Documentation (this feature)

```text
specs/001-cocoapods-to-spm-migration/
├── plan.md              # This file
├── research.md          # Phase 0 output — dual support research
├── data-model.md        # Phase 1 output — file structure changes
├── quickstart.md        # Phase 1 output — validation guide
└── tasks.md             # Phase 2 output (created by /speckit-tasks)
```

### Source Code (repository root)

```text
# SDK repo — iOS layer changes
ios/
├── optimizely_flutter_sdk.podspec                   # UPDATED: source_files path changed
├── optimizely_flutter_sdk/                          # NEW: SPM package directory
│   ├── Package.swift                                # NEW: SPM manifest
│   └── Sources/
│       └── optimizely_flutter_sdk/                  # NEW: SPM sources
│           ├── include/
│           │   └── optimizely_flutter_sdk/
│           │       └── OptimizelyFlutterSdkPlugin.h  # MOVED from Classes/
│           ├── OptimizelyFlutterSdkPlugin.m           # MOVED from Classes/ (import path updated)
│           ├── SwiftOptimizelyFlutterSdkPlugin.swift  # MOVED from Classes/
│           ├── OptimizelyFlutterLogger.swift           # MOVED from Classes/
│           ├── Constants.swift                         # MOVED from Classes/HelperClasses/
│           ├── OptimizelyConfig+Extension.swift        # MOVED from Classes/HelperClasses/
│           └── Utils.swift                             # MOVED from Classes/HelperClasses/
├── Classes/                                          # REMOVED (files moved to SPM layout)
└── Assets/                                           # REMOVED (empty)

# Example app — NO CHANGES (keeps Podfile for CocoaPods backward compat)
example/ios/
├── Podfile                                          # KEPT
├── Podfile.lock                                     # KEPT (regenerated on next pod install)
└── Pods/                                            # KEPT

# Test app — CI updates + SPM configuration added
optimizely-flutter-testapp/ios/
├── Podfile                                          # KEPT for CocoaPods fallback
├── Podfile.lock                                     # KEPT
└── Pods/                                            # KEPT

# Test app CI
optimizely-flutter-testapp/.github/workflows/
└── ios.yml                                          # UPDATED: SPM-compatible build steps

# SDK CI
.github/workflows/
└── flutter.yml                                      # UPDATED: version drift check step added (FR-014)

# Dart layer — NO CHANGES
# Android layer — NO CHANGES
```

**Structure Decision**: Source files move from `ios/Classes/` to `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/` (SPM-standard layout). The podspec's `source_files` is updated to point to the new location. Both dependency mechanisms share the same physical files. ObjC header goes into an `include/` subdirectory per SPM convention.

## Complexity Tracking

No constitution violations — this section is empty.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| (none)    | —          | —                                    |

## Research Artifacts

See [research.md](research.md) for detailed findings on:
- Flutter plugin dual SPM + CocoaPods support (official recommendation)
- Source file layout for dual support
- ObjC bridging file handling in SPM
- Podspec path updates
- OptimizelySwiftSDK SPM compatibility
- Version synchronization requirements

## Key Risks

1. **SPM version tag**: The podspec pins OptimizelySwiftSDK 5.4.2, but the git tag format on `swift-sdk` repo needs verification (could be `5.4.2` or `v5.4.2`).
2. **ObjC header search paths**: SPM requires headers in an `include/` subdirectory with `cSettings`. This must be validated against both SPM and CocoaPods builds.
3. **Podspec source path**: After moving files, `pod lib lint` must pass to confirm CocoaPods can still find all sources. Note: the current glob is `'Classes/**/*'` (all types), so the updated path must preserve this pattern.
4. **Version drift**: Two files now declare the native SDK version. **Mitigated by FR-014**: a CI validation check MUST fail the build if versions diverge.
5. **Mixed CocoaPods/SPM state**: Resolved — Flutter's tooling handles resolution automatically. No SDK-level detection or intervention needed.
