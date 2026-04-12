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

// MARK: - EINTR Detection

extension Kernel.Error.Code {
    /// Returns `true` if this error code represents EINTR (interrupted by signal).
    ///
    /// EINTR indicates a blocking syscall was interrupted by a signal before
    /// completing. The operation did not fail — it was merely interrupted.
    /// Callers should typically retry the operation.
    ///
    /// This is the single source of truth for EINTR detection across all
    /// error types. Individual error types expose this via `error.code.isInterrupted`.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// while true {
    ///     do {
    ///         return try Kernel.IO.Write.write(descriptor, from: buffer)
    ///     } catch where error.code.isInterrupted {
    ///         continue
    ///     }
    /// }
    /// ```
    @inlinable
    public var isInterrupted: Bool {
        self == .POSIX.EINTR
    }
}
