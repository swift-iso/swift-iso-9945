# ISO 9945 Kernel Modularization Analysis

> Date: 2026-04-10
> Status: Recommendation ready — awaiting decision
> Scope: Whether `ISO 9945 Kernel` (97 files, 11,834 lines) should be split into domain-specific targets

---

## Context

`ISO 9945 Kernel` is a single monolithic target at L2 (Standards) that provides POSIX
syscall wrappers for all kernel domains: file I/O, sockets, memory mapping, process
management, signals, threads, terminals, and system queries. It extends L1 vocabulary
types from `swift-kernel-primitives` with POSIX-specific implementations.

### Consumers

| Consumer | Layer | Package | Usage |
|----------|-------|---------|-------|
| `swift-posix` | L3 | `swift-foundations/swift-posix/` | Imports `ISO 9945 Kernel` (whole product) |
| `swift-linux-standard` | L2 | `swift-linux-foundation/swift-linux-standard/` | Imports `ISO 9945 Kernel` (two targets) |

Both consumers import the entire product. No consumer currently selectively imports a
subset of POSIX kernel functionality.

### L1 Precedent

`swift-kernel-primitives` (L1) is already modular with 23 targets organized by kernel
domain. ISO 9945 Kernel extends these L1 namespaces:

| L1 Target | L2 Extension (ISO 9945 Kernel) |
|-----------|-------------------------------|
| Kernel Primitives Core | Descriptor veneer, Error.captureErrno() |
| Kernel File Primitives | File.Open, File.Seek, File.Stats, etc. |
| Kernel IO Primitives | IO.Read, IO.Write |
| Kernel Socket Primitives | Socket.getError, Socket.Pair |
| Kernel Memory Primitives | Memory.Map (mmap/munmap/mprotect) |
| Kernel Process Primitives | Process.Fork, Process.Wait, Process.Spawn |
| Kernel Thread Primitives | Thread.Mutex, Thread.Condition |
| Kernel Terminal Primitives | Termios, TTY |
| Kernel System Primitives | System.Name, uname |
| Kernel Time/Clock Primitives | Clock.Continuous, nanosleep |
| Kernel Environment Primitives | Environment get/set/entries |
| *(no L1 equivalent)* | Signal (entire domain is L2-only) |

---

## Step 1: File Inventory by POSIX Domain

| Domain | Files | Lines | Representative Files |
|--------|-------|-------|---------------------|
| **Error / Base** | 6 | ~417 | `Kernel.swift`, `Error.swift`, `Error.Code.swift`, `Error.Number.swift`, `Error.Mapping.swift`, `exports.swift` |
| **File** (incl. IO, Close, Descriptor, Device, Link, Path, Pipe, Lock, Directory) | 30 | ~3,489 | `File.Open.swift`, `IO.Read.swift`, `IO.Write.swift`, `Directory.swift`, `Link.Symbolic.swift`, `Lock.swift`, `Pipe.swift`, `Path.Canonical.swift` |
| **Socket** | 5 | 409 | `Socket.swift`, `Socket.Pair.swift`, `Socket.Shutdown.swift` |
| **Memory** | 15 | 1,093 | `Memory.Map.swift`, `Memory.Shared.swift`, `Memory.Lock.All.swift` |
| **Process** | 12 | 1,326 | `Process.Fork.swift`, `Process.Wait.swift`, `Process.Spawn.swift`, `Process.Status.swift`, `Process.Kill.swift` |
| **Signal** | 11 | 1,496 | `Signal.Number.swift`, `Signal.Action.swift`, `Signal.Mask.swift`, `Signal.Send.swift`, `Signal.Set.swift` |
| **Thread** | 4 | 588 | `Thread.Mutex.swift`, `Thread.Condition.swift`, `Thread.Handle.swift` |
| **Terminal** | 4 | 372 | `Termios.swift`, `TTY.swift`, `Terminal.swift`, `Terminal.Stream.Read.swift` |
| **Time / Clock** | 4 | 295 | `Clock.swift`, `Clock.Continuous.swift`, `Time.swift`, `CPU.Atomic.Flag.swift` |
| **Environment** | 3 | 380 | `Environment.swift`, `Environment.Entries.swift`, `Environment.Error.swift` |
| **System** | 3 | 165 | `System.swift`, `System.Name.swift`, `Random.swift` |
| **Total** | **97** | **11,834** | |

