// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//


extension ISO_9945.Kernel.File {
    /// File position seeking operations.
    ///
    /// Wraps POSIX `lseek()` / Windows `SetFilePointerEx()`.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-posix-primitives` (`Posix.Kernel.File.Seek`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.File.Seek`)
    public enum Seek: Sendable {}
}

// MARK: - Whence

extension ISO_9945.Kernel.File.Seek {
    /// The reference point for a seek operation.
    ///
    /// POSIX constants (start, current, end) are in `swift-iso-9945`.
    /// Platform extensions (hole, data) are in platform packages.
    public struct Whence: RawRepresentable, Sendable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Error

extension ISO_9945.Kernel.File.Seek {
    /// Errors that can occur during seek operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The file descriptor is invalid.
        case invalidDescriptor

        /// The resulting offset would be negative.
        case negativeOffset

        /// The file descriptor refers to a pipe, socket, or FIFO.
        case notSeekable

        /// The resulting offset is too large for the file.
        case overflow

        /// Platform-specific error.
        case platform(code: Error_Primitives.Error.Code)
    }
}

// MARK: - CustomStringConvertible

extension ISO_9945.Kernel.File.Seek.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .invalidDescriptor:
            return "Invalid file descriptor"
        case .negativeOffset:
            return "Resulting offset would be negative"
        case .notSeekable:
            return "File descriptor is not seekable (pipe, socket, or FIFO)"
        case .overflow:
            return "Resulting offset would overflow"
        case .platform(let code):
            return "Seek failed: \(code)"
        }
    }
}

