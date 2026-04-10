// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-posix open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-posix project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

@_spi(Syscall) import Kernel_Descriptor_Primitives

#if canImport(Darwin)
    internal import Darwin
    internal import CPOSIXProcessShim
#elseif canImport(Glibc)
    internal import Glibc
    internal import CPOSIXProcessShim
#elseif canImport(Musl)
    internal import Musl
    internal import CPOSIXProcessShim
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
