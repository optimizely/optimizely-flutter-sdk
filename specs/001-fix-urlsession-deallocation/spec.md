# Feature Specification: Fix Premature URLSession Deallocation Crash

**Feature Branch**: `001-fix-urlsession-deallocation`
**Created**: 2026-05-11
**Status**: Draft
**Input**: Fix EXC_BAD_ACCESS crash caused by premature URLSession invalidation in Optimizely Swift SDK network modules

## User Scenarios & Testing

### User Story 1 - Datafile Download Without Crash (Priority: P1)

An SDK consumer initializes the Optimizely client with `OptimizelyClient.start(resourceTimeout:completion:)`. The SDK downloads the datafile over the network. The download completes successfully without crashing, regardless of network latency, and the completion handler is called with valid data.

**Why this priority**: This is the primary crash path reported in production. The datafile download is the first network operation during SDK initialization — a crash here prevents the SDK from functioning at all.

**Independent Test**: Initialize an OptimizelyClient with a valid SDK key on a slow or throttled network connection. Verify initialization completes without EXC_BAD_ACCESS and the completion handler receives either a success result with datafile data or a well-formed error.

**Acceptance Scenarios**:

1. **Given** the SDK is initializing, **When** the datafile download completes on a slow network (>2s latency), **Then** the completion handler is called with a valid result and no crash occurs.
2. **Given** the SDK is initializing, **When** the datafile download fails due to a network error, **Then** the completion handler is called with an appropriate error result (not a crash).
3. **Given** the SDK is initializing and Firebase Performance Monitoring is active, **When** Firebase swizzles the NSURLSession delegate, **Then** the download still completes without EXC_BAD_ACCESS.

---

### User Story 2 - Event Dispatch Without Crash (Priority: P1)

An SDK consumer tracks events via the Optimizely SDK. The event dispatcher sends batched events to the Optimizely backend. The upload completes and the completion handler executes without accessing deallocated memory.

**Why this priority**: Event dispatch is a high-frequency operation. The same premature deallocation pattern exists in the event dispatcher, making it a crash risk under normal SDK usage.

**Independent Test**: Track multiple events in rapid succession under varying network conditions. Verify all event dispatch completion handlers execute without crash.

**Acceptance Scenarios**:

1. **Given** the SDK is tracking events, **When** multiple events are dispatched concurrently, **Then** all completion handlers are called with valid results and no crash occurs.
2. **Given** the SDK is dispatching an event, **When** the network request takes longer than expected, **Then** the URLSession remains valid until the completion handler finishes executing.

---

### User Story 3 - ODP Operations Without Crash (Priority: P2)

An SDK consumer uses ODP (Optimizely Data Platform) features including segment fetching and event sending. These operations make network requests that complete without crashing, even under concurrent usage or slow network conditions.

**Why this priority**: ODP operations are used less frequently than datafile downloads and event dispatch, but contain the same vulnerability and will crash under the same race conditions.

**Independent Test**: Trigger ODP segment fetch and ODP event dispatch under throttled network conditions. Verify completion handlers execute without crash.

**Acceptance Scenarios**:

1. **Given** the SDK is fetching ODP segments via GraphQL, **When** the network response is delayed, **Then** the completion handler executes with a valid result and no crash occurs.
2. **Given** the SDK is sending ODP events, **When** the network response is delayed, **Then** the completion handler executes with a valid result and no crash occurs.

---

### Edge Cases

- What happens when the URLSession completion handler fires after the enclosing object is deallocated (e.g., `OptimizelyClient.close()` called during in-flight request)?
- What happens under extreme memory pressure where the system aggressively reclaims resources?
- What happens when multiple concurrent datafile downloads or event dispatches are triggered simultaneously?
- What happens when a third-party library (e.g., Firebase Performance) swizzles NSURLSession methods, altering the callback delivery timing?

## Requirements

### Functional Requirements

- **FR-001**: The URLSession instance used for network requests MUST remain valid and not be invalidated until after the associated completion handler has finished executing.
- **FR-002**: The `session.finishTasksAndInvalidate()` call MUST occur inside the URLSession task completion handler closure, not in a `defer` block at the enclosing async scope level.
- **FR-003**: This fix MUST be applied consistently across all four affected network modules:
  - `DefaultDatafileHandler.downloadDatafile()`
  - `DefaultEventDispatcher.sendEvent()`
  - `OdpEventApiManager.sendOdpEvents()`
  - `OdpSegmentApiManager.fetchQualifiedSegments()`
- **FR-004**: The URLSession MUST still be properly invalidated after use to prevent resource leaks (preserving the intent of the original code).
- **FR-005**: The fix MUST NOT change any public API surface, method signatures, or observable behavior beyond eliminating the crash.
- **FR-006**: All existing unit tests for the affected modules MUST continue to pass without modification (unless a test was explicitly relying on the broken behavior).

### Key Entities

- **URLSession**: The Apple networking primitive that manages HTTP requests. Must follow a strict lifecycle: create, use for tasks, invalidate only after all task callbacks complete.
- **Completion Handler**: Asynchronous callback closures that execute when network requests finish. These closures capture `self` and must execute while the session is still valid.
- **Dispatch Queue**: Serial queue (`downloadQueue`) used to serialize datafile downloads. The `defer` in this queue's async block is the root cause — it fires when the block exits, not when the task completes.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Zero EXC_BAD_ACCESS crashes originating from URLSession delegate callbacks in the Optimizely SDK across all network modules.
- **SC-002**: All four affected code paths maintain proper URLSession lifecycle — session invalidation occurs only after completion handler execution, verified by code review and tests.
- **SC-003**: No URLSession resource leaks introduced — sessions are still invalidated after use, confirmed by profiling or leak-detection tests.
- **SC-004**: All existing unit and integration tests pass without modification after the fix is applied.
- **SC-005**: SDK initialization, event dispatch, and ODP operations function correctly under slow network conditions (>2s latency) without crash or hang.

## Assumptions

- The crash is caused solely by the misplaced `defer { session.finishTasksAndInvalidate() }` statement and not by a deeper architectural issue in URLSession lifecycle management.
- The fix applies to the Optimizely Swift SDK source (swift-sdk repository), which is consumed as a dependency by the Flutter SDK via CocoaPods (`OptimizelySwiftSDK 5.2.1`).
- Firebase Performance Monitoring's NSURLSession swizzling exacerbates the race condition but is not the root cause — the fix must work regardless of whether Firebase is present.
- The `getSession()` factory methods create ephemeral, non-shared URLSession instances, meaning each network request owns its session exclusively.
- Moving `finishTasksAndInvalidate()` inside the completion handler is safe because the session is not reused after the task completes.
