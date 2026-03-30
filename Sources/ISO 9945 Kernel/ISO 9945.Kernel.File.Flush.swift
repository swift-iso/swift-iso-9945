// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

@_spi(Syscall) public import Kernel_Primitives
public import ISO_9945

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX fsync() syscall

extension ISO_9945.Kernel.File.Flush {
    /// Synchronizes a file's in-core state with storage device.
    ///
    /// This is the raw POSIX `fsync(2)` syscall. It does NOT automatically retry
    /// on EINTR - callers must handle signal interruption explicitly. For automatic
    /// EINTR retry, use the policy-aware wrapper in `POSIX_Kernel`.
    ///
    /// ## EINTR
    /// This function does NOT retry on EINTR. On signal interruption, throws
    /// `.platform(Kernel.Error(code: .posix(EINTR)))`. Callers should check
    /// `error.isInterrupted` and retry if appropriate.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Throws: `Kernel.File.Flush.Error` on failure (including EINTR).
    public static func flush(_ descriptor: borrowing Kernel.Descriptor) throws(Error) {
        #if canImport(Darwin)
            let result = Darwin.fsync(descriptor._rawValue)
        #elseif canImport(Musl)
            let result = Musl.fsync(descriptor._rawValue)
        #elseif canImport(Glibc)
            let result = Glibc.fsync(descriptor._rawValue)
        #endif

        if result == 0 {
            return
        }

        throw Error.current()
    }

    #if os(Linux)
    /// Synchronizes a file's data (without metadata) to storage device.
    ///
    /// This is the raw POSIX `fdatasync(2)` syscall. It does NOT automatically retry
    /// on EINTR - callers must handle signal interruption explicitly. For automatic
    /// EINTR retry, use the policy-aware wrapper in `POSIX_Kernel`.
    ///
    /// Like `flush()`, but does not flush modified metadata unless needed
    /// to allow subsequent data retrieval.
    ///
    /// ## EINTR
    /// This function does NOT retry on EINTR. On signal interruption, throws
    /// `.platform(Kernel.Error(code: .posix(EINTR)))`. Callers should check
    /// `error.isInterrupted` and retry if appropriate.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Throws: `Kernel.File.Flush.Error` on failure (including EINTR).
    public static func data(_ descriptor: borrowing Kernel.Descriptor) throws(Error) {
        #if canImport(Musl)
            let result = Musl.fdatasync(descriptor._rawValue)
        #elseif canImport(Glibc)
            let result = Glibc.fdatasync(descriptor._rawValue)
        #endif

        if result == 0 {
            return
        }

        throw Error.current()
    }
    #endif

    #if canImport(Darwin)
    /// Flushes data to permanent storage with full sync (Darwin).
    ///
    /// This is the raw Darwin `fcntl(F_FULLFSYNC)` syscall. It does NOT automatically
    /// retry on EINTR - callers must handle signal interruption explicitly. For automatic
    /// EINTR retry, use the policy-aware wrapper in `POSIX_Kernel`.
    ///
    /// Uses F_FULLFSYNC to ensure data is flushed through disk caches.
    /// This is the strongest durability guarantee on Darwin.
    ///
    /// ## EINTR
    /// This function does NOT retry on EINTR. On signal interruption, throws
    /// `.platform(Kernel.Error(code: .posix(EINTR)))`. Callers should check
    /// `error.isInterrupted` and retry if appropriate.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Throws: `Kernel.File.Flush.Error` on failure (including EINTR).
    public static func full(_ descriptor: borrowing Kernel.Descriptor) throws(Error) {
        let result = Darwin.fcntl(descriptor._rawValue, F_FULLFSYNC)

        if result != -1 {
            return
        }

        throw Error.current()
    }

    /// Flushes data with barrier sync (Darwin).
    ///
    /// This is the raw Darwin `fcntl(F_BARRIERFSYNC)` syscall. It does NOT automatically
    /// retry on EINTR - callers must handle signal interruption explicitly. For automatic
    /// EINTR retry, use the policy-aware wrapper in `POSIX_Kernel`.
    ///
    /// Uses F_BARRIERFSYNC which is lighter than F_FULLFSYNC but still provides
    /// ordering guarantees. Data is flushed to disk and a barrier is issued to
    /// ensure ordering with subsequent writes.
    ///
    /// ## EINTR
    /// This function does NOT retry on EINTR. On signal interruption, throws
    /// `.platform(Kernel.Error(code: .posix(EINTR)))`. Callers should check
    /// `error.isInterrupted` and retry if appropriate.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Throws: `Kernel.File.Flush.Error` on failure (including EINTR).
    public static func barrier(_ descriptor: borrowing Kernel.Descriptor) throws(Error) {
        let result = Darwin.fcntl(descriptor._rawValue, F_BARRIERFSYNC)

        if result != -1 {
            return
        }

        throw Error.current()
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
        let e = errno
        let code = Kernel.Error.Code.posix(e)
        if let handleError = Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        if let ioError = Kernel.IO.Error(code: code) {
            return .io(ioError)
        }
        return .platform(Kernel.Error(code: code))
    }
}
