# Feature Specification: CocoaPods to Swift Package Manager Migration

**Feature Branch**: `001-cocoapods-to-spm-migration`

**Created**: 2026-08-20

**Status**: Draft

**Input**: User description: "Flutter going to drop CocoaPods support. Want to move Swift Package Manager. Migrate the Flutter SDK and test app from CocoaPods to SPM gracefully. Follow web and Flutter official guidelines for the migration."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - SDK Consumers Build iOS Without CocoaPods (Priority: P1)

A developer who integrates the Optimizely Flutter SDK into their Flutter app can build and run the iOS target without CocoaPods installed. The SDK's iOS dependency (OptimizelySwiftSDK) is resolved through Swift Package Manager instead. The developer's existing workflow (`flutter build ios`, `flutter run`) continues to work without manual SPM configuration steps.

**Why this priority**: This is the core deliverable. Without this, the SDK cannot function once Flutter drops CocoaPods support. It directly unblocks all iOS users.

**Independent Test**: Can be tested by removing CocoaPods from the build environment, running `flutter build ios` against a fresh Flutter app that depends on `optimizely_flutter_sdk`, and verifying a successful build with OptimizelySwiftSDK resolved via SPM.

**Acceptance Scenarios**:

1. **Given** a Flutter app with `optimizely_flutter_sdk` as a dependency, **When** the developer runs `flutter build ios` on a machine without CocoaPods, **Then** the build succeeds and OptimizelySwiftSDK is resolved via SPM.
2. **Given** the SDK plugin's iOS platform configuration, **When** Flutter tooling resolves iOS dependencies, **Then** the OptimizelySwiftSDK package is fetched from its SPM-compatible repository and linked correctly.
3. **Given** a developer upgrades from a prior CocoaPods-based version of the SDK, **When** they run `flutter pub get` and `flutter build ios`, **Then** the migration to SPM happens transparently without manual intervention beyond cleaning old CocoaPods artifacts.

---

### User Story 2 - Test App Migrated to SPM (Priority: P1)

The `optimizely-flutter-testapp` project's iOS target builds and runs using SPM instead of CocoaPods. Integration tests and CI pipelines that depend on the test app continue to pass.

**Why this priority**: The test app is the SDK's validation layer. CI integration tests (`integration_ios_tests`) depend on it. Without migrating it, the team cannot verify the SDK works end-to-end on iOS.

**Independent Test**: Can be tested by building and running the test app's iOS target from the `optimizely-flutter-testapp` repo after removing Podfile/Pods, and verifying all integration tests pass.

**Acceptance Scenarios**:

1. **Given** the test app repository, **When** a developer runs `flutter build ios` or `flutter run` targeting iOS, **Then** the build succeeds without CocoaPods and uses SPM for native dependency resolution.
2. **Given** the test app's CI pipeline, **When** the `integration_ios_tests` workflow runs, **Then** it completes successfully with SPM-based dependency resolution.

---

### User Story 3 - Clean Removal of CocoaPods Artifacts (Priority: P2)

All CocoaPods-specific configuration files (Podfile, Podfile.lock, .podspec, Pods directory references) are removed from both the SDK and test app repositories. No orphaned CocoaPods configuration remains that could confuse developers or tooling.

**Why this priority**: Leaving CocoaPods artifacts creates confusion and maintenance burden. However, the migration must work first (P1) before cleanup matters.

**Independent Test**: Can be tested by searching both repositories for CocoaPods references (Podfile, .podspec, pod commands) and verifying none remain, then building successfully.

**Acceptance Scenarios**:

1. **Given** the SDK repository after migration, **When** searching for CocoaPods artifacts (`Podfile`, `*.podspec`, `Pods/` references), **Then** none are found.
2. **Given** the test app repository after migration, **When** searching for CocoaPods artifacts, **Then** none are found (Podfile, Podfile.lock, Pods directory are removed).
3. **Given** the SDK's CLAUDE.md and documentation, **When** reviewing setup instructions, **Then** all references to `pod install` are removed or replaced with SPM equivalents.

---

### User Story 4 - CI Pipeline Adapted for SPM (Priority: P2)

CI workflows (`build_test_ios`, `integration_ios_tests`) are updated to work without CocoaPods. Build steps that previously ran `pod install` are removed or replaced. SPM dependency caching is configured for reasonable build times.

**Why this priority**: CI must pass for any PR to merge. This is essential but follows from the migration itself being complete.

**Independent Test**: Can be tested by triggering the CI pipeline on a branch with SPM changes and verifying all iOS-related jobs pass.

**Acceptance Scenarios**:

1. **Given** the CI workflow for `build_test_ios`, **When** the job runs, **Then** it builds successfully without any `pod install` step.
2. **Given** the CI workflow for `integration_ios_tests`, **When** the job runs against the migrated test app, **Then** integration tests pass with SPM dependency resolution.

---

