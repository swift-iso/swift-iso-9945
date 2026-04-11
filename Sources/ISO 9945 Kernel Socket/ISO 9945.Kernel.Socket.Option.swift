@_spi(Syscall) import Kernel_Descriptor_Primitives
@_spi(Syscall) import Kernel_Socket_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket {
    /// Socket option namespace.
    public enum Option {}
}

// MARK: - Level

extension ISO_9945.Kernel.Socket.Option {
    /// Socket option level.
    public struct Level: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Socket.Option.Level {
    /// Socket-level options (SOL_SOCKET).
    public static let socket = Self(rawValue: SOL_SOCKET)

    /// TCP-level options (IPPROTO_TCP).
    public static let tcp = Self(rawValue: Int32(IPPROTO_TCP))

    /// IPv4-level options (IPPROTO_IP).
    public static let ip = Self(rawValue: Int32(IPPROTO_IP))

    /// IPv6-level options (IPPROTO_IPV6).
    public static let ipv6 = Self(rawValue: Int32(IPPROTO_IPV6))
}

// MARK: - Get/Set Int32 Options

extension ISO_9945.Kernel.Socket.Option {
    /// Gets a socket option as an Int32 value.
    ///
    /// - Parameters:
    ///   - descriptor: The socket descriptor.
    ///   - level: The option level (e.g., `.socket`, `.tcp`).
    ///   - name: The option name (platform constant, e.g., `SO_REUSEADDR`).
    /// - Returns: The option value.
    /// - Throws: `Kernel.Socket.Error` on failure.
    public static func get(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        level: Level,
        name: Int32
    ) throws(Kernel.Socket.Error) -> Int32 {
        var value: Int32 = 0
        var len = socklen_t(MemoryLayout<Int32>.size)

        let rc = unsafe getsockopt(
            descriptor._rawValue,
            level.rawValue,
            name,
            &value,
            &len
        )

        guard rc == 0 else {
            throw Kernel.Socket.Error.current()
        }

        return value
    }

    /// Sets a socket option to an Int32 value.
    ///
    /// - Parameters:
    ///   - descriptor: The socket descriptor.
    ///   - level: The option level (e.g., `.socket`, `.tcp`).
    ///   - name: The option name (platform constant, e.g., `SO_REUSEADDR`).
    ///   - value: The option value to set.
    /// - Throws: `Kernel.Socket.Error` on failure.
    public static func set(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        level: Level,
        name: Int32,
        value: Int32
    ) throws(Kernel.Socket.Error) {
        var val = value
        let rc = unsafe setsockopt(
            descriptor._rawValue,
            level.rawValue,
            name,
            &val,
            socklen_t(MemoryLayout<Int32>.size)
        )

        guard rc == 0 else {
            throw Kernel.Socket.Error.current()
        }
    }
}

// MARK: - Convenience: Bool Options

extension ISO_9945.Kernel.Socket.Option {
    /// Gets a boolean socket option.
    public static func get(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        level: Level,
        name: Int32
    ) throws(Kernel.Socket.Error) -> Bool {
        let value: Int32 = try get(descriptor, level: level, name: name)
        return value != 0
    }

    /// Sets a boolean socket option.
    public static func set(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        level: Level,
        name: Int32,
        enabled: Bool
    ) throws(Kernel.Socket.Error) {
        try set(descriptor, level: level, name: name, value: enabled ? 1 : 0)
    }
}

// MARK: - Common Socket-Level Options

extension ISO_9945.Kernel.Socket.Option {
    /// Enables address reuse (SO_REUSEADDR).
    public static func setReuseAddress(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        enabled: Bool = true
    ) throws(Kernel.Socket.Error) {
        try set(descriptor, level: .socket, name: SO_REUSEADDR, enabled: enabled)
    }

    /// Enables keepalive probes (SO_KEEPALIVE).
    public static func setKeepAlive(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        enabled: Bool = true
    ) throws(Kernel.Socket.Error) {
        try set(descriptor, level: .socket, name: SO_KEEPALIVE, enabled: enabled)
    }

    /// Disables Nagle's algorithm for TCP (TCP_NODELAY).
    public static func setNoDelay(
        _ descriptor: borrowing Kernel.Socket.Descriptor,
        enabled: Bool = true
    ) throws(Kernel.Socket.Error) {
        try set(descriptor, level: .tcp, name: TCP_NODELAY, enabled: enabled)
    }
}
