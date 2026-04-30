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



extension Kernel.IO.Write {
    /// Errors that can occur during write operations.
    public enum Error: Swift.Error, Sendable {
        case handle(Kernel.Descriptor.Validity.Error)
        case blocking(Kernel.IO.Blocking.Error)
        case platform(Error_Primitives.Error)
    }
}

// MARK: - Equatable

extension Kernel.IO.Write.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.handle(let l), .handle(let r)): return l == r
        case (.blocking(let l), .blocking(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

// MARK: - CustomStringConvertible

extension Kernel.IO.Write.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .handle(let e): return "handle: \(e)"
        case .blocking(let e): return "blocking: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}

// MARK: - Platform Bindings
//
// Per [PLAT-ARCH-008c], the platform-specific `var code` accessor and
// `init(code:)` mapping live in L2:
// - POSIX: `swift-iso-9945` (`ISO 9945.Kernel.IO.Write.Error+code.swift`)
// - Windows: `swift-windows-standard` (`Windows.Kernel.IO.Write.Error+code.swift`)

