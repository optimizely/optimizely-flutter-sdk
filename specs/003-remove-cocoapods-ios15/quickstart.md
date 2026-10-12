# Quickstart Validation: Remove CocoaPods Support and Raise Minimum iOS to 15.0

**Prerequisites**: Flutter ≥3.44 with SPM enabled (`flutter config --enable-swift-package-manager`), Xcode with an iOS 15+ simulator, Android emulator for testapp Android checks.

## 1. Testapp (PR 1): validate against current SDK master

```bash
cd optimizely-flutter-testapp
# place SDK checkout at ./home/runner/optimizely_flutter_sdk (master)
flutter pub get
flutter analyze
flutter build ios --simulator --target=integration_test/app_test.dart
flutter test integration_test/app_test.dart -d <ios-simulator-id>
flutter test integration_test/app_test.dart -d <android-emulator-id>
```

**Expected**: build succeeds with no `Pods/` generated; all integration tests pass on both platforms. `git grep -i "pod"` in `ios/` shows only Flutter-generated ignores.

## 2. SDK (PR 2): unit and static checks

```bash
cd optimizely-flutter-sdk
flutter pub get
flutter analyze        # zero issues
flutter test           # zero failures
```

## 3. SDK: example app builds SPM-only at iOS 15

```bash
cd example
flutter build ios --simulator
```

**Expected**: build succeeds; no `ios/Pods`, no `ios/Podfile`; the build log shows the swift-sdk package resolved.

## 4. Testapp against the SDK feature branch

Repeat step 1 with the SDK checkout on the feature branch. **Expected**: same results (spec US1-AS3, US3-AS2).

## 5. Negative checks (spec US2)

| Check | How | Expected |
|---|---|---|
| iOS target too low | In `example`, set the Runner target to 14.0 and run `flutter build ios --simulator` | Flutter bumps the target to 15.0 ("Updating minimum iOS deployment target to 15.0") and the build succeeds |
| Flutter too old | Use Flutter <3.44 (e.g., via fvm), run `flutter pub get` in `example` | Resolution fails, naming the Flutter constraint |

Revert the target change afterwards.

## 6. Leftover references (spec SC-002)

```bash
git grep -n -i -E "cocoapod|podspec|Podfile|iOS 10|ios, '10" -- ':!CHANGELOG.md' ':!specs/' ':!macos/' ':!example/macos/'
```

**Expected**: no hits in either repo.

## 7. CI

Push both branches. **Expected**: testapp `iOS` and `Android` workflows are green. All SDK jobs are green, with no `version_drift_check` job listed.
