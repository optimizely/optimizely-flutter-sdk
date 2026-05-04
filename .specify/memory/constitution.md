<!--
Sync Impact Report
==================
Version change: 0.0.0 → 1.0.0 (initial ratification)

Modified principles: N/A (initial version)

Added sections:
  - Core Principles (8 principles)
  - Platform Compatibility Standards
  - Development Workflow & Quality Gates
  - Governance

Removed sections: N/A (initial version)

Templates requiring updates:
  - .specify/templates/plan-template.md — ✅ reviewed, compatible
  - .specify/templates/spec-template.md — ✅ reviewed, compatible
  - .specify/templates/tasks-template.md — ✅ reviewed, compatible

Follow-up TODOs: None
-->

# Optimizely Flutter SDK Constitution

## Core Principles

### I. Bridge Pattern Integrity

All features MUST follow the three-layer bridge architecture:

1. **Dart API Layer** — Public-facing classes (`OptimizelyFlutterSdk`,
   `OptimizelyUserContext`) that consumers import and call.
2. **MethodChannel Bridge** — `OptimizelyClientWrapper` serialises calls
   to `Map<String, dynamic>` and dispatches via `MethodChannel`.
3. **Native Plugin Layer** — Platform-specific handlers
   (`SwiftOptimizelyFlutterSdkPlugin.swift`,
   `OptimizelyFlutterClient.java`) that delegate to the native
   Optimizely SDKs.

No Dart code may call native SDK APIs directly. No native plugin may
expose platform-specific behaviour that bypasses the Dart wrapper.
Every new feature MUST touch all three layers and use the dual
MethodChannel architecture (`optimizely_flutter_sdk` for API,
`optimizely_flutter_sdk_logger` for log forwarding).

### II. Response Object Pattern (NON-NEGOTIABLE)

Every public SDK method MUST return a `BaseResponse` derivative.
Methods MUST NOT throw exceptions to callers. Errors are communicated
exclusively through the `success` boolean and `reason` string fields.

- `_invoke()` in `OptimizelyClientWrapper` catches
  `PlatformException` and converts it to `{success: false, reason: message}`.
- Native plugins MUST return result maps with `success` and `reason`
  keys, never throw unhandled exceptions across the MethodChannel.
- New response types MUST extend `BaseResponse` and live in
  `lib/src/data_objects/`.

### III. Platform Parity

Every feature MUST be implemented on both Android and iOS before
merging to `master`. A feature that works on only one platform is
incomplete.

- Method dispatch cases MUST exist in both
  `SwiftOptimizelyFlutterSdkPlugin.handle()` and
  `OptimizelyFlutterSdkPlugin.onMethodCall()`.
- Constants (API names, parameter keys, response keys) MUST be
  synchronised across `Constants.dart`, `Constants.swift`, and
  `Constants.java`.
- Behaviour MUST be functionally identical on both platforms, even
  when native SDK APIs differ in shape.

### IV. Type Safety Across the Bridge

Platform-specific type encoding MUST be handled transparently by
`Utils.convertToTypedMap()` in the Dart layer.

- **iOS** requires explicit type metadata:
  `{"value": 123, "type": "int"}`.
- **Android** uses direct primitives: `{"attribute": 123}`.
- All supported types (string, int, double, bool, map, list) MUST be
  covered by the conversion utility.
- The `forceIOSFormat` parameter MUST be used in tests to verify iOS
  encoding without requiring a physical device.
- New attribute types MUST be added to the conversion utility before
  they are used anywhere else.

### V. Thread Safety

All MethodChannel result callbacks MUST execute on the main thread.

- **iOS**: Use the `mainThreadResult` wrapper for every `FlutterResult`
  callback. This is required by iOS 16+ and prevents crashes.
- **Android**: Use the `MainThreadResult` wrapper to enforce main-thread
  execution of `MethodChannel.Result` callbacks.
- Native → Dart notification dispatch (activate, track, decision,
  logEvent, configUpdate) MUST use `invokeMethod` on the main thread.
- Logger bridge callbacks MUST be dispatched safely from background
  task queues to the main channel.

### VI. Multi-Instance State Isolation

The SDK MUST support multiple concurrent instances keyed by `sdkKey`.

- SDK instances, user contexts, and notification listeners MUST be
  tracked in isolated maps: `sdkKey → resource`.
- User contexts MUST be uniquely identified by `sdkKey + userContextId`.
- `close()` MUST clean up all resources (instances, contexts,
  listeners) for the given `sdkKey`.
- No global mutable state is permitted outside of the per-`sdkKey`
  registry.

### VII. Version Synchronisation (NON-NEGOTIABLE)

The SDK version MUST be identical in exactly three locations:

1. `pubspec.yaml` → `version: X.Y.Z`
2. `lib/package_info.dart` → `version = 'X.Y.Z'`
3. `README.md` → Installation example `^X.Y.Z`

