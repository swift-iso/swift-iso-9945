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

@_spi(Syscall) public import Kernel_Primitives_Core
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_IO_Primitives
@_spi(Syscall) public import Kernel_Socket_Primitives
@_spi(Syscall) public import Kernel_Memory_Primitives
@_spi(Syscall) public import Kernel_Process_Primitives
@_spi(Syscall) public import Kernel_Permission_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives
@_spi(Syscall) public import Kernel_Thread_Primitives
@_spi(Syscall) public import Kernel_System_Primitives
@_spi(Syscall) public import Kernel_Time_Primitives
@_spi(Syscall) public import Kernel_Clock_Primitives
@_spi(Syscall) public import Kernel_Random_Primitives
@_spi(Syscall) public import Kernel_Environment_Primitives
@_spi(Syscall) public import Kernel_Syscall_Primitives
@_spi(Syscall) public import Kernel_Terminal_Primitives
public import ISO_9945

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

    public static func getError(_ descriptor: borrowing Kernel.Descriptor) throws(Kernel.Socket.Error) -> Kernel.Error.Code {
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

// MARK: - Error Conversion

extension ISO_9945.Kernel.Socket.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let e = errno
        let code = Kernel.Error.Code.posix(e)
        if let handleError = Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        return .platform(Kernel.Error(code: code))
    }
}
