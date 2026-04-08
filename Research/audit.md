# Audit: swift-iso-9945

## Testing — 2026-04-08

### Scope

- **Target**: swift-iso-9945 test target (`ISO 9945 Kernel Tests`)
- **Skill**: testing — inventory of disabled, removed, and reduced-coverage tests after the 2026-04-07/08 test-target compile fix session
- **Files**: 13 test files modified

### Context

The test target had pre-existing compile errors that blocked the entire suite from running. Fixing the compile errors required navigating ~Copyable migrations, OptionSet → struct migrations, removed Handle methods, missing helper executables, and the `Kernel.Descriptor(_rawValue:)` ownership-aliasing anti-pattern. Some tests could not be migrated as-is and were disabled or removed. This section inventories the lost coverage so it can be restored when the underlying API gaps are filled.

After the session: all 527 tests in 258 suites pass, zero issues. The lost coverage is what was excluded to reach that state.

### Findings

| # | Severity | Rule | Location | Finding | Status |
|---|----------|------|----------|---------|--------|
| 1 | HIGH | TEST regression | `Tests/.../ISO 9945.Terminal.Stream.Read Tests.swift:46` | `Read bytes from pipe via stdin redirect` — disabled. Test redirected stdin to a pipe, read from `Terminal.Stream.stdin.read(into:)`, verified bytes. Original code constructed `Kernel.Descriptor(_rawValue: Terminal.Stream.stdin.rawValue)` which closed the test process's stdin on deinit. | DEFERRED — needs non-owning descriptor API for well-known fds OR a child-process harness. |
| 2 | HIGH | TEST regression | `Tests/.../ISO 9945.Terminal.Stream.Read Tests.swift:52` | `Read returns 0 on EOF when write end closed` — disabled. Test required closing only the write end of a pipe via `Kernel.Close.close(pipe.write)` but `pipe.write` is exposed via `_read` accessor (borrow), and `close` takes `consuming Kernel.Descriptor`. | DEFERRED — needs `Pipe.Descriptors.takeWrite() -> Kernel.Descriptor` (consuming) or equivalent. |
| 3 | HIGH | TEST regression | `Tests/.../ISO 9945.Terminal.Stream.Read Tests.swift:58` | `Read escape sequence bytes from pipe` — disabled. Same root cause as #1. | DEFERRED — same as #1. |
| 4 | HIGH | TEST regression | `Tests/.../ISO 9945.Terminal.Stream.Read Tests.swift:63` | `Read multiple bytes preserves order` — disabled. Same root cause as #1. | DEFERRED — same as #1. |
| 5 | HIGH | TEST regression | `Tests/.../ISO 9945.Kernel.File.Handle Tests.swift` | `readReturnsBytesFromFile` — REMOVED. Tested `handle.read(into:at:)`. The `Kernel.File.Handle` type is declared in `swift-kernel-primitives` with the comment that `read/write/close/withDescriptor` are platform-provided in `swift-iso-9945`, but the POSIX implementations have not yet landed. | DEFERRED — re-add when `ISO_9945.Kernel.File.Handle.read` is implemented. |
| 6 | HIGH | TEST regression | `Tests/.../ISO 9945.Kernel.File.Handle Tests.swift` | `writeWritesBytesToFile` — REMOVED. Tested `handle.write(from:at:)`. | DEFERRED — re-add when `ISO_9945.Kernel.File.Handle.write` is implemented. |
| 7 | HIGH | TEST regression | `Tests/.../ISO 9945.Kernel.File.Handle Tests.swift` | `closeExplicitlyClosesHandle` — REMOVED. Tested `handle.close()` (idempotent explicit close). | DEFERRED — re-add when `ISO_9945.Kernel.File.Handle.close` is implemented. |
| 8 | HIGH | TEST regression | `Tests/.../ISO 9945.Kernel.File.Handle Tests.swift` | `withDescriptorProvidesAccess` — REMOVED. Tested `handle.withDescriptor { }` accessor. | DEFERRED — re-add when `ISO_9945.Kernel.File.Handle.withDescriptor` is implemented. |
| 9 | MEDIUM | TEST coverage loss | `Tests/.../ISO 9945.Kernel.Lock Tests.swift` | `withExclusiveExecutesBody` — re-acquire verification removed. Originally: after `withExclusive`, attempted `Immediate.lock` on the same fd to confirm release. Now only checks that the body ran. | OPEN — coverage loss is acceptable since lock release is structurally guaranteed by Token's `release()` defer + Descriptor's auto-closing deinit (POSIX advisory locks released on close), but explicit release verification is still missing. |
| 10 | MEDIUM | TEST coverage loss | `Tests/.../ISO 9945.Kernel.Lock Tests.swift` | `withExclusiveReleasesOnThrow` — re-acquire verification removed. Same pattern as #9. | OPEN — same as #9. |
| 11 | MEDIUM | TEST coverage loss | `Tests/.../ISO 9945.Kernel.Lock Tests.swift` | `tokenAcquiresAndReleases` — re-acquire verification removed. Originally created Token, released, then re-acquired via `Immediate.lock` to confirm. Now just constructs Token and calls `release()`. | OPEN — same as #9. |
| 12 | MEDIUM | TEST regression | `Tests/.../ISO 9945.Kernel.Descriptor Tests.swift` | `descriptorIsEquatable` — REMOVED. Tested `==` between two Descriptors. `Kernel.Descriptor` is `~Copyable, Sendable` per [MEM-COPY-001] and intentionally not Equatable. | RESOLVED 2026-04-08 — type is correctly not Equatable; the test was semantically invalid. Compare via `.fileDescriptor` (Int32) raw values where identity comparison is needed. |
| 13 | MEDIUM | TEST regression | `Tests/.../ISO 9945.Kernel.Descriptor Tests.swift` | `descriptorIsHashable` — REMOVED. Tested `Set<Kernel.Descriptor>` insertion. Type is intentionally not Hashable. | RESOLVED 2026-04-08 — same as #12. |
| 14 | MEDIUM | TEST regression | `Tests/.../ISO 9945.Kernel.Descriptor Tests.swift` | `descriptorInDictionary` — REMOVED. Tested `[Kernel.Descriptor: String]`. Requires Hashable. | RESOLVED 2026-04-08 — same as #12. |
| 15 | LOW | TEST regression | `Tests/.../ISO 9945.Kernel.Descriptor Tests.swift` | `internalRawRoundtrip` — REMOVED. Constructed `Kernel.Descriptor(_rawValue: 42)` twice and checked round-trip via `.fileDescriptor`. Trivial accessor test using the ownership-aliasing anti-pattern. | RESOLVED 2026-04-08 — low-value test of an obvious accessor. |
| 16 | MEDIUM | TEST regression | `Tests/.../ISO 9945.Kernel.File.Open Tests.swift` | `modeIsOptionSet` — REMOVED. `Mode` was an OptionSet; tested `[.read, .write].contains(.read)`. Mode is now a struct with `read: Bool` and `write: Bool` fields. | RESOLVED 2026-04-08 — replaced by `explicitInit`, `readConstant`, `writeConstant`, `readWriteConstant` in `File.Open.Mode Tests.swift`. |
| 17 | MEDIUM | TEST regression | `Tests/.../ISO 9945.Kernel.File.Open Tests.swift` | `modeOptionsDistinct` — REMOVED. Tested `read.intersection(write).contains(.read) == false`. OptionSet API gone. | RESOLVED 2026-04-08 — replaced by `distinctConstants` in `File.Open.Mode Tests.swift`. |
| 18 | MEDIUM | TEST regression | `Tests/.../ISO 9945.Kernel.File.Open Tests.swift` | `modeIsSendable` (in File.Open Tests.swift) — REMOVED. Duplicate of test now in `File.Open.Mode Tests.swift`. | RESOLVED 2026-04-08 — preserved in dedicated `Mode Tests.swift`. |
| 19 | MEDIUM | TEST regression | `Tests/.../ISO 9945.Kernel.File.Open Tests.swift` | `modeCombine` — REMOVED. Same OptionSet pattern as #16. | RESOLVED 2026-04-08 — replaced by `readWriteConstant` in `Mode Tests.swift`. |
| 20 | LOW | TEST coverage loss | `Tests/.../ISO 9945.Kernel.File.Open Tests.swift:213` | `openWithExclusiveFailsIfExists` — error type assertion weakened. Originally `#expect(throws: Kernel.File.Open.Error.self)`. Now `do { ... } catch { /* any error */ }`. `Kernel.Path.scope` wraps the inner error in its own ScopeError, so the specific type is no longer reachable. | OPEN — re-tighten when there's an idiomatic way to unwrap `Kernel.Path.scope` errors to assert the underlying type. |
| 21 | LOW | TEST regression | `Tests/.../ISO 9945.Kernel.Lock.Integration Tests.swift` | `fdIsValid` assertions removed from all 11 tests. Originally each test extracted `let fdIsValid = testFile.fd.isValid; #expect(fdIsValid, "Failed to create test file")`. Helper now closes its internal fd before returning the path, so there's no persistent fd to validate. | RESOLVED 2026-04-08 — `makeLockTestFile` already throws on creation failure; the assertion was redundant. |
| 22 | LOW | TEST surface change | `Tests/.../ISO 9945.Kernel.Lock.Integration Tests.swift:127` | `LockTestFile` `~Copyable` bundle struct removed. Originally returned `(path, fd)` to callers. Replaced with `makeLockTestFile` returning just the path, plus `openLockTestFile(_:)` for fresh re-opens. | RESOLVED 2026-04-08 — Swift does not support tuples with ~Copyable elements per [IMPL-072], and the bundle struct could not yield the fd to callers for consumption. The split helper is the correct shape. |

