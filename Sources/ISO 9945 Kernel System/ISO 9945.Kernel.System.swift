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

// MARK: - POSIX System Information

extension System {
    /// Platform path length limit.
    ///
    /// The platform's `PATH_MAX` (1024 on Darwin, usually 4096 on Linux).
    /// A platform that does not define `PATH_MAX` fails to compile here;
    /// there is no runtime fallback.
    /// Note: This is a conservative limit, not a universal truth.
    public static var pathMax: System.Path.Length {
        System.Path.Length(_unchecked: Cardinal(UInt(PATH_MAX)))
    }

    /// Memory page size in bytes.
    ///
    /// This is the fundamental unit of memory management.
    /// Typically 4096 bytes on most systems, 16384 on Apple Silicon.
    public static var pageSize: System.Page.Size {
        System.Page.Size(_unchecked: Cardinal(UInt(sysconf(Int32(_SC_PAGESIZE)))))
    }

    /// Number of active/online processors.
    ///
    /// Uses `sysconf(_SC_NPROCESSORS_ONLN)` to get the count of
    /// processors currently online (not just configured).
    ///
    /// Returns 1 as a fallback if the syscall fails.
    public static var processorCount: System.Processor.Count {
        let count = sysconf(Int32(_SC_NPROCESSORS_ONLN))
        return System.Processor.Count(_unchecked: Cardinal(UInt(count > 0 ? count : 1)))
    }

    /// Sleeps for the specified duration.
    ///
    /// Restarts on `EINTR` using the remaining time `nanosleep` reports,
    /// so the full duration elapses even when signals are delivered. A
    /// non-positive duration returns immediately rather than handing
    /// `nanosleep` an invalid `timespec`.
    ///
    /// - Parameter duration: The duration to sleep.
    public static func sleep(_ duration: Duration) {
        guard duration > .zero else { return }
        let (seconds, attoseconds) = duration.components
        var ts = timespec()
        ts.tv_sec = Int(seconds)
        ts.tv_nsec = Int(attoseconds / 1_000_000_000)
        var rem = timespec()
        while unsafe nanosleep(&ts, &rem) == -1, errno == EINTR {
            ts = rem
        }
    }
}
