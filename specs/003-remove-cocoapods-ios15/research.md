# Research: Remove CocoaPods Support and Raise Minimum iOS to 15.0

**Feature**: 003-remove-cocoapods-ios15 | **Date**: 2026-10-12

## R1. Minimum Flutter version

- **Decision**: `pubspec.yaml` → `environment.flutter: ">=3.44.0"`. Leave the Dart constraint (`>=2.16.2 <4.0.0`) unchanged.
- **Rationale**: Flutter 3.44 resolves SPM plugins by default (README line 24 already says so), and SDK CI already pins `flutter-version: '3.44.0'` in all three jobs. Without a podspec, older Flutter versions (or SPM disabled) cannot integrate the plugin on iOS, so the constraint makes `flutter pub get` fail early with a clear message (spec US2-AS2). The Flutter constraint already implies a Dart 3 SDK, so changing the Dart constraint adds diff with no effect.
- **Alternatives considered**: Leave `>=2.5.0` and rely on the iOS build failing. Rejected because the failure is obscure (spec US2). Pinning a newer Flutter (e.g., the local 3.47.1) was also rejected: 3.44 is the lowest version that works and the one CI already proves.

## R2. Objective-C registration shim

- **Decision**: Delete `ios/optimizely_flutter_sdk/Sources/optimizely_flutter_sdk/OptimizelyFlutterSdkPlugin.m` and `.../include/` (the header). Remove the `exclude:` argument and the ObjC comment from `Package.swift`.
- **Rationale**: `Package.swift` already excludes these files, and its comment says they "remain on disk for CocoaPods builds". The iOS `pluginClass` in `pubspec.yaml` is already `SwiftOptimizelyFlutterSdkPlugin`, so registration doesn't change. macOS has its own `pluginClass` (`OptimizelyFlutterSdkPlugin`) backed by `macos/Classes/`, which is a separate directory, so macOS is unaffected.
- **Alternatives considered**: Keep the files but leave them unused. Rejected as dead code that FR-002 explicitly removes.

## R3. Behaviour when the app targets iOS < 15.0

- **Decision**: No custom code. Flutter reads `Package.swift` `platforms: [.iOS("15.0")]` and raises the app's deployment target to 15.0 automatically ("Updating minimum iOS deployment target to 15.0"). Verified 2026-10-12: an example app at 14.0 was bumped and built successfully.
- **Rationale**: Flutter's SPM integration migrates the app's deployment target up to the highest plugin minimum, so developers get a working build plus a printed notice instead of an error. That satisfies spec US2-AS1 at no cost.
- **Alternatives considered**: A build-phase script that checks the deployment target. Rejected because it duplicates what SPM already does.

## R4. In-repo example app (`example/ios`)

- **Decision**:
  1. Run `pod deintegrate` in `example/ios`. This strips `Pods_Runner.framework`, the `Pods` group, the `Pods-Runner.*.xcconfig` refs and the `[CP]` build phases from `project.pbxproj`.
  2. Delete `example/ios/Podfile`. `Podfile.lock` and `Pods/` are untracked.
  3. Remove the `#include? "Pods/..."` line from `Flutter/Debug.xcconfig` and `Flutter/Release.xcconfig`.
  4. Change `IPHONEOS_DEPLOYMENT_TARGET` from 10.0 to 15.0 (3 occurrences in `project.pbxproj`).
  5. Run `flutter build ios --simulator` with SPM enabled to confirm. The SPM package reference (`FlutterGeneratedPluginSwiftPackage`) is already in the pbxproj.
- **Rationale**: The example's only plugin dependency is this SDK, so no CocoaPods plugin is left to need a Podfile. `pod deintegrate` is the supported way to clean the pbxproj; editing it by hand is error-prone.
- **Out of scope**: `example/macos/Podfile` stays (macOS is out of scope).

## R5. Test app (`optimizely-flutter-testapp`)

