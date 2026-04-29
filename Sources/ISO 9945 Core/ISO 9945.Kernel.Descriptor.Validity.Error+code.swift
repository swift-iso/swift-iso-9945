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

// MARK: - POSIX Error Code Access

extension Kernel.Descriptor.Validity.Error {
    /// The underlying POSIX error code.
    @inlinable
    public var code: Error_Primitives.Error.Code {
        switch self {
        case .invalid:
            return .POSIX.EBADF
        case .limit(let limit):
            return limit.code
        }
    }
}

extension Kernel.Descriptor.Validity.Error.Limit {
    /// The underlying POSIX error code.
    @inlinable
    public var code: Error_Primitives.Error.Code {
        switch self {
        case .process:
            return .POSIX.EMFILE
        case .system:
            return .POSIX.ENFILE
        }
    }
}

// MARK: - POSIX Error Code Mapping

extension Kernel.Descriptor.Validity.Error {
    /// Creates an error from a POSIX error code, if applicable.
    ///
    /// Returns `nil` if the error code doesn't map to a handle error.
    ///
    /// - Parameter code: The platform error code.
    /// - Returns: A handle error, or `nil` if not applicable.
    @inlinable
    public init?(code: Error_Primitives.Error.Code) {
        switch code {
        case .POSIX.EBADF:
            self = .invalid
        case .POSIX.EMFILE:
            self = .limit(.process)
        case .POSIX.ENFILE:
            self = .limit(.system)
        default:
            return nil
        }
    }
}
