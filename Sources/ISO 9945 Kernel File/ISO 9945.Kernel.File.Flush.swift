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

@_spi(Syscall) import ISO_9945_Core

@_spi(Syscall) import Kernel_File_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX fsync() syscall (raw @_spi(Syscall))

extension ISO_9945.Kernel.File.Flush {
    /// Synchronizes a raw file descriptor's in-core state with storage device.
    ///
    /// Spec-literal raw `fsync(2)`. The typed L2 convenience
    /// (`ISO_9945.Kernel.File.Flush.fsync(_:)` taking
    /// `borrowing Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// ## EINTR
    /// This function does NOT retry on EINTR. On signal interruption, throws
    /// `.platform(Error_Primitives.Error(code: .posix(EINTR)))`. Callers should check
    /// `error.code.isInterrupted` and retry if appropriate.
    ///
    /// - Parameter fd: The raw file descriptor.
    /// - Throws: `Kernel.File.Flush.Error` on failure (including EINTR).
    @_spi(Syscall)
    public static func fsync(fd: Int32) throws(Error) {
        #if canImport(Darwin)
            let result = unsafe Darwin.fsync(fd)
        #elseif canImport(Musl)
            let result = unsafe Musl.fsync(fd)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.fsync(fd)
        #endif

        if result == 0 {
            return
        }

        throw Error.current()
    }

    #if os(Linux)
    /// Synchronizes a raw file descriptor's data (without metadata) to storage device.
    ///
    /// Spec-literal raw `fdatasync(2)`. Like `fsync()`, but does not flush
    /// modified metadata unless needed to allow subsequent data retrieval.
    /// The typed L2 convenience
    /// (`ISO_9945.Kernel.File.Flush.fdatasync(_:)` taking
    /// `borrowing Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// ## EINTR
    /// This function does NOT retry on EINTR. On signal interruption, throws
    /// `.platform(Error_Primitives.Error(code: .posix(EINTR)))`. Callers should check
    /// `error.code.isInterrupted` and retry if appropriate.
    ///
    /// - Parameter fd: The raw file descriptor.
    /// - Throws: `Kernel.File.Flush.Error` on failure (including EINTR).
    @_spi(Syscall)
    public static func fdatasync(fd: Int32) throws(Error) {
        #if canImport(Musl)
            let result = unsafe Musl.fdatasync(fd)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.fdatasync(fd)
        #endif

        if result == 0 {
            return
        }

        throw Error.current()
    }
    #endif

    #if canImport(Darwin)
    /// Flushes data to permanent storage with full sync (Darwin) on a raw file descriptor.
    ///
    /// Spec-literal raw `fcntl(F_FULLFSYNC)`. Ensures data is flushed through
    /// disk caches — strongest durability guarantee on Darwin. The typed L2
    /// convenience (`ISO_9945.Kernel.File.Flush.fullFsync(_:)` taking
    /// `borrowing Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// ## EINTR
    /// This function does NOT retry on EINTR. On signal interruption, throws
    /// `.platform(Error_Primitives.Error(code: .posix(EINTR)))`. Callers should check
    /// `error.code.isInterrupted` and retry if appropriate.
    ///
    /// - Parameter fd: The raw file descriptor.
    /// - Throws: `Kernel.File.Flush.Error` on failure (including EINTR).
    @_spi(Syscall)
    public static func fullFsync(fd: Int32) throws(Error) {
        let result = unsafe Darwin.fcntl(fd, F_FULLFSYNC)

        if result != -1 {
            return
        }

        throw Error.current()
    }

    /// Flushes data with barrier sync (Darwin) on a raw file descriptor.
    ///
    /// Spec-literal raw `fcntl(F_BARRIERFSYNC)`. Lighter than F_FULLFSYNC but
    /// still provides ordering guarantees: data is flushed to disk and a
    /// barrier is issued to ensure ordering with subsequent writes. The typed
    /// L2 convenience (`ISO_9945.Kernel.File.Flush.barrierFsync(_:)` taking
    /// `borrowing Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// ## EINTR
    /// This function does NOT retry on EINTR. On signal interruption, throws
    /// `.platform(Error_Primitives.Error(code: .posix(EINTR)))`. Callers should check
    /// `error.code.isInterrupted` and retry if appropriate.
    ///
    /// - Parameter fd: The raw file descriptor.
    /// - Throws: `Kernel.File.Flush.Error` on failure (including EINTR).
    @_spi(Syscall)
    public static func barrierFsync(fd: Int32) throws(Error) {
        let result = unsafe Darwin.fcntl(fd, F_BARRIERFSYNC)

        if result != -1 {
            return
        }

        throw Error.current()
    }
    #endif
}

// MARK: - Typed Convenience

extension ISO_9945.Kernel.File.Flush {
    /// Synchronizes a file's in-core state with storage device.
    ///
    /// Typed L2 form. Delegates to the raw `fsync(fd:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Throws: `Kernel.File.Flush.Error` on failure (including EINTR).
    public static func fsync(_ descriptor: borrowing Kernel.Descriptor) throws(Error) {
        try unsafe fsync(fd: descriptor._rawValue)
    }

    #if os(Linux)
    /// Synchronizes a file's data (without metadata) to storage device.
    ///
    /// Typed L2 form. Delegates to the raw `fdatasync(fd:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Throws: `Kernel.File.Flush.Error` on failure (including EINTR).
    public static func fdatasync(_ descriptor: borrowing Kernel.Descriptor) throws(Error) {
        try unsafe fdatasync(fd: descriptor._rawValue)
    }
    #endif

    #if canImport(Darwin)
    /// Flushes data to permanent storage with full sync (Darwin).
    ///
    /// Typed L2 form. Delegates to the raw `fullFsync(fd:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Throws: `Kernel.File.Flush.Error` on failure (including EINTR).
    public static func fullFsync(_ descriptor: borrowing Kernel.Descriptor) throws(Error) {
        try unsafe fullFsync(fd: descriptor._rawValue)
    }

    /// Flushes data with barrier sync (Darwin).
    ///
    /// Typed L2 form. Delegates to the raw `barrierFsync(fd:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Throws: `Kernel.File.Flush.Error` on failure (including EINTR).
    public static func barrierFsync(_ descriptor: borrowing Kernel.Descriptor) throws(Error) {
        try unsafe barrierFsync(fd: descriptor._rawValue)
    }
    #endif
}

// MARK: - Error

extension ISO_9945.Kernel.File.Flush {
    public typealias Error = Kernel.File.Flush.Error
}

extension ISO_9945.Kernel.File.Flush.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Error_Primitives.Error.Code.current()
        if let handleError = Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        return .platform(Error_Primitives.Error(code: code))
    }
}
