// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-posix open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-posix project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Error

extension ISO_9945.Kernel.Socket.Pair {
    /// Errors from socket pair operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Platform-specific error.
        case platform(Platform)
    }

    /// Creates the current error from errno.
    static func currentError() -> Error {
        .platform(.posix(errno))
    }
}

extension ISO_9945.Kernel.Socket.Pair.Error {
    /// Platform-specific error details.
    public enum Platform: Sendable, Equatable {
        /// A POSIX errno value.
        case posix(Int32)
    }
}

// MARK: - CustomStringConvertible

extension ISO_9945.Kernel.Socket.Pair.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .platform(let p):
            switch p {
            case .posix(let code):
                return "socketpair failed: errno \(code)"
            }
        }
    }
}
