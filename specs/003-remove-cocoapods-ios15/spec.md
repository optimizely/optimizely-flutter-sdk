# Feature Specification: Remove CocoaPods Support and Raise Minimum iOS to 15.0

**Feature Branch**: `003-remove-cocoapods-ios15`

**Created**: 2026-10-12

**Status**: Draft

**Input**: User description: "specify the ticket 1" — [Flutter] Remove CocoaPods support and raise minimum iOS to 15.0. OptimizelySwiftSDK 6.0.0 (Oct 7, 2026) dropped CocoaPods distribution and raised its minimum to iOS 15.0. The Flutter SDK must become SPM-only before it can adopt 6.0.0. Includes updating the `optimizely-flutter-testapp` repo.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - SDK Consumers Build iOS via SPM Only (Priority: P1)

A developer integrating `optimizely_flutter_sdk` into a Flutter app on an SPM-capable Flutter version builds and runs the iOS target exactly as today (`flutter pub get`, `flutter build ios`). The plugin ships only an SPM manifest; no CocoaPods artifacts remain in the published package. All SDK features behave identically to the previous release.

**Why this priority**: This is the prerequisite for adopting OptimizelySwiftSDK 6.0.0, which has no CocoaPods distribution. Without it the Flutter SDK is stuck on the 5.x native line.

**Independent Test**: Create a fresh Flutter app on the minimum supported Flutter version with iOS deployment target 15.0, add the SDK as a dependency, run `flutter build ios`, and verify the build succeeds and the native SDK is resolved through SPM.

**Acceptance Scenarios**:

1. **Given** a Flutter app on the minimum supported Flutter version with iOS target 15.0, **When** the developer runs `flutter build ios`, **Then** the build succeeds with the native Optimizely dependency resolved via SPM.
2. **Given** the published SDK package, **When** its iOS directory is inspected, **Then** it contains no CocoaPods spec and no source files used only by CocoaPods builds.
3. **Given** an app that previously worked with the SDK, **When** it upgrades to this version, **Then** initialize, decide (sync and async), track, user context, ODP, notification listeners, and logger forwarding behave identically on iOS.

---

### User Story 2 - Developers Below the New Minimums Get a Clear Signal (Priority: P1)

A developer whose app targets iOS below 15.0, or whose Flutter version cannot consume SPM-only plugins, is told clearly what to change — through version constraints, a build-time error that names the requirement, and a migration note in the README and CHANGELOG — rather than hitting an obscure native build failure.

**Why this priority**: This is a breaking change. Constitution (Platform Compatibility Standards) requires raised minimums to ship as a major version, and consumers need a clear upgrade path.

**Independent Test**: Attempt to depend on the SDK from (a) an app with iOS target 14.0 and (b) a project on a Flutter version below the new minimum; verify (a) Flutter raises the app's deployment target to 15.0 and reports it, and (b) dependency resolution fails naming the Flutter constraint, and that the README migration note explains the fix.

**Acceptance Scenarios**:

1. **Given** an app with iOS deployment target below 15.0, **When** it builds with the SDK, **Then** Flutter raises the app's iOS deployment target to 15.0, prints "Updating minimum iOS deployment target to 15.0", and the build succeeds (verified 2026-10-12).
2. **Given** a project on a Flutter version below the declared minimum, **When** the developer runs `flutter pub get`, **Then** dependency resolution fails, naming the Flutter version constraint.
3. **Given** the README and CHANGELOG, **When** a developer reads the upgrade section, **Then** it lists the new iOS and Flutter minimums and the steps to migrate an app from CocoaPods to SPM.

---

### User Story 3 - Test App Validates the SPM-Only SDK (Priority: P2)

The `optimizely-flutter-testapp` repository builds its iOS target via SPM with deployment target 15.0, and its integration suite passes against the SPM-only SDK. Because SDK CI pulls the test app's `master` branch, test-app changes land before (or are coordinated with) the SDK change.

**Why this priority**: The test app is the end-to-end validation layer for `integration_ios_tests`. If it still depends on CocoaPods or iOS 13, SDK CI breaks.

**Independent Test**: In the test-app repo, run the iOS build and integration suite against the SDK feature branch; verify all tests pass with no CocoaPods artifacts present.

**Acceptance Scenarios**:

1. **Given** the test app with CocoaPods artifacts removed and iOS target 15.0, **When** its iOS CI runs, **Then** the build and all integration tests pass.
2. **Given** the SDK feature branch and the updated test app, **When** SDK CI triggers `integration_ios_tests`, **Then** the job passes.
3. **Given** the test app's Android target, **When** its Android CI runs, **Then** it passes unchanged.

---

### User Story 4 - Maintainers Have One iOS Dependency Path (Priority: P3)

SDK maintainers maintain a single iOS dependency manifest. CI no longer runs a podspec/SPM version-parity check, the in-repo example app builds via SPM at iOS 15.0, and project guidance (README, CLAUDE.md, constitution) no longer references CocoaPods for iOS.

**Why this priority**: Reduces maintenance and removes a CI gate that has no purpose once only one manifest exists. Lower priority because it does not affect consumers.

**Independent Test**: Search the repo for iOS CocoaPods references and run full CI; verify none remain outside historical records (CHANGELOG, prior specs) and all CI jobs pass.

**Acceptance Scenarios**:

1. **Given** the SDK repo after the change, **When** CI runs, **Then** there is no version-parity job and all remaining jobs pass.
2. **Given** the in-repo example app, **When** a developer runs it on iOS, **Then** it builds via SPM with deployment target 15.0.
3. **Given** README, CLAUDE.md, and the constitution, **When** reviewed, **Then** they describe SPM as the only iOS integration path and iOS 15.0 as the minimum.

---

### Edge Cases

- **App has an existing Podfile with other pods**: Other plugins or pods may still use CocoaPods; Flutter's tooling supports mixed apps where SPM-capable plugins resolve via SPM. The SDK makes no assumptions about the app's other dependencies.
- **SPM disabled in the developer's Flutter config**: With no CocoaPods spec, the plugin cannot be integrated. The migration note must tell developers to ensure SPM is enabled.
- **macOS plugin platform**: macOS is experimental (constitution, Platform Compatibility Standards) and its plugin is a template stub. It moves to SPM too (Package.swift at macOS 10.15, Flutter 3.44's minimum), its podspec is removed, and the macOS example and test apps drop CocoaPods. Its behaviour is unchanged.
- **Objective-C registration shim**: The iOS Objective-C plugin files exist only for CocoaPods builds (already excluded from the SPM target). They are removed with CocoaPods; registration continues through the Swift plugin class already declared in `pubspec.yaml`.
- **Test app on `master` lags the SDK**: If the SDK change merges first, `integration_ios_tests` fails. Mitigated by merging the test-app change first or temporarily pointing SDK CI at the test-app feature branch, then reverting.
- **Native SDK version**: This change keeps OptimizelySwiftSDK at its current version (5.4.2); the 6.0.0 bump is a separate ticket (Ticket 2) and must not be bundled (constitution VIII.1).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The SDK MUST NOT ship a CocoaPods spec for iOS; SPM MUST be the only iOS dependency mechanism.
- **FR-002**: The SDK MUST remove iOS source files used only by CocoaPods builds (the Objective-C registration shim and its header).
- **FR-003**: The SDK MUST declare iOS 15.0 as its minimum iOS platform.
- **FR-004**: The SDK MUST declare a minimum Flutter version that resolves SPM-only plugins by default (Flutter 3.44, the version CI already uses with SPM).
- **FR-005**: The SDK MUST keep OptimizelySwiftSDK pinned at its current exact version (5.4.2) in this change.
- **FR-006**: The SDK MUST preserve all existing iOS behaviour (MethodChannel handlers, logger bridge, type encoding, main-thread result dispatch) with no Dart public API changes.
- **FR-007**: CI MUST remove the podspec/SPM version-parity check and any job dependencies on it; all remaining CI jobs MUST pass.
- **FR-008**: The in-repo example app MUST build on iOS via SPM with deployment target 15.0 and no CocoaPods artifacts.
- **FR-009**: The `optimizely-flutter-testapp` iOS target MUST build via SPM with deployment target 15.0, with CocoaPods artifacts removed, and its iOS and Android CI MUST pass.
- **FR-010**: README MUST state the new iOS and Flutter minimums and include a CocoaPods-to-SPM migration note for app developers.
- **FR-011**: CLAUDE.md and the constitution (Principle VIII and the Minimum Platform Versions table) MUST be updated to remove iOS CocoaPods references and state iOS 15.0; the constitution amendment MUST follow its amendment procedure.
- **FR-012**: The change MUST be released only as part of a new major SDK version (4.0.0), together with Ticket 2; no intermediate release may ship this change alone.
- **FR-013**: All existing unit tests MUST pass and `flutter analyze` MUST report zero issues.

### Key Entities

- **iOS SPM manifest**: The single remaining declaration of the plugin's iOS target, its minimum iOS platform, and the pinned native Optimizely dependency.
- **CocoaPods spec (iOS)**: Removed. Previously a parallel declaration of the same dependency.
- **Version-parity check**: CI gate comparing the two manifests. Removed, as only one manifest remains.
- **Test app**: External repository consumed by SDK CI from its `master` branch; must be migrated in lockstep.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A fresh app on the minimum supported Flutter version with iOS target 15.0 builds for iOS on the first attempt with no manual steps beyond `flutter pub get` and `flutter build ios`.
- **SC-002**: Zero iOS CocoaPods references remain in the SDK and test-app repos outside historical records (CHANGELOG, prior specs).
- **SC-003**: 100% of existing unit tests and test-app integration tests pass on both platforms.
- **SC-004**: All SDK CI jobs pass on the feature branch.
- **SC-005**: A developer below the new minimums can identify what to change from the error message or README within 5 minutes.

## Assumptions

- Flutter 3.44+ resolves SPM-capable plugins by default (README already states this; CI already uses 3.44.0).
- Existing SPM integration from spec 001 (Package.swift, directory layout, Swift plugin registration) is correct and needs no structural change beyond the platform minimum.
- The Windows plugin platform is out of scope (it has no CocoaPods files).
- Android is unaffected except for test-app CI continuing to pass.
- The release (version files, CHANGELOG, 4.0.0) is handled by Ticket 3, not this change; this change only adds README/migration content.
- Xcode 27 runner migration belongs to Ticket 2 (required by OptimizelySwiftSDK 6.0.0), not this change.
