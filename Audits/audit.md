# Audit: swift-iso-9945

## Code Surface — 2026-04-10

### Scope

- **Target**: swift-iso-9945 (all source targets)
- **Skill**: code-surface — [API-NAME-001], [API-NAME-002], [API-NAME-003], [API-NAME-004], [API-NAME-004a], [API-ERR-001], [API-ERR-002], [API-ERR-003], [API-ERR-004], [API-IMPL-003], [API-IMPL-005], [API-IMPL-006], [API-IMPL-007], [API-IMPL-008], [API-IMPL-009], [API-IMPL-010], [API-IMPL-011]
- **Files**: 121 Swift source files across 14 targets (excluding CISO9945Shim)

### Findings

| # | Severity | Rule | Location | Finding | Status |
|---|----------|------|----------|---------|--------|
| 1 | HIGH | [API-IMPL-005] | `Sources/ISO 9945 Kernel Process/ISO 9945.Kernel.Process.Status.swift` | 6 type declarations: `Status`, `Exit`, `Terminating`, `Stop`, `Core`, `Classification`. | RESOLVED 2026-04-10 — extracted to 5 new files |
| 2 | HIGH | [API-IMPL-005] | `Sources/ISO 9945 Kernel Thread/ISO 9945.Kernel.Thread.Mutex.swift` | 3 type declarations: `Mutex`, `Lock`, `Error`. | RESOLVED 2026-04-10 — `Lock` extracted to `Mutex.Lock.swift` with `Error` in extension; body members moved to extensions |
| 3 | HIGH | [API-IMPL-005] | `Sources/ISO 9945 Kernel Socket/ISO 9945.Kernel.Socket.Pair.swift` | 3 type declarations: `Pair`, `Error`, `Platform`. | RESOLVED 2026-04-10 — `Error` + `Platform` extracted to `Pair.Error.swift` |
| 4 | HIGH | [API-IMPL-005] | `Sources/ISO 9945 Kernel Process/ISO 9945.Kernel.Process.Wait.swift` | 3 type declarations: `Wait`, `Selector`, `Result`. | RESOLVED 2026-04-10 — `Selector` and `Result` extracted to own files |
| 5 | HIGH | [API-IMPL-005] | `Sources/ISO 9945 Kernel Process/ISO 9945.Kernel.Process.Group.swift` | 2 sibling type declarations: `Process` and `Target`. | RESOLVED 2026-04-10 — extracted to `Group.Process.swift` and `Group.Target.swift` |
| 6 | HIGH | [API-IMPL-005] | `Sources/ISO 9945 Kernel File/ISO 9945.Kernel.Device.swift` | 2 type declarations: `Major` and `Minor`. | RESOLVED 2026-04-10 — extracted to `Device.Major.swift` and `Device.Minor.swift` with `ExpressibleByIntegerLiteral` + `CustomStringConvertible` |
| 7 | HIGH | [API-IMPL-005] | `Sources/ISO 9945 Kernel Process/ISO 9945.Kernel.Process.Kill.swift` | 2 type declarations: `Kill` and `Process.Signal`. | RESOLVED 2026-04-10 — `Process.Signal` deleted; `kill()` now accepts `Signal.Number` from Core |
| 8 | HIGH | [API-IMPL-005] [API-IMPL-006] | `Sources/ISO 9945 Kernel Signal/ISO 9945.Kernel.Signal.Action.Handler.swift` | `Signal.Action` namespace declared in `Handler.swift` instead of `Action.swift`. | RESOLVED 2026-04-10 — `Action` namespace moved to `Action.swift` |
| 9 | HIGH | [API-NAME-002] | `Sources/ISO 9945 Kernel File/ISO 9945.Kernel.File.Attributes.swift` | `setPermissions` — compound method name. | RESOLVED 2026-04-10 — renamed to `set(_:at:)` (path) and `set(_:on:)` (descriptor); `init(major: UInt32, minor: UInt32)` made `internal` |
| 10 | HIGH | [API-IMPL-008] | `Sources/ISO 9945 Kernel Signal/ISO 9945.Kernel.Signal.Set.swift` | `Signal.Set` struct body with 6 non-canonical members. | RESOLVED 2026-04-10 — body reduced to `storage` + `init()`; all others moved to extension |
| 11 | MEDIUM | [API-IMPL-005] | `Sources/ISO 9945 Kernel Process/ISO 9945.Kernel.Process.Fork.swift` | 2 types: `Fork` + `Result`. | RESOLVED 2026-04-10 — `Result` extracted to `Fork.Result.swift` |
| 12 | MEDIUM | [API-IMPL-005] | `Sources/ISO 9945 Kernel Signal/ISO 9945.Kernel.Signal.Mask.How.swift` | 2 types: `Mask` + `How`. | RESOLVED 2026-04-10 — `Mask` namespace moved to `Mask.swift` |
| 13 | MEDIUM | [API-IMPL-005] | `Sources/ISO 9945 Kernel Memory/ISO 9945.Kernel.Memory.Lock.All.Options.swift` | 2 types: `All` + `Options`. | RESOLVED 2026-04-10 — `All` namespace moved to existing `Lock.All.swift` |
| 14 | MEDIUM | [API-IMPL-005] | `Sources/ISO 9945 Kernel Memory/ISO 9945.Kernel.Memory.Map.Sync.Options.swift` | 2 types: `Sync` + `Options`. | RESOLVED 2026-04-10 — `Sync` namespace extracted to `Map.Sync.swift` |
| 15 | MEDIUM | [API-IMPL-005] | `Sources/ISO 9945 Kernel Process/ISO 9945.Kernel.Process.Wait.Options.swift` | 2 types: `Options` + `No`. | RESOLVED 2026-04-10 — `No` extracted to `Wait.Options.No.swift` |
| 16 | MEDIUM | [API-IMPL-005] | `Sources/ISO 9945 Kernel Signal/ISO 9945.Kernel.Signal.Error.swift` | 2 types: `Error` + `Semantic`. | RESOLVED 2026-04-10 — `Semantic` extracted to `Error.Semantic.swift` |
| 17 | MEDIUM | [API-IMPL-005] | `Sources/ISO 9945 Kernel Process/ISO 9945.Kernel.Process.Error.swift` | 2 types: `Error` + `Semantic`. | RESOLVED 2026-04-10 — `Semantic` extracted to `Error.Semantic.swift` |
| 18 | MEDIUM | [API-NAME-001] | `Sources/ISO 9945 Kernel Lock/ISO 9945.Kernel.Lock.WithLockError.swift` | `WithLockError` — compound type name. | RESOLVED 2026-04-10 — renamed to `Lock.Scope.Error<E>`; file split to `Scope.swift` + `Scope.Error.swift`; old file deleted |
| 19 | MEDIUM | [API-NAME-002] | `Sources/ISO 9945 Kernel File/ISO 9945.Kernel.Device.swift` | `typedMajor` — compound identifier. | RESOLVED 2026-04-10 — removed; `var major` now returns `Major` directly (was `UInt32`) |
| 20 | MEDIUM | [API-NAME-002] | `Sources/ISO 9945 Kernel File/ISO 9945.Kernel.Device.swift` | `typedMinor` — compound identifier. | RESOLVED 2026-04-10 — removed; `var minor` now returns `Minor` directly (was `UInt32`) |
| 21 | MEDIUM | [API-IMPL-008] | `Sources/ISO 9945 Kernel System/CPU.Atomic.Flag.swift` | `CPU.Atomic.Flag` — `isSet` and `set()` in class body. | RESOLVED 2026-04-10 — moved to extension |
| 22 | MEDIUM | [API-IMPL-008] | `Sources/ISO 9945 Kernel Thread/ISO 9945.Kernel.Thread.Mutex.swift` | `Mutex.Lock` — nested type + methods in struct body. | RESOLVED 2026-04-10 — `Lock` extracted to own file with body members in extensions |
| 23 | MEDIUM | [API-IMPL-008] | `Sources/ISO 9945 Kernel Directory/ISO 9945.Kernel.Directory.swift` | `Directory.Stream` — `close()` and `next()` in class body. | RESOLVED 2026-04-10 — moved to extension |
| 24 | LOW | [API-NAME-002] | `Sources/ISO 9945 Core/ISO 9945.Kernel.swift:41` | `fileDescriptor` — compound: file+Descriptor. | RESOLVED 2026-04-10 — veneer deleted entirely; property had zero production callers |
| 25 | LOW | [API-IMPL-008] | `Sources/ISO 9945 Kernel Signal/ISO 9945.Kernel.Signal.Mask.How.swift` | `Signal.Mask.How` — 3 static constants in struct body. | RESOLVED 2026-04-10 — moved to extension |
| 26 | LOW | [API-IMPL-008] | `Sources/ISO 9945 Kernel Signal/ISO 9945.Kernel.Signal.Action.Options.swift` | `Signal.Action.Options` — 7 static constants in struct body. | RESOLVED 2026-04-10 — moved to extension |
| 27 | LOW | [API-IMPL-008] | `Sources/ISO 9945 Kernel Memory/ISO 9945.Kernel.Memory.Shared.Access.swift` | Body is clean; statics correctly in extension. | FALSE_POSITIVE |

