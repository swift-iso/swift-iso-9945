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

public import Path_Primitives

// MARK: - POSIX Error Code Mapping

extension Path.Resolution.Error {
    /// Creates an error from a POSIX error code, if it maps to a path resolution error.
    ///
    /// - Parameter code: The platform error code.
    /// - Returns: The semantic error, or nil if the code doesn't map to a path resolution error.
    @inlinable
    public init?(code: Kernel.Error.Code) {
        switch code {
        case .POSIX.ENOENT:
            self = .notFound
        case .POSIX.EEXIST:
            self = .exists
        case .POSIX.EISDIR:
            self = .isDirectory
        case .POSIX.ENOTDIR:
            self = .notDirectory
        case _ where Kernel.Error.Code.POSIX.isENOTEMPTY(code):
            self = .notEmpty
        case _ where Kernel.Error.Code.POSIX.isELOOP(code):
            self = .loop
        case .POSIX.EXDEV:
            self = .crossDevice
        case _ where Kernel.Error.Code.POSIX.isENAMETOOLONG(code):
            self = .nameTooLong
        default:
            return nil
        }
    }
}
