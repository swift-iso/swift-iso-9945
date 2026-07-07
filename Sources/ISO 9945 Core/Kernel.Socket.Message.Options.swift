// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Kernel.Socket.Message {
    /// Socket message flags (MSG_* constants).
    ///
    /// Controls behavior of send and receive operations on sockets.
    /// Multiple options can be combined using bitwise OR.
    ///
    /// ## Platform Constants
    ///
    /// POSIX constants are in `swift-iso-9945` (`ISO_9945.Kernel.Socket.Message.Options`).
    /// Linux-specific constants are in `swift-linux-primitives`.
    /// Darwin-specific constants are in `swift-darwin-primitives`.
    public struct Options: OptionSet, Sendable {
        /// The platform message flags.
        public let rawValue: Int32

        /// Creates options from raw platform flags.
        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}