---

## Step 2: Cross-Domain Dependency Analysis

### Methodology

Every file in the target has an identical 18-line import block importing ALL L1 kernel
primitive modules. Import statements provide no signal about actual coupling. Analysis
was performed by examining actual type usage in function signatures, return types,
parameters, and expressions.

### L1 vs L2 Dependency Distinction

Most apparent cross-domain coupling is through **L1 vocabulary types**, not L2 types.
This distinction is critical:

| Type | Defined At | Used By |
|------|-----------|---------|
| `Kernel.Descriptor` | L1 Core | File, Socket, Memory, Pipe, Lock, Directory, IO, Terminal |
| `Kernel.File.Size` | L1 Core | File, Memory (mmap length) |
| `Kernel.File.Offset` | L1 Core | File, IO (pread/pwrite), Memory (mmap offset) |
| `Kernel.Process.ID` | L1 Process | Process, Signal (Send.toProcess) |
| `Kernel.Error.Code` | L1 Error | All domains |
| `Kernel.Pipe.Error` | L1 File | Pipe |
| `Kernel.Socket.Error` | L1 Socket | Socket |
| `POSIX.Kernel.Signal.Number` | **L2 Signal** | Process (Status) |
| `POSIX.Kernel.Process.Group.ID` | **L2 Process** | Signal (Send.toGroup) |
| `POSIX.Kernel.Error.captureErrno()` | **L2 Base** | ~23 files across all domains |
| `POSIX.Kernel.Process.Error` | **L2 Process** | Process only |
| `POSIX.Kernel.Signal.Error` | **L2 Signal** | Signal only |

### Genuine L2 Cross-Domain Dependencies

Only **two** cross-domain references exist at L2:

1. **Process → Signal**: `Process.Status` (`:148`, `:160`, `:204`, `:207`) references
   `POSIX.Kernel.Signal.Number` for decoding WTERMSIG/WSTOPSIG from wait status.

2. **Signal → Process** *(eliminated by L1 promotion)*: `Signal.Send` (`:128`) references
   `POSIX.Kernel.Process.Group.ID`. Per architectural decision, `Process.Group.ID`
   promotes to L1 (`Kernel Process Primitives`), resolving this as an L1 dependency.

**Result**: After L1 promotion, the only genuine L2 cross-domain dependency is
**Process → Signal** (unidirectional).

### All Domains → Core

`POSIX.Kernel.Error.captureErrno()` is referenced by ~23 files across Memory, Process,
Signal, Lock, File, Socket, Pipe. This is the universal L2 dependency — every domain
needs errno capture. It belongs in Core.

### C Shim Dependencies

| Shim | Used By | Files |
|------|---------|-------|
| `CPOSIXProcessShim` | Process domain only | `Process.Execute.swift`, `Process.Spawn.swift`, `Process.Fork.swift`, `Process.Status.swift` |
| `CISO9945Shim` | Memory + Terminal | `Memory.Shared.swift`, `TTY.swift` |

Shim usage is domain-localized — no shim spans all domains.

### Dependency Matrix (L2 internal, after L1 promotion)

```
              Core  File  Socket  Memory  Process  Signal  Thread  Terminal  System
Core           -
File           ✓     -
Socket         ✓           -
Memory         ✓                   -
Process        ✓                            -        ✓
Signal         ✓                                      -
Thread         ✓                                              -
Terminal       ✓                                                       -
System         ✓                                                                -
```

