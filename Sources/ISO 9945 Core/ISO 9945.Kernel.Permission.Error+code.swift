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

// MARK: - POSIX Error Code Mapping

extension Kernel.Permission.Error {
    /// Creates an error from a POSIX error code, if it maps to a permission error.
    ///
    /// - Parameter code: The platform error code.
    /// - Returns: The semantic error, or nil if the code doesn't map to a permission error.
    @inlinable
    public init?(code: Error_Primitives.Error.Code) {
        switch code {
        case .POSIX.EACCES:
            self = .denied
        case .POSIX.EPERM:
            self = .notPermitted
        case .POSIX.EROFS:
            self = .readOnlyFilesystem
        default:
            return nil
        }
    }
}
