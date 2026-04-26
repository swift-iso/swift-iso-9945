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

extension Kernel.Storage.Error {
    /// The underlying POSIX error code.
    @inlinable
    public var code: Kernel.Error.Code {
        switch self {
        case .exhausted:
            return .POSIX.ENOSPC
        case .quota:
            return .POSIX.EDQUOT
        }
    }
}

// MARK: - POSIX Error Code Mapping

extension Kernel.Storage.Error {
    /// Creates an error from a POSIX error code, if applicable.
    ///
    /// Returns `nil` if the error code doesn't map to a storage error.
    ///
    /// - Parameter code: The platform error code.
    /// - Returns: A storage error, or `nil` if not applicable.
    @inlinable
    public init?(code: Kernel.Error.Code) {
        switch code {
        case .POSIX.ENOSPC:
            self = .exhausted
        case _ where Kernel.Error.Code.POSIX.isEDQUOT(code):
            self = .quota
        default:
            return nil
        }
    }
}
