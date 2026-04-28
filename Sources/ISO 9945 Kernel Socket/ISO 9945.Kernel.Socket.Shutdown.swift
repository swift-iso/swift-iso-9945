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

// MARK: - POSIX shutdown() syscall

extension ISO_9945.Kernel.Socket.Shutdown {
    /// Shuts down part of a full-duplex connection (raw fd).
    ///
    /// Spec-literal: takes a raw `Int32` fd. The L3-policy typed-descriptor
    /// convenience lives at swift-posix per [PLAT-ARCH-005] / [PLAT-ARCH-008e].
    ///
    /// - Parameters:
    ///   - fd: The socket file descriptor.
    ///   - how: Which half of the connection to shut down.
    /// - Throws: `Kernel.Socket.Shutdown.Error` on failure.
    @_spi(Syscall)
    public static func shutdown(
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
            throw Kernel.Socket.Shutdown.Error.current()
        }
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.Socket.Shutdown.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Kernel.Error.Code.current()
        if let handleError = Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        if let ioError = Kernel.IO.Error(code: code) {
            return .io(ioError)
        }
        return .platform(Kernel.Error(code: code))
    }
}