All domains depend on Core. Only Process depends on one sibling (Signal).
No cycles. No diamonds.

---

## Step 3: Split Options

### Option A: Full Domain Split (9 targets + umbrella)

| Target | Files | Lines | L1 Dependencies | L2 Dependencies | C Shims |
|--------|-------|-------|-----------------|-----------------|---------|
| `ISO 9945 Kernel Core` | 6 | ~417 | Kernel Primitives Core, Kernel Error Primitives, Kernel Descriptor Primitives | ISO 9945 | — |
| `ISO 9945 Kernel File` | 30 | ~3,489 | Kernel File, IO, Descriptor, Permission, Path Primitives | Core | — |
| `ISO 9945 Kernel Socket` | 5 | 409 | Kernel Socket Primitives | Core | — |
| `ISO 9945 Kernel Memory` | 15 | 1,093 | Kernel Memory Primitives | Core | CISO9945Shim |
| `ISO 9945 Kernel Signal` | 11 | 1,496 | Kernel Syscall Primitives | Core | — |
| `ISO 9945 Kernel Process` | 12 | 1,326 | Kernel Process, Syscall Primitives | Core, Signal | CPOSIXProcessShim |
| `ISO 9945 Kernel Thread` | 4 | 588 | Kernel Thread Primitives | Core | — |
| `ISO 9945 Kernel Terminal` | 4 | 372 | Kernel Terminal Primitives | Core | CISO9945Shim |
| `ISO 9945 Kernel System` | 10 | 644 | Kernel System, Time, Clock, Random, Environment Primitives | Core | — |
| `ISO 9945 Kernel` (umbrella) | 1 | ~20 | — | All above | — |

**Dependency graph**:
```
                    ISO 9945 Kernel Core
                    /  |  |  |  |  \  \  \
                   /   |  |  |  |   \  \  \
               File Socket Mem Signal Thread Term System
                              |
                           Process
```

Max depth: **2** (Core → Signal → Process). Satisfies [MOD-007] (threshold ≤ 3).

**Assessment per [MOD-008]**:

| Criterion | Verdict |
|-----------|---------|
| Different dependency set | **Yes** — each target needs different L1 primitives. File needs 5 L1 targets; Socket needs 1; Memory needs 1. Current monolith imports all 18 indiscriminately. |
| Independent consumer value | **Moderate** — current consumers import everything. Future L3/L4 consumers (e.g., a socket-only networking library) would benefit from selective import. |
| Depended-on by siblings | **Signal only** — depended on by Process. All others are leaves. |
| Semantic independence | **Yes** — each target maps to a distinct POSIX specification chapter and L1 primitive domain. |

**Pros**:
- Mirrors L1 target structure — spec↔vocabulary alignment is immediately legible
- Build parallelism: 8 targets compile in parallel after Core; theoretical speedup ~8x
- Import precision: each target declares only its actual L1 dependencies (vs current 18-import-everything)
- C shim dependencies become precise (CPOSIXProcessShim only in Process, CISO9945Shim only in Memory + Terminal)
- Selective consumer import enabled for future packages

**Cons**:
- `@inlinable` annotation burden for cross-target specialization (most syscall wrappers are already small `@inlinable` static functions)
- Package.swift complexity increases (10 targets vs 1)
- Current consumers still import the umbrella — no immediate consumer-side benefit
- File target (30 files) is disproportionately large relative to System (10 files) and Thread (4 files)

### Option B: Partial Split (4-5 targets)

Group domains by shared characteristics:

| Target | Domains | Files | Lines |
|--------|---------|-------|-------|
| `ISO 9945 Kernel Core` | Error, base | 6 | ~417 |
| `ISO 9945 Kernel File` | File, IO, Directory, Link, Lock, Path, Pipe, Socket, Memory, Terminal | 54 | ~5,363 |
| `ISO 9945 Kernel Process` | Process, Signal | 23 | ~2,822 |
| `ISO 9945 Kernel System` | System, Thread, Time, Clock, Environment, Random | 14 | 1,232 |
| `ISO 9945 Kernel` (umbrella) | — | 1 | ~10 |

