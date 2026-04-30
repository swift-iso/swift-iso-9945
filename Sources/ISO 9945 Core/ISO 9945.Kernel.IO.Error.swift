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

extension ISO_9945.Kernel.IO {
    /// I/O operation errors.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Broken pipe — peer closed the connection.
        /// - POSIX: `EPIPE`
        ///
        /// Writing to a pipe or socket whose read end is closed.
        case broken

        /// Connection reset by peer.
        /// - POSIX: `ECONNRESET`
        ///
        /// The remote end forcibly closed the connection.
        case reset

        /// Physical I/O error.
        /// - POSIX: `EIO`
        ///
        /// Hardware failure or unrecoverable device error.
        case hardware

        /// Illegal seek on non-seekable descriptor.
        /// - POSIX: `ESPIPE`
        ///
        /// Attempting to seek on a pipe, socket, or FIFO.
        case illegalSeek

        /// Device does not support the operation.
        /// - POSIX: `ENODEV`
        case deviceUnsupported

        /// Device not configured or unavailable.
        /// - POSIX: `ENXIO`
        case deviceUnavailable

        /// Operation not supported on this type.
        /// - POSIX: `ENOTSUP`, `EOPNOTSUPP`
        case unsupported
    }
}

// MARK: - CustomStringConvertible

extension ISO_9945.Kernel.IO.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .broken:
            return "broken pipe"
        case .reset:
            return "connection reset"
        case .hardware:
            return "I/O error"
        case .illegalSeek:
            return "illegal seek"
        case .deviceUnsupported:
            return "operation not supported by device"
        case .deviceUnavailable:
            return "device unavailable"
        case .unsupported:
            return "operation not supported"
        }
    }
}
