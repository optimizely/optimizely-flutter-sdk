# Feature Specification: Add SPM Support with CocoaPods Backward Compatibility

**Feature Branch**: `001-cocoapods-to-spm-migration`

**Created**: 2026-08-20

**Status**: Draft (Revised)

**Input**: User description: "Flutter going to drop CocoaPods support. Want to move to Swift Package Manager. Support both SPM and CocoaPods. Migrate the Flutter SDK and test app gracefully."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - SDK Consumers Build iOS via SPM (Priority: P1)

A developer who integrates the Optimizely Flutter SDK into their Flutter app can build and run the iOS target using Swift Package Manager. The SDK's iOS dependency (OptimizelySwiftSDK) is resolved through SPM when the developer's Flutter tooling supports it. The developer's existing workflow (`flutter build ios`, `flutter run`) continues to work without manual SPM configuration steps.

**Why this priority**: This is the core deliverable. Flutter is deprecating CocoaPods support, and SPM readiness ensures the SDK works with future Flutter versions.

**Independent Test**: Run `flutter build ios` against a fresh Flutter app (on Flutter 3.44+) that depends on `optimizely_flutter_sdk`, and verify a successful build with OptimizelySwiftSDK resolved via SPM.

**Acceptance Scenarios**:

1. **Given** a Flutter app with `optimizely_flutter_sdk` as a dependency on Flutter 3.44+, **When** the developer runs `flutter build ios`, **Then** the build succeeds and OptimizelySwiftSDK is resolved via SPM.
2. **Given** the SDK plugin's iOS platform configuration, **When** Flutter tooling detects SPM support (Package.swift present), **Then** the OptimizelySwiftSDK package is fetched from its SPM-compatible repository and linked correctly.

---

### User Story 2 - SDK Consumers Continue Building iOS via CocoaPods (Priority: P1)

A developer on an older Flutter version (pre-3.44) or one who has not yet adopted SPM can continue building the iOS target using CocoaPods. The existing podspec remains functional and resolves the same OptimizelySwiftSDK version.

**Why this priority**: Backward compatibility is essential. Not all consumers will be on Flutter 3.44+ immediately. Dropping CocoaPods support abruptly would break existing users.

**Independent Test**: Run `flutter build ios` against a Flutter app (on any supported Flutter version) using CocoaPods, and verify the build succeeds with the same SDK functionality.

**Acceptance Scenarios**:

1. **Given** a Flutter app with `optimizely_flutter_sdk` as a dependency on Flutter <3.44, **When** the developer runs `flutter build ios`, **Then** the build succeeds using CocoaPods dependency resolution.
2. **Given** the updated podspec with new source file paths, **When** CocoaPods resolves the SDK, **Then** all Swift source files are found and compiled correctly.
3. **Given** a developer who was already using the SDK via CocoaPods, **When** they upgrade to this version, **Then** `pod install` succeeds and the app builds without changes to their Podfile.

---

### User Story 3 - Test App Works with SPM (Priority: P2)

The `optimizely-flutter-testapp` project's iOS target builds and runs using SPM. Integration tests and CI pipelines that depend on the test app continue to pass when using the SPM-based dependency path.

**Why this priority**: The test app is the SDK's validation layer. CI integration tests (`integration_ios_tests`) depend on it. The test app should validate the SPM path to ensure it works end-to-end.

**Independent Test**: Build and run the test app's iOS target from the `optimizely-flutter-testapp` repo using SPM, and verify all integration tests pass.

**Acceptance Scenarios**:

1. **Given** the test app repository with SPM-enabled Flutter, **When** a developer runs `flutter build ios` targeting iOS, **Then** the build succeeds using SPM for native dependency resolution.
2. **Given** the test app's CI pipeline configured for SPM, **When** the `integration_ios_tests` workflow runs, **Then** it completes successfully.
3. **Given** the test app's iOS project with SPM configuration added, **When** the SDK's native dependency is resolved, **Then** OptimizelySwiftSDK is fetched via SPM and the test app compiles and runs all integration tests.