- **Finding**: Both `.github/workflows/ios.yml:39` and `android.yml:57` pin `flutter-version: '3.16.0'`. With R1 the SDK requires Flutter ≥3.44, so **both** testapp workflows fail `flutter pub get` unless upgraded. The iOS project has no SPM integration (no `FlutterGeneratedPluginSwiftPackage` in the pbxproj) and still uses CocoaPods with `platform :ios, '13.0'`.
- **Decision**:
  1. In `ios.yml` and `android.yml`, change `flutter-version` from `3.16.0` to `3.44.0` (matching SDK CI). In `ios.yml`, add a `flutter config --enable-swift-package-manager` step before `flutter pub get`, mirroring SDK CI.
  2. Run `pod deintegrate` in `ios/`. Delete `ios/Podfile`. Remove the `#include? "Pods/..."` lines from `ios/Flutter/{Debug,Release}.xcconfig`.
  3. Change `IPHONEOS_DEPLOYMENT_TARGET` from 10.0 to 15.0 (3 occurrences).
  4. Run `flutter build ios --simulator` locally with SPM enabled. Flutter's auto-migration adds the `FlutterGeneratedPluginSwiftPackage` reference to the pbxproj; commit that.
  5. Verify the Android build locally on Flutter 3.44. The testapp is already on AGP 8.7.0, Gradle 8.10.2 and Kotlin 2.1.0, which are expected to be compatible. The CI run confirms it.
- **Rationale**: The testapp has to work against both SDK `master` (podspec still present, iOS 10) and the SDK feature branch. An iOS-15, SPM-only testapp works with both, because SPM resolves the SDK's existing `Package.swift`. So the testapp PR can merge first with no flag-day coordination.
- **Risk**: The jump from Flutter 3.16 to 3.44 may surface Dart analyzer or lint changes in the testapp's `integration_test/`. Mitigation: run `flutter analyze` and the integration suite locally before opening the PR.
- **Noted, out of scope**: `ios.yml` uses `inputs.tags` but the declared input is `release_version`. That's an existing bug in the release-install step and is left untouched.

## R6. SDK CI

- **Decision**: Delete `.github/scripts/check-version-drift.sh`. Remove the `version_drift_check` job (`flutter.yml:20-25`) and both `needs: version_drift_check` lines (`flutter.yml:29`, `:155`).
- **Rationale**: Only one manifest remains, so the parity check has nothing to compare (FR-007).
- **Alternatives considered**: Repurpose the script to check something else. Rejected as YAGNI.
- **Noted**: `build_test_ios` only runs `flutter pub get`/`flutter test`. It doesn't actually build iOS. The real iOS build is covered by `integration_ios_tests` (the testapp). Adding an iOS build step is out of scope.

## R7. Documentation and constitution

- **Decision**:
  - `README.md:24`: say iOS 15.0 minimum, Flutter 3.44+, SPM only, and add a short "Migrating from CocoaPods" note (enable SPM, raise the deployment target, run `pod deintegrate` if no other pods remain).
  - `CLAUDE.md`: in lines 39, 80-85 (iOS native version pair → single file), 193 (iOS 15.0), 195 and 214, remove the podspec references and the drift-check sentence.
  - `.github/copilot-instructions.md:13`: change iOS 10.0+ to 15.0+.
  - `.specify/memory/constitution.md`: in Principle VIII, keep only `Package.swift` as the iOS source of truth. In the Minimum Platform Versions table, set iOS to 15.0 and Flutter to >=3.44.0. Bump the constitution version **1.1.1 → 1.2.0** (MINOR: materially changed guidance, no principle removed), update the Sync Impact Report and Last Amended date, and use the commit message `docs: amend constitution to v1.2.0 (SPM-only iOS, iOS 15 minimum)`.
- **Rationale**: FR-010 and FR-011, plus the constitution's amendment procedure.
- **Not touched**: CHANGELOG (Ticket 3 writes the 4.0.0 entry), prior specs 001/002 (historical).