**Assessment**:

This groups everything descriptor-based into File (54 files), everything
process-lifecycle-related into Process (23 files), and miscellaneous into System.

**Pros**:
- Simpler Package.swift (5 targets vs 10)
- Eliminates the Process→Signal cross-target dependency (merged)
- Broader groupings mean fewer `@inlinable` boundaries

**Cons**:
- File target (54 files, 5,363 lines) is half the entire codebase — barely modularized
- Semantic groupings are forced: Socket ≠ File, Memory ≠ Terminal, Thread ≠ Random
- Doesn't align with L1 structure — L1 has Socket, Memory, Terminal as separate targets
- Violates [MOD-DOMAIN]: "File" would contain Socket (a distinct POSIX subsystem)
- Build parallelism limited: only 3 targets in parallel after Core

### Option C: Keep Monolith

**Assessment**:

| Criterion | Verdict |
|-----------|---------|
| Consumer pattern | All consumers import everything — no demonstrated selective need |
| L2 coupling | Minimal (1 cross-domain edge), but error base is universal |
| Size | 97 files / 11,834 lines — large but not unprecedented at L2 |
| Build impact | Single target compiles sequentially; no parallelism within |

**Pros**:
- Zero Package.swift complexity increase
- No `@inlinable` cross-target burden
- No risk of getting the boundaries wrong
- All consumers already import the whole product

**Cons**:
- Every file imports all 18 L1 kernel primitive modules whether needed or not
- No build parallelism (all 97 files are one compilation unit)
- Doesn't align with L1's modular structure
- Cannot express per-domain C shim dependencies (both shims are always linked)
- Violates [MOD-008] criterion 1 (different dependency sets exist) and criterion 4 (semantic independence exists)
- Growth concern: as more POSIX features are implemented, the monolith only gets larger

---

## Step 4: Recommendation

**Recommended: Option A (Full Domain Split)**

The analysis shows clean domain separation with minimal L2 cross-domain coupling
(exactly one edge: Process → Signal, after promoting `Process.Group.ID` to L1).

### Rationale

1. **[MOD-DOMAIN] compliance**: Each proposed target represents a coherent POSIX
   specification chapter — a semantic domain, not a code convenience grouping.

2. **L1 alignment**: L1 already invested in 23 domain-specific targets. L2 should
   mirror this structure so the spec↔vocabulary relationship is immediately legible.
   Each L2 target extends exactly the L1 targets it corresponds to.

3. **Dependency precision**: The current 18-import-everything pattern in every file
   is the exact anti-pattern [MOD-002] warns against. Splitting centralizes each
   domain's L1 dependencies and makes them explicit.

4. **C shim isolation**: `CPOSIXProcessShim` is only needed by Process (4 files).
   `CISO9945Shim` is only needed by Memory (1 file) and Terminal (1 file). The
   monolith links both shims unconditionally.

5. **Build parallelism**: 8 independent targets after Core. Brent's theorem:
   with depth 2 and 9 non-umbrella targets, theoretical max parallelism ≈ 4.5x
   over the sequential monolith. Actual gain depends on file distribution but
   is significant given the 97-file / 11,834-line total.

6. **Growth safety**: POSIX has many more syscalls that could be added (poll, select,
   epoll wrappers, additional ioctl operations, etc.). Domain targets prevent the
   monolith from growing unboundedly.

### Prerequisite

Promote `POSIX.Kernel.Process.Group.ID` from L2 (`ISO 9945.Kernel.Process.Group.swift`)
to L1 (`Kernel Process Primitives`). This:
- Breaks the Process ↔ Signal cycle at L2
- Is semantically justified: process group IDs are kernel vocabulary, not POSIX-specific
- L1 already has `Kernel.Group.swift` in `Kernel Process Primitives` — natural home
- Minimal change: move a `Tagged<..., pid_t>` typealias and its `.current` constant

