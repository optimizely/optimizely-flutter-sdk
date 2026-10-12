---

description: "Task list for removing CocoaPods support and raising minimum iOS to 15.0"
---

# Tasks: Remove CocoaPods Support and Raise Minimum iOS to 15.0

**Input**: Design documents from `/specs/003-remove-cocoapods-ios15/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/platform-requirements.md, quickstart.md

**Tests**: No new test code. The spec has no logic changes; verification is the existing `flutter test`/`flutter analyze`, the example app build, and the testapp integration suite (quickstart.md).

**Organization**: Grouped by user story. **Phase order differs from priority order**: US3 (testapp, P2) runs first, because SDK CI builds testapp `master` (plan.md → Delivery Order).

**Repos**: Paths prefixed `optimizely-flutter-testapp/` are in the sibling testapp repo (`/Users/muzahidul.islam/workspace/optimizely-flutter-testapp`). All other paths are relative to the SDK repo root (`/Users/muzahidul.islam/workspace/optimizely-flutter-sdk`).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US4)

---

## Phase 1: Setup

**Purpose**: Branches and local toolchain.

- [X] T001 In the SDK repo, create branch `feature/remove-cocoapods-ios15` from an up-to-date `master` (`git checkout master && git pull && git checkout -b feature/remove-cocoapods-ios15`)
- [X] T002 [P] In the testapp repo, create branch `feature/spm-ios15` from an up-to-date `master`. The local checkout is currently on `ci/ios-single-entrypoint`, so switch first: `git checkout master && git pull && git checkout -b feature/spm-ios15`
- [X] T003 [P] Verify local Flutter is ≥3.44 (`flutter --version`) and SPM is enabled (`flutter config --enable-swift-package-manager`)

---

## Phase 2: User Story 3 — Test App Validates the SPM-Only SDK (Priority: P2, runs first) → testapp PR

**Goal**: The testapp builds iOS via SPM at iOS 15.0, with CI on Flutter 3.44, and passes against current SDK `master`.

**Independent Test**: quickstart.md §1. iOS build with no `Pods/`; integration suite green on iOS and Android.

- [X] T004 [US3] In `optimizely-flutter-testapp/.github/workflows/ios.yml`, change `flutter-version: '3.16.0'` to `'3.44.0'`. Add a step named `Enable Swift Package Manager` that runs `flutter config --enable-swift-package-manager`, immediately before the `Install Flutter dependencies` step. Do NOT touch the existing `inputs.tags` bug (research R5).
- [X] T005 [P] [US3] In `optimizely-flutter-testapp/.github/workflows/android.yml`, change `flutter-version: '3.16.0'` to `'3.44.0'`
- [X] T006 [US3] In `optimizely-flutter-testapp/ios/`, run `pod deintegrate`. This removes `Pods_Runner.framework`, the `Pods` group, `Pods-Runner.*.xcconfig` refs and the `[CP]` phases from `ios/Runner.xcodeproj/project.pbxproj`. Then delete `optimizely-flutter-testapp/ios/Podfile` (and local untracked `Podfile.lock`/`Pods/` if present).
- [X] T007 [P] [US3] Remove the line `#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"` from `optimizely-flutter-testapp/ios/Flutter/Debug.xcconfig`, and the matching `.release.xcconfig` line from `optimizely-flutter-testapp/ios/Flutter/Release.xcconfig`. Keep `#include "Generated.xcconfig"`.
- [X] T008 [US3] In `optimizely-flutter-testapp/ios/Runner.xcodeproj/project.pbxproj`, change all 3 occurrences of `IPHONEOS_DEPLOYMENT_TARGET = 10.0;` to `IPHONEOS_DEPLOYMENT_TARGET = 15.0;` (after T006, same file)
- [X] T009 [US3] Clone SDK `master` into `optimizely-flutter-testapp/home/runner/optimizely_flutter_sdk` (the path dependency in `pubspec.yaml`; **do not commit it**, since `home/` is not gitignored). Then run `flutter pub get` and `flutter build ios --simulator --target=integration_test/app_test.dart`. Flutter auto-migrates `ios/Runner.xcodeproj/project.pbxproj` to add the `FlutterGeneratedPluginSwiftPackage` reference; keep those changes. Confirm no `ios/Pods/` was created.
- [X] T010 [US3] Run `flutter analyze` in `optimizely-flutter-testapp/`. Fix only the errors and warnings introduced by the Flutter 3.16 → 3.44 jump, in `optimizely-flutter-testapp/lib/` and `optimizely-flutter-testapp/integration_test/`, with minimal edits and no refactors.
- [X] T011 [US3] Verify the Android build on Flutter 3.44: `flutter build apk --debug` in `optimizely-flutter-testapp/`. If AGP 8.7.0 / Gradle 8.10.2 / Kotlin 2.1.0 are rejected, bump only what the error names, in `optimizely-flutter-testapp/android/settings.gradle` / `android/gradle/wrapper/gradle-wrapper.properties`.
- [X] T012 [US3] Run `flutter test integration_test/app_test.dart -d <id>` on an iOS 15+ simulator and an Android emulator from `optimizely-flutter-testapp/`. All tests pass.
- [X] T013 [US3] Commit in the testapp (`ci: migrate iOS to SPM, require iOS 15 and Flutter 3.44`, ending with the `Co-Authored-By` line), push `feature/spm-ios15`, and open a PR to `master` referencing the Ticket 1 Jira key. Confirm the testapp `iOS` and `Android` workflows are green. **Merge before T030.**

