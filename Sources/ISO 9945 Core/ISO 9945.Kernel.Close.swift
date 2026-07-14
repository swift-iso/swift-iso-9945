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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#elseif os(Windows)
    // CRT is the Swift overlay over ucrt: `errno` and the standard streams are
    // vended as computed accessors, and errno.h / string.h / stdlib.h symbols
    // (E* constants, strerror, getenv) import directly.
    internal import CRT
#endif

extension ISO_9945.Kernel {
    /// POSIX file descriptor close operations.
    ///
    /// Inseparable from the descriptor concept. Lives alongside ``Descriptor``.
    ///
    /// ## Ownership
    ///
    /// ``close(_:)`` consumes the descriptor: after the call the wrapper is
    /// destroyed. If you don't call ``close(_:)`` explicitly, the
    /// descriptor's `deinit` closes the fd automatically (best-effort,
    /// errors swallowed).
    public enum Close: Sendable {}
}

extension ISO_9945.Kernel.Close {
    /// Close a POSIX file descriptor, reporting errors.
    ///
    /// Consumes the descriptor: after this call, the descriptor is destroyed.
    /// The deinit does NOT double-close — the descriptor is disarmed before
    /// the syscall.
    ///
    /// - Parameter descriptor: The file descriptor to close (consumed).
    /// - Throws: ``Error`` on failure.
    public static func close(_ descriptor: consuming ISO_9945.Kernel.Descriptor) throws(Error) {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        let raw = descriptor._raw
        // Disarm: deinit will see !isValid and skip.
        descriptor._raw = -1

        let result: Int32
        #if canImport(Darwin)
            result = Darwin.close(raw)
        #elseif canImport(Glibc)
            result = unsafe Glibc.close(raw)
        #elseif canImport(Musl)
            result = unsafe Musl.close(raw)
        #elseif os(Windows)
            // The CRT descriptor-close analogue (corecrt_io.h). CRT file
            // descriptors are the POSIX-shaped fd surface on Windows.
            result = unsafe _close(raw)
        #endif
        if result == -1 {
            throw .platform(Error_Primitives.Error(code: .posix(errno)))
        }
    }
}
