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

@_spi(Syscall) import Kernel_Descriptor_Primitives  // for Kernel.Descriptor.Validity.Error in error mapping
@_spi(Syscall) import Kernel_Socket_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX socket operations

extension ISO_9945.Kernel.Socket {
    /// Gets and clears the pending socket error (SO_ERROR).
    ///
    /// Retrieves and atomically clears the pending error on a socket.
    /// Commonly used after non-blocking connect to check connection status,
    /// or after select/poll indicates an error condition.
    ///
    /// - Parameter descriptor: The socket descriptor.
    /// - Returns: The error code (`.posix(0)` if no pending error).
    /// - Throws: `Kernel.Socket.Error` if getsockopt fails.

    /// Gets and clears the pending socket error (SO_ERROR) — raw fd variant.
    ///
    /// Spec-literal: takes a raw `Int32` fd. The L3-policy typed-descriptor
    /// convenience lives at swift-posix per [PLAT-ARCH-005] / [PLAT-ARCH-008e].
    ///
    /// - Parameter fd: The socket file descriptor.
    /// - Returns: The error code (`.posix(0)` if no pending error).
    /// - Throws: `Kernel.Socket.Error` if getsockopt fails.
    @_spi(Syscall)
    public static func getError(fd: Int32) throws(Kernel.Socket.Error) -> Kernel.Error.Code {
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
            throw Kernel.Socket.Error.current()
        }

        return .posix(err)
    }

    /// Gets and clears the pending socket error (SO_ERROR) on a socket descriptor.
    ///
    /// Overload accepting `Kernel.Socket.Descriptor` for direct use from
    /// socket operations without ownership transfer.
    ///
    /// - Parameter descriptor: The socket descriptor.
    /// - Returns: The error code (`.posix(0)` if no pending error).
    /// - Throws: `Kernel.Socket.Error` if getsockopt fails.
    public static func getError(_ descriptor: borrowing Kernel.Socket.Descriptor) throws(Kernel.Socket.Error) -> Kernel.Error.Code {
        var err: Int32 = 0
        var len = socklen_t(MemoryLayout<Int32>.size)

        let rc = unsafe getsockopt(
            descriptor._rawValue,
            SOL_SOCKET,
            SO_ERROR,
            &err,
            &len
        )

        guard rc == 0 else {
            throw Kernel.Socket.Error.current()
        }

        return .posix(err)
    }
}

// MARK: - Typed Convenience (Phase 1.5)

extension ISO_9945.Kernel.Socket {
    /// Gets and clears the pending socket error using a typed descriptor.
    ///
    /// Phase 1.5 typed L2 form. Delegates to the raw `getError(fd:)` SPI.
    public static func getError(
        _ descriptor: borrowing Kernel.Descriptor
    ) throws(Kernel.Socket.Error) -> Kernel.Error.Code {
        try getError(fd: descriptor._rawValue)
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.Socket.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Kernel.Error.Code.current()
        if let handleError = Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        return .platform(Kernel.Error(code: code))
    }
}
