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

extension ISO_9945.Kernel.Socket.Address {
    /// Unix domain socket address.
    ///
    /// Wraps `sockaddr_un`.
    public struct Unix: Sendable {
        internal var cValue: sockaddr_un

        /// Creates an empty Unix socket address.
        public init() {
            self.cValue = sockaddr_un()
            self.cValue.sun_family = sa_family_t(AF_UNIX)
            #if canImport(Darwin)
                self.cValue.sun_len = UInt8(Self.pathOffset + 1)
            #endif
        }
    }
}

// MARK: - Path

extension ISO_9945.Kernel.Socket.Address.Unix {
    /// Errors constructing a Unix domain address.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The path does not fit `sun_path` (including its terminator).
        case pathTooLong(length: Int, capacity: Int)
    }

    /// The byte offset of `sun_path` within `sockaddr_un`.
    internal static var pathOffset: Int {
        MemoryLayout<sockaddr_un>.offset(of: \.sun_path) ?? 2
    }

    /// The capacity of `sun_path` in bytes, including the terminator.
    public static var pathCapacity: Int {
        MemoryLayout<sockaddr_un>.size - pathOffset
    }

    /// Creates a Unix domain address for a filesystem path.
    ///
    /// - Parameter path: The socket path, UTF-8 encoded.
    /// - Throws: ``Error/pathTooLong(length:capacity:)`` when the encoded
    ///   path plus terminator exceeds `sun_path`'s capacity — never a
    ///   silent truncation.
    public init(path: Swift.String) throws(Error) {
        let bytes = Array(path.utf8)
        guard bytes.count + 1 <= Self.pathCapacity else {
            throw .pathTooLong(length: bytes.count, capacity: Self.pathCapacity)
        }
        self.init()
        withUnsafeMutableBytes(of: &cValue.sun_path) { dst in
            for (index, byte) in bytes.enumerated() {
                unsafe (dst[index] = byte)
            }
            unsafe (dst[bytes.count] = 0)
        }
        #if canImport(Darwin)
            cValue.sun_len = UInt8(Self.pathOffset + bytes.count + 1)
        #endif
    }

    /// The socket path, decoded as UTF-8.
    public var path: Swift.String {
        withUnsafeBytes(of: cValue.sun_path) { bytes in
            var length = 0
            while length < bytes.count && (unsafe bytes[length]) != 0 {
                length += 1
            }
            return unsafe Swift.String(decoding: bytes[..<length], as: UTF8.self)
        }
    }
}

// MARK: - Accessors

extension ISO_9945.Kernel.Socket.Address.Unix {
    /// The address family (always `.unix`).
    public var family: ISO_9945.Kernel.Socket.Address.Family {
        .unix
    }

    /// The size of the underlying sockaddr_un structure.
    ///
    /// This is the full struct size. Syscalls should pass ``length`` — the
    /// used portion of the address — so a pathname bind means the same
    /// thing on every platform and the Linux abstract namespace is never
    /// entered by accident.
    public static var size: ISO_9945.Kernel.Socket.Address.Length {
        ISO_9945.Kernel.Socket.Address.Length(UInt(MemoryLayout<sockaddr_un>.size))
    }

    /// The address length covering exactly the used portion of `sun_path`
    /// (`offsetof(sockaddr_un, sun_path) + strlen(path) + 1`), as POSIX
    /// expects for a pathname address.
    public var length: ISO_9945.Kernel.Socket.Address.Length {
        let pathLength = withUnsafeBytes(of: cValue.sun_path) { bytes in
            var length = 0
            while length < bytes.count && (unsafe bytes[length]) != 0 {
                length += 1
            }
            return length
        }
        return ISO_9945.Kernel.Socket.Address.Length(UInt(Self.pathOffset + pathLength + 1))
    }
}

// MARK: - Storage Conversion

extension ISO_9945.Kernel.Socket.Address.Unix {
    /// Converts to the generic `Storage` container.
    public var storage: ISO_9945.Kernel.Socket.Address.Storage {
        var result = ISO_9945.Kernel.Socket.Address.Storage()
        withUnsafePointer(to: cValue) { src in
            withUnsafeMutablePointer(to: &result.cValue) { dst in
                unsafe UnsafeMutableRawPointer(dst)
                    .copyMemory(from: src, byteCount: MemoryLayout<sockaddr_un>.size)
            }
        }
        return result
    }
}
