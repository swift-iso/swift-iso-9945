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

extension ISO_9945.Kernel.User.Database {
    /// Errors from user database lookups (`getpwnam_r`/`getpwuid_r`).
    ///
    /// Distinct from absence: `find(name:)`/`find(uid:)` return `nil` when
    /// the name or ID simply has no entry. This error is thrown only when
    /// the lookup itself failed (`EINTR`, `EMFILE`, `EIO`, an oversized
    /// entry that exceeded the growth cap, etc.) — a caller can no longer
    /// conflate "not found" with "the lookup did not run."
    public enum Error: Swift.Error, Sendable, Equatable {
        case lookup(Error_Primitives.Error.Code)
    }
}

extension ISO_9945.Kernel.User.Database.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .lookup(let code):
            return "user database lookup failed: \(code)"
        }
    }
}
