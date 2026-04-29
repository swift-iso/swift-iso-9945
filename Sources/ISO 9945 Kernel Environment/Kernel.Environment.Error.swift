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


extension Kernel.Environment {
    /// Errors that can occur during environment operations.
    public enum Error: Swift.Error, Sendable {
        case permission(Kernel.Permission.Error)
        case invalid(Invalid)
        case platform(Error_Primitives.Error)
    }
}

// MARK: - Invalid

extension Kernel.Environment.Error {
    /// Invalid argument errors specific to environment operations.
    public enum Invalid: Swift.Error, Sendable, Equatable, Hashable {
        /// The variable name is empty.
        case emptyName
        /// The variable name contains an equals sign.
        case nameContainsEquals
    }
}

// MARK: - Equatable

extension Kernel.Environment.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.permission(let l), .permission(let r)): return l == r
        case (.invalid(let l), .invalid(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

// MARK: - CustomStringConvertible

extension Kernel.Environment.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .permission(let e): return "permission: \(e)"
        case .invalid(let e): return "invalid: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}

extension Kernel.Environment.Error.Invalid: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .emptyName: return "empty variable name"
        case .nameContainsEquals: return "variable name contains '='"
        }
    }
}

// MARK: - Platform Implementation
//
// Error code mapping and current() helpers are in platform-specific packages:
// - POSIX: `swift-iso-9945` (`Kernel.Environment.Error.current()`)
// - Windows: `swift-windows-primitives` (`Kernel.Environment.Error.current()`)