### Checks Passed

| Rule | Check | Result |
|------|-------|--------|
| [API-ERR-001] | Typed throws required | **PASS** — all 50+ `throws` declarations use typed throws; zero untyped `throws` found |
| [API-ERR-002] | Nested error types | **PASS** — all error types follow `Domain.Error` nesting |
| [API-ERR-003] | Describe failure, not recovery | **PASS** — error cases describe conditions (`.contention`, `.deadlock`, `.interrupted`) |
| [API-NAME-001] | Nest.Name pattern (types) | **PASS** (1 exception: #18 `WithLockError`) — all other types use Nest.Name correctly |
| [API-NAME-003] | Specification-mirroring names | **PASS** — types mirror POSIX/ISO 9945 terminology (Signal, Process, Fork, Wait, etc.) |
| [API-NAME-004] | No unification typealiases | **PASS** — all typealiases are namespace adoption ([API-NAME-004a]) or generic instantiation ([PATTERN-024]) |
| [API-IMPL-007] | Extension file naming | **PASS** — `+Constants.swift`, `+Path.Protocol.swift` follow convention |
| [API-IMPL-009] | Hoisted protocol pattern | **N/A** — no generic types requiring hoisted protocols found |
| [API-IMPL-010] | Visibility widening audit | **N/A** — no evidence of recent visibility changes |

### Summary

27 findings: 26 RESOLVED, 0 DEFERRED, 1 FALSE_POSITIVE. Build verified clean.

**Systemic patterns**:

1. **Multi-type files are pervasive** (15 files, findings #1–#8, #11–#17). The dominant pattern is namespace-enum + child type co-located in one file. This accounts for most MEDIUM findings. The HIGH findings involve sibling types or deep chains (3+ types). The legacy audit (2026-04-03) identified 7 of these; the count has grown because this audit applies the rule strictly — namespace enums count as type declarations.

2. **Type body overloading** (6 files, findings #10, #21–#23, #25–#26). Methods, computed properties, and static constants inside type bodies. `Signal.Set` (#10) is the worst offender with 6 non-canonical members. The package already demonstrates the correct pattern in `Signal.Number+Constants.swift` (static constants in extension file) and `Process.Status.swift` (accessor computed properties in extensions), so the fix pattern is established.

3. **Compound identifiers** (4 findings, #9, #19–#20, #24). `setPermissions` (#9) is the most impactful — a public API with a compound method name AND redundant parameter labeling. `typedMajor`/`typedMinor` (#19–#20) are less common patterns. `fileDescriptor` (#24) has a strong spec-mirroring argument.

**Comparison with legacy (2026-04-03)**:

| Legacy finding | Status |
|----------------|--------|
| P1 #1: WithLockError in Token.swift | RESOLVED — extracted to own file |
| P1 #2: Group.swift Process+Target | Still OPEN (#5) |
| P1 #3: Device.swift Major+Minor | Still OPEN (#6) |
| P1 #4: Wait.swift Selector+Result | Still OPEN (#4) |
| P1 #5: Clone.swift platform types | Not re-checked — platform-conditional |
| P1 #6: Status.swift 6 types | Still OPEN (#1) |
| P2 #8–#11: Status accessor body | RESOLVED — computed properties moved to extensions |

---

## Testing — 2026-04-08

### Scope

- **Target**: swift-iso-9945 test target (`ISO 9945 Kernel Tests`)
- **Skill**: testing — inventory of disabled, removed, and reduced-coverage tests after the 2026-04-07/08 test-target compile fix session
- **Files**: 13 test files modified

### Context

The test target had pre-existing compile errors that blocked the entire suite from running. Fixing the compile errors required navigating ~Copyable migrations, OptionSet -> struct migrations, removed Handle methods, missing helper executables, and the `Kernel.Descriptor(_rawValue:)` ownership-aliasing anti-pattern. Some tests could not be migrated as-is and were disabled or removed. This section inventories the lost coverage so it can be restored when the underlying API gaps are filled.

After the 2026-04-07/08 session: 527 tests in 258 suites pass. After the 2026-04-11 session: 534 tests in 269 suites pass (+7 net).

### Findings

| # | Severity | Rule | Location | Finding | Status |
|---|----------|------|----------|---------|--------|
| 1 | HIGH | TEST regression | `Tests/.../ISO 9945.Terminal.Stream.Read Tests.swift:46` | `Read bytes from pipe via stdin redirect` — disabled. Test redirected stdin to a pipe, read from `Terminal.Stream.stdin.read(into:)`, verified bytes. Original code constructed `Kernel.Descriptor(_rawValue: Terminal.Stream.stdin.rawValue)` which closed the test process's stdin on deinit. | DEFERRED — needs non-owning descriptor API for well-known fds OR a child-process harness. |
| 2 | HIGH | TEST regression | `Tests/.../ISO 9945.Terminal.Stream.Read Tests.swift:52` | `Read returns 0 on EOF when write end closed` — disabled. Test required closing only the write end of a pipe via `Kernel.Close.close(pipe.write)` but `pipe.write` is exposed via `_read` accessor (borrow), and `close` takes `consuming Kernel.Descriptor`. | RESOLVED 2026-04-11 — `Kernel.Pipe.Close.write()` splits descriptors via `Pair.apply`. Test re-enabled. |
| 3 | HIGH | TEST regression | `Tests/.../ISO 9945.Terminal.Stream.Read Tests.swift:58` | `Read escape sequence bytes from pipe` — disabled. Same root cause as #1. | DEFERRED — same as #1. |
| 4 | HIGH | TEST regression | `Tests/.../ISO 9945.Terminal.Stream.Read Tests.swift:63` | `Read multiple bytes preserves order` — disabled. Same root cause as #1. | DEFERRED — same as #1. |
| 5 | HIGH | TEST regression | `Tests/.../ISO 9945.Kernel.File.Handle Tests.swift` | `readReturnsBytesFromFile` — REMOVED. Tested `handle.read(into:at:)`. The `Kernel.File.Handle` type is declared in `swift-kernel-primitives` with the comment that `read/write/close/withDescriptor` are platform-provided in `swift-iso-9945`, but the POSIX implementations have not yet landed. | RESOLVED 2026-04-11 — Handle POSIX `read(into:)` implemented, test restored. |
| 6 | HIGH | TEST regression | `Tests/.../ISO 9945.Kernel.File.Handle Tests.swift` | `writeWritesBytesToFile` — REMOVED. Tested `handle.write(from:at:)`. | RESOLVED 2026-04-11 — Handle POSIX `write(from:)` implemented, test restored. |
| 7 | HIGH | TEST regression | `Tests/.../ISO 9945.Kernel.File.Handle Tests.swift` | `closeExplicitlyClosesHandle` — REMOVED. Tested `handle.close()` (idempotent explicit close). | RESOLVED 2026-04-11 — Handle POSIX `close()` implemented (consuming, @frozen enables cross-module partial consumption), test restored. |
| 8 | HIGH | TEST regression | `Tests/.../ISO 9945.Kernel.File.Handle Tests.swift` | `withDescriptorProvidesAccess` — REMOVED. Tested `handle.withDescriptor { }` accessor. | RESOLVED 2026-04-11 — `withDescriptor` deleted; `~Copyable` property borrowing (`handle.descriptor`) replaces the closure pattern. Test replaced with `descriptor property provides borrowing access`. |
| 9 | MEDIUM | TEST coverage loss | `Tests/.../ISO 9945.Kernel.Lock Tests.swift` | `withExclusiveExecutesBody` — re-acquire verification removed. Originally: after `withExclusive`, attempted `Immediate.lock` on the same fd to confirm release. Now only checks that the body ran. | RESOLVED 2026-04-11 — cross-process release verification added in `ISO 9945.Kernel.Lock.Integration Tests.swift`: `withExclusive releases lock visible to other process` spawns helper process that acquires after release. |
| 10 | MEDIUM | TEST coverage loss | `Tests/.../ISO 9945.Kernel.Lock Tests.swift` | `withExclusiveReleasesOnThrow` — re-acquire verification removed. Same pattern as #9. | RESOLVED 2026-04-11 — covered by `release allows cross-process acquisition` (same mechanism, verifies direct unlock). |
| 11 | MEDIUM | TEST coverage loss | `Tests/.../ISO 9945.Kernel.Lock Tests.swift` | `tokenAcquiresAndReleases` — re-acquire verification removed. Originally created Token, released, then re-acquired via `Immediate.lock` to confirm. Now just constructs Token and calls `release()`. | RESOLVED 2026-04-11 — `Token release allows cross-process acquisition` spawns helper after Token.release(). |
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

**Status after 2026-04-11 session**: 17 RESOLVED, 4 DEFERRED (pre-existing, awaiting API), 1 OPEN.

**Resolved in 2026-04-11 session** (7 items):
- #2: Pipe EOF test — `Kernel.Pipe.Close.write()` via `Pair.apply`
- #5-#7: Handle read/write/close — POSIX implementations landed
- #8: withDescriptor → `~Copyable` property borrowing (`handle.descriptor`)
- #9-#11: Lock release verification — cross-process tests using LockTestHelper

**Remaining open work**:

- **Terminal stream stdin redirection** (#1, #3, #4): use `borrowing` language feature for well-known fds + child-process test harness. No `Kernel.Descriptor.Borrowed` type — the `borrowing` keyword is sufficient. Affects 3 tests.
- **Path.scope error type assertion** (#20): consider exposing `Kernel.Path.ScopeError.body` or similar so consumers can unwrap to the underlying type for assertions.

**Resolved on triage**: #12-#19, #21, #22 — these test removals were correct because the underlying type semantics changed (Descriptor became `~Copyable`, Mode became a struct, the bundle struct can't exist) and the original tests were testing removed/changed behavior. They are recorded here for traceability, not for re-implementation.

**Systemic patterns**:

1. **Construction-implies-ownership**: Multiple tests assumed `Kernel.Descriptor(_rawValue:)` was a lightweight wrapper (legacy from when Descriptor was Copyable). With ~Copyable + auto-closing deinit, every such construction implies a fd close. The audit at `HANDOFF-descriptor-ownership-audit.md` (parent of this directory) tracks the same pattern in production code.
2. **Cross-module API drift**: Test files often lag behind cross-package API changes (Mode OptionSet -> struct, File.Handle methods, Path.scope wrapping, etc.). Per [TEST-027], test target compilation should be a commit gate, but in practice the gate was not being enforced. Re-establishing the gate would prevent the next round of cumulative drift.

### Provenance

Session commits:
- `1ed0c86` Fix pre-existing test-target compile errors
- `b347108` Fix Kernel.Lock.Token double-close via consuming ownership transfer
- `1c43b43` Remove test patterns that close well-known fds via Descriptor deinit

---

## Legacy — Consolidated 2026-04-08

### From: swift-institute/Research/audit-standards-p2.md (2026-04-03)

> Code-surface findings (P1 multi-type files, P1 compound names, P2 methods in body) superseded by fresh Code Surface audit above (2026-04-10).

#### P0: Foundation Imports [PRIM-FOUND-001]

**Result: PASS** — No `import Foundation` in any Sources/ directory.

#### P3: Missing Doc Comments [DOC-001]

**Result: FAIL — ~20 declarations (systemic pattern)**

Systematic gaps in RawRepresentable boilerplate (`rawValue`, `init(rawValue:)`) and some typealiases. Representative:

| # | Severity | Rule | Location | Finding |
|---|----------|------|----------|---------|
| 1 | P3 | DOC-001 | `Sources/.../ISO 9945.Kernel.File.Seek.swift:597` | `public let rawValue: Int32` — missing doc comment |
| 2 | P3 | DOC-001 | `Sources/.../ISO 9945.Kernel.Signal.Mask.How.swift:972` | `public let rawValue: Int32` — missing doc comment |
| 3 | P3 | DOC-001 | `Sources/.../ISO 9945.Kernel.Signal.Number.swift:4700` | `public let rawValue: Int32` — missing doc comment |
| 4 | P3 | DOC-001 | `Sources/.../ISO 9945.Kernel.Pipe.swift:2745` | `public let rawValue: Int32` — missing doc comment |
| 5 | P3 | DOC-001 | `Sources/.../ISO 9945.Kernel.Device.swift:8772,8784` | `public let rawValue: UInt32` — missing doc comment |
| 6 | P3 | DOC-001 | `Sources/.../ISO 9945.Kernel.Process.Status.swift:5743` | `public let rawValue: Int32` — missing doc comment |
| 7 | P3 | DOC-001 | `Sources/.../ISO 9945.Kernel.Process.Kill.swift:9642` | `public let rawValue: Int32` — missing doc comment |
| 8 | P3 | DOC-001 | `Sources/.../ISO 9945.Kernel.Memory.Lock.All.Flags.swift:10712` | `public let rawValue: Int32` — missing doc comment |
| 9 | P3 | DOC-001 | Various files | ~10 `public typealias Error = ...` — missing doc comments |

**Pattern**: Undocumented declarations are overwhelmingly RawRepresentable boilerplate. Systemic, not individual omissions.
