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

extension ISO_9945.Kernel.IO.Blocking.Error {
    /// The underlying POSIX error code.
    @inlinable
    public var code: Error_Primitives.Error.Code {
        switch self {
        case .wouldBlock:
            return .POSIX.EAGAIN
        }
    }
}

// MARK: - POSIX Error Code Mapping

extension ISO_9945.Kernel.IO.Blocking.Error {
    /// Creates an error from a POSIX error code, if applicable.
    ///
    /// Returns `nil` if the error code doesn't map to a blocking error.
    ///
    /// - Parameter code: The platform error code.
    /// - Returns: A blocking error, or `nil` if not applicable.
    @inlinable
    public init?(code: Error_Primitives.Error.Code) {
        if Error_Primitives.Error.Code.POSIX.isEAGAIN(code) {
            self = .wouldBlock
        } else {
            return nil
        }
    }
}
