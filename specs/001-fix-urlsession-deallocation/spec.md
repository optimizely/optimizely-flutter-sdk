# Feature Specification: Fix Premature URLSession Deallocation Crash

**Feature Branch**: `001-fix-urlsession-deallocation`
**Created**: 2026-05-11
**Status**: Draft
**Input**: Fix EXC_BAD_ACCESS crash caused by premature network session invalidation in Optimizely Swift SDK network modules (BUG-8628)

## Clarifications

### Session 2026-05-21

- Q: Given the crash cannot be reproduced in-house (BUG-8628), what is the primary validation strategy for SC-001? → A: Code review only — root cause is clear (misplaced `defer` block fires before async completion callback), fix is deterministic; no test-based reproduction required.

## User Scenarios & Testing

### User Story 1 - SDK Initialization Completes Without Crash (Priority: P1)

An SDK consumer starts the Optimizely client, triggering a datafile download over the network. The download completes and the initialization callback is invoked with a valid result — no crash occurs, regardless of network latency or third-party library interference.

**Why this priority**: The datafile download is the first network operation during SDK initialization. A crash here prevents the SDK from functioning at all, blocking any A/B testing or feature flag evaluation.

**Independent Test**: Start the Optimizely client with a valid SDK key under slow or throttled network conditions. Verify the initialization completion callback is called with either a success result or a well-formed error. Confirm no EXC_BAD_ACCESS crash occurs.

**Acceptance Scenarios**:

1. **Given** the SDK is starting up, **When** the datafile download completes on a slow network (>2s latency), **Then** the initialization completion callback is called with a valid result and no crash occurs.
2. **Given** the SDK is starting up, **When** the datafile download fails due to a network error, **Then** the initialization completion callback is called with an appropriate error result (not a crash).
3. **Given** a third-party performance monitoring library (e.g., Firebase Performance Monitoring) is active, **When** the SDK downloads the datafile, **Then** the download completes without EXC_BAD_ACCESS regardless of any network session method interception by that library.

---

### User Story 2 - Event Dispatch Completes Without Crash (Priority: P1)

An SDK consumer tracks events. The SDK dispatches batched events to the Optimizely backend. Each dispatch completes and the callback executes with a valid result — no crash occurs under any network condition or concurrency level.

**Why this priority**: Event dispatch is a high-frequency operation used throughout normal SDK usage. The same premature session cleanup vulnerability exists here as in datafile download.

**Independent Test**: Track multiple events in rapid succession under varying network conditions. Verify all dispatch completion callbacks execute without crash.

**Acceptance Scenarios**:

1. **Given** the SDK is dispatching events, **When** multiple events are sent in rapid succession, **Then** all dispatch completion callbacks are called with valid results and no crash occurs.
2. **Given** the SDK is dispatching an event, **When** the network request takes longer than expected, **Then** the network session remains valid until the callback finishes, and the callback fires with a valid result.

---

### User Story 3 - ODP Operations Complete Without Crash (Priority: P2)

An SDK consumer uses ODP (Optimizely Data Platform) features. ODP segment fetches and ODP event sends complete and their callbacks execute without crashing, even under concurrent usage or slow network conditions.

**Why this priority**: ODP operations are used less frequently than datafile download and event dispatch, but contain the same session lifecycle vulnerability and will crash under the same conditions.

**Independent Test**: Trigger an ODP segment fetch and an ODP event send under throttled network conditions. Verify both completion callbacks execute without crash.

**Acceptance Scenarios**:

1. **Given** the SDK is fetching ODP segments, **When** the GraphQL network response is delayed, **Then** the completion callback executes with a valid result and no crash occurs.
2. **Given** the SDK is sending ODP events, **When** the network response is delayed, **Then** the completion callback executes with a valid result and no crash occurs.

---

### Edge Cases

