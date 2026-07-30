// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Kernel.Group.Database {
    /// Errors from group database lookups (`getgrnam_r`/`getgrgid_r`).
    ///
    /// Distinct from absence: `find(name:)`/`find(gid:)` return `nil` when
    /// the name or ID simply has no entry. This error is thrown only when
    /// the lookup itself failed (`EINTR`, `EMFILE`, `EIO`, an oversized
    /// entry that exceeded the growth cap, etc.).
    public enum Error: Swift.Error, Sendable, Equatable {
        case lookup(Error_Primitives.Error.Code)
    }
}

extension ISO_9945.Kernel.Group.Database.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .lookup(let code):
            return "group database lookup failed: \(code)"
        }
    }
}
