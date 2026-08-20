# Tasks: Add SPM Support with CocoaPods Backward Compatibility

**Input**: Design documents from `specs/001-cocoapods-to-spm-migration/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Tests**: Not explicitly requested — test tasks omitted. Existing tests must pass (verified in validation tasks).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup

**Purpose**: Verify prerequisites and prepare for migration

- [x] T001 Verify OptimizelySwiftSDK git tag format for version 5.4.2 on https://github.com/optimizely/swift-sdk (confirm tag is `5.4.2` vs `v5.4.2` and note the exact string for Package.swift)
- [x] T002 Create SPM directory structure: `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/include/optimizely_flutter_sdk/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Move source files to SPM layout and create Package.swift — MUST complete before any user story work

**CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Move `ios/Classes/OptimizelyFlutterSdkPlugin.h` to `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/include/optimizely_flutter_sdk/OptimizelyFlutterSdkPlugin.h`
- [x] T004 Move `ios/Classes/OptimizelyFlutterSdkPlugin.m` to `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/OptimizelyFlutterSdkPlugin.m` and update its import path from `#import "OptimizelyFlutterSdkPlugin.h"` to `#import "./include/optimizely_flutter_sdk/OptimizelyFlutterSdkPlugin.h"`
- [x] T005 [P] Move `ios/Classes/SwiftOptimizelyFlutterSdkPlugin.swift` to `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/SwiftOptimizelyFlutterSdkPlugin.swift`
- [x] T006 [P] Move `ios/Classes/OptimizelyFlutterLogger.swift` to `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/OptimizelyFlutterLogger.swift`
- [x] T007 [P] Move `ios/Classes/HelperClasses/Constants.swift` to `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/Constants.swift`
- [x] T008 [P] Move `ios/Classes/HelperClasses/OptimizelyConfig+Extension.swift` to `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/OptimizelyConfig+Extension.swift`
- [x] T009 [P] Move `ios/Classes/HelperClasses/Utils.swift` to `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/Utils.swift`
- [x] T010 Remove empty `ios/Classes/` directory (including `HelperClasses/` subdirectory)
- [x] T011 Remove empty `ios/Assets/` directory
- [x] T012 Create `ios/optimizely_flutter_sdk/Package.swift` with: swift-tools-version 5.9, iOS platform 10.0, FlutterFramework dependency, OptimizelySwiftSDK via `https://github.com/optimizely/swift-sdk.git` with exact version pinning, and `cSettings: [.headerSearchPath("include/optimizely_flutter_sdk")]` in target
- [x] T013 Verify `flutter pub get` succeeds from SDK repo root after file restructuring

**Checkpoint**: SPM package structure is in place, all source files are in their new locations, Package.swift is created

---

## Phase 3: User Story 1 — SDK Consumers Build iOS via SPM (Priority: P1) MVP

**Goal**: The SDK plugin builds for iOS via SPM. Consumers on Flutter 3.44+ can run `flutter build ios` with SPM dependency resolution.

**Independent Test**: Enable SPM (`flutter config --enable-swift-package-manager`), run `flutter build ios --simulator --no-codesign` from `example/` directory, and verify it succeeds with SPM resolving OptimizelySwiftSDK.

### Implementation for User Story 1

- [ ] T014 [US1] Run `flutter config --enable-swift-package-manager` to enable SPM for testing
- [ ] T015 [US1] Run `flutter clean && flutter pub get` from `example/` directory
- [ ] T016 [US1] Verify `flutter build ios --simulator --no-codesign` succeeds from `example/` directory with SPM resolving the swift-sdk package
- [ ] T017 [US1] Run `flutter test` from SDK repo root and verify all existing unit tests pass with zero failures

**Checkpoint**: SDK plugin builds for iOS via SPM. Example app compiles via SPM. All unit tests pass.

---

## Phase 4: User Story 2 — SDK Consumers Continue Building via CocoaPods (Priority: P1)

