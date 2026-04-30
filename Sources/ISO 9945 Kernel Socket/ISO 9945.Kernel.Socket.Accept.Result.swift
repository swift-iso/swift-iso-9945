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

extension ISO_9945.Kernel.Socket.Accept {
    /// Result of an accept operation.
    ///
    /// `@frozen` commits the struct's layout so consumers across module
    /// boundaries can partially consume individual stored properties
    /// without the swap-with-sentinel workaround. The layout is stable by
    /// construction — the three stored properties mirror the POSIX
    /// `accept(2)` return shape and are not expected to evolve.
    ///
    /// Per Cycle 21, the descriptor is the raw POSIX fd. L3-policy callers
    /// at swift-posix wrap into POSIX.Kernel.Socket.Descriptor via the
    /// `Kernel.Socket.Descriptor` typealias chain at swift-kernel L3.
    @frozen
    public struct Result: Sendable {
        /// The new connected socket file descriptor (raw POSIX fd).
        public var descriptor: Int32

        /// The address of the connecting peer.
        public var address: Kernel.Socket.Address.Storage

        /// The length of the peer address.
        public var length: Kernel.Socket.Address.Length

        @inlinable
        internal init(
            descriptor: Int32,
            address: Kernel.Socket.Address.Storage,
            length: Kernel.Socket.Address.Length
        ) {
            self.descriptor = descriptor
            self.address = address
            self.length = length
        }
    }
}
