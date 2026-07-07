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

extension ISO_9945.Kernel.File.Stats {
    /// Errors that can occur during stat operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The file descriptor or handle is invalid.
        case handle(ISO_9945.Kernel.Descriptor.Validity.Error)

        /// A platform-specific error that doesn't map to a semantic case.
        case platform(Error_Primitives.Error)
    }
}

// MARK: - Stats.Error CustomStringConvertible

extension ISO_9945.Kernel.File.Stats.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .handle(let e): return "handle: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}
