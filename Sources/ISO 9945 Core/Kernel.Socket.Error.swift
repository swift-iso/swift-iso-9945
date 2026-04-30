// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
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
    }
}

// MARK: - Equatable

extension ISO_9945.Kernel.Socket.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.platform(let l), .platform(let r)): return l == r
        }
    }
}

// MARK: - CustomStringConvertible

extension ISO_9945.Kernel.Socket.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .platform(let e): return "\(e)"
        }
    }
}

// MARK: - Platform Bindings
//
// Per [PLAT-ARCH-008c], the platform-specific `var code` accessor and
// `init(code:)` mapping live in L2:
// - POSIX: `swift-iso-9945` (`ISO 9945.Kernel.Socket.Error+code.swift`)
// - Windows: `swift-windows-standard` (`Windows.Kernel.Socket.Error+code.swift`)