**Goal**: The existing podspec still works after source files moved to the new directory layout. Consumers on older Flutter can continue using CocoaPods.

**Independent Test**: Disable SPM (`flutter config --no-enable-swift-package-manager`), run `flutter build ios --simulator --no-codesign` from `example/`, and verify it succeeds via CocoaPods with updated source paths.

### Implementation for User Story 2

- [ ] T018 [US2] Update `ios/optimizely_flutter_sdk.podspec`: change `s.source_files` from `'Classes/**/*'` to `'optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/**/*'`
- [ ] T019 [US2] Run `pod lib lint ios/optimizely_flutter_sdk.podspec --allow-warnings` to verify podspec validity with new source paths
- [ ] T020 [US2] Run `flutter config --no-enable-swift-package-manager` to test CocoaPods path
- [ ] T021 [US2] Run `flutter clean && flutter pub get` from `example/` directory
- [ ] T022 [US2] Verify `flutter build ios --simulator --no-codesign` succeeds from `example/` directory via CocoaPods
- [ ] T023 [US2] Run `flutter test` from SDK repo root and verify all existing unit tests still pass

**Checkpoint**: SDK plugin builds for iOS via CocoaPods with updated source paths. Podspec lints clean. All unit tests pass.

---

## Phase 5: User Story 3 — Test App Works with SPM (Priority: P2)

**Goal**: The `optimizely-flutter-testapp` builds and runs on iOS via SPM. Integration tests pass.

**Independent Test**: Build the test app with SPM enabled and run integration tests on iOS simulator.

### Implementation for User Story 3

- [ ] T024 [US3] Ensure test app's dependency on `optimizely_flutter_sdk` resolves the SPM-enabled version (check `/Users/muzahidul.islam/workspace/optimizely-flutter-testapp/pubspec.yaml` path dependency)
- [ ] T025 [US3] Update test app CI workflow at `/Users/muzahidul.islam/workspace/optimizely-flutter-testapp/.github/workflows/ios.yml`: add `flutter config --enable-swift-package-manager` step before the build step; keep existing `brew install cocoapods` + `pod repo update` steps as fallback for CocoaPods backward compatibility
- [ ] T026 [US3] Run `flutter config --enable-swift-package-manager && flutter clean && flutter pub get` from test app repo root
- [ ] T027 [US3] Verify `flutter build ios --simulator --no-codesign` succeeds from test app repo with SPM resolving dependencies
- [ ] T028 [US3] Run integration tests on iOS simulator and verify all e2e test cases pass with zero failures

**Checkpoint**: Test app builds and runs on iOS via SPM. CI workflow updated. All integration tests pass.

---

## Phase 6: User Story 4 — CI Pipeline Validates Both Paths (Priority: P2)

**Goal**: All CI workflows pass. Both CocoaPods and SPM build paths are validated.

**Independent Test**: Push branch, create PR, and verify all five CI jobs pass.

### Implementation for User Story 4

- [ ] T029 [US4] Create version drift check script at `.github/scripts/check-version-drift.sh` (FR-014) that extracts OptimizelySwiftSDK version from both `ios/optimizely_flutter_sdk.podspec` and `ios/optimizely_flutter_sdk/Package.swift`, compares them, and exits non-zero if they diverge
- [ ] T030 [US4] Integrate version drift check into SDK CI workflow `.github/workflows/flutter.yml` as a job step that runs before build jobs
- [ ] T031 [US4] Review and confirm SDK CI `.github/workflows/flutter.yml` needs no other changes (no explicit pod commands exist)
- [ ] T032 [US4] Push branch and create PR to trigger all five CI jobs: `unit_test_coverage`, `build_test_android`, `build_test_ios`, `integration_android_tests`, `integration_ios_tests`
- [ ] T033 [US4] Verify all five CI jobs pass green, including the version drift check

**Checkpoint**: All CI pipelines pass. Version drift is enforced. Both dependency paths validated.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Documentation updates, version sync, and final validation

