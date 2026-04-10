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
    /// Core dump accessor (Nest.Name pattern).
    public struct Core: Sendable {
        let status: ISO_9945.Kernel.Process.Status
        init(_ status: ISO_9945.Kernel.Process.Status) { self.status = status }
    }
}

// MARK: - Core Accessor

extension ISO_9945.Kernel.Process.Status.Core {
    /// Whether core dump was produced (WCOREDUMP).
    ///
    /// Returns `false` on platforms where WCOREDUMP is unavailable.
    public var dumped: Bool {
        #if canImport(Darwin)
            guard status.signaled else { return false }
            return swift_WCOREDUMP(status.rawValue) != 0
        #elseif canImport(Glibc)
            guard status.signaled else { return false }
            #if _GNU_SOURCE
                return swift_WCOREDUMP(status.rawValue) != 0
            #else
                return false
            #endif
        #else
            return false
        #endif
    }
}
