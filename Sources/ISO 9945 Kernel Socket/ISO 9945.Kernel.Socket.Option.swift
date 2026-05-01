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

@_spi(Syscall) public import ISO_9945_Core

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

// MARK: - Get/Set typed (Phase 1.5)
//
// Typed Phase-1.5 forms re-added in Wave 4c-Socket Main (2026-05-01) per
// [PLAT-ARCH-005] three-tier chain (Prerequisite II). Both the descriptor
// AND the option name are typed: descriptor as
// `borrowing ISO_9945.Kernel.Socket.Descriptor`, name as
// `ISO_9945.Kernel.Socket.Option.Name` (RawRepresentable<Int32>).

extension ISO_9945.Kernel.Socket.Option {
    /// Gets a socket option as an Int32 value from a typed descriptor.
    public static func get(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        level: Level,
        name: Name
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int32 {
        try get(fd: descriptor._rawValue, level: level, name: name.rawValue)
    }

    /// Sets a socket option to an Int32 value on a typed descriptor.
    public static func set(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        level: Level,
        name: Name,
        value: Int32
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try set(fd: descriptor._rawValue, level: level, name: name.rawValue, value: value)
    }

    /// Gets a boolean socket option from a typed descriptor.
    public static func get(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        level: Level,
        name: Name
    ) throws(ISO_9945.Kernel.Socket.Error) -> Bool {
        try get(fd: descriptor._rawValue, level: level, name: name.rawValue)
    }

    /// Sets a boolean socket option on a typed descriptor.
    public static func set(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        level: Level,
        name: Name,
        enabled: Bool
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try set(fd: descriptor._rawValue, level: level, name: name.rawValue, enabled: enabled)
    }
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
    /// - Throws: `ISO_9945.Kernel.Socket.Error` on failure.
    internal static func get(
        fd: Int32,
        level: Level,
        name: Int32
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int32 {
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
            throw ISO_9945.Kernel.Socket.Error.current()
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
    /// - Throws: `ISO_9945.Kernel.Socket.Error` on failure.
    internal static func set(
        fd: Int32,
        level: Level,
        name: Int32,
        value: Int32
    ) throws(ISO_9945.Kernel.Socket.Error) {
        var val = value
        let rc = unsafe setsockopt(
            fd,
            level.rawValue,
            name,
            &val,
            socklen_t(MemoryLayout<Int32>.size)
        )

        guard rc == 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }
    }
}

// MARK: - Bool Overloads (raw fd SPI)

extension ISO_9945.Kernel.Socket.Option {
    /// Gets a boolean socket option.
    internal static func get(
        fd: Int32,
        level: Level,
        name: Int32
    ) throws(ISO_9945.Kernel.Socket.Error) -> Bool {
        let value: Int32 = try get(fd: fd, level: level, name: name)
        return value != 0
    }

    /// Sets a boolean socket option.
    internal static func set(
        fd: Int32,
        level: Level,
        name: Int32,
        enabled: Bool
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try set(fd: fd, level: level, name: name, value: enabled ? 1 : 0)
    }
}
