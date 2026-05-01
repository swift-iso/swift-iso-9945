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

@_spi(Syscall) public import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - getError typed (Phase 1.5)

extension ISO_9945.Kernel.Socket {
    /// Gets and clears the pending socket error (SO_ERROR) on a typed descriptor.
    public static func getError(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor
    ) throws(ISO_9945.Kernel.Socket.Error) -> Error_Primitives.Error.Code {
        try getError(fd: descriptor._rawValue)
    }
}

// MARK: - POSIX socket operations (raw fd SPI)

extension ISO_9945.Kernel.Socket {
    /// Gets and clears the pending socket error (SO_ERROR) — raw fd variant.
    ///
    /// Retrieves and atomically clears the pending error on a socket.
    /// Commonly used after non-blocking connect to check connection status,
    /// or after select/poll indicates an error condition.
    ///
    /// - Parameter fd: The socket file descriptor.
    /// - Returns: The error code (`.posix(0)` if no pending error).
    /// - Throws: `ISO_9945.Kernel.Socket.Error` if getsockopt fails.
    internal static func getError(fd: Int32) throws(ISO_9945.Kernel.Socket.Error) -> Error_Primitives.Error.Code {
        var err: Int32 = 0
        var len = socklen_t(MemoryLayout<Int32>.size)

        let rc = unsafe getsockopt(
            fd,
            SOL_SOCKET,
            SO_ERROR,
            &err,
            &len
        )

        guard rc == 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }

        return .posix(err)
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.Socket.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Error_Primitives.Error.Code.current()
        return .platform(Error_Primitives.Error(code: code))
    }
}
