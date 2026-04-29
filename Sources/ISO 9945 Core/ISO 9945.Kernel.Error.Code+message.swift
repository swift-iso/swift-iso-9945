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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Error_Primitives.Error.Code {
    /// Returns the platform error message for a POSIX error code.
    ///
    /// Calls `strerror()` (ISO 9945 / POSIX.1) for `.posix` codes.
    /// Returns `nil` for `.win32` codes.
    public var posixMessage: Swift.String? {
        switch self {
        case .posix(let rawValue):
            return unsafe Swift.String(cString: strerror(rawValue))
        case .win32:
            return nil
        }
    }
}
