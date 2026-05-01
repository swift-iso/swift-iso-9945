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

extension ISO_9945.Kernel.Socket.Option {
    /// Socket option name.
    ///
    /// Typed wrapper for the platform constant identifying which option
    /// to get/set within a `Level`. Pair with `ISO_9945.Kernel.Socket.Option.Level`
    /// per POSIX `getsockopt(2)` / `setsockopt(2)` calling convention.
    public struct Name: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - SOL_SOCKET names

extension ISO_9945.Kernel.Socket.Option.Name {
    /// Pending socket error (`SO_ERROR`). Read-only via `getsockopt`.
    public static let error = Self(rawValue: SO_ERROR)

    /// Allow reuse of local addresses (`SO_REUSEADDR`).
    public static let reuseAddress = Self(rawValue: SO_REUSEADDR)

    /// Allow reuse of local ports for multiple listeners (`SO_REUSEPORT`).
    public static let reusePort = Self(rawValue: SO_REUSEPORT)

    /// Enable keep-alive probes on a connection-mode socket (`SO_KEEPALIVE`).
    public static let keepAlive = Self(rawValue: SO_KEEPALIVE)

    /// Permit sending broadcast datagrams (`SO_BROADCAST`).
    public static let broadcast = Self(rawValue: SO_BROADCAST)

    /// Linger on close if data is present (`SO_LINGER`).
    public static let linger = Self(rawValue: SO_LINGER)

    /// Receive buffer size in bytes (`SO_RCVBUF`).
    public static let receiveBuffer = Self(rawValue: SO_RCVBUF)

    /// Send buffer size in bytes (`SO_SNDBUF`).
    public static let sendBuffer = Self(rawValue: SO_SNDBUF)

    /// Receive timeout (`SO_RCVTIMEO`).
    public static let receiveTimeout = Self(rawValue: SO_RCVTIMEO)

    /// Send timeout (`SO_SNDTIMEO`).
    public static let sendTimeout = Self(rawValue: SO_SNDTIMEO)

    /// Send out-of-band data inline (`SO_OOBINLINE`).
    public static let outOfBandInline = Self(rawValue: SO_OOBINLINE)

    /// Suppress SIGPIPE on broken-pipe writes — Darwin only (`SO_NOSIGPIPE`).
    #if canImport(Darwin)
    public static let noSIGPIPE = Self(rawValue: SO_NOSIGPIPE)
    #endif

    /// Get the socket type (`SO_TYPE`). Read-only via `getsockopt`.
    public static let type = Self(rawValue: SO_TYPE)

    /// Get the protocol family of the socket (`SO_DOMAIN`) — Linux only.
    #if canImport(Glibc) || canImport(Musl)
    public static let domain = Self(rawValue: SO_DOMAIN)
    #endif
}

// MARK: - IPPROTO_TCP names

extension ISO_9945.Kernel.Socket.Option.Name {
    /// Disable Nagle's algorithm (`TCP_NODELAY`).
    public static let tcpNoDelay = Self(rawValue: TCP_NODELAY)

    /// Maximum segment size (`TCP_MAXSEG`).
    public static let tcpMaxSegmentSize = Self(rawValue: TCP_MAXSEG)
}

// MARK: - IPPROTO_IP names

extension ISO_9945.Kernel.Socket.Option.Name {
    /// IPv4 time-to-live (`IP_TTL`).
    public static let ipTimeToLive = Self(rawValue: IP_TTL)

    /// IPv4 type-of-service (`IP_TOS`).
    public static let ipTypeOfService = Self(rawValue: IP_TOS)
}

// MARK: - IPPROTO_IPV6 names

extension ISO_9945.Kernel.Socket.Option.Name {
    /// IPv6 hop limit for unicast (`IPV6_UNICAST_HOPS`).
    public static let ipv6UnicastHops = Self(rawValue: IPV6_UNICAST_HOPS)

    /// Bind only to IPv6 (no IPv4-mapped) — `IPV6_V6ONLY`.
    public static let ipv6Only = Self(rawValue: IPV6_V6ONLY)
}
