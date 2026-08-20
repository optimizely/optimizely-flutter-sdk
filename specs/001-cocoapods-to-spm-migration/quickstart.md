# Quickstart Validation Guide: CocoaPods to SPM Migration

**Date**: 2026-08-20 | **Feature**: [spec.md](spec.md)

## Prerequisites

- Flutter SDK (stable channel, 3.44+)
- Xcode 15+ with iOS simulators
- No CocoaPods required (that's the point)
- Access to `optimizely-flutter-testapp` repo

## Validation Scenario 1: SDK Plugin Builds via SPM

**Goal**: Verify the SDK's Package.swift is correctly structured and the OptimizelySwiftSDK dependency resolves via SPM.

```bash
# From SDK repo root
flutter clean
flutter pub get
cd example
flutter build ios --simulator --no-codesign
```

**Expected**: Build succeeds. Console shows SPM resolving `swift-sdk` package (not pod install). No CocoaPods warnings.

## Validation Scenario 2: Unit Tests Pass

**Goal**: Verify no test regressions from the migration.

```bash
# From SDK repo root
flutter test
```

**Expected**: All existing tests pass with zero failures. Test count matches pre-migration count.

## Validation Scenario 3: Lint Clean

**Goal**: Verify no analysis issues introduced.

```bash
flutter analyze
```

**Expected**: No issues found.

## Validation Scenario 4: Test App Builds and Runs

**Goal**: Verify the test app resolves the SDK via SPM and integration tests pass.

```bash
# From optimizely-flutter-testapp repo
flutter clean
flutter pub get
flutter build ios --simulator --no-codesign
```

**Expected**: Build succeeds without CocoaPods. The SDK plugin is resolved via SPM.

## Validation Scenario 5: Integration Tests Pass

**Goal**: Verify end-to-end functionality on iOS simulator.

```bash
# From optimizely-flutter-testapp repo
flutter test integration_test -d <simulator_id>
```

**Expected**: All e2e test cases pass with zero failures.

## Validation Scenario 6: CocoaPods Artifacts Removed

**Goal**: Verify no CocoaPods remnants in either repo.

```bash
# From SDK repo root
find . -name "Podfile" -o -name "Podfile.lock" -o -name "*.podspec" -o -name "Pods" -type d | grep -v ".git"

# From test app repo root
find . -name "Podfile" -o -name "Podfile.lock" -o -name "Pods" -type d | grep -v ".git"
```

**Expected**: Both commands return empty output (no matches).

## Validation Scenario 7: Clean Machine Build

**Goal**: Verify a developer without CocoaPods can build the SDK.

```bash
# Temporarily hide CocoaPods if installed
which pod && echo "CocoaPods present — test on clean env or rename binary"

# Create a fresh Flutter project and add the SDK
flutter create spm_test_app
cd spm_test_app
# Add SDK dependency pointing to local path
flutter pub add optimizely_flutter_sdk --path /path/to/optimizely-flutter-sdk
flutter build ios --simulator --no-codesign
```

**Expected**: Build succeeds. No errors about missing CocoaPods or podspec.

## Validation Scenario 8: CI Pipeline

**Goal**: Verify all five CI jobs pass.

Push the migration branch and create a PR against `master`. Monitor:

1. `unit_test_coverage` — Dart tests + coverage
2. `build_test_android` — Android build (should be unaffected)
3. `build_test_ios` — iOS build via SPM
4. `integration_android_tests` — Android e2e (should be unaffected)
5. `integration_ios_tests` — iOS e2e via SPM

**Expected**: All five jobs pass green.

## Troubleshooting

- **SPM resolution fails**: Verify the `swift-sdk` git tag for version 5.4.2 exists. Check Package.swift URL.
- **Mixed ObjC/Swift errors**: If ObjC bridging files were kept, ensure they're in a separate target or removed.
- **Xcode cache issues**: Run `flutter clean`, delete `~/Library/Developer/Xcode/DerivedData/`, rebuild.
- **Old Pods artifacts**: Delete `ios/Pods/`, `ios/Podfile.lock`, `example/ios/Pods/`, `example/ios/Podfile.lock`.
