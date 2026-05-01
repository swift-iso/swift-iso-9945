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

@_spi(Syscall) public import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Shutdown typed (Phase 1.5)

extension ISO_9945.Kernel.Socket.Shutdown {
    /// Shuts down part of a full-duplex connection on a typed socket descriptor.
    public static func shutdown(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        how: How
    ) throws(Error) {
        try shutdown(fd: descriptor._rawValue, how: how)
    }
}

// MARK: - POSIX shutdown() syscall (raw fd SPI)

extension ISO_9945.Kernel.Socket.Shutdown {
    /// Shuts down part of a full-duplex connection (raw fd).
    ///
    /// - Parameters:
    ///   - fd: The socket file descriptor.
    ///   - how: Which half of the connection to shut down.
    /// - Throws: `ISO_9945.Kernel.Socket.Shutdown.Error` on failure.
    internal static func shutdown(
        fd: Int32,
        how: How
    ) throws(Error) {
        #if canImport(Darwin)
            let result = Darwin.shutdown(fd, how.rawValue)
        #elseif canImport(Musl)
            let result = Musl.shutdown(fd, how.rawValue)
        #elseif canImport(Glibc)
            let result = Glibc.shutdown(fd, how.rawValue)
        #endif

        guard result == 0 else {
            throw ISO_9945.Kernel.Socket.Shutdown.Error.current()
        }
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.Socket.Shutdown.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Error_Primitives.Error.Code.current()
        return .platform(Error_Primitives.Error(code: code))
    }
}
