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

#if !os(Linux) && !canImport(Darwin)

extension Kernel.File.Flush {
    /// Synchronizes file data to storage with the best available platform semantic.
    ///
    /// Single entry point for "data-only sync" semantics. Consumer code can write
    /// a single unconditional call site instead of a per-platform `#if` between
    /// `data(_:)` (Linux), `barrier(_:)` (Darwin), and `flush(_:)` (fallback).
    ///
    /// Cross-platform contract:
    /// - **Linux**: ``ISO_9945/Kernel/File/Flush/data(_:)`` (`fdatasync(2)`).
    /// - **Darwin**: ``ISO_9945/Kernel/File/Flush/barrier(_:)``
    ///   (`fcntl(F_BARRIERFSYNC)`) — closest available "data-only-ish" semantic.
    /// - **Other POSIX** (OpenBSD, etc.): falls back to
    ///   ``ISO_9945/Kernel/File/Flush/flush(_:)`` (`fsync(2)`).
    /// - **Windows**: ``Windows/Kernel/File/Flush/flush(_:)``
    ///   (`FlushFileBuffers`) — Windows has no data-only distinction.
    ///
    /// On platforms without a distinct data-only sync primitive, this falls
    /// back to `fsync(2)` — strictly stronger semantics than data-only, never
    /// weaker. The unifier's "best available" contract is preserved.
    ///
    /// ## EINTR
    /// Inherits the underlying syscall's EINTR behavior — throws
    /// `.platform(Kernel.Error(code: .posix(EINTR)))` on signal interruption.
    /// Callers should check `error.code.isInterrupted` and retry if appropriate.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Throws: ``Kernel/File/Flush/Error`` on failure (including EINTR).
    @inlinable
    public static func dataOnly(_ descriptor: borrowing Kernel.Descriptor) throws(Error) {
        try flush(descriptor)
    }
}

#endif
