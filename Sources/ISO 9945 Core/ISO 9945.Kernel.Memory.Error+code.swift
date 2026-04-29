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

extension Kernel.Memory.Error {
    /// The underlying POSIX error code.
    @inlinable
    public var code: Error_Primitives.Error.Code {
        switch self {
        case .fault:
            return .POSIX.EFAULT
        case .exhausted:
            return .POSIX.ENOMEM
        }
    }
}

// MARK: - POSIX Error Code Mapping

extension Kernel.Memory.Error {
    /// Creates an error from a POSIX error code, if applicable.
    ///
    /// Returns `nil` if the error code doesn't map to a memory error.
    ///
    /// - Parameter code: The platform error code.
    /// - Returns: A memory error, or `nil` if not applicable.
    @inlinable
    public init?(code: Error_Primitives.Error.Code) {
        switch code {
        case .POSIX.EFAULT:
            self = .fault
        case .POSIX.ENOMEM:
            self = .exhausted
        default:
            return nil
        }
    }
}