- **`close()` called during an in-flight request**: The fix does not change `close()` semantics. Behavior when `OptimizelyClient.close()` is called while a request is in-flight is preserved as-is from before the fix. This scenario is explicitly out of scope.
- **Concurrent datafile downloads**: The existing serial dispatch queue already serializes download requests. The fix does not alter this queuing behavior.
- **Third-party NSURLSession interception (e.g., Firebase Performance)**: The fix is agnostic to method swizzling. Moving session invalidation inside the completion callback resolves the race condition regardless of whether any third-party library intercepts network session methods.
- **Memory pressure**: The fix does not alter memory management for sessions. Each session is still invalidated after its callback completes, bounding its lifetime.

## Requirements

### Functional Requirements

- **FR-001**: Each network session used for a request MUST remain valid and accessible until after the associated completion callback has fully executed.
- **FR-002**: Session cleanup MUST occur inside the completion callback of the network task — not in a synchronous `defer` block at the enclosing scope level that exits before the async callback fires.
- **FR-003**: This correction MUST be applied to all four affected network modules in the Optimizely Swift SDK:
  - `DefaultDatafileHandler.downloadDatafile()`
  - `DefaultEventDispatcher.sendEvent()`
  - `OdpEventApiManager.sendOdpEvents()`
  - `OdpSegmentApiManager.fetchQualifiedSegments()`
- **FR-004**: Each session MUST still be invalidated exactly once after use — the fix MUST NOT introduce network session resource leaks.
- **FR-005**: The fix MUST NOT alter any public API surface, method signatures, or observable SDK behavior beyond eliminating the crash.
- **FR-006**: All changes MUST be made exclusively in the Optimizely Swift SDK repository. The Optimizely Flutter SDK repository requires no code changes — it receives the fix by updating its dependency to the new Swift SDK release.

### Key Entities

- **Network Session**: Manages the lifecycle of a single HTTP request. Must be kept alive until all callbacks associated with its tasks have finished executing.
- **Completion Callback**: An asynchronous closure invoked when a network request finishes. Executes on a background thread after the enclosing function has already returned. Must execute while the session is still valid.
- **Session Cleanup**: The act of releasing a network session after its task completes. Must occur after — not before — the completion callback finishes.
- **Synchronous Scope Exit**: The point at which a function or async block returns. A `defer` registered at this scope fires here, which is earlier than when an async completion callback executes.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Zero EXC_BAD_ACCESS crashes originating from network session callbacks across all four corrected modules. Verified by code review — the crash is not reproducible in-house (BUG-8628) and the root cause is deterministic and unambiguous.
- **SC-002**: All four corrected code paths exhibit session cleanup occurring after completion callback execution, confirmed by code review of each change.
- **SC-003**: No network session resource leaks are introduced — each session is invalidated exactly once, confirmed by code review.
- **SC-004**: All existing unit and integration tests in the Optimizely Swift SDK pass without modification after the fix is applied.

## Assumptions

- The crash is caused solely by session cleanup being triggered before the async completion callback executes. No deeper architectural issue in session lifecycle management is assumed.
- The fix applies exclusively to the Optimizely Swift SDK source repository. The Flutter SDK receives the fix by updating its CocoaPods dependency to the new Swift SDK release containing the fix.
- Firebase Performance Monitoring's NSURLSession method interception exacerbates the race condition but is not the root cause. The fix resolves the crash regardless of whether Firebase or any similar library is present.
- The session factory methods (`getSession()`) create ephemeral, non-shared session instances — each network request owns its session exclusively. Moving cleanup inside the callback does not affect session reuse.
- Flutter SDK plugin-level threading issues (e.g., potential data race on `optimizelyClientsTracker` dictionary) are a separate concern and explicitly out of scope for this fix.
- The crash cannot be reproduced in-house (BUG-8628). Validation relies on code review of the deterministic, clearly-scoped fix rather than test-based reproduction.
- The fix is self-contained: no changes to public API, no new dependencies, no behavioral changes other than eliminating the crash.