### Summary

22 findings: 0 critical, 8 high, 9 medium, 5 low.

**Open work** (re-add coverage when underlying API exists):

- **Terminal stream stdin redirection** (#1, #3, #4): need either a non-owning Descriptor API for well-known fds (`stdin`/`stdout`/`stderr`) or a spawned child-process test harness with the pipe wired to its stdin. Affects 3 tests.
- **Pipe write-end EOF close** (#2): need `Pipe.Descriptors.takeWrite()` (consuming) or equivalent so callers can close one end of a pipe individually. Affects 1 test plus any future tests that need partial pipe close.
- **POSIX `Kernel.File.Handle` operations** (#5–#8): the `Handle` type is declared in `swift-kernel-primitives` with `read`/`write`/`close`/`withDescriptor` documented as platform-provided, but the POSIX implementations have not landed in `swift-iso-9945`. Affects 4 tests and is a real production gap, not just a test issue.
- **Lock release verification** (#9–#11): structurally guaranteed by `Token.release()` defer + Descriptor.deinit, but no explicit assertion that the release actually happened. Could add a multi-process test (similar to `lockWithDeadlineTimesOut`) that confirms lock release from a separate process's perspective.
- **Path.scope error type assertion** (#20): consider exposing `Kernel.Path.ScopeError.body` or similar so consumers can unwrap to the underlying type for assertions.

**Resolved on triage**: #12–#19, #21, #22 — these test removals were correct because the underlying type semantics changed (Descriptor became `~Copyable`, Mode became a struct, the bundle struct can't exist) and the original tests were testing removed/changed behavior. They are recorded here for traceability, not for re-implementation.

**Systemic patterns**:

1. **Construction-implies-ownership**: Multiple tests assumed `Kernel.Descriptor(_rawValue:)` was a lightweight wrapper (legacy from when Descriptor was Copyable). With ~Copyable + auto-closing deinit, every such construction implies a fd close. The audit at `HANDOFF-descriptor-ownership-audit.md` (parent of this directory) tracks the same pattern in production code.
2. **Cross-module API drift**: Test files often lag behind cross-package API changes (Mode OptionSet → struct, File.Handle methods, Path.scope wrapping, etc.). Per [TEST-027], test target compilation should be a commit gate, but in practice the gate was not being enforced. Re-establishing the gate would prevent the next round of cumulative drift.

### Provenance

Session commits:
- `1ed0c86` Fix pre-existing test-target compile errors
- `b347108` Fix Kernel.Lock.Token double-close via consuming ownership transfer
- `1c43b43` Remove test patterns that close well-known fds via Descriptor deinit

---

## Legacy — Consolidated 2026-04-08

### From: swift-institute/Research/audit-standards-p2.md (2026-04-03)

**Pre-publication audit — P0/P1/P2 checks**

#### P0: Foundation Imports [PRIM-FOUND-001]

**Result: PASS** — No `import Foundation` in any Sources/ directory.

#### P1: Multi-Type Files [API-IMPL-005]

**Result: FAIL — 7 files (4 actionable, 3 borderline)**

| # | Severity | Rule | Location | Finding | Action |
|---|----------|------|----------|---------|--------|
| 1 | P1 | API-IMPL-005 | `Sources/.../ISO 9945.Kernel.Lock.Token.swift` | `WithLockError` is a generic error type alongside `Token`. Two sibling types. | Extract `WithLockError` to own file |
| 2 | P1 | API-IMPL-005 | `Sources/.../ISO 9945.Kernel.Process.Group.swift` | `Process` and `Target` are sibling types. | Split to separate files |
| 3 | P1 | API-IMPL-005 | `Sources/.../ISO 9945.Kernel.Device.swift` | `Major` and `Minor` are sibling types under `Device`. | Split to `ISO 9945.Kernel.Device.Major.swift` and `ISO 9945.Kernel.Device.Minor.swift` |
| 4 | P1 | API-IMPL-005 | `Sources/.../ISO 9945.Kernel.Process.Wait.swift` | `Wait`, `Selector`, and `Result` are distinct types. `Selector` and `Result` are not nested in `Wait`. | Extract `Selector` and `Result` to own files |
| 5 | P1 (borderline) | API-IMPL-005 | `Sources/.../ISO 9945.Kernel.File.Clone.swift` | 4 types: `Clonefile`, `Copyfile`, `Ficlone`, `CopyRange` — each behind `#if os(...)`. Platform-conditional. | Consider per-platform splitting |
| 6 | P1 (borderline) | API-IMPL-005 | `Sources/.../ISO 9945.Kernel.Process.Status.swift` | 6 types: `Status`, `Exit`, `Terminating`, `Stop`, `Core`, `Classification`. Nest.Name accessor types tightly coupled to `Status`. | Borderline — tightly coupled accessors |
| 7 | acceptable | API-IMPL-005 | Various files | `Fork`/`Result`, `Mask`/`How`, `Error`/`Semantic`, `Action`/`Handler`, `Options`/`No`, `Mutex`/`Error`, `Signal.Error`/`Semantic`, `Socket.Pair`/`Error`/`Platform`, `Kill`/`Signal` — all nested types. | No action needed |

#### P1: Compound Type Names [API-NAME-001]

**Result: PASS** — All types use the Nest.Name pattern correctly (e.g., `Signal.Number`, `Process.Status`, `File.Clone`).

#### P2: Methods in Type Bodies [API-IMPL-008]

**Result: FAIL — 4 Nest.Name accessor types**

| # | Severity | Rule | Location | Finding | Action |
|---|----------|------|----------|---------|--------|
| 8 | P2 | API-IMPL-008 | `Sources/.../ISO 9945.Kernel.Process.Status.swift:80-92` | `Exit` — computed property `code` inside struct body | Move computed property to extension |
| 9 | P2 | API-IMPL-008 | `Sources/.../ISO 9945.Kernel.Process.Status.swift:98-109` | `Terminating` — computed property `signal` inside struct body | Move computed property to extension |
| 10 | P2 | API-IMPL-008 | `Sources/.../ISO 9945.Kernel.Process.Status.swift:116-128` | `Stop` — computed property `signal` inside struct body | Move computed property to extension |
| 11 | P2 | API-IMPL-008 | `Sources/.../ISO 9945.Kernel.Process.Status.swift:134-158` | `Core` — computed property `dumped` inside struct body | Move computed property to extension |

#### P3: Missing Doc Comments [DOC-001]

**Result: FAIL — ~20 declarations (systemic pattern)**

Systematic gaps in RawRepresentable boilerplate (`rawValue`, `init(rawValue:)`) and some typealiases. Representative:

| # | Severity | Rule | Location | Finding |
|---|----------|------|----------|---------|
| 12 | P3 | DOC-001 | `Sources/.../ISO 9945.Kernel.File.Seek.swift:597` | `public let rawValue: Int32` — missing doc comment |
| 13 | P3 | DOC-001 | `Sources/.../ISO 9945.Kernel.Signal.Mask.How.swift:972` | `public let rawValue: Int32` — missing doc comment |
| 14 | P3 | DOC-001 | `Sources/.../ISO 9945.Kernel.Signal.Number.swift:4700` | `public let rawValue: Int32` — missing doc comment |
| 15 | P3 | DOC-001 | `Sources/.../ISO 9945.Kernel.Pipe.swift:2745` | `public let rawValue: Int32` — missing doc comment |
| 16 | P3 | DOC-001 | `Sources/.../ISO 9945.Kernel.Device.swift:8772,8784` | `public let rawValue: UInt32` — missing doc comment |
| 17 | P3 | DOC-001 | `Sources/.../ISO 9945.Kernel.Process.Status.swift:5743` | `public let rawValue: Int32` — missing doc comment |
| 18 | P3 | DOC-001 | `Sources/.../ISO 9945.Kernel.Process.Kill.swift:9642` | `public let rawValue: Int32` — missing doc comment |
| 19 | P3 | DOC-001 | `Sources/.../ISO 9945.Kernel.Memory.Lock.All.Flags.swift:10712` | `public let rawValue: Int32` — missing doc comment |
| 20 | P3 | DOC-001 | Various files | ~10 `public typealias Error = ...` — missing doc comments |

**Pattern**: Undocumented declarations are overwhelmingly RawRepresentable boilerplate. Systemic, not individual omissions.

#### Summary

| Check | Result | Count |
|-------|--------|-------|
| P0: Foundation imports | PASS | 0 |
| P1: Multi-type files | FAIL | 7 files (4 actionable, 3 borderline) |
| P1: Compound type names | PASS | 0 |
| P2: Methods in type bodies | FAIL | 4 types |
| P3: Missing doc comments | FAIL | ~20 declarations |