---

### User Story 4 - CI Pipeline Validates Both Dependency Paths (Priority: P2)

CI workflows validate that the SDK works with both CocoaPods and SPM. The existing CocoaPods-based CI continues to work, and SPM-based builds are also verified.

**Why this priority**: CI must validate both paths to ensure neither is broken. This is essential for maintaining dual support confidence.

**Independent Test**: Trigger CI and verify all five jobs pass, with iOS builds validating SPM resolution.

**Acceptance Scenarios**:

1. **Given** the CI workflow for `build_test_ios`, **When** the job runs, **Then** it builds successfully.
2. **Given** the CI workflow for `integration_ios_tests`, **When** the job runs against the test app, **Then** integration tests pass.
3. **Given** both CocoaPods and SPM configurations exist, **When** CI runs, **Then** all five pipeline jobs pass without conflicts between the two dependency mechanisms.

---

### Edge Cases

- **Mixed CocoaPods/SPM state (Podfile + SPM-capable Flutter)**: Flutter's tooling handles resolution automatically. The SDK provides both Package.swift and podspec; Flutter picks the appropriate mechanism based on version and project configuration. No SDK-level detection or intervention is needed.
- **SPM package URL or version tag format differs from CocoaPods**: Mitigated by FR-006 — both manifests pin the same OptimizelySwiftSDK version. The SPM repository URL must match the official OptimizelySwiftSDK SPM-compatible repository.
- **Podspec source file paths after directory restructuring**: The podspec's `source_files` declaration is updated to point to the new SPM-compatible directory structure (FR-008). Existing CocoaPods users running `pod install` will pick up the new paths automatically.
- **Package.swift and podspec declare different OptimizelySwiftSDK versions**: Prevented by FR-006 and enforced by FR-014 — a CI validation check fails the build if versions diverge.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The SDK MUST declare its iOS native dependency (OptimizelySwiftSDK) using Swift Package Manager via a Package.swift file.
- **FR-002**: The SDK MUST use Flutter's official SPM integration mechanism (Package.swift in the plugin's iOS directory) to declare the native dependency.
- **FR-003**: The SDK MUST specify the OptimizelySwiftSDK version using exact pinning (`.exact("5.4.2")`) in the SPM package dependency, matching the version pinned in the podspec.
- **FR-004**: The SDK MUST retain the `optimizely_flutter_sdk.podspec` file with updated source file paths pointing to the new SPM-compatible directory structure. Both Package.swift and podspec MUST coexist.
- **FR-005**: The SDK MUST maintain all existing iOS functionality (MethodChannel handlers, logger bridge, type encoding) without any behavioral changes.
- **FR-006**: The podspec and Package.swift MUST declare the same OptimizelySwiftSDK version to prevent version drift.
- **FR-007**: The SDK's `pubspec.yaml` plugin declaration for iOS MUST remain compatible with both Flutter's SPM plugin system and CocoaPods.
- **FR-008**: Source files MUST be organized in a directory structure that is accessible from both the SPM Package.swift target and the podspec `source_files` declaration.
- **FR-009**: The SDK documentation (README.md, CLAUDE.md) MUST be updated to document both CocoaPods and SPM setup paths.
- **FR-010**: The SDK MUST retain iOS 10.0 as its minimum deployment target. The test app maintains its own minimum of iOS 13.0.
- **FR-011**: All existing SDK unit tests (`flutter test`) MUST pass with zero failures after the changes — no test regressions are acceptable.
- **FR-012**: All test app end-to-end test cases MUST pass with zero failures on both Android and iOS platforms.
- **FR-013**: All five CI pipeline jobs MUST pass: `unit_test_coverage`, `build_test_android`, `build_test_ios`, `integration_android_tests`, and `integration_ios_tests`. The changes MUST NOT break any existing CI workflow.
- **FR-014**: CI MUST include a validation check that verifies the OptimizelySwiftSDK version declared in Package.swift matches the version declared in the podspec. The build MUST fail if the versions diverge.

