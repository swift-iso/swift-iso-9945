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
    /// (`consume result.descriptor`) without the swap-with-sentinel
    /// workaround. The layout is stable by construction — the three
    /// stored properties mirror the POSIX `accept(2)` return shape and
    /// are not expected to evolve.
    ///
    /// The descriptor is typed at birth: `accept(2)` is the ownership
    /// boundary, so the raw fd is wrapped into the move-only Descriptor
    /// inside the syscall layer. `Result` is therefore `~Copyable` —
    /// dropping it without consuming the descriptor closes the accepted
    /// connection via Descriptor deinit instead of leaking the fd.
    @frozen
    public struct Result: ~Copyable, Sendable {
        /// The new connected socket descriptor.
        public var descriptor: ISO_9945.Kernel.Socket.Descriptor

        /// The address of the connecting peer.
        public var address: ISO_9945.Kernel.Socket.Address.Storage

        /// The length of the peer address.
        public var length: ISO_9945.Kernel.Socket.Address.Length

        @inlinable
        package init(
            descriptor: consuming ISO_9945.Kernel.Socket.Descriptor,
            address: ISO_9945.Kernel.Socket.Address.Storage,
            length: ISO_9945.Kernel.Socket.Address.Length
        ) {
            self.descriptor = descriptor
            self.address = address
            self.length = length
        }
    }
}
