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
    internal import POSIX_Process_Shims
#elseif canImport(Glibc)
    internal import Glibc
    internal import POSIX_Process_Shims
#elseif canImport(Musl)
    internal import Musl
    internal import POSIX_Process_Shims
#endif

extension ISO_9945.Kernel.Process.Status {
    /// Terminating signal accessor (Nest.Name pattern).
    public struct Terminating: Sendable {
        let status: ISO_9945.Kernel.Process.Status
        init(_ status: ISO_9945.Kernel.Process.Status) { self.status = status }
    }
}

// MARK: - Terminating Accessor

extension ISO_9945.Kernel.Process.Status.Terminating {
    /// The terminating signal (WTERMSIG).
    ///
    /// Returns `nil` if process was not terminated by signal.
    public var signal: ISO_9945.Kernel.Signal.Number? {
        guard status.signaled else { return nil }
        return ISO_9945.Kernel.Signal.Number(rawValue: swift_WTERMSIG(status.rawValue))
    }
}
