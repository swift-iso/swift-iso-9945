// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Kernel.Socket.Shutdown {
    /// Specifies which half of the connection to shut down.
    ///
    /// POSIX.1-2017 `<sys/socket.h>` defines `SHUT_RD`/`SHUT_WR`/`SHUT_RDWR`
    /// as symbolic constants only; it does not fix their numeric values.
    /// The raw values below are not a spec guarantee — they are the value
    /// every platform this package supports (Darwin, Linux, the BSDs)
    /// happens to agree on in practice.
    public enum How: Int32, Sendable {
        /// Shut down the read side of the connection.
        case read = 0  // SHUT_RD

        /// Shut down the write side of the connection.
        case write = 1  // SHUT_WR

        /// Shut down both read and write sides.
        case both = 2  // SHUT_RDWR
    }
}
