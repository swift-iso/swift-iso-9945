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
    /// Stop signal accessor (Nest.Name pattern).
    public struct Stop: Sendable {
        let status: ISO_9945.Kernel.Process.Status
        init(_ status: ISO_9945.Kernel.Process.Status) { self.status = status }
    }
}

// MARK: - Stop Accessor

extension ISO_9945.Kernel.Process.Status.Stop {
    /// The stop signal (WSTOPSIG).
    ///
    /// Returns `nil` if process was not stopped.
    public var signal: ISO_9945.Kernel.Signal.Number? {
        guard status.stopped else { return nil }
        return ISO_9945.Kernel.Signal.Number(rawValue: swift_WSTOPSIG(status.rawValue))
    }
}
