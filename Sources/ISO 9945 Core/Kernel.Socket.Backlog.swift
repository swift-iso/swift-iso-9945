// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//


extension ISO_9945.Kernel.Socket {
    /// Listen backlog size.
    ///
    /// Specifies the maximum length of the queue of pending connections
    /// for the `listen` syscall.
    ///
    /// ## Platform Implementation
    ///
    /// Platform-specific maximum values are defined in:
    /// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.Socket.Backlog.max`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.Socket.Backlog.max`)
    public struct Backlog: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        /// Creates a backlog from a raw value.
        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Creates a backlog from an Int32 value.
        @inlinable
        public init(_ value: Int32) {
            self.rawValue = value
        }

        // MARK: - Common Values

        /// Default backlog (128).
        ///
        /// A reasonable default for most applications.
        public static let `default` = Backlog(128)

        /// Small backlog (16).
        ///
        /// Suitable for low-traffic services.
        public static let small = Backlog(16)

        /// Large backlog (4096).
        ///
        /// For high-traffic servers that can handle many pending connections.
        public static let large = Backlog(4096)
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension ISO_9945.Kernel.Socket.Backlog: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: Int32) {
        self.rawValue = value
    }
}

// MARK: - CustomStringConvertible

extension ISO_9945.Kernel.Socket.Backlog: CustomStringConvertible {
    public var description: Swift.String {
        "\(rawValue)"
    }
}

