# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Optimizely Flutter SDK - Cross-platform plugin wrapping native Optimizely SDKs (iOS, Android) for A/B testing, feature flags, CMAB, and ODP integration and others.

**Main Branch:** master

## Project Structure

```
lib/                        # Dart: Public API, data models, user context, platform bridge
android/src/main/java/      # Java: OptimizelyFlutterClient.java, Plugin, helpers
ios/Classes/                # Swift: Plugin, logger bridge, helpers
test/                       # Unit tests (SDK, CMAB, logger, nested objects)
example/                    # Example app
```

## Essential Commands

```bash
# Setup
flutter pub get

# Testing
flutter test                                    # All tests
flutter test test/cmab_test.dart                # Specific test
flutter test --coverage                         # With coverage

# Linting
flutter analyze

# iOS setup
cd ios && pod install

# Run example
cd example && flutter run
```

## Architecture

### Bridge Pattern
```
Dart API (OptimizelyFlutterSdk)
    ↓
Wrapper (OptimizelyClientWrapper) + MethodChannel
    ↓
Native (Swift/Java plugin implementations)
    ↓
Native Optimizely SDKs
```

### Critical Patterns

**1. Response Object Pattern**
- ALL methods return `BaseResponse` derivatives (never throw exceptions)
- Check `success` boolean and `reason` string for errors

**2. Multi-Instance State**
- SDK instances tracked by `sdkKey`
- User contexts: `sdkKey → userContextId → context`
- Notification listeners: `sdkKey → listenerId → callback`
- Call `close()` for cleanup

**3. Platform-Specific Type Encoding**
- **iOS**: Attributes need type metadata: `{"value": 123, "type": "int"}`
- **Android**: Direct primitives: `{"attribute": 123}`
- Conversion in `convertToTypedMap()` (`optimizely_client_wrapper.dart`)

**4. Dual Channels**
- `optimizely_flutter_sdk` - Main API
- `optimizely_flutter_logger` - Native log forwarding

## Key Files

**Dart:**
- `lib/optimizely_flutter_sdk.dart` - Public API entry point
- `lib/src/optimizely_client_wrapper.dart` - Platform channel bridge
- `lib/src/user_context/optimizely_user_context.dart` - User context API
- `lib/src/data_objects/` - 21 response/request models

**Android:**
- `android/src/.../OptimizelyFlutterSdkPlugin.java` - MethodChannel handler
- `android/src/.../OptimizelyFlutterClient.java` - Core client wrapper
- `android/build.gradle` - Dependencies & build config

**iOS:**
- `ios/Classes/SwiftOptimizelyFlutterSdkPlugin.swift` - MethodChannel handler
- `ios/optimizely_flutter_sdk.podspec` - Pod dependencies

## Adding Cross-Platform Features

1. Add data models in `lib/src/data_objects/` if needed
2. Update `optimizely_client_wrapper.dart` with method channel call
3. **Android**: Add case in `OptimizelyFlutterClient.java`, parse args, call native SDK
4. **iOS**: Add case in `SwiftOptimizelyFlutterSdkPlugin.swift`, parse args, call native SDK
5. Handle type conversions (iOS requires metadata)
6. Add tests
7. Update public API in `optimizely_flutter_sdk.dart`


## Contributing

### Commit Format
Follow [Angular guidelines](https://github.com/angular/angular/blob/master/CONTRIBUTING.md#-commit-message-guidelines): `feat:`, `fix:`, `docs:`, `refactor:`, `test:`

### Requirements
- **Never commit directly to `master` branch** - Always create a feature branch
- Tests required for all changes
- PR to `master` branch
- All CI checks must pass (unit tests, build validation, integration tests)
- Apache 2.0 license header on new files

### CI Pipeline
- `unit_test_coverage` (macOS) - Coverage to Coveralls
- `build_test_android/ios` - Build validation
- `integration_android/ios_tests` - External test app triggers

## Platform Requirements

- Dart: >=2.16.2 <4.0.0, Flutter: >=2.5.0
- Android: minSdk 21, compileSdk 35
- iOS: 10.0+, Swift 5.0