- [ ] T034 [P] Update `CLAUDE.md`: remove `cd ios && pod install` from setup commands (no longer needed), add note about dual SPM/CocoaPods support, update iOS setup instructions, add `ios/optimizely_flutter_sdk/Package.swift` to version pinning source-of-truth list in the Native SDK Version Pinning section
- [ ] T035 [P] Update `README.md`: add note about SPM support alongside existing CocoaPods instructions if applicable (FR-009)
- [ ] T036 Verify version consistency: confirm `ios/optimizely_flutter_sdk.podspec` and `ios/optimizely_flutter_sdk/Package.swift` both declare OptimizelySwiftSDK 5.4.2
- [ ] T037 Run full `flutter test` from SDK repo root — verify zero failures (final regression check)
- [ ] T038 Run full `flutter analyze` from SDK repo root — verify zero issues
- [ ] T039 Run quickstart.md validation scenarios end-to-end (both SPM and CocoaPods paths, including version drift check)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup (T001 tag verification informs T012 Package.swift version string)
- **User Story 1 (Phase 3)**: Depends on Foundational phase completion (Package.swift must exist)
- **User Story 2 (Phase 4)**: Depends on Foundational phase completion (files must be moved before podspec path update)
- **User Story 3 (Phase 5)**: Depends on US1 completion (SDK must have working SPM support)
- **User Story 4 (Phase 6)**: Depends on US1 and US2 completion (both paths must work before CI validation)
- **Polish (Phase 7)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) — no dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) — can run in parallel with US1
- **User Story 3 (P2)**: Depends on US1 — test app needs the SDK's SPM support to be working
- **User Story 4 (P2)**: Depends on US1 and US2 — CI validates both paths

### Within Each User Story

- Configuration before build verification
- Build verification before test verification
- Story complete before moving to next priority

### Parallel Opportunities

- T005, T006, T007, T008, T009 can all run in parallel (independent file moves)
- US1 and US2 can be worked on in parallel after Foundational phase completes
- T034 and T035 can run in parallel (independent documentation updates)

---

## Parallel Example: Foundational Phase

```bash
# Launch all Swift source file moves together (after T003/T004 ObjC handling):
Task: "Move SwiftOptimizelyFlutterSdkPlugin.swift to SPM sources"
Task: "Move OptimizelyFlutterLogger.swift to SPM sources"
Task: "Move Constants.swift to SPM sources"
Task: "Move OptimizelyConfig+Extension.swift to SPM sources"
Task: "Move Utils.swift to SPM sources"
```

## Parallel Example: User Story 1 + User Story 2

```bash
# After Foundational phase, both can start simultaneously:
# Developer A: User Story 1 (verify SPM path)
Task: "Enable SPM, build example app via SPM, verify tests pass"

# Developer B: User Story 2 (verify CocoaPods path)
Task: "Update podspec paths, lint podspec, build example app via CocoaPods, verify tests pass"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (verify SPM tag)
2. Complete Phase 2: Foundational (move files + create Package.swift)
3. Complete Phase 3: User Story 1 (SDK builds via SPM)
4. **STOP and VALIDATE**: Build example app via SPM, run unit tests
5. This alone proves SPM support works

### Incremental Delivery

1. Setup + Foundational → Files moved, Package.swift created
2. Add User Story 1 → SDK builds via SPM (MVP!)
3. Add User Story 2 → SDK also builds via CocoaPods (backward compat confirmed)
4. Add User Story 3 → Test app works via SPM
5. Add User Story 4 → CI passes on both paths
6. Polish → Documentation updated, version sync verified

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each phase or logical group
- Stop at any checkpoint to validate story independently
- The ObjC header placement (T003) and import path update (T004) should be done before Swift file moves to avoid build issues
- Version consistency (T036) is critical — both podspec and Package.swift must always declare the same OptimizelySwiftSDK version
- FR-014 version drift CI check is implemented in US4 (T029-T030)
