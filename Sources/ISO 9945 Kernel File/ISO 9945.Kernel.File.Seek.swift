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

@_spi(Syscall) import Kernel_Descriptor_Primitives
@_spi(Syscall) import Kernel_File_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX lseek() syscall (raw @_spi(Syscall))

extension ISO_9945.Kernel.File.Seek {
    /// Repositions the offset of a raw file descriptor.
    ///
    /// Spec-literal raw `lseek(2)`. The typed L2 convenience
    /// (`ISO_9945.Kernel.File.Seek.seek(_:offset:whence:)` taking
    /// `borrowing Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// - Parameters:
    ///   - fd: The raw file descriptor.
    ///   - offset: The offset value.
    ///   - whence: The reference point for the offset.
    /// - Returns: The resulting offset from the beginning of the file.
    /// - Throws: `Kernel.File.Seek.Error` on failure.
    @discardableResult
    @_spi(Syscall)
    public static func seek(
        fd: Int32,
        offset: Int64,
        whence: Whence
    ) throws(Error) -> Int64 {
        #if canImport(Darwin)
            let result = unsafe Darwin.lseek(fd, offset, whence.rawValue)
        #elseif canImport(Musl)
            let result = unsafe Musl.lseek(fd, offset, whence.rawValue)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.lseek(fd, off_t(offset), whence.rawValue)
        #endif

        guard result >= 0 else {
            throw Error.current()
        }
        return Int64(result)
    }

    /// Gets the current file offset of a raw file descriptor.
    ///
    /// Equivalent to `seek(fd:, offset: 0, whence: .current)`. The typed L2
    /// convenience (`ISO_9945.Kernel.File.Seek.tell(_:)` taking
    /// `borrowing Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// - Parameter fd: The raw file descriptor.
    /// - Returns: The current offset from the beginning of the file.
    /// - Throws: `Kernel.File.Seek.Error` on failure.
    @_spi(Syscall)
    public static func tell(fd: Int32) throws(Error) -> Int64 {
        try unsafe seek(fd: fd, offset: 0, whence: .current)
    }
}

// MARK: - Typed Convenience

extension ISO_9945.Kernel.File.Seek {
    /// Repositions the file offset of a file descriptor.
    ///
    /// Typed L2 form. Delegates to the raw `seek(fd:offset:whence:)` SPI via
    /// `descriptor._rawValue`.
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
        try unsafe seek(fd: descriptor._rawValue, offset: offset, whence: whence)
    }

    /// Gets the current file offset.
    ///
    /// Typed L2 form. Delegates to the raw `tell(fd:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Returns: The current offset from the beginning of the file.
    /// - Throws: `Kernel.File.Seek.Error` on failure.
    public static func tell(_ descriptor: borrowing Kernel.Descriptor) throws(Error) -> Int64 {
        try unsafe tell(fd: descriptor._rawValue)
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
        let code = Kernel.Error.Code.current()
        switch code {
        case .EBADF:
            return .invalidDescriptor
        case .EINVAL:
            return .negativeOffset
        case .ESPIPE:
            return .notSeekable
        case .EOVERFLOW:
            return .overflow
        default:
            return .platform(code: code)
        }
    }
}
