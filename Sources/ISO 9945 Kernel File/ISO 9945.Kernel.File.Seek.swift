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

// MARK: - POSIX lseek() syscall

extension ISO_9945.Kernel.File.Seek {
    /// Repositions the file offset of a file descriptor.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor.
    ///   - offset: The offset value.
    ///   - whence: The reference point for the offset.
    /// - Returns: The resulting offset from the beginning of the file.
    /// - Throws: `Kernel.File.Seek.Error` on failure.
    @discardableResult
    public static func seek(
        _ descriptor: borrowing Kernel.Descriptor,
        offset: Int64,
        whence: Whence
    ) throws(Error) -> Int64 {
        #if canImport(Darwin)
            let result = Darwin.lseek(descriptor._rawValue, offset, whence.rawValue)
        #elseif canImport(Musl)
            let result = Musl.lseek(descriptor._rawValue, offset, whence.rawValue)
        #elseif canImport(Glibc)
            let result = Glibc.lseek(descriptor._rawValue, off_t(offset), whence.rawValue)
        #endif

        guard result >= 0 else {
            throw Error.current()
        }
        return Int64(result)
    }

    /// Gets the current file offset.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Returns: The current offset from the beginning of the file.
    /// - Throws: `Kernel.File.Seek.Error` on failure.
    public static func tell(_ descriptor: borrowing Kernel.Descriptor) throws(Error) -> Int64 {
        try seek(descriptor, offset: 0, whence: .current)
    }
}

// MARK: - POSIX Whence Constants

extension Kernel.File.Seek.Whence {
    /// Seek from the beginning of the file (SEEK_SET).
    public static let start = Self(rawValue: SEEK_SET)

    /// Seek from the current position (SEEK_CUR).
    public static let current = Self(rawValue: SEEK_CUR)

    /// Seek from the end of the file (SEEK_END).
    public static let end = Self(rawValue: SEEK_END)
}

// MARK: - Error

extension ISO_9945.Kernel.File.Seek {
    public typealias Error = Kernel.File.Seek.Error
}

extension ISO_9945.Kernel.File.Seek.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let e = errno
        switch e {
        case EBADF:
            return .invalidDescriptor
        case EINVAL:
            return .negativeOffset
        case ESPIPE:
            return .notSeekable
        case EOVERFLOW:
            return .overflow
        default:
            return .platform(code: .posix(e))
        }
    }
}