A release MUST NOT be tagged or published if these three values
diverge. Strict semantic versioning applies: breaking public API
changes MUST increment the major version. New features increment
minor. Bug fixes increment patch.

### VIII. Native SDK Version Pinning

Native Optimizely SDK versions are pinned in build configuration:

- **iOS**: `OptimizelySwiftSDK` version in
  `ios/optimizely_flutter_sdk.podspec`.
- **Android**: `com.optimizely.ab:android-sdk` version in
  `android/build.gradle`.

Native SDK upgrades MUST:

1. Be performed in a dedicated branch (not bundled with feature work).
2. Update both platforms simultaneously when possible.
3. Verify that the bridge layer still functions correctly by running
   the full test suite and integration tests.
4. Document the upgrade in `CHANGELOG.md` with the old and new
   versions.

## Platform Compatibility Standards

### Minimum Platform Versions

| Platform | Minimum | Compile/Target |
|----------|---------|----------------|
| Dart     | >=2.16.2 | <4.0.0        |
| Flutter  | >=2.5.0  | —             |
| Android  | API 21 (5.0) | API 35 (15) |
| iOS      | 10.0     | —             |

Changes that raise minimum platform versions MUST be treated as
breaking changes (major version bump).

### Language & Tooling

| Layer   | Language   | Version   |
|---------|------------|-----------|
| Dart    | Dart       | >=2.16.2  |
| Android | Java/Kotlin| Kotlin 2.1.0 |
| iOS     | Swift      | 5.0       |

### Licensing

All source code files (`.dart`, `.java`, `.swift`, `.kt`) MUST carry
the Apache 2.0 license header. Test files, configuration files, and
documentation are exempt.

## Development Workflow & Quality Gates

### Branching

- **Never** commit directly to `master`.
- Feature branches: `feature/<name>`, `fix/<name>`.
- Release branches: `prepare-X.Y.Z`.
- All PRs target `master`.

### Testing

Tests MUST accompany all code changes. The testing approach is
flexible (TDD is encouraged but not mandated), provided that:

- Unit tests exist in `test/` for all new Dart-layer behaviour.
- Mock MethodChannel responses via `TestDefaultBinaryMessenger`.
- Platform-specific type encoding is tested using `forceIOSFormat`.
- `flutter test` passes with zero failures before merge.
- `flutter analyze` reports zero issues before merge.

### Commit Messages

Follow Angular commit message guidelines:

- `feat:` — New features
- `fix:` — Bug fixes
- `chore:` — Maintenance and releases
- `docs:` — Documentation only
- `refactor:` — Code restructuring
- `test:` — Test additions or modifications

### CI Pipeline

All four CI jobs MUST pass before merge:

1. `unit_test_coverage` — Dart tests + Coveralls upload (macOS)
2. `build_test_android` — Android build validation (Ubuntu)
3. `build_test_ios` — iOS build validation (macOS)
4. Integration tests — Triggered in `optimizely-flutter-testapp`

### Adding a Cross-Platform Feature (Checklist)

1. Add data models in `lib/src/data_objects/` if needed.
2. Update `lib/src/optimizely_client_wrapper.dart` with MethodChannel
   call.
3. Add handler case in `OptimizelyFlutterClient.java` (Android).
4. Add handler case in `SwiftOptimizelyFlutterSdkPlugin.swift` (iOS).
5. Handle type conversions (iOS metadata wrapping).
6. Write tests in `test/`.
7. Update public API in `lib/optimizely_flutter_sdk.dart`.

### CLA Requirement

All contributors MUST sign the Contributor License Agreement before
their first PR can be merged.

## Governance

This constitution is the authoritative reference for architectural
decisions and development standards in the Optimizely Flutter SDK.
All code changes MUST comply with the principles defined above.

### Amendment Procedure

1. Edit `.specify/memory/constitution.md` directly.
2. Increment the version according to semantic versioning:
   - **MAJOR**: Principle removal or backward-incompatible redefinition.
   - **MINOR**: New principle or materially expanded guidance.
   - **PATCH**: Clarifications, wording, or non-semantic refinements.
3. Update `LAST_AMENDED_DATE` to the current date.
4. Commit with message format:
   `docs: amend constitution to vX.Y.Z (<summary>)`.
5. Propagate changes to dependent templates if principles are
   added, renamed, or removed.

### Compliance

- PRs SHOULD reference the relevant principle when introducing
  architectural changes.
- Complexity beyond what the principles allow MUST be justified in
  the PR description.
- Use `CLAUDE.md` for runtime development guidance that supplements
  (but does not override) this constitution.

**Version**: 1.0.0 | **Ratified**: 2022-06-07 | **Last Amended**: 2026-04-29
