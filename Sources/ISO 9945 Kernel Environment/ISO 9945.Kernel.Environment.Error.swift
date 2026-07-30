// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX environment error mapping

extension ISO_9945.Kernel.Environment.Error {
    internal init(code: Error_Primitives.Error.Code) {
        if let e = ISO_9945.Kernel.Permission.Error(code: code) {
            self = .permission(e)
            return
        }
        // EINVAL covers a name that is null, empty, or contains '=' —
        // indistinguishable from errno alone. The distinct .invalid
        // conditions are produced by pre-call validation in
        // Environment.set/unset; an EINVAL that still reaches here passes
        // through as a platform error rather than a wrong diagnosis.
        self = .platform(Error_Primitives.Error(code: code))
    }

    internal static func current() -> Self {
        Self(code: .captureErrno())
    }
}
