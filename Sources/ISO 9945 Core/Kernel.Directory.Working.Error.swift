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


extension ISO_9945.Kernel.Directory.Working {
    /// Errors from working directory operations.
    public enum Error: Swift.Error, Sendable {
        /// Path resolution error (directory not found, etc.).
        case path(Path.Resolution.Error)

        /// Platform-specific error.
        case platform(Error_Primitives.Error)
    }
}

// MARK: - Equatable

extension ISO_9945.Kernel.Directory.Working.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.path(let l), .path(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

// MARK: - CustomStringConvertible

extension ISO_9945.Kernel.Directory.Working.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .path(let e): return "working directory: \(e)"
        case .platform(let e): return "working directory: \(e)"
        }
    }
}

// MARK: - Platform Bindings
//
// Per [PLAT-ARCH-008c], the platform-specific `init(code:)` mapping lives in L2:
// - POSIX: `swift-iso-9945` (`ISO 9945.Kernel.Directory.Working.Error+code.swift`)
// - Windows: `swift-windows-standard` (`Windows.Kernel.Directory.Working.Error+code.swift`)

