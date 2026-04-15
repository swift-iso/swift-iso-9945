# Error.current() Comparative Audit

Audit of all 22 `static func current() -> Self` implementations across 6 targets.

---

## Pattern 1: L1 Cascade (7 instances)

Tries failable L1 error `init(code:)` calls in sequence, falls through to `.platform(Kernel.Error(code: code))`.

### #1 Kernel.IO.Read.Error

- **File**: `Sources/ISO 9945 Kernel File/ISO 9945.Kernel.IO.Read.swift:149`
- **Access**: `internal`
- **@usableFromInline**: No
- **Cascade order**:
  1. `Kernel.Descriptor.Validity.Error(code:)` -> `.handle`
  2. `Kernel.IO.Blocking.Error(code:)` -> `.blocking`
  3. `Kernel.IO.Error(code:)` -> `.io`
  4. `Kernel.Memory.Error(code:)` -> `.memory`
- **Fallthrough**: `.platform(Kernel.Error(code: code))`
- **L1 enum cases**: `.handle`, `.blocking`, `.io`, `.memory`, `.platform`
- **Coverage**: COMPLETE -- all 4 non-platform cases checked

### #2 Kernel.IO.Write.Error

- **File**: `Sources/ISO 9945 Kernel File/ISO 9945.Kernel.IO.Write.swift:228`
- **Access**: `internal`
- **@usableFromInline**: No
- **Cascade order**:
  1. `Kernel.Descriptor.Validity.Error(code:)` -> `.handle`
  2. `Kernel.IO.Blocking.Error(code:)` -> `.blocking`
  3. `Kernel.IO.Error(code:)` -> `.io`
  4. `Kernel.Storage.Error(code:)` -> `.space`
  5. `Kernel.Memory.Error(code:)` -> `.memory`
- **Fallthrough**: `.platform(Kernel.Error(code: code))`
- **L1 enum cases**: `.handle`, `.blocking`, `.io`, `.space`, `.memory`, `.platform`
- **Coverage**: COMPLETE -- all 5 non-platform cases checked

### #3 Kernel.File.Control.Error

- **File**: `Sources/ISO 9945 Kernel File/ISO 9945.Kernel.File.Control.swift:101`
- **Access**: `internal`
- **@usableFromInline**: No
- **Cascade order**:
  1. `Kernel.Descriptor.Validity.Error(code:)` -> `.handle`
  2. `Kernel.IO.Error(code:)` -> `.io`
- **Fallthrough**: `.platform(Kernel.Error(code: code))`
- **L1 enum cases**: `.handle`, `.io`, `.platform`
- **Coverage**: COMPLETE -- all 2 non-platform cases checked

### #4 Kernel.File.Flush.Error

- **File**: `Sources/ISO 9945 Kernel File/ISO 9945.Kernel.File.Flush.swift:151`
- **Access**: `internal`
- **@usableFromInline**: No
- **Cascade order**:
  1. `Kernel.Descriptor.Validity.Error(code:)` -> `.handle`
  2. `Kernel.IO.Error(code:)` -> `.io`
- **Fallthrough**: `.platform(Kernel.Error(code: code))`
- **L1 enum cases**: `.handle`, `.io`, `.platform`
- **Coverage**: COMPLETE -- all 2 non-platform cases checked

### #5 Kernel.Pipe.Error

- **File**: `Sources/ISO 9945 Kernel File/ISO 9945.Kernel.Pipe.swift:95`
- **Access**: `internal`
- **@usableFromInline**: No
- **Cascade order**:
  1. `Kernel.Descriptor.Validity.Error(code:)` -> `.handle`
- **Fallthrough**: `.platform(Kernel.Error(code: code))`
- **L1 enum cases**: `.handle`, `.io`, `.platform`
- **Coverage**: INCOMPLETE -- `.io` case exists on L1 enum but is NOT checked

### #6 Kernel.Socket.Error

