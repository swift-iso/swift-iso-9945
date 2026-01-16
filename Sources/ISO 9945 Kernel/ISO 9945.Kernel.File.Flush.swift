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
    /// Flushes all modified data and attributes of the file to permanent storage.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Throws: `Kernel.File.Flush.Error` on failure.
    public static func flush(_ descriptor: Kernel.Descriptor) throws(Error) {
        #if canImport(Darwin)
            let result = Darwin.fsync(descriptor._rawValue)
        #elseif canImport(Musl)
            let result = Musl.fsync(descriptor._rawValue)
        #elseif canImport(Glibc)
            let result = Glibc.fsync(descriptor._rawValue)
        #endif

        try Kernel.Syscall.require(result, .equals(0), orThrow: Error.current())
    }

    #if os(Linux)
    /// Synchronizes a file's data (without metadata) to storage device.
    ///
    /// Like `flush()`, but does not flush modified metadata unless needed
    /// to allow subsequent data retrieval.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Throws: `Kernel.File.Flush.Error` on failure.
    public static func flushData(_ descriptor: Kernel.Descriptor) throws(Error) {
        let result = Glibc.fdatasync(descriptor._rawValue)
        try Kernel.Syscall.require(result, .equals(0), orThrow: Error.current())
    }
    #endif

    #if canImport(Darwin)
    /// Flushes data to permanent storage with full sync (Darwin).
    ///
    /// Uses F_FULLFSYNC to ensure data is flushed through disk caches.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Throws: `Kernel.File.Flush.Error` on failure.
    public static func fullFlush(_ descriptor: Kernel.Descriptor) throws(Error) {
        let result = Darwin.fcntl(descriptor._rawValue, F_FULLFSYNC)
        try Kernel.Syscall.require(result, .not(-1), orThrow: Error.current())
    }
    #endif
}

// MARK: - Error

extension ISO_9945.Kernel.File.Flush {
    public typealias Error = Kernel.File.Flush.Error
}

extension Kernel.File.Flush.Error {
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
