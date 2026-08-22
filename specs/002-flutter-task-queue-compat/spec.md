# Spec: FlutterTaskQueue Backward Compatibility

**Date**: 2026-08-22
**Status**: In Progress
**Severity**: Build-breaking on older Flutter + modern Xcode

## Problem

`SwiftOptimizelyFlutterSdkPlugin.register(with:)` calls
`registrar.messenger().makeBackgroundTaskQueue?()` and passes the result to
`FlutterMethodChannel(name:binaryMessenger:codec:taskQueue:)` when creating the
logger channel (line 52-56 of `SwiftOptimizelyFlutterSdkPlugin.swift`).

The `FlutterTaskQueue` protocol and the `makeBackgroundTaskQueue` method were
introduced in Flutter 3.3. However, on older Flutter versions (e.g. 3.16.0) the
`FlutterTaskQueue` protocol is declared in the ObjC header as a forward
reference without a full definition. When compiled with a modern Xcode (26.6+)
and iOS SDK (26.5+), the Swift compiler cannot import the incomplete protocol
and emits two hard errors:

```
error: value of type 'any FlutterBinaryMessenger' has no member 'makeBackgroundTaskQueue'
note: protocol 'FlutterTaskQueue' is incomplete

error: extra argument 'taskQueue' in call
```

This breaks the CocoaPods build path in the `optimizely-flutter-testapp` CI,
which uses Flutter 3.16.0 with the latest macOS runner (Xcode 26.6).

## Root Cause

Flutter 3.16.0's `Flutter.xcframework` ships an ObjC header where
`FlutterTaskQueue` is forward-declared but not fully defined. Swift's strict
ObjC interop (tightened in recent Xcode toolchains) rejects methods whose
return type references an incomplete protocol. Newer Flutter versions (3.44+)
ship a complete protocol definition, so the same code compiles cleanly.

## Impact

- **Testapp iOS CI**: Build failure on every run against the SDK's master
  branch or any feature branch.
- **Consumer apps**: Any app using an older Flutter version (< 3.22) with a
  modern Xcode will hit the same compilation error.
- **Functionality**: The `taskQueue` parameter is an optimization that routes
  logger channel callbacks to a background serial queue. Passing `nil` falls
  back to the platform's default (main thread), which is how the logger already
  operated before this code was added. There is no functional regression from
  removing it.

## Solution

Use `responds(to:)` to guard the `makeBackgroundTaskQueue` call at runtime.
If the method is unavailable (older Flutter), fall back to creating the
`FlutterMethodChannel` without a `taskQueue` parameter.

### Before

```swift
let taskQueue = registrar.messenger().makeBackgroundTaskQueue?()
let loggerChannel = FlutterMethodChannel(name: OptimizelyFlutterLogger.LOGGER_CHANNEL,
                                        binaryMessenger: registrar.messenger(),
                                        codec: FlutterStandardMethodCodec.sharedInstance(),
                                        taskQueue: taskQueue)
```

### After

```swift
let loggerChannel = FlutterMethodChannel(name: OptimizelyFlutterLogger.LOGGER_CHANNEL,
                                        binaryMessenger: messenger)
```

### Why drop `taskQueue` instead of guarding it?

A runtime guard (`responds(to:)`) is insufficient because the Swift compiler
rejects the code at **compile time** — `FlutterTaskQueue` is incomplete, so any
code path that references `makeBackgroundTaskQueue` or casts to `FlutterTaskQueue`
fails to compile regardless of whether it would execute at runtime.

`performSelector`-based workarounds are fragile and hard to maintain for a minor
optimization. The logger channel already dispatches callbacks to the main thread
via `DispatchQueue.main.async` in `OptimizelyFlutterLogger.swift`, so the
background task queue adds no real value here.

## Files Changed

| File | Change |
|------|--------|
| `ios/Classes/SwiftOptimizelyFlutterSdkPlugin.swift` | Remove `makeBackgroundTaskQueue` / `taskQueue` usage from logger channel creation |

## Testing

- **CI**: Re-run testapp iOS integration tests with Flutter 3.16.0 — build
  should succeed.
- **Local**: Build with Flutter 3.44.0 + Xcode 26.6 — `taskQueue` path should
  still be taken.
- **Existing tests**: No Dart-layer changes, so `flutter test` should pass
  unchanged.
