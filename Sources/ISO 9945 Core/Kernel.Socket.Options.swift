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


extension Kernel.Socket {
    /// Socket creation options.
    ///
    /// Options that can be combined with socket type when creating a socket.
    /// These affect the behavior of the created socket descriptor.
    ///
    /// ## Platform Implementation
    ///
    /// Option values are defined in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.Socket.Options`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.Socket.Options`)
    public struct Options: OptionSet, Sendable {
        public let rawValue: Int32

        /// Creates socket options from a raw value.
        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// No special options.
        public static let none = Options([])
    }
}

