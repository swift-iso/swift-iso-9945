// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Kernel.Socket {
    /// Errors that can occur during socket operations.
    public enum Error: Swift.Error, Sendable {
        /// A platform-specific error.
        case platform(Error_Primitives.Error)

        /// `connect` was interrupted by a signal; the connection attempt
        /// continues asynchronously (POSIX).
        ///
        /// Not a failed connection: retrying `connect` yields `EALREADY`,
        /// and abandoning it discards a connection still being
        /// established. Complete the attempt by waiting for the socket to
        /// become writable and then reading `SO_ERROR`.
        case interrupted
    }
}

// MARK: - Equatable

extension ISO_9945.Kernel.Socket.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.platform(let l), .platform(let r)): return l == r
        case (.interrupted, .interrupted): return true
        default: return false
        }
    }
}

// MARK: - CustomStringConvertible

extension ISO_9945.Kernel.Socket.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .platform(let e): return "\(e)"
        case .interrupted: return "connect interrupted; attempt continues asynchronously"
        }
    }
}

// MARK: - Platform Bindings
//
// Per [PLAT-ARCH-008c], the platform-specific `var code` accessor and
// `init(code:)` mapping live in L2:
// - POSIX: `swift-iso-9945` (`ISO 9945.Kernel.Socket.Error+code.swift`)
// - Windows: `swift-windows-standard` (`Windows.Kernel.Socket.Error+code.swift`)
