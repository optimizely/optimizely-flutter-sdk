# Copilot Instructions

## Project Constitution

All code changes MUST comply with the project constitution at `.specify/memory/constitution.md`. This document defines the team's non-negotiable standards for correctness, testing, security, observability, naming, PR discipline, and architectural simplicity. Read it before proposing changes.

## Tech Stack

This is a **Flutter SDK** wrapping native Optimizely SDKs for iOS and Android.

**Technology Stack:**
- **Dart/Flutter**: Cross-platform API layer (>=2.16.2, Flutter >=2.5.0)
- **Swift**: iOS native bridge (Swift 5.0, iOS 10.0+)
- **Kotlin/Java**: Android native bridge (Kotlin 2.1.0, Android 5.0+)
- **Native SDKs**: OptimizelySwiftSDK 5.2.1 (iOS), android-sdk 5.1.1 (Android)

## Folder Structure

- `lib/` - Dart SDK code (public API, wrapper, data objects, user context)
- `android/` - Android native plugin code (Java/Kotlin)
- `ios/` - iOS native plugin code (Swift)
- `test/` - Dart unit tests
- `example/` - Example Flutter app demonstrating SDK usage

## Code Conventions

### Dart
- Follow official [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `lowerCamelCase` for variables, methods, parameters
- Use `UpperCamelCase` for classes, types
- Prefix private members with underscore `_privateMethod`
- ALL methods return `BaseResponse` derivatives (never throw exceptions)
- Check `success` boolean and `reason` string for errors

### Swift (iOS)
- Follow Swift naming conventions
- Use type-safe Optional unwrapping
- iOS attributes need type metadata: `{"value": 123, "type": "int"}`

### Java/Kotlin (Android)
- Follow Android/Kotlin style guide
- Android uses direct primitives: `{"attribute": 123}`

## Testing

Run tests with:
```bash
flutter test                       # All tests
flutter test test/cmab_test.dart   # Specific test
flutter test --coverage            # With coverage
```

**Requirements:**
- Tests required for all code changes
- All CI checks must pass (4 parallel workflows)
- Test both success and error paths
- Mock platform channels appropriately

## Commit Messages

Follow [Angular guidelines](https://github.com/angular/angular/blob/master/CONTRIBUTING.md#-commit-message-guidelines):
- `feat:` - New features
- `fix:` - Bug fixes
- `chore:` - Maintenance
- `docs:` - Documentation
- `refactor:` - Code restructuring
- `test:` - Test additions

**Never commit directly to `master`** - use feature branches and PRs.
