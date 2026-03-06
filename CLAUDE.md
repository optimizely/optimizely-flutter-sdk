# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Optimizely Flutter SDK - Cross-platform plugin wrapping native Optimizely SDKs (iOS, Android) for A/B testing, feature flags, CMAB, and ODP integration.

**Main Branch:** master

## Essential Commands

```bash
# Setup
flutter pub get
cd ios && pod install              # iOS dependencies

# Testing
flutter test                       # All tests
flutter test test/cmab_test.dart   # Specific test
flutter test --coverage            # With coverage

# Linting
flutter analyze

# Run example app
cd example && flutter run
```

## Architecture

### Bridge Pattern
```
Dart API (OptimizelyFlutterSdk)
    ↓
Wrapper (OptimizelyClientWrapper) + MethodChannel
    ↓
Native Plugins (Swift/Java)
    ↓
Native Optimizely SDKs (5.2.1 iOS / 5.1.1 Android)
```

### Critical Patterns

**1. Response Object Pattern**
- ALL methods return `BaseResponse` derivatives (never throw exceptions)
- Check `success` boolean and `reason` string for errors

**2. Multi-Instance State Management**
- SDK instances tracked by `sdkKey`
- User contexts: `sdkKey → userContextId → context`
- Notification listeners: `sdkKey → listenerId → callback`
- Call `close()` for cleanup

**3. Platform-Specific Type Encoding (CRITICAL)**
- **iOS**: Attributes need type metadata: `{"value": 123, "type": "int"}`
- **Android**: Direct primitives: `{"attribute": 123}`
- Conversion in `Utils.convertToTypedMap()` (lib/src/utils/utils.dart)
- Test override: `forceIOSFormat` parameter

**4. Dual MethodChannel Architecture**
- `optimizely_flutter_sdk` - Main API operations
- `optimizely_flutter_sdk_logger` - Native → Dart log forwarding

## Adding Cross-Platform Features

1. Add data models in `lib/src/data_objects/` if needed
2. Update `lib/src/optimizely_client_wrapper.dart` with MethodChannel call
3. **Android**: Add case in `OptimizelyFlutterClient.java`, parse args, call native SDK
4. **iOS**: Add case in `SwiftOptimizelyFlutterSdkPlugin.swift`, parse args, call native SDK
5. Handle type conversions (iOS requires metadata wrapping)
6. Write tests in `test/`
7. Update public API in `lib/optimizely_flutter_sdk.dart`

## Version Management

**Three locations must stay synchronized:**
1. `pubspec.yaml` → `version: X.Y.Z`
2. `lib/package_info.dart` → `version = 'X.Y.Z'`
3. `README.md` → Installation example `^X.Y.Z`

## Release Workflow

### With Claude Code (Recommended)

Simply ask Claude to create a release:
```
"Create release 3.4.2 with ticket FSSDK-12345"
"Bump patch version with ticket FSSDK-12345"
```

Claude will execute the full workflow:
- ✅ Pre-flight checks (master branch, clean working tree)
- ✅ Create release branch (prepare-X.Y.Z)
- ✅ Update all 3 version files (pubspec.yaml, package_info.dart, README.md)
- ✅ Generate CHANGELOG.md template
- ✅ Commit and push
- ✅ Create PR

### Manual Release

```bash
# 1. Create release branch
git checkout -b prepare-X.Y.Z

# 2. Update versions (pubspec.yaml, package_info.dart, README.md)
# 3. Update CHANGELOG.md (add release notes at top)

# 4. Commit with standard format
git commit -m "chore: prepare for release X.Y.Z

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# 5. Push and create PR
git push -u origin prepare-X.Y.Z
gh pr create --title "[FSSDK-XXXXX] prepare for release X.Y.Z"

# 6. After merge, create GitHub release
gh release create vX.Y.Z --title "Release X.Y.Z" --draft --target master

# 7. Publish to pub.dev
flutter pub publish
```

### CHANGELOG Format
```markdown
## X.Y.Z
Month Day, Year

### New Features / Enhancements / Bug Fixes
* Description ([#PR](link))
```

## Contributing Guidelines

### Commit Messages
Follow [Angular guidelines](https://github.com/angular/angular/blob/master/CONTRIBUTING.md#-commit-message-guidelines):
- `feat:` - New features
- `fix:` - Bug fixes
- `chore:` - Maintenance
- `docs:` - Documentation
- `refactor:` - Code restructuring
- `test:` - Test additions

### Branch Strategy
- **Never commit directly to `master`**
- Feature branches: `feature/name`, `prepare-X.Y.Z`, `fix/name`
- All PRs target `master` branch

### Requirements
- Tests required for all code changes
- All CI checks must pass (4 parallel workflows)
- Apache 2.0 license header on new files
- Sign CLA (Contributor License Agreement)

### CI Pipeline
- `unit_test_coverage` (macOS) - Dart tests + Coveralls upload
- `build_test_android` (Ubuntu) - Android build validation
- `build_test_ios` (macOS) - iOS build validation
- `integration_android_tests` (Ubuntu) - Triggers `optimizely-flutter-testapp` repo
- `integration_ios_tests` (Ubuntu) - Triggers `optimizely-flutter-testapp` repo

## Platform Requirements

**Flutter/Dart:**
- Dart: >=2.16.2 <4.0.0
- Flutter: >=2.5.0

**Android:**
- minSdk: 21 (Android 5.0)
- compileSdk: 35 (Android 15)
- Kotlin: 2.1.0
- Native SDK: android-sdk 5.1.1

**iOS:**
- Minimum: iOS 10.0
- Swift: 5.0
- Native SDK: OptimizelySwiftSDK 5.2.1

## Key Implementation Files

**Dart Layer:**
- `lib/optimizely_flutter_sdk.dart` - Public API (initialize, decide, track)
- `lib/src/optimizely_client_wrapper.dart` - Platform bridge (545 LOC)
- `lib/src/user_context/optimizely_user_context.dart` - User context operations
- `lib/src/data_objects/` - 21 response/request models

**Android Layer:**
- `android/src/.../OptimizelyFlutterSdkPlugin.java` - MethodChannel handler
- `android/src/.../OptimizelyFlutterClient.java` - Core client wrapper (921 LOC)
- `android/build.gradle` - Dependencies & SDK versions

**iOS Layer:**
- `ios/Classes/SwiftOptimizelyFlutterSdkPlugin.swift` - Plugin implementation (786 LOC)
- `ios/Classes/OptimizelyFlutterLogger.swift` - Logger bridge with task queue
- `ios/optimizely_flutter_sdk.podspec` - CocoaPods dependencies