**Checkpoint**: the testapp on `master` is SPM-only and still green against SDK `master`.

---

## Phase 3: User Story 1 — SDK Consumers Build iOS via SPM Only (Priority: P1) 🎯 MVP

**Goal**: The plugin ships SPM-only for iOS at 15.0 minimum. All behaviour is unchanged.

**Independent Test**: quickstart.md §2–3. `flutter analyze` is clean, `flutter test` is green, and `example` builds for the iOS simulator with no Podfile/Pods.

- [X] T014 [P] [US1] Delete `ios/optimizely_flutter_sdk.podspec` (`git rm`)
- [X] T015 [P] [US1] Delete `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/OptimizelyFlutterSdkPlugin.m` and the directory `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/include/` (`git rm -r`). Do NOT touch `macos/Classes/` (research R2).
- [X] T016 [US1] Edit `ios/optimizely_flutter_sdk/Package.swift` (after T015):
  - remove comment lines 2–4 (the ObjC/CocoaPods note), leaving `// swift-tools-version: 5.9` on line 1
  - change `platforms: [.iOS("10.0")]` to `platforms: [.iOS("15.0")]`
  - remove the `exclude: ["OptimizelyFlutterSdkPlugin.m", "include"]` argument, together with the trailing comma after the target's `dependencies: [...]` array
  - keep `exact: "5.4.2"` unchanged (FR-005)
- [X] T017 [US1] In `example/ios/`, run `pod deintegrate`, then `git rm example/ios/Podfile` (and delete untracked `Podfile.lock`/`Pods/`). Leave `example/macos/Podfile` alone.
- [X] T018 [P] [US1] Remove the `#include? "Pods/..."` first line from `example/ios/Flutter/Debug.xcconfig` and `example/ios/Flutter/Release.xcconfig`. Keep `#include "Generated.xcconfig"`.
- [X] T019 [US1] In `example/ios/Runner.xcodeproj/project.pbxproj`, change all 3 occurrences of `IPHONEOS_DEPLOYMENT_TARGET = 10.0;` to `15.0;` (after T017, same file)
- [X] T020 [US1] Validate: from the repo root run `flutter pub get && flutter analyze && flutter test` (zero issues, zero failures). Then `cd example && flutter build ios --simulator`: it succeeds, swift-sdk 5.4.2 resolves via SPM, and no `example/ios/Pods/` exists.

**Checkpoint**: the SDK is SPM-only and the example builds. US1 is done.

---

## Phase 4: User Story 2 — Developers Below the New Minimums Get a Clear Signal (Priority: P1)

**Goal**: Old Flutter and low iOS targets fail early with clear messages, and the README explains the migration.

**Independent Test**: quickstart.md §5, plus a README review against contracts/platform-requirements.md.

- [X] T021 [US2] In `pubspec.yaml`, change `environment.flutter: ">=2.5.0"` to `">=3.44.0"`. Leave the Dart `sdk:` constraint unchanged (research R1). Run `flutter pub get`.
- [X] T022 [US2] In `README.md`, replace line 24 with: iOS minimum 15.0; Flutter 3.44+ required; iOS integration is via Swift Package Manager only (CocoaPods no longer supported). Add a short "Migrating from CocoaPods" subsection right after it, with the 4 steps from `specs/003-remove-cocoapods-ios15/contracts/platform-requirements.md` → "Migration steps for app developers". Match the README's existing heading level and tone.
- [X] T023 [US2] Negative check from quickstart.md §5: set `IPHONEOS_DEPLOYMENT_TARGET` to `14.0` in `example/ios/Runner.xcodeproj/project.pbxproj`, run `flutter build ios --simulator` in `example/`, and confirm the error names the iOS 15.0 minimum. Then revert the file (`git checkout -- example/ios/Runner.xcodeproj/project.pbxproj` only if T019 is already committed; otherwise set it back to 15.0). Run the Flutter-too-old check only if `fvm` is available; otherwise note it as skipped.

**Checkpoint**: US1 and US2 are complete. This is consumer-facing done.

