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

extension ISO_9945.Kernel.Socket {
    /// Socket option namespace.
    public enum Option {}
}

// MARK: - Get/Set Int32 Options (raw fd SPI)

extension ISO_9945.Kernel.Socket.Option {
    /// Gets a socket option as an Int32 value.
    ///
    /// - Parameters:
    ///   - fd: The socket raw fd.
    ///   - level: The option level (e.g., `.socket`, `.tcp`).
    ///   - name: The option name (platform constant, e.g., `SO_REUSEADDR`).
    /// - Returns: The option value.
    /// - Throws: `Kernel.Socket.Error` on failure.
    @_spi(Syscall)
    public static func get(
        fd: Int32,
        level: Level,
        name: Int32
    ) throws(Kernel.Socket.Error) -> Int32 {
        var value: Int32 = 0
        var len = socklen_t(MemoryLayout<Int32>.size)

        let rc = unsafe getsockopt(
            fd,
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
    ///   - fd: The socket raw fd.
    ///   - level: The option level (e.g., `.socket`, `.tcp`).
    ///   - name: The option name (platform constant, e.g., `SO_REUSEADDR`).
    ///   - value: The option value to set.
    /// - Throws: `Kernel.Socket.Error` on failure.
    @_spi(Syscall)
    public static func set(
        fd: Int32,
        level: Level,
        name: Int32,
        value: Int32
    ) throws(Kernel.Socket.Error) {
        var val = value
        let rc = unsafe setsockopt(
            fd,
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

// MARK: - Bool Overloads (raw fd SPI)

extension ISO_9945.Kernel.Socket.Option {
    /// Gets a boolean socket option.
    @_spi(Syscall)
    public static func get(
        fd: Int32,
        level: Level,
        name: Int32
    ) throws(Kernel.Socket.Error) -> Bool {
        let value: Int32 = try get(fd: fd, level: level, name: name)
        return value != 0
    }

    /// Sets a boolean socket option.
    @_spi(Syscall)
    public static func set(
        fd: Int32,
        level: Level,
        name: Int32,
        enabled: Bool
    ) throws(Kernel.Socket.Error) {
        try set(fd: fd, level: level, name: name, value: enabled ? 1 : 0)
    }
}
