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

extension ISO_9945.Kernel {
    /// A readiness event from the kernel selector.
    ///
    /// Events are produced by the selector's poll operation and represent
    /// what readiness conditions are now true for a registered descriptor.
    ///
    /// ## Architecture
    ///
    /// 1. **Vocabulary**: `Event`, `Interest`, `Options`, `ID` (this file + siblings)
    /// 2. **Platform backends**: kqueue (Darwin), epoll (Linux), IOCP (Windows)
    /// 3. **IO layer**: Selector, channels, async coordination
    public struct Event: Sendable, Equatable {
        /// The registration ID this event belongs to.
        public let id: ID

        /// Which interests are now ready.
        public let interest: Interest

        /// Additional status flags (error, hangup, etc.).
        public let flags: Options

        public init(id: ID, interest: Interest, flags: Options = []) {
            self.id = id
            self.interest = interest
            self.flags = flags
        }

        /// An empty event for buffer initialization.
        public static let empty = Event(id: .zero, interest: [], flags: [])
    }
}

extension ISO_9945.Kernel.Event: CustomStringConvertible {
    public var description: Swift.String {
        var parts = ["Event(id: \(id), interest: \(interest)"]
        if !flags.isEmpty {
            parts.append(", flags: \(flags)")
        }
        return parts.joined() + ")"
    }
}
