# Quickstart Validation Guide: Add SPM Support with CocoaPods Backward Compatibility

**Date**: 2026-08-20 (Revised) | **Feature**: [spec.md](spec.md)

## Prerequisites

- Flutter SDK (stable channel)
- Xcode 15+ with iOS simulators
- CocoaPods installed (for backward compatibility validation)
- Access to `optimizely-flutter-testapp` repo

## Validation Scenario 1: SDK Plugin Builds via SPM

**Goal**: Verify the SDK's Package.swift is correctly structured and OptimizelySwiftSDK resolves via SPM.

```bash
# From SDK repo root (with Flutter 3.44+ or SPM enabled)
flutter config --enable-swift-package-manager
flutter clean
flutter pub get
cd example
flutter build ios --simulator --no-codesign
```

**Expected**: Build succeeds. Console shows SPM resolving `swift-sdk` package. No CocoaPods warnings.

## Validation Scenario 2: SDK Plugin Builds via CocoaPods

**Goal**: Verify the podspec still works with updated source file paths.

```bash
# From SDK repo root (with CocoaPods path)
flutter config --no-enable-swift-package-manager
flutter clean
flutter pub get
cd example
flutter build ios --simulator --no-codesign
```

**Expected**: Build succeeds via CocoaPods. `pod install` finds source files at the new path. No missing file errors.

## Validation Scenario 3: Podspec Lint

**Goal**: Verify the podspec is valid after source path changes.

```bash
cd ios
pod lib lint optimizely_flutter_sdk.podspec --allow-warnings
```

**Expected**: Lint passes. Source files found at updated paths.

## Validation Scenario 4: Unit Tests Pass

**Goal**: Verify no test regressions from the file restructuring.

```bash
# From SDK repo root
flutter test
```

**Expected**: All existing tests pass with zero failures.

## Validation Scenario 5: Lint Clean

**Goal**: Verify no analysis issues introduced.

```bash
flutter analyze
```

**Expected**: No issues found.

## Validation Scenario 6: Test App Builds via SPM

**Goal**: Verify the test app resolves the SDK via SPM and integration tests pass.

```bash
# From optimizely-flutter-testapp repo (with SPM enabled)
flutter config --enable-swift-package-manager
flutter clean
flutter pub get
flutter build ios --simulator --no-codesign
```

**Expected**: Build succeeds with SPM dependency resolution.

## Validation Scenario 7: Test App Integration Tests

**Goal**: Verify end-to-end functionality on iOS simulator.

```bash
# From optimizely-flutter-testapp repo
flutter test integration_test -d <simulator_id>
```

**Expected**: All e2e test cases pass with zero failures.

## Validation Scenario 8: Version Consistency

**Goal**: Verify both dependency files declare the same OptimizelySwiftSDK version.

```bash
# From SDK repo root
grep "OptimizelySwiftSDK" ios/optimizely_flutter_sdk.podspec
grep "exact:" ios/optimizely_flutter_sdk/Package.swift
```

**Expected**: Both show version `5.4.2` (or whatever the current pinned version is).

## Validation Scenario 9: CI Version Drift Check (FR-014)

**Goal**: Verify the CI validation step detects version mismatches between Package.swift and podspec.

```bash
# Extract versions and compare
PODSPEC_VER=$(grep "OptimizelySwiftSDK" ios/optimizely_flutter_sdk.podspec | grep -oE "'[0-9]+\.[0-9]+\.[0-9]+'" | tr -d "'")
SPM_VER=$(grep 'exact:' ios/optimizely_flutter_sdk/Package.swift | grep -oE '"[0-9]+\.[0-9]+\.[0-9]+"' | tr -d '"')
[ "$PODSPEC_VER" = "$SPM_VER" ] && echo "PASS: versions match ($PODSPEC_VER)" || echo "FAIL: podspec=$PODSPEC_VER spm=$SPM_VER"
```

**Expected**: Versions match. If intentionally mismatched for testing, the check should fail.

## Validation Scenario 10: CI Pipeline

**Goal**: Verify all five CI jobs pass.

Push the branch and create a PR against `master`. Monitor:

1. `unit_test_coverage` — Dart tests + coverage
2. `build_test_android` — Android build (unaffected)
3. `build_test_ios` — iOS build
4. `integration_android_tests` — Android e2e (unaffected)
5. `integration_ios_tests` — iOS e2e

**Expected**: All five jobs pass green.

## Troubleshooting

- **SPM resolution fails**: Verify the `swift-sdk` git tag for version 5.4.2 exists. Check Package.swift URL.
- **CocoaPods can't find source files**: Verify podspec `source_files` path matches the new directory layout.
- **ObjC header not found**: Check that the `.h` file is in `include/optimizely_flutter_sdk/` and import path in `.m` is updated.
- **Mixed ObjC/Swift errors in SPM**: Ensure `cSettings: [.headerSearchPath("include/optimizely_flutter_sdk")]` is in Package.swift target.
- **Xcode cache issues**: Run `flutter clean`, delete `~/Library/Developer/Xcode/DerivedData/`, rebuild.
- **Wrong dependency path used**: Use `flutter config --enable-swift-package-manager` or `--no-enable-swift-package-manager` to force a specific path for testing.
