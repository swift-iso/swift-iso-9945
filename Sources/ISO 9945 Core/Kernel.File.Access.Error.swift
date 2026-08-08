// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Kernel.File.Access {
    /// Errors from a caller-effective file access check.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The path could not be resolved.
        case path(Path.Resolution.Error)

        /// The platform does not provide POSIX effective-identity access checks.
        case unsupported

        /// A platform error not represented by a semantic case.
        case platform(Error_Primitives.Error)
    }
}

extension ISO_9945.Kernel.File.Access.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .path(let error):
            return "path: \(error)"
        case .unsupported:
            return "effective file access checks are unsupported"
        case .platform(let error):
            return "\(error)"
        }
    }
}