### Target Structure (proposed)

```swift
// MARK: - Core
.target(name: "ISO 9945 Kernel Core",
    dependencies: [
        .target(name: "ISO 9945"),
        .product(name: "Kernel Primitives Core", package: "swift-kernel-primitives"),
        .product(name: "Kernel Descriptor Primitives", package: "swift-kernel-primitives"),
        .product(name: "Kernel Error Primitives", package: "swift-kernel-primitives"),
    ]),

// MARK: - File
.target(name: "ISO 9945 Kernel File",
    dependencies: [
        "ISO 9945 Kernel Core",
        .target(name: "ISO 9945 ABI"),
        .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
        .product(name: "Kernel IO Primitives", package: "swift-kernel-primitives"),
        .product(name: "Kernel Permission Primitives", package: "swift-kernel-primitives"),
        .product(name: "Kernel Path Primitives", package: "swift-kernel-primitives"),
        .product(name: "Algebra Primitives", package: "swift-algebra-primitives"),
    ]),

// MARK: - Socket
.target(name: "ISO 9945 Kernel Socket",
    dependencies: [
        "ISO 9945 Kernel Core",
        .product(name: "Kernel Socket Primitives", package: "swift-kernel-primitives"),
    ]),

// MARK: - Memory
.target(name: "ISO 9945 Kernel Memory",
    dependencies: [
        "ISO 9945 Kernel Core",
        .target(name: "CISO9945Shim", condition: .when(platforms: [...])),
        .product(name: "Kernel Memory Primitives", package: "swift-kernel-primitives"),
    ]),

// MARK: - Signal
.target(name: "ISO 9945 Kernel Signal",
    dependencies: [
        "ISO 9945 Kernel Core",
        .product(name: "Kernel Process Primitives", package: "swift-kernel-primitives"),
        .product(name: "Kernel Syscall Primitives", package: "swift-kernel-primitives"),
    ]),

// MARK: - Process
.target(name: "ISO 9945 Kernel Process",
    dependencies: [
        "ISO 9945 Kernel Core",
        "ISO 9945 Kernel Signal",
        .target(name: "CPOSIXProcessShim", condition: .when(platforms: [...])),
        .product(name: "Kernel Process Primitives", package: "swift-kernel-primitives"),
        .product(name: "Kernel Syscall Primitives", package: "swift-kernel-primitives"),
    ]),

// MARK: - Thread
.target(name: "ISO 9945 Kernel Thread",
    dependencies: [
        "ISO 9945 Kernel Core",
        .product(name: "Kernel Thread Primitives", package: "swift-kernel-primitives"),
    ]),

// MARK: - Terminal
.target(name: "ISO 9945 Kernel Terminal",
    dependencies: [
        "ISO 9945 Kernel Core",
        .target(name: "CISO9945Shim", condition: .when(platforms: [...])),
        .product(name: "Kernel Terminal Primitives", package: "swift-kernel-primitives"),
        .product(name: "Terminal Primitives", package: "swift-terminal-primitives"),
    ]),

// MARK: - System
.target(name: "ISO 9945 Kernel System",
    dependencies: [
        "ISO 9945 Kernel Core",
        .product(name: "Kernel System Primitives", package: "swift-kernel-primitives"),
        .product(name: "Kernel Time Primitives", package: "swift-kernel-primitives"),
        .product(name: "Kernel Clock Primitives", package: "swift-kernel-primitives"),
        .product(name: "Kernel Random Primitives", package: "swift-kernel-primitives"),
        .product(name: "Kernel Environment Primitives", package: "swift-kernel-primitives"),
        .product(name: "Clock Primitives", package: "swift-clock-primitives"),
    ]),

// MARK: - Umbrella
.target(name: "ISO 9945 Kernel",
    dependencies: [
        "ISO 9945 Kernel Core",
        "ISO 9945 Kernel File",
        "ISO 9945 Kernel Socket",
        "ISO 9945 Kernel Memory",
        "ISO 9945 Kernel Signal",
        "ISO 9945 Kernel Process",
        "ISO 9945 Kernel Thread",
        "ISO 9945 Kernel Terminal",
        "ISO 9945 Kernel System",
    ]),
```

