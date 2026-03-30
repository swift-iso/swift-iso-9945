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
            let result = Glibc.lseek(descriptor._rawValue, offset, whence.rawValue)
        #endif

        guard result >= 0 else {
            throw Error.current()
        }
        return result
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

// MARK: - Whence

extension ISO_9945.Kernel.File.Seek {
    /// The reference point for seek operations.
    public struct Whence: RawRepresentable, Sendable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Seek from the beginning of the file.
        public static let start = Whence(rawValue: SEEK_SET)

        /// Seek from the current position.
        public static let current = Whence(rawValue: SEEK_CUR)

        /// Seek from the end of the file.
        public static let end = Whence(rawValue: SEEK_END)

        #if canImport(Darwin)
        /// Seek to the next hole (Darwin).
        public static let hole = Whence(rawValue: SEEK_HOLE)

        /// Seek to the next data region (Darwin).
        public static let data = Whence(rawValue: SEEK_DATA)
        #elseif os(Linux)
        /// Seek to the next hole (Linux).
        public static let hole = Whence(rawValue: SEEK_HOLE)

        /// Seek to the next data region (Linux).
        public static let data = Whence(rawValue: SEEK_DATA)
        #endif
    }
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
