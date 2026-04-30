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



extension ISO_9945.Kernel.File.Open {
    public enum Error: Swift.Error, Sendable {
        case path(Path.Resolution.Error)
        case handle(ISO_9945.Kernel.Descriptor.Validity.Error)
        case platform(Error_Primitives.Error)
    }
}

extension ISO_9945.Kernel.File.Open.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.path(let l), .path(let r)): return l == r
        case (.handle(let l), .handle(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

extension ISO_9945.Kernel.File.Open.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .path(let e): return "path: \(e)"
        case .handle(let e): return "handle: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}

// MARK: - Platform Bindings
//
// Per [PLAT-ARCH-008c], the platform-specific `init(code:)` mapping lives in L2:
// - POSIX: `swift-iso-9945` (`ISO 9945.Kernel.File.Open.Error+code.swift`)
// - Windows: `swift-windows-standard` (`Windows.Kernel.File.Open.Error+code.swift`)

