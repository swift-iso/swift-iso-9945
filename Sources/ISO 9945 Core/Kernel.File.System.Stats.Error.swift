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



extension Kernel.File.System.Stats {
    /// Error type for filesystem statistics operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        case path(Path.Resolution.Error)
        case handle(Kernel.Descriptor.Validity.Error)
        case platform(Error_Primitives.Error)
    }
}

extension Kernel.File.System.Stats.Error: CustomStringConvertible {
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
// - POSIX: `swift-iso-9945` (`ISO 9945.Kernel.File.System.Stats.Error+code.swift`)
// - Windows: `swift-windows-standard` (`Windows.Kernel.File.System.Stats.Error+code.swift`)