### Naming (per [MOD-012])

L2 Standards naming drops the layer word:

| Role | Name | Import |
|------|------|--------|
| Core | `ISO 9945 Kernel Core` | `ISO_9945_Kernel_Core` |
| Variant | `ISO 9945 Kernel File` | `ISO_9945_Kernel_File` |
| Variant | `ISO 9945 Kernel Socket` | `ISO_9945_Kernel_Socket` |
| Variant | `ISO 9945 Kernel Memory` | `ISO_9945_Kernel_Memory` |
| Variant | `ISO 9945 Kernel Signal` | `ISO_9945_Kernel_Signal` |
| Variant | `ISO 9945 Kernel Process` | `ISO_9945_Kernel_Process` |
| Variant | `ISO 9945 Kernel Thread` | `ISO_9945_Kernel_Thread` |
| Variant | `ISO 9945 Kernel Terminal` | `ISO_9945_Kernel_Terminal` |
| Variant | `ISO 9945 Kernel System` | `ISO_9945_Kernel_System` |
| Umbrella | `ISO 9945 Kernel` | `ISO_9945_Kernel` |

### Consumer Import (per [MOD-015])

This is a **primary decomposition** along the POSIX subsystem axis. Core is scaffolding
(error capture, descriptor veneer); the variants are the product.

- Platform packages (linux-standard, darwin-standard) that need everything: import the
  umbrella `ISO 9945 Kernel` — this is correct for full-platform consumers.
- Future selective consumers (e.g., a socket library, a file I/O library): import
  specific variants like `ISO 9945 Kernel Socket`.

### Metrics (projected)

| Metric | Current | After Split | Threshold |
|--------|---------|-------------|-----------|
| Target count | 1 | 10 (9 + umbrella) | — |
| Max depth | 1 | 2 | ≤ 3 ✓ |
| Mean sibling deps | 0 | 0.11 (1/9) | ≤ 2.0 ✓ |
| Largest target (files) | 97 | 30 (File) | — |
| Largest target (lines) | 11,834 | ~3,489 (File) | — |
| Cross-domain edges | — | 1 (Process→Signal) | — |

---

## Open Items

### Requiring Decision Before Implementation

1. **File target granularity**: File (30 files, ~3,489 lines) is the largest variant.
   Should Directory (4 files, 648 lines) and/or Lock (3 files, 524 lines) be separate
   targets? They are semantically distinct POSIX subsystems but always co-occur with
   File operations in practice.

2. **System target composition**: System groups 5 small L1 domains (System, Time,
   Clock, Random, Environment) into one L2 target. Should any of these be independent?
   Environment (3 files, 380 lines) has the strongest case for independence — it's a
   distinct POSIX concept with its own error type.

3. **`ISO 9945 ABI` target disposition**: Currently `ISO 9945 Kernel` depends on
   `ISO 9945 ABI` (CChar↔UInt8 pointer projections). After split, which variant(s)
   need it? File target (for path-related syscalls) is the primary consumer. Should
   it be a Core dependency (universal) or File-only?

### Implementation Notes (for future reference)

- Each file's 18-line import block must be replaced with target-specific imports
- `exports.swift` in Core should re-export the L1 modules that Core depends on
- Each variant's `exports.swift` should re-export Core
- Process.Kill.swift defines its own `Process.Signal` (focused subset) independent
  of `Signal.Number` — no additional coupling
- Pipe.swift imports `Algebra_Primitives` and `Identity_Primitives` beyond the
  standard kernel imports — these go in File's dependency list
