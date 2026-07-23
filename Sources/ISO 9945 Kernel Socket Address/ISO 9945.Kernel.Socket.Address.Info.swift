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

extension ISO_9945.Kernel.Socket.Address {
    /// One owned host-resolution result entry.
    ///
    /// Mirrors one POSIX `addrinfo` node as a value. Every field the node
    /// referenced is copied into owned storage during conversion; no platform
    /// pointer survives into this type. Collections of entries preserve the
    /// order the system resolver returned.
    public struct Info: Sendable, Equatable {
        /// The address family (`ai_family`).
        public let family: ISO_9945.Kernel.Socket.Address.Family

        /// The socket type (`ai_socktype`).
        public let kind: ISO_9945.Kernel.Socket.Kind

        /// The protocol number (`ai_protocol`).
        public let `protocol`: Int32

        /// The socket address (`ai_addr`), copied into owned storage.
        public let address: ISO_9945.Kernel.Socket.Address.Storage

        /// The byte length of the socket address (`ai_addrlen`).
        public let length: ISO_9945.Kernel.Socket.Address.Length

        /// The canonical node name (`ai_canonname`), present on the first
        /// entry when ``Options-swift.struct/canonicalName`` was requested.
        public let canonical: String?

        /// Creates an owned host-resolution entry.
        ///
        /// - Parameters:
        ///   - family: The address family.
        ///   - kind: The socket type.
        ///   - protocol: The protocol number.
        ///   - address: The socket address in owned storage.
        ///   - length: The byte length of the address within storage.
        ///   - canonical: The canonical node name, if any.
        public init(
            family: ISO_9945.Kernel.Socket.Address.Family,
            kind: ISO_9945.Kernel.Socket.Kind,
            protocol: Int32,
            address: ISO_9945.Kernel.Socket.Address.Storage,
            length: ISO_9945.Kernel.Socket.Address.Length,
            canonical: String? = nil
        ) {
            self.family = family
            self.kind = kind
            self.protocol = `protocol`
            self.address = address
            self.length = length
            self.canonical = canonical
        }
    }
}

// MARK: - Equatable

extension ISO_9945.Kernel.Socket.Address.Info {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard
            lhs.family == rhs.family,
            lhs.kind == rhs.kind,
            lhs.protocol == rhs.protocol,
            lhs.length == rhs.length,
            lhs.canonical == rhs.canonical
        else { return false }
        return unsafe lhs.address.withUnsafeBytes { left, leftCapacity in
            unsafe rhs.address.withUnsafeBytes { right, rightCapacity in
                let count = Int(min(leftCapacity, rightCapacity))
                let length = Int(lhs.length.underlying.rawValue)
                guard length <= count else { return false }
                return unsafe UnsafeRawBufferPointer(start: left, count: length)
                    .elementsEqual(unsafe UnsafeRawBufferPointer(start: right, count: length))
            }
        }
    }
}
