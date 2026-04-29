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

extension Kernel.IO.Error {
    /// The underlying POSIX error code.
    @inlinable
    public var code: Error_Primitives.Error.Code {
        switch self {
        case .broken:
            return .POSIX.EPIPE
        case .reset:
            return .POSIX.ECONNRESET
        case .hardware:
            return .POSIX.EIO
        case .illegalSeek:
            return .POSIX.ESPIPE
        case .deviceUnsupported:
            return .POSIX.ENODEV
        case .deviceUnavailable:
            return .POSIX.ENXIO
        case .unsupported:
            return .POSIX.ENOTSUP
        }
    }
}

// MARK: - POSIX Error Code Mapping

extension Kernel.IO.Error {
    /// Creates an error from a POSIX error code, if applicable.
    ///
    /// Returns `nil` if the error code doesn't map to an I/O error.
    ///
    /// - Parameter code: The platform error code.
    /// - Returns: An I/O error, or `nil` if not applicable.
    @inlinable
    public init?(code: Error_Primitives.Error.Code) {
        switch code {
        case .POSIX.EPIPE:
            self = .broken
        case _ where Error_Primitives.Error.Code.POSIX.isECONNRESET(code):
            self = .reset
        case .POSIX.EIO:
            self = .hardware
        case .POSIX.ESPIPE:
            self = .illegalSeek
        case .POSIX.ENODEV:
            self = .deviceUnsupported
        case .POSIX.ENXIO:
            self = .deviceUnavailable
        case _ where Error_Primitives.Error.Code.POSIX.isENOTSUP(code):
            self = .unsupported
        default:
            return nil
        }
    }
}
