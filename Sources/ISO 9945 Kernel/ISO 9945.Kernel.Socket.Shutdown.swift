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

// MARK: - POSIX shutdown() syscall

extension ISO_9945.Kernel.Socket.Shutdown {
    /// Shuts down part of a full-duplex connection.
    ///
    /// - Parameters:
    ///   - descriptor: The socket descriptor.
    ///   - how: Which half of the connection to shut down.
    /// - Throws: `Kernel.Socket.Shutdown.Error` on failure.
    public static func shutdown(
        _ descriptor: borrowing Kernel.Descriptor,
        how: How
    ) throws(Error) {
        #if canImport(Darwin)
            let result = Darwin.shutdown(descriptor._rawValue, how.rawValue)
        #elseif canImport(Musl)
            let result = Musl.shutdown(descriptor._rawValue, how.rawValue)
        #elseif canImport(Glibc)
            let result = Glibc.shutdown(descriptor._rawValue, how.rawValue)
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