### Key Entities

- **Package.swift**: SPM package manifest declaring the OptimizelySwiftSDK dependency and linking the plugin's Swift source files. Coexists with the podspec.
- **optimizely_flutter_sdk.podspec**: Updated CocoaPods spec with source file paths pointing to the new SPM-compatible directory layout.
- **Plugin Registration**: The mechanism by which Flutter discovers and loads the native iOS plugin, which must work through both SPM and CocoaPods.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A fresh Flutter project (3.44+) depending on `optimizely_flutter_sdk` builds for iOS successfully via SPM.
- **SC-002**: A fresh Flutter project (pre-3.44 or CocoaPods-configured) depending on `optimizely_flutter_sdk` builds for iOS successfully via CocoaPods.
- **SC-003**: All existing SDK unit tests (`flutter test`) pass with zero failures — no test regressions.
- **SC-004**: All five CI pipeline jobs pass: `unit_test_coverage`, `build_test_android`, `build_test_ios`, `integration_android_tests`, and `integration_ios_tests`.
- **SC-005**: All test app end-to-end test cases pass on both Android and iOS platforms with zero failures.
- **SC-006**: Developer setup time for iOS does not increase — no new manual steps required beyond `flutter pub get` and `flutter build ios` for either dependency mechanism.
- **SC-007**: The podspec and Package.swift both reference the same OptimizelySwiftSDK version (no version drift).

## Clarifications

### Session 2026-08-20

- Q: What should the minimum iOS deployment target be after the SPM migration? → A: SDK keeps iOS 10.0; test app keeps iOS 13.0 (independent targets).
- Q: Should the SDK support both CocoaPods and SPM during a transition period? → A: ~~Clean cut~~ **Revised**: Support both CocoaPods and SPM simultaneously. Keep the podspec with updated paths alongside the new Package.swift.
- Q: How should the OptimizelySwiftSDK version be pinned in SPM Package.swift? → A: Exact version pinning (`.exact("5.4.2")`), matching current podspec behavior.
- Q: What specific changes are needed in the `optimizely-flutter-testapp` repo? → A: CI workflow updates + add SPM configuration to the test app's iOS project.
- Q: For mixed CocoaPods/SPM states, does the SDK need intervention logic? → A: No. Flutter's tooling handles resolution automatically; the SDK just provides both manifests.
- Q: How should version parity between Package.swift and podspec (FR-006) be enforced? → A: CI validation check that fails the build if versions diverge.
- Q: Should this release include deprecation notices or migration guidance for CocoaPods users? → A: No — premature until Flutter officially drops CocoaPods.

## Assumptions

- The OptimizelySwiftSDK already publishes SPM-compatible releases (it does — the library supports SPM via its Package.swift).
- Flutter's SPM integration for plugins is stable enough for production use (Flutter has been shipping SPM support and is actively deprecating CocoaPods).
- The SDK retains iOS 10.0 as its minimum deployment target; the test app uses iOS 13.0. These are independent and intentional.
- Source files can be organized in a single directory structure (SPM layout) that both Package.swift and podspec reference via their respective path declarations.
- The example app (`example/`) within the SDK repo will work with whichever dependency mechanism the local Flutter version prefers.
- macOS plugin platform (declared but experimental in pubspec.yaml) is out of scope for this effort.
- The `optimizely-flutter-testapp` repository is accessible and modifiable as part of this effort. Changes include CI workflow updates and adding SPM configuration to the test app's iOS project.
- CocoaPods support will be maintained for as long as Flutter officially supports it, then can be dropped in a future release. No deprecation notices or migration guides are included in this release — that will be addressed closer to Flutter's actual CocoaPods removal.