### Edge Cases

- What happens when a developer has an existing project with cached CocoaPods artifacts (Pods/ directory, Podfile.lock) from a prior SDK version and upgrades?
- How does the migration behave when the developer's Xcode version does not support the minimum SPM features required?
- What happens if the OptimizelySwiftSDK SPM package URL or version tag format differs from the CocoaPods version specifier?
- How does the SDK handle a scenario where Flutter's own SPM migration tooling is partially adopted (mixed CocoaPods/SPM state during Flutter's transition period)?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The SDK MUST declare its iOS native dependency (OptimizelySwiftSDK) using Swift Package Manager configuration instead of a CocoaPods podspec.
- **FR-002**: The SDK MUST use Flutter's official SPM integration mechanism (Package.swift in the plugin's iOS directory) to declare the native dependency.
- **FR-003**: The SDK MUST specify the OptimizelySwiftSDK version using exact pinning (`.exact("5.4.2")`) in the SPM package dependency, matching the version previously pinned in the podspec.
- **FR-004**: The SDK MUST remove the `optimizely_flutter_sdk.podspec` file from the `ios/` directory. This is a clean cut — no dual CocoaPods/SPM support period.
- **FR-005**: The SDK MUST maintain all existing iOS functionality (MethodChannel handlers, logger bridge, type encoding) without any behavioral changes.
- **FR-006**: The test app MUST remove its Podfile, Podfile.lock, and Pods directory and rely solely on SPM for iOS dependency resolution.
- **FR-007**: The SDK's `pubspec.yaml` plugin declaration for iOS MUST remain compatible with Flutter's SPM plugin system.
- **FR-008**: All CI workflows involving iOS builds MUST be updated to remove CocoaPods steps and work with SPM.
- **FR-009**: The SDK documentation (README.md, CLAUDE.md) MUST be updated to remove CocoaPods references and reflect SPM-based setup instructions.
- **FR-010**: The SDK MUST retain iOS 10.0 as its minimum deployment target. The test app maintains its own minimum of iOS 13.0.

- **FR-011**: All existing SDK unit tests (`flutter test`) MUST pass with zero failures after the migration — no test regressions are acceptable.
- **FR-012**: All test app end-to-end test cases MUST pass with zero failures after the migration on both Android and iOS platforms.
- **FR-013**: All five CI pipeline jobs MUST pass on the migration PR: `unit_test_coverage`, `build_test_android`, `build_test_ios`, `integration_android_tests`, and `integration_ios_tests`. The migration MUST NOT break any existing CI workflow.

### Key Entities

- **Package.swift**: SPM package manifest that replaces the podspec, declaring the OptimizelySwiftSDK dependency and linking the plugin's Swift source files.
- **Plugin Registration**: The mechanism by which Flutter discovers and loads the native iOS plugin, which must work through SPM instead of CocoaPods.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A fresh Flutter project depending on `optimizely_flutter_sdk` builds for iOS successfully without CocoaPods installed on the build machine.
- **SC-002**: All existing SDK unit tests (`flutter test`) pass with zero failures — no test regressions.
- **SC-003**: All five CI pipeline jobs pass on the migration PR: `unit_test_coverage`, `build_test_android`, `build_test_ios`, `integration_android_tests`, and `integration_ios_tests`.
- **SC-004**: All test app end-to-end test cases pass on both Android and iOS platforms with zero failures.
- **SC-005**: Zero CocoaPods-specific files remain in either the SDK or test app repositories after migration.
- **SC-006**: Developer setup time for iOS does not increase — no new manual steps are required beyond `flutter pub get` and `flutter build ios`.

## Clarifications

### Session 2026-08-20

- Q: What should the minimum iOS deployment target be after the SPM migration? → A: SDK keeps iOS 10.0; test app keeps iOS 13.0 (independent targets).
- Q: Should the SDK support both CocoaPods and SPM during a transition period? → A: Clean cut — CocoaPods removed entirely in this release, no dual-support period.
- Q: How should the OptimizelySwiftSDK version be pinned in SPM Package.swift? → A: Exact version pinning (`.exact("5.4.2")`), matching current podspec behavior.

## Assumptions

- The OptimizelySwiftSDK already publishes SPM-compatible releases (it does — the library supports SPM via its Package.swift).
- Flutter's SPM integration for plugins is stable enough for production use (Flutter has been shipping SPM support and is actively deprecating CocoaPods).
- The SDK retains iOS 10.0 as its minimum deployment target; the test app uses iOS 13.0. These are independent and intentional.
- The example app (`example/`) within the SDK repo, if it has iOS-specific CocoaPods setup, will also be migrated as part of this effort.
- macOS plugin platform (declared but experimental in pubspec.yaml) is out of scope for this migration unless it shares the same CocoaPods configuration.
- The `optimizely-flutter-testapp` repository is accessible and modifiable as part of this migration effort.