---

## Phase 5: User Story 4 — Maintainers Have One iOS Dependency Path (Priority: P3)

**Goal**: No parity CI job, and docs and the constitution describe SPM only and iOS 15.

**Independent Test**: quickstart.md §6 (leftover grep returns nothing); the CI job list has no `version_drift_check`.

- [X] T024 [P] [US4] Delete `.github/scripts/check-version-drift.sh` (`git rm`)
- [X] T025 [US4] In `.github/workflows/flutter.yml`, delete the `version_drift_check:` job (lines 20–25: job key, `runs-on`, `steps`, checkout, and the "Check OptimizelySwiftSDK version parity" step) and both `needs: version_drift_check` lines (currently lines 29 and 155). Keep YAML indentation valid.
- [X] T026 [P] [US4] Edit `CLAUDE.md`:
  - line 39: change `check podspec/build.gradle` to `check Package.swift/build.gradle`
  - lines 82–86: replace the "Two locations must stay synchronized (native iOS SDK version)" block and the following CI sentence with a single line saying the native iOS SDK version lives in `ios/optimizely_flutter_sdk/Package.swift` → `.package(url: "...swift-sdk.git", exact: "A.B.C")`
  - Platform Requirements → Flutter: change `>=2.5.0` to `>=3.44.0`
  - line 193: `iOS 10.0` → `iOS 15.0`
  - line 195: drop `ios/optimizely_flutter_sdk.podspec and `
  - line 214: delete the `ios/optimizely_flutter_sdk.podspec - CocoaPods dependencies` bullet
- [X] T027 [P] [US4] In `.github/copilot-instructions.md` line 13, change `iOS 10.0+` to `iOS 15.0+`
- [X] T028 [US4] Amend `.specify/memory/constitution.md` per research R7:
  - Principle VIII iOS bullet: only `ios/optimizely_flutter_sdk/Package.swift` (SPM); remove the podspec mention and "Both files MUST declare the same version."
  - Minimum Platform Versions table: iOS `15.0`, Flutter `>=3.44.0`
  - Replace the Sync Impact Report comment with Version change 1.1.1 → 1.2.0, modified Principle VIII and Platform Compatibility table
  - footer: `**Version**: 1.2.0 | **Ratified**: 2022-06-07 | **Last Amended**: 2026-10-12`
  - commit this file alone: `docs: amend constitution to v1.2.0 (SPM-only iOS, iOS 15 minimum)`

**Checkpoint**: all user stories are complete.

---

## Phase 6: Polish & Delivery

- [X] T029 Run the leftover-reference grep from quickstart.md §6 in both repos. Fix any hit outside `CHANGELOG.md`, `specs/`, `macos/` and `example/macos/`.
- [ ] T030 Commit the remaining SDK changes as `chore!: remove CocoaPods support, require iOS 15 and Flutter 3.44`, with a `BREAKING CHANGE:` footer naming the new minimums and ending with the `Co-Authored-By` line. Push `feature/remove-cocoapods-ios15` and open a PR to `master` referencing the Ticket 1 Jira key (use the `pr` skill for the body). Confirm all SDK CI jobs, including `integration_ios_tests`, are green. Requires T013 to be merged. **Do not cut a release** (FR-012: 4.0.0 ships with Ticket 2, via Ticket 3).

---

## Dependencies & Execution Order

- **Setup (T001–T003)** → everything.
- **US3 (T004–T013)**: independent of SDK changes; must **merge** before T030.
- **US1 (T014–T020)**: after T001. T016 needs T015; T019 needs T017; T020 needs T014–T019.
- **US2 (T021–T023)**: T021/T022 are independent of US1; T023 needs T019.
- **US4 (T024–T028)**: independent of US1/US2; T025 should follow T024.
- **Polish (T029–T030)**: after all stories; T030 needs T013 merged.

Phases 3–5 all live in one SDK PR, so splitting by story is for ordering only, not separate PRs.

## Parallel Opportunities

- T002 ∥ T003
- US3: T005 ∥ T007 ∥ (T006 → T008)
- US1: T014 ∥ T015 ∥ T018, then T016, T017 → T019
- US2/US4 file edits (T021, T022, T024, T026, T027) can all run alongside US1, since they touch different files
- SDK work (Phases 3–5) can proceed in parallel with the testapp PR review; only T030 waits on T013

## Implementation Strategy

1. **Testapp first** (Phase 2). Merge it once green; it's safe against current SDK `master`.
2. **MVP = US1** (Phase 3): SPM-only plugin and example build.
3. Add **US2** (Flutter constraint + README) and **US4** (CI/docs/constitution) on the same branch.
4. Run Polish, then open the SDK PR. Hold the release for Ticket 2 + Ticket 3.
