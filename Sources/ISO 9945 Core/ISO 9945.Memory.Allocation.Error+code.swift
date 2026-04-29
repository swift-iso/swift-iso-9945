// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// MARK: - POSIX Error Code Mapping

extension Memory.Allocation.Error {
    /// Creates an allocation error from a POSIX error code, if applicable.
    ///
    /// Returns `nil` if the code does not map to a memory allocation failure.
    ///
    /// - Parameter code: The platform error code.
    @inlinable
    public init?(code: Error_Primitives.Error.Code) {
        switch code {
        case .POSIX.ENOMEM:
            self = .exhausted
        default:
            return nil
        }
    }
}