- **File**: `Sources/ISO 9945 Kernel Socket/ISO 9945.Kernel.Socket.swift:60`
- **Access**: `internal`
- **@usableFromInline**: No
- **Cascade order**:
  1. `Kernel.Descriptor.Validity.Error(code:)` -> `.handle`
- **Fallthrough**: `.platform(Kernel.Error(code: code))`
- **L1 enum cases**: `.handle`, `.platform`
- **Coverage**: COMPLETE -- only 1 non-platform case

### #7 Kernel.Socket.Shutdown.Error

- **File**: `Sources/ISO 9945 Kernel Socket/ISO 9945.Kernel.Socket.Shutdown.swift:54`
- **Access**: `internal`
- **@usableFromInline**: No
- **Cascade order**:
  1. `Kernel.Descriptor.Validity.Error(code:)` -> `.handle`
  2. `Kernel.IO.Error(code:)` -> `.io`
- **Fallthrough**: `.platform(Kernel.Error(code: code))`
- **L1 enum cases**: `.handle`, `.io`, `.platform`
- **Coverage**: COMPLETE -- all 2 non-platform cases checked

---

## Pattern 2: errno Switch (8 instances)

Captures errno, switches on specific POSIX codes, falls through to `.platform()`.

### #8 Kernel.File.Delete.Error

- **File**: `Sources/ISO 9945 Kernel File/ISO 9945.Kernel.File.Delete.swift:87`
- **Access**: `internal`
- **@usableFromInline**: No
- **errno capture**: `Kernel.Error.Code.current()`
- **Mappings**:
  - `ENOENT` -> `.notFound`
  - `EACCES, EPERM` -> `.permission`
  - `EISDIR` -> `.isDirectory`
  - `ENOTDIR` -> `.notDirectory`
  - `EROFS` -> `.readOnly`
  - `EBUSY` -> `.busy`
  - `ELOOP` -> `.loop`
  - `ENAMETOOLONG` -> `.nameTooLong`
- **Fallthrough**: `.platform(Kernel.Error(code: code))`
- **L1 enum cases**: `.notFound`, `.permission`, `.isDirectory`, `.notDirectory`, `.readOnly`, `.busy`, `.loop`, `.nameTooLong`, `.platform`
- **Coverage**: COMPLETE -- all 8 non-platform cases mapped

### #9 Kernel.File.Move.Error

- **File**: `Sources/ISO 9945 Kernel File/ISO 9945.Kernel.File.Move.swift:122`
- **Access**: `internal`
- **@usableFromInline**: No
- **errno capture**: `Kernel.Error.Code.current()`
- **Mappings**:
  - `ENOENT` -> `.notFound`
  - `EACCES, EPERM` -> `.permission`
  - `EXDEV` -> `.crossDevice`
  - `ENOTEMPTY` -> `.notEmpty`
  - `ENOTDIR` -> `.notDirectory`
  - `EINVAL` -> `.invalidArgument`
  - `EISDIR` -> `.isDirectory`
  - `EROFS` -> `.readOnly`
  - `ELOOP` -> `.loop`
  - `ENAMETOOLONG` -> `.nameTooLong`
  - `ENOSPC` -> `.noSpace`
- **Fallthrough**: `.platform(Kernel.Error(code: code))`
- **L1 enum cases**: `.notFound`, `.permission`, `.crossDevice`, `.notEmpty`, `.notDirectory`, `.invalidArgument`, `.isDirectory`, `.readOnly`, `.loop`, `.nameTooLong`, `.noSpace`, `.platform`
- **Coverage**: COMPLETE -- all 11 non-platform cases mapped

### #10 Kernel.File.Attributes.Error

- **File**: `Sources/ISO 9945 Kernel File/ISO 9945.Kernel.File.Attributes.swift:96`
- **Access**: `internal`
- **@usableFromInline**: Yes
- **errno capture**: raw `errno` (not via `Kernel.Error.Code.current()`)
- **Mappings**:
  - `ENOENT` -> `.path(.notFound)`
  - `ENAMETOOLONG` -> `.path(.tooLong)`
  - `ELOOP` -> `.path(.loop)`
  - `EACCES` -> `.permission(.denied)`
  - `EPERM` -> `.permission(.notPermitted)`
  - `EROFS` -> `.permission(.readOnlyFilesystem)`
  - `EIO` -> `.io(.hardware)`
