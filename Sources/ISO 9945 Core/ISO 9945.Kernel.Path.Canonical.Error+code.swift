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

public import Path_Primitives

// MARK: - POSIX Error Code Mapping

extension Path.Canonical.Error {
    /// Creates an error from a POSIX error code.
    ///
    /// Permission-denied errors (EACCES, EPERM) surface as `.platform(...)`
    /// post-Path-X Cycle 8 — the L1 `Kernel.Permission.Error` wrapper case
    /// was dropped to break the L1 cross-package dep on Kernel.Permission.
    /// Consumers that need to distinguish permission errors can pattern-match
    /// on the platform code.
    @usableFromInline
    internal init(code: Error_Primitives.Error.Code) {
        if let e = Path.Resolution.Error(code: code) {
            self = .path(e)
            return
        }
        self = .platform(Error_Primitives.Error(code: code))
    }
}
