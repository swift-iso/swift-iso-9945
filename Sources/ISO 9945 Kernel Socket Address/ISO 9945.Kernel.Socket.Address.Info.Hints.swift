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

extension ISO_9945.Kernel.Socket.Address.Info {
    /// Host-resolution input constraints.
    ///
    /// Mirrors the hints `addrinfo` accepted by `getaddrinfo`: options
    /// (`ai_flags`), family (`ai_family`), socket type (`ai_socktype`), and
    /// protocol number (`ai_protocol`). Absent constraints leave the system
    /// resolver's defaults in force.
    public struct Hints: Sendable, Equatable, Hashable {
        /// Input options (`ai_flags`).
        public var options: ISO_9945.Kernel.Socket.Address.Info.Options

        /// The requested address family (`ai_family`).
        public var family: ISO_9945.Kernel.Socket.Address.Family

        /// The requested socket type (`ai_socktype`), or nil for any.
        public var kind: ISO_9945.Kernel.Socket.Kind?

        /// The requested protocol number (`ai_protocol`); 0 means any.
        public var `protocol`: Int32

        /// Creates host-resolution hints.
        ///
        /// - Parameters:
        ///   - options: Input options.
        ///   - family: The requested address family.
        ///   - kind: The requested socket type, or nil for any.
        ///   - protocol: The requested protocol number; 0 means any.
        public init(
            options: ISO_9945.Kernel.Socket.Address.Info.Options = [],
            family: ISO_9945.Kernel.Socket.Address.Family = .unspecified,
            kind: ISO_9945.Kernel.Socket.Kind? = nil,
            protocol: Int32 = 0
        ) {
            self.options = options
            self.family = family
            self.kind = kind
            self.protocol = `protocol`
        }
    }
}