- **Fallthrough**: `.platform(Kernel.Error(code: .posix(e)))`
- **L1 enum cases**: `.path(Path)`, `.permission(Permission)`, `.io(IO)`, `.platform`
- **Coverage**: COMPLETE -- all 3 non-platform case families covered

### #11 Kernel.File.Times.Error

- **File**: `Sources/ISO 9945 Kernel File/ISO 9945.Kernel.File.Times.swift:133`
- **Access**: `internal`
- **@usableFromInline**: Yes
- **errno capture**: raw `errno` (not via `Kernel.Error.Code.current()`)
- **Mappings**:
  - `ENOENT` -> `.path(.notFound)`
  - `ENAMETOOLONG` -> `.path(.tooLong)`
  - `ELOOP` -> `.path(.loop)`
  - `EACCES` -> `.permission(.denied)`
  - `EPERM` -> `.permission(.notPermitted)`
  - `EROFS` -> `.permission(.readOnlyFilesystem)`
  - `EIO` -> `.io(.hardware)`
- **Fallthrough**: `.platform(Kernel.Error(code: .posix(e)))`
- **L1 enum cases**: `.path(Path)`, `.permission(Permission)`, `.io(IO)`, `.platform`
- **Coverage**: COMPLETE -- all 3 non-platform case families covered
- **Note**: Identical implementation to Attributes (#10)

### #12 Kernel.File.Chown.Error

- **File**: `Sources/ISO 9945 Kernel File/ISO 9945.Kernel.File.Chown.swift:147`
- **Access**: `internal`
- **@usableFromInline**: Yes
- **errno capture**: raw `errno` (not via `Kernel.Error.Code.current()`)
- **Mappings**:
  - `ENOENT` -> `.path(.notFound)`
  - `ENAMETOOLONG` -> `.path(.tooLong)`
  - `ELOOP` -> `.path(.loop)`
  - `EACCES` -> `.permission(.denied)`
  - `EPERM` -> `.permission(.notPermitted)`
  - `EROFS` -> `.permission(.readOnlyFilesystem)`
  - `EIO` -> `.io(.hardware)`
- **Fallthrough**: `.platform(Kernel.Error(code: .posix(e)))`
- **L1 enum cases**: `.path(Path)`, `.permission(Permission)`, `.io(IO)`, `.platform`
- **Coverage**: COMPLETE -- all 3 non-platform case families covered
- **Note**: Identical implementation to Attributes (#10) and Times (#11)

### #13 Kernel.File.Seek.Error

- **File**: `Sources/ISO 9945 Kernel File/ISO 9945.Kernel.File.Seek.swift:85`
- **Access**: `internal`
- **@usableFromInline**: No
- **errno capture**: raw `errno` (not via `Kernel.Error.Code.current()`)
- **Mappings**:
  - `EBADF` -> `.invalidDescriptor`
  - `EINVAL` -> `.negativeOffset`
  - `ESPIPE` -> `.notSeekable`
  - `EOVERFLOW` -> `.overflow`
- **Fallthrough**: `.platform(code: .posix(e))`
- **L1 enum cases**: `.invalidDescriptor`, `.negativeOffset`, `.notSeekable`, `.overflow`, `.platform(code:)`
- **Coverage**: COMPLETE -- all 4 non-platform cases mapped
- **Note**: Unique fallthrough syntax `.platform(code: .posix(e))` -- the only error type where `.platform` takes `Kernel.Error.Code` instead of `Kernel.Error`

### #14 Kernel.Descriptor.Duplicate.Error

- **File**: `Sources/ISO 9945 Kernel File/ISO 9945.Kernel.Descriptor.Duplicate.swift:100`
- **Access**: `internal`
- **@usableFromInline**: No
- **errno capture**: raw `errno` (not via `Kernel.Error.Code.current()`)
- **Mappings**:
  - `EBADF` -> `.handle(.invalid)`
  - `EMFILE` -> `.tooManyOpen`
- **Fallthrough**: `.platform(Kernel.Error(code: .posix(e)))`
- **L1 enum cases**: `.handle`, `.tooManyOpen`, `.platform`
- **Coverage**: COMPLETE -- all 2 non-platform cases mapped

### #15 Kernel.Link.Error

- **File**: `Sources/ISO 9945 Kernel File/ISO 9945.Kernel.Link.swift:113`
- **Access**: `internal`
- **@usableFromInline**: No
- **errno capture**: `Kernel.Error.Code.current()`
- **Mappings**:
  - `ENOENT` -> `.notFound`
  - `EACCES, EPERM` -> `.permission`
  - `EEXIST` -> `.exists`
  - `EXDEV` -> `.crossDevice`
  - `EISDIR` -> `.isDirectory`
  - `ENOTDIR` -> `.notDirectory`
  - `EROFS` -> `.readOnly`
  - `EMLINK` -> `.tooManyLinks`
  - `ENOSPC` -> `.noSpace`
  - `ELOOP` -> `.loop`
  - `ENAMETOOLONG` -> `.nameTooLong`
- **Fallthrough**: `.platform(Kernel.Error(code: code))`
- **L1 enum cases**: `.notFound`, `.permission`, `.exists`, `.crossDevice`, `.isDirectory`, `.notDirectory`, `.readOnly`, `.tooManyLinks`, `.noSpace`, `.loop`, `.nameTooLong`, `.platform`
- **Coverage**: COMPLETE -- all 11 non-platform cases mapped

---

## Pattern 3: Delegation (3 instances)

One-liner calling `Self(code:)` or `init(code:)`, delegating to the L1 initializer.

### #16 Kernel.File.Open.Error

- **File**: `Sources/ISO 9945 Kernel File/ISO 9945.Kernel.File.Open.swift:113`
- **Access**: `internal`
- **@usableFromInline**: Yes
- **Implementation**: `Self(code: .posix(errno))`
- **L1 init cascade** (in `Kernel File Primitives`):
  1. `Kernel.Path.Resolution.Error(code:)` -> `.path`
  2. `Kernel.Permission.Error(code:)` -> `.permission`
  3. `Kernel.Descriptor.Validity.Error(code:)` -> `.handle`
  4. `Kernel.Storage.Error(code:)` -> `.space`
  5. `Kernel.IO.Error(code:)` -> `.io`
- **Fallthrough**: `.platform(Kernel.Error(code: code))`

### #17 Kernel.Environment.Error

- **File**: `Sources/ISO 9945 Kernel Environment/ISO 9945.Kernel.Environment.Error.swift:43`
- **Access**: `internal`
- **@usableFromInline**: No
- **Implementation**: `Self(code: .captureErrno())`
- **The `init(code:)` is in the same file (line 26)**, using L1 cascade:
  1. `Kernel.Memory.Error(code:)` -> `.memory`
  2. `Kernel.Permission.Error(code:)` -> `.permission`
  3. EINVAL check -> `.invalid(.nameContainsEquals)`
- **Fallthrough**: `.platform(Kernel.Error(code: code))`
- **Note**: The `init(code:)` is defined in the L2 file itself (not in L1), making this a hybrid: delegation to a local init that uses L1 cascade + a manual EINVAL check.

### #18 Kernel.Directory.Working.Error

- **File**: `Sources/ISO 9945 Kernel Directory/ISO 9945.Kernel.Directory.Working.swift:182`
- **Access**: `internal`
- **@usableFromInline**: No
- **Implementation**: `fromPosixErrno(.posix(errno))`
- **The `fromPosixErrno` is in the same extension (line 187)**, using L1 cascade:
  1. `Kernel.Path.Resolution.Error(code:)` -> `.path`
  2. `Kernel.Permission.Error(code:)` -> `.permission`
- **Fallthrough**: `.platform(Kernel.Error(code: code))`
- **Note**: Uses a named helper `fromPosixErrno` rather than `init(code:)`. The L1 type also has its own `init(code:)` with the same cascade order, so this is redundant duplication.

---

## Pattern 4: Directory errno Switch (2 instances)

### #19 Kernel.Directory.Remove.Error

- **File**: `Sources/ISO 9945 Kernel Directory/ISO 9945.Kernel.Directory.Remove.swift:65`
- **Access**: `internal`
- **@usableFromInline**: No
- **errno capture**: `Kernel.Error.Code.current()`
- **Mappings**:
  - `ENOENT` -> `.notFound`
  - `EACCES, EPERM` -> `.permission`
  - `ENOTEMPTY` -> `.notEmpty`
  - `ENOTDIR` -> `.notDirectory`
  - `EBUSY` -> `.busy`
  - `EROFS` -> `.readOnly`
  - `ELOOP` -> `.loop`
  - `ENAMETOOLONG` -> `.nameTooLong`
- **Fallthrough**: `.platform(Kernel.Error(code: code))`
- **L1 enum cases**: `.notFound`, `.permission`, `.notEmpty`, `.notDirectory`, `.busy`, `.readOnly`, `.loop`, `.nameTooLong`, `.platform`
- **Coverage**: COMPLETE -- all 8 non-platform cases mapped

### #20 Kernel.Directory.Create.Error

- **File**: `Sources/ISO 9945 Kernel Directory/ISO 9945.Kernel.Directory.Create.swift:94`
- **Access**: `internal`
- **@usableFromInline**: No
- **errno capture**: `Kernel.Error.Code.current()`
- **Mappings**:
  - `ENOENT` -> `.notFound`
  - `EACCES, EPERM` -> `.permission`
  - `EEXIST` -> `.exists`
  - `ENOTDIR` -> `.notDirectory`
  - `EROFS` -> `.readOnly`
  - `ENOSPC` -> `.noSpace`
  - `ELOOP` -> `.loop`
  - `ENAMETOOLONG` -> `.nameTooLong`
- **Fallthrough**: `.platform(Kernel.Error(code: code))`
- **L1 enum cases**: `.notFound`, `.permission`, `.exists`, `.notDirectory`, `.readOnly`, `.noSpace`, `.loop`, `.nameTooLong`, `.platform`
- **Coverage**: COMPLETE -- all 8 non-platform cases mapped

---

## Pattern 5: Core (1 instance)

### #21 Kernel.Error.Code

- **File**: `Sources/ISO 9945 Core/ISO 9945.Kernel.Error.Code.swift:33`
- **Access**: `public`
- **@usableFromInline**: No
- **Implementation**: Alias for `captureErrno()` which returns `.posix(errno)`
- **Note**: This is the foundation that all others build upon. Only instance that is `public`.

---

## Pattern 6: Terminal Duplicate (1 instance)

### #22 Kernel.IO.Read.Error (Terminal)

- **File**: `Sources/ISO 9945 Kernel Terminal/ISO 9945.Kernel.IO.Read+Terminal.swift:74`
- **Access**: `fileprivate`
- **@usableFromInline**: No
- **Cascade order**:
  1. `Kernel.Descriptor.Validity.Error(code:)` -> `.handle`
  2. `Kernel.IO.Blocking.Error(code:)` -> `.blocking`
  3. `Kernel.IO.Error(code:)` -> `.io`
  4. `Kernel.Memory.Error(code:)` -> `.memory`
- **Fallthrough**: `.platform(Kernel.Error(code: code))`

**Verification**: The Terminal instance (#22) is IDENTICAL in logic to File's IO.Read.Error (#1). Same cascade order, same mappings, same fallthrough. Only difference: access is `fileprivate` instead of `internal`.

---

## Consistency Analysis

### L1 Cascade Ordering

The L1 cascades that share the same sub-error types use a consistent ordering convention:

1. `Kernel.Descriptor.Validity.Error` (handle) -- always first
2. `Kernel.IO.Blocking.Error` (blocking) -- when present, second
3. `Kernel.IO.Error` (io) -- after blocking
4. `Kernel.Storage.Error` (space) -- Write only
5. `Kernel.Memory.Error` (memory) -- always last before platform

This ordering is consistent across all L1 cascade instances and matches the L1 `init(code:)` definitions.

### Missing Coverage

| # | Error Type | Issue |
|---|-----------|-------|
| 5 | `Kernel.Pipe.Error` | **MISSING** `.io` check -- L1 enum has `.io(Kernel.IO.Error)` case but `current()` only checks `.handle`, skipping `.io`. L1 `init(code:)` does check both. |

This means `Kernel.Pipe.Error.current()` will route IO errors (e.g., EIO) to `.platform()` instead of `.io()`, diverging from the L1 `init(code:)` behavior.

### Superfluous Checks

None found. All cascades only check for error types that exist as cases on their enum.

### errno Capture Inconsistency

Two approaches are used to capture errno:

| Approach | Used by |
|----------|---------|
| `let code = Kernel.Error.Code.current()` then switch on `code` | Delete, Move, Link, Directory.Remove, Directory.Create |
| `let e = errno` then switch on raw `e` (matching POSIX constants directly) | Attributes, Times, Chown, Seek, Duplicate |
| `let e = errno; let code = Kernel.Error.Code.posix(e)` then cascade | IO.Read, IO.Write, Control, Flush, Pipe, Socket, Socket.Shutdown |

The difference is cosmetic for the errno switch pattern (both work correctly), but the approaches should ideally be unified for readability.

### Fallthrough Consistency

| Fallthrough form | Used by |
|------------------|---------|
| `.platform(Kernel.Error(code: code))` | All L1 cascades, Delete, Move, Link, Dir.Remove, Dir.Create |
| `.platform(Kernel.Error(code: .posix(e)))` | Attributes, Times, Chown, Duplicate |
| `.platform(code: .posix(e))` | Seek -- **unique**: wraps `Kernel.Error.Code`, not `Kernel.Error` |

The Seek fallthrough is structurally different because its `.platform` case takes `Kernel.Error.Code` rather than `Kernel.Error`. This is by design (the L1 enum definition confirms this).

### @usableFromInline Distribution

| Marked | Instances |
|--------|-----------|
| Yes | File.Open (#16), File.Attributes (#10), File.Times (#11), File.Chown (#12) |
| No | All 18 others |

**Pattern**: `@usableFromInline` is applied when the `current()` function is called from a `@usableFromInline` internal function (e.g., `_open`, `_setPermissions`, `_setTimes`, `_chown`). The four marked instances all have `@usableFromInline` callers. All unmarked instances are called from `public` functions or `internal` functions that are not `@usableFromInline`.

### Duplication: Directory.Working.Error

`Directory.Working.Error` defines `fromPosixErrno(_:)` in the L2 layer (line 187) that duplicates the L1 `init(code:)` (same cascade: Path.Resolution.Error then Permission.Error). The `current()` calls `fromPosixErrno` instead of delegating to `Self(code:)`. This is redundant -- it could be a one-liner like File.Open (#16).

### Duplication: Terminal IO.Read.Error

The Terminal target (#22) duplicates the entire `IO.Read.Error.current()` implementation as `fileprivate` because it cannot see the `internal` version from the File target. This is a necessary cross-target duplication, but both implementations must be kept in sync manually.

---

## Summary of Findings

| Finding | Severity | Instance |
|---------|----------|----------|
| `Pipe.Error.current()` skips `.io` check that L1 enum supports | Bug | #5 |
| `Directory.Working.Error` has redundant `fromPosixErrno` duplicating L1 init | Cleanup | #18 |
| Terminal IO.Read.Error duplicates File IO.Read.Error (correct but fragile) | Design debt | #22 vs #1 |
| Two errno capture styles (`.current()` vs raw `errno`) in switches | Style inconsistency | #8-9,15,19-20 vs #10-14 |
