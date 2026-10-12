# Implementation Plan: Remove CocoaPods Support and Raise Minimum iOS to 15.0

**Branch**: `003-remove-cocoapods-ios15` | **Date**: 2026-10-12 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/003-remove-cocoapods-ios15/spec.md`

## Summary

Make the plugin's iOS integration SPM-only, so a later change (Ticket 2) can adopt OptimizelySwiftSDK 6.0.0, which has no CocoaPods distribution. The work:
- delete the iOS podspec and the Objective-C shim used only by CocoaPods
- raise the iOS minimum to 15.0 and the Flutter minimum to 3.44.0
- de-CocoaPod the in-repo example app
- drop the now-pointless podspec/SPM version-parity CI job
- update docs and the constitution

The `optimizely-flutter-testapp` repo gets the same iOS migration plus a Flutter 3.16 → 3.44 CI upgrade, and merges first. No Dart, Swift or Java logic changes.

## Technical Context

**Language/Version**: Dart (Flutter ≥3.44.0), Swift 5.0 (swift-tools-version 5.9), build config (SPM manifest, Xcode project, GitHub Actions YAML)

**Primary Dependencies**: OptimizelySwiftSDK 5.4.2 (unchanged, via SPM), Flutter SPM plugin integration

**Storage**: N/A

**Testing**: `flutter test`, `flutter analyze`, example app iOS build, testapp integration suite (`integration_test/app_test.dart`) on iOS and Android

**Target Platform**: iOS 15.0+ (raised from 10.0); Android unchanged (API 21+)

**Project Type**: Flutter plugin (library) + external test app repo

**Performance Goals**: N/A (no runtime change)

**Constraints**:
- No public Dart API changes
- Native SDK version unchanged (constitution VIII.1)
- Ships only in 4.0.0 together with Ticket 2

**Scale/Scope**: About 15 files in the SDK repo and about 8 in the testapp repo. Two PRs, testapp first.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle / Standard | Status | Notes |
|---|---|---|
| I. Bridge Pattern Integrity | ✅ N/A | No feature added; the bridge is untouched. |
| II. Response Object Pattern | ✅ N/A | No method changes. |
| III. Platform Parity | ✅ Pass | Only the iOS build mechanism changes; runtime behaviour is identical on both platforms. Android is untouched. |
| IV. Type Safety | ✅ N/A | |
| V. Thread Safety | ✅ Pass | `mainThreadResult` lives in the Swift plugin, which stays. Only the ObjC shim is removed. |
| VI. Multi-Instance | ✅ N/A | |
| VII. Version Synchronisation | ✅ Pass | No SDK version bump in this change; Ticket 3 bumps all three locations to 4.0.0. |
| VIII. Native SDK Version Pinning | ⚠️ Amend | The swift-sdk version stays at 5.4.2 (no upgrade bundled). The principle text names the podspec as a source of truth, so it's amended in this change (research R7). |
| Platform Compatibility: raising iOS minimum = major bump | ✅ Pass | Spec FR-012: released only as 4.0.0. |
| Testing: tests accompany code changes | ✅ Pass (justified) | No Dart/native logic changes, so there are no new unit tests. Verification is the existing `flutter test`, the example app build, and the testapp integration suite on both platforms (quickstart.md). |
| CI: all jobs pass | ✅ Pass | One job (`version_drift_check`) is removed because it has no remaining purpose. The five constitution-listed jobs remain. |
| Licensing | ✅ N/A | No new source files. |
| Branching | ✅ Pass | Feature branch; PR targets `master`. Suggested git branch: `feature/remove-cocoapods-ios15`. |

**Post-design re-check**: unchanged. The Principle VIII amendment is part of the deliverable (FR-011), not a violation.

## Project Structure

### Documentation (this feature)

```text
specs/003-remove-cocoapods-ios15/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── platform-requirements.md
└── tasks.md             # /speckit-tasks
```

### Source Code

```text
# optimizely-flutter-sdk (PR 2 — after testapp)
pubspec.yaml                                   # flutter: ">=3.44.0"
ios/
├── optimizely_flutter_sdk.podspec             # DELETE
└── optimizely_flutter_sdk/
    ├── Package.swift                          # .iOS("15.0"); drop exclude + ObjC comment
    └── Sources/optimizely_flutter_sdk/
        ├── OptimizelyFlutterSdkPlugin.m       # DELETE
        └── include/                           # DELETE
example/ios/
├── Podfile                                    # DELETE
├── Flutter/Debug.xcconfig, Release.xcconfig   # drop Pods #include
└── Runner.xcodeproj/project.pbxproj           # pod deintegrate; target 15.0
.github/
├── scripts/check-version-drift.sh             # DELETE
├── workflows/flutter.yml                      # drop version_drift_check job + needs
└── copilot-instructions.md                    # iOS 15.0+
README.md, CLAUDE.md                           # SPM-only, iOS 15, Flutter 3.44, migration note
.specify/memory/constitution.md                # v1.2.0 amendment

# optimizely-flutter-testapp (PR 1 — merges first)
.github/workflows/ios.yml                      # Flutter 3.44.0 + enable SPM
.github/workflows/android.yml                  # Flutter 3.44.0
ios/Podfile                                    # DELETE
ios/Flutter/Debug.xcconfig, Release.xcconfig   # drop Pods #include
ios/Runner.xcodeproj/project.pbxproj           # pod deintegrate; SPM ref; target 15.0
```

**Structure Decision**: Existing layout from spec 001 is kept; this change only deletes files and edits config. Not touched: macOS (`macos/`, `example/macos/Podfile`), Android, and `lib/`.

## Delivery Order

1. **Testapp PR**: works against current SDK `master` (SPM resolves its existing `Package.swift`), so it merges independently.
2. **SDK PR**: after the testapp merges, `integration_ios_tests` exercises the SPM-only SDK.
3. No release until Ticket 2 merges; Ticket 3 cuts 4.0.0.

## Complexity Tracking

No violations to justify.
