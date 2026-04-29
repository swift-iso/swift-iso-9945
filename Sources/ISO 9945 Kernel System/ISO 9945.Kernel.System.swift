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

@_spi(Syscall) import Kernel_Descriptor_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX System Information

extension System {
    /// Platform path length limit.
    ///
    /// Falls back to 4096 if the platform constant is undefined.
    /// Note: This is a conservative limit, not a universal truth.
    public static var pathMax: System.Path.Length {
        #if canImport(Darwin)
            return System.Path.Length(__unchecked: (), Cardinal(UInt(PATH_MAX)))  // 1024
        #else
            return System.Path.Length(__unchecked: (), Cardinal(UInt(PATH_MAX)))  // Usually 4096
        #endif
    }

    /// Memory page size in bytes.
    ///
    /// This is the fundamental unit of memory management.
    /// Typically 4096 bytes on most systems, 16384 on Apple Silicon.
    public static var pageSize: System.Page.Size {
        System.Page.Size(__unchecked: (), Cardinal(UInt(sysconf(Int32(_SC_PAGESIZE)))))
    }

    /// Number of active/online processors.
    ///
    /// Uses `sysconf(_SC_NPROCESSORS_ONLN)` to get the count of
    /// processors currently online (not just configured).
    ///
    /// Returns 1 as a fallback if the syscall fails.
    public static var processorCount: System.Processor.Count {
        let count = sysconf(Int32(_SC_NPROCESSORS_ONLN))
        return System.Processor.Count(__unchecked: (), Cardinal(UInt(count > 0 ? count : 1)))
    }

    /// Sleeps for the specified duration.
    ///
    /// - Parameter duration: The duration to sleep.

    public static func sleep(_ duration: Duration) {
        let (seconds, attoseconds) = duration.components
        var ts = timespec()
        ts.tv_sec = Int(seconds)
        ts.tv_nsec = Int(attoseconds / 1_000_000_000)
        unsafe nanosleep(&ts, nil)
    }
}
