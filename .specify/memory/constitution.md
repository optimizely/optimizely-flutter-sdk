<!--
Sync Impact Report
==================
Version change: 1.0.0 → 1.1.0 (codebase alignment audit)

Modified principles:
  - V. Thread Safety — corrected Android/iOS threading descriptions
  - VIII. Native SDK Version Pinning — removed stale pinned versions,
    now references source-of-truth files only

Added sections:
  - IX. CMAB & Async Decide
  - X. ODP Integration
  - XI. Event Batching Configuration
  - XII. Logger Bridge Architecture
  - Platform Compatibility: macOS/Windows noted as experimental

Removed sections: N/A

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

- **iOS**: The `mainThreadResult` wrapper is applied once at the top of
  `handle()` in `SwiftOptimizelyFlutterSdkPlugin.swift`, wrapping all
  handlers automatically. It checks `Thread.isMainThread` and dispatches
  to `DispatchQueue.main.async` if needed. Required by iOS 16+.
- **Android**: The inline `safeResult()` method in
  `OptimizelyFlutterSdkPlugin.java` routes all three `Result` methods
  (success/error/notImplemented) to the main thread via
  `Handler(Looper.getMainLooper())`. Short-circuits if already on main.
- Native → Dart notification dispatch (activate, track, decision,
  logEvent, configUpdate) MUST use `invokeMethod` on the main thread.
- Logger bridge callbacks MUST be dispatched to the main thread:
  iOS uses `DispatchQueue.main.async`, Android uses
  `mainThreadHandler.post()` in `FlutterLogbackAppender`.

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

Native Optimizely SDK versions are pinned in build configuration.
The source-of-truth for current versions is always the build files
themselves — not this document:

- **iOS**: `OptimizelySwiftSDK` version in
  `ios/optimizely_flutter_sdk.podspec` (CocoaPods) and
  `ios/optimizely_flutter_sdk/Package.swift` (SPM). Both files MUST
  declare the same version.
- **Android**: `com.optimizely.ab:android-sdk` version in
  `android/build.gradle`.

Native SDK upgrades MUST:

1. Be performed in a dedicated branch (not bundled with feature work).
2. Update both platforms simultaneously when possible.
3. Verify that the bridge layer still functions correctly by running
   the full test suite and integration tests.
4. Document the upgrade in `CHANGELOG.md` with the old and new
   versions.

### IX. CMAB & Async Decide

The SDK supports Contextual Multi-Armed Bandit (CMAB) decisions.

- `CmabConfig` data object (in `lib/src/data_objects/`) carries CMAB
  configuration in decide responses.
- `decideAsync`, `decideForKeysAsync`, and `decideAllAsync` provide
  non-blocking decide calls that support CMAB lookups requiring
  network round-trips.
- Three CMAB-specific decide options MUST be supported:
  `ignoreCmabCache`, `resetCmabCache`, `invalidateUserCmabCache`.
- Async decide methods MUST have dispatch cases on both iOS and
  Android native layers alongside their synchronous counterparts.
- CMAB constants MUST be synchronised across Dart, Swift, and Java
  constant files.

### X. ODP Integration

The SDK integrates with Optimizely Data Platform (ODP) for audience
segmentation and event tracking.

- **Segments**: `fetchQualifiedSegments`, `getQualifiedSegments`,
  `setQualifiedSegments`, and `isQualifiedFor` manage user segment
  membership. Segment fetch options control caching behaviour.
- **Events**: `sendOdpEvent` dispatches custom events to ODP.
- **VUID**: `getVuid()` returns the Visitor UUID. Enabled via
  `enableVuid` in `SDKSettings`.
- **Configuration**: `SDKSettings` exposes ODP tuning fields:
  `segmentsCacheSize`, `segmentsCacheTimeoutInSecs`, `disableOdp`.
- All ODP features MUST follow the same cross-platform parity
  requirements as other SDK features (Principle III).

### XI. Event Batching Configuration

The SDK supports configurable event batching via `EventOptions`:

- `batchSize` — number of events per batch.
- `timeInterval` — flush interval in milliseconds.
- `maxQueueSize` — maximum queued events before forced flush.

Event batching settings are passed during SDK initialisation and
forwarded to the native SDKs. Changes to event batching MUST be
tested on both platforms.

### XII. Logger Bridge Architecture

The SDK uses a dual-channel architecture for logging:

- **Main channel** (`optimizely_flutter_sdk`) — all API operations.
- **Logger channel** (`optimizely_flutter_sdk_logger`) — native → Dart
  log forwarding.

Dart layer:
- `OptimizelyLogger` abstract class defines the logging interface.
- `DefaultOptimizelyLogger` provides the default implementation.
- `LoggerBridge` listens on the logger channel and forwards native
  log messages to the Dart logger.

Native layer:
- **iOS**: `OptimizelyFlutterLogger.swift` dispatches log calls to
  the main thread via `DispatchQueue.main.async`.
- **Android**: `FlutterLogbackAppender` uses logback integration and
  dispatches via `mainThreadHandler.post()`.

Custom loggers are configured during SDK initialisation via the
`logger` parameter.

## Platform Compatibility Standards

### Minimum Platform Versions

| Platform | Minimum | Compile/Target |
|----------|---------|----------------|
| Dart     | >=2.16.2 | <4.0.0        |
| Flutter  | >=2.5.0  | —             |
| Android  | API 21 (5.0) | API 35 (15) |
| iOS      | 10.0     | —             |
| macOS    | Declared | Experimental   |
| Windows  | Declared | Experimental   |

macOS and Windows plugin platforms are declared in `pubspec.yaml` but
are not yet fully supported — they share the Dart layer but lack
dedicated native plugin implementations. They are NOT subject to
Principle III (Platform Parity) until formally promoted.

Changes that raise minimum platform versions for iOS or Android MUST
be treated as breaking changes (major version bump).

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

All five CI jobs MUST pass before merge:

1. `unit_test_coverage` — Dart tests + Coveralls upload (macOS)
2. `build_test_android` — Android build validation (Ubuntu)
3. `build_test_ios` — iOS build validation (macOS)
4. `integration_android_tests` — Triggers `optimizely-flutter-testapp`
   repo via ci-helper-tools (Ubuntu)
5. `integration_ios_tests` — Triggers `optimizely-flutter-testapp`
   repo via ci-helper-tools (Ubuntu)

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

**Version**: 1.1.1 | **Ratified**: 2022-06-07 | **Last Amended**: 2026-08-22
