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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Address.Info {
    /// Host-resolution input options (`ai_flags`).
    public struct Options: OptionSet, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Constants

extension ISO_9945.Kernel.Socket.Address.Info.Options {
    /// Returned addresses are intended for `bind` (AI_PASSIVE).
    public static let passive = Self(rawValue: AI_PASSIVE)

    /// Request the canonical node name (AI_CANONNAME).
    public static let canonicalName = Self(rawValue: AI_CANONNAME)

    /// The node name is a numeric address string; no name lookup (AI_NUMERICHOST).
    public static let numericHost = Self(rawValue: AI_NUMERICHOST)

    /// The service name is a numeric port string; no service lookup (AI_NUMERICSERV).
    public static let numericService = Self(rawValue: AI_NUMERICSERV)

    /// Report IPv4-mapped IPv6 addresses when no IPv6 addresses exist (AI_V4MAPPED).
    public static let v4Mapped = Self(rawValue: AI_V4MAPPED)

    /// Report both IPv6 and IPv4-mapped IPv6 addresses (AI_ALL).
    public static let all = Self(rawValue: AI_ALL)

    /// Report addresses of a family only when the system has an address of
    /// that family configured (AI_ADDRCONFIG).
    public static let addressConfiguration = Self(rawValue: AI_ADDRCONFIG)
}
