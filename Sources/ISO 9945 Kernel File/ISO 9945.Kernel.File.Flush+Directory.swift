// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Kernel.File.Flush {
    /// Persists directory entries (rename visibility) to storage.
    ///
    /// Single entry point for "directory sync" semantics. Consumer code can
    /// write a single unconditional call site instead of a `#if os(Windows)`
    /// branch separating the POSIX `open + fsync + close` recipe from a
    /// Windows no-op.
    ///
    /// Cross-platform contract:
    /// - **POSIX**: opens the directory `O_RDONLY`, calls `fsync`, then
    ///   relies on `Kernel.Descriptor`'s `deinit` to close. The directory is
    ///   opened with `O_CLOEXEC` so it does not leak across `exec`.
    /// - **Windows**: documented no-op. Windows does not expose a
    ///   directory-fsync primitive; rename durability is provided by the
    ///   rename itself plus subsequent `FlushFileBuffers` on affected files.
    ///
    /// ## EINTR
    /// Inherits the underlying open / flush syscalls' EINTR behavior —
    /// throws `.platform(Kernel.Error(code: .posix(EINTR)))` on signal
    /// interruption. Callers should check `error.code.isInterrupted` and
    /// retry if appropriate.
    ///
    /// - Parameter path: The directory path (borrowed view).
    /// - Throws: ``Kernel/File/Flush/Error`` on failure of either the open
    ///   or the flush. Open errors are mapped to ``Error``: `handle` and
    ///   `io` carry losslessly; `path` / `permission` / `space` flatten to
    ///   ``Error/platform(_:)`` with a canonical POSIX code that captures
    ///   the broad failure category (`ENOENT` / `EACCES` / `ENOSPC`).
    @inlinable
    public static func directory(path: borrowing Kernel.Path.View) throws(Error) {
        let fd: Kernel.Descriptor
        do throws(Kernel.File.Open.Error) {
            fd = try Kernel.File.Open.open(
                path: path,
                mode: .read,
                options: [.execClose],
                permissions: .none
            )
        } catch {
            // Map Kernel.File.Open.Error -> Kernel.File.Flush.Error.
            // Direct cases (handle, io) carry losslessly. Structural cases
            // (path, permission, space) carry no .code accessor on their
            // sub-error, so they flatten to .platform with a canonical
            // POSIX code naming the category — strictly less informative
            // than the raw errno but sufficient for `code.isNotFound` /
            // `isPermissionDenied` / `isNoSpace` consumer dispatch.
            switch error {
            case .handle(let e): throw .handle(e)
            case .io(let e): throw .io(e)
            case .path: throw .platform(Kernel.Error(code: .POSIX.ENOENT))
            case .permission: throw .platform(Kernel.Error(code: .POSIX.EACCES))
            case .space: throw .platform(Kernel.Error(code: .POSIX.ENOSPC))
            case .platform(let e): throw .platform(e)
            }
        }
        try flush(fd)
        // fd auto-closes via Kernel.Descriptor.deinit at end of scope.
    }
}
