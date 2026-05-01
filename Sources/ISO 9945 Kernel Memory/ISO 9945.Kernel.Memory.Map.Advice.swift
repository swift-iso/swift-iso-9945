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

#if !os(Windows)

import Memory_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX madvise Constants

extension Memory.Map.Advice {
    /// Normal access pattern (default).
    ///
    /// No special treatment - the system will read-ahead and free pages as normal.
    public static var normal: Self {
        Self(rawValue: MADV_NORMAL)
    }

    /// Sequential access pattern.
    ///
    /// Pages will be accessed sequentially. The system may perform aggressive
    /// read-ahead and free pages behind the current access point.
    public static var sequential: Self {
        Self(rawValue: MADV_SEQUENTIAL)
    }

    /// Random access pattern.
    ///
    /// Pages will be accessed randomly. The system will minimize read-ahead
    /// as it provides little benefit.
    public static var random: Self {
        Self(rawValue: MADV_RANDOM)
    }

    /// Pages will be needed soon.
    ///
    /// Advises the kernel to read the pages into memory. Useful for prefetching
    /// data that will be accessed shortly.
    public static var willNeed: Self {
        Self(rawValue: MADV_WILLNEED)
    }

    /// Pages won't be needed soon.
    ///
    /// Advises the kernel that the pages can be freed. For anonymous memory,
    /// the pages may be zeroed when next accessed. For file-backed memory,
    /// pages may be discarded.
    public static var dontNeed: Self {
        Self(rawValue: MADV_DONTNEED)
    }
}

import Memory_Primitives

#if canImport(Darwin)
// MARK: - Darwin-specific Advice

extension Memory.Map.Advice {
    /// Free pages immediately (Darwin).
    ///
    /// Similar to `dontNeed` but guarantees the pages are freed immediately.
    public static var free: Self {
        Self(rawValue: MADV_FREE)
    }

    /// Pages contain no useful data (Darwin).
    ///
    /// Indicates pages will be overwritten entirely before being read.
    public static var zeroWiredPages: Self {
        Self(rawValue: MADV_ZERO_WIRED_PAGES)
    }
}
#endif

#if canImport(Glibc) || canImport(Musl)
// MARK: - Linux-specific Advice

extension Memory.Map.Advice {
    /// Remove pages from memory (Linux).
    ///
    /// For shared memory or file mappings, removes the pages from memory
    /// and discards any modifications.
    public static var remove: Self {
        Self(rawValue: MADV_REMOVE)
    }

    /// Don't include in core dump (Linux).
    ///
    /// Excludes the pages from core dumps, useful for sensitive data.
    public static var dontDump: Self {
        Self(rawValue: MADV_DONTDUMP)
    }

    /// Include in core dump (Linux).
    ///
    /// Re-enables core dump for pages previously marked with `dontDump`.
    public static var doDump: Self {
        Self(rawValue: MADV_DODUMP)
    }

    /// Hint for huge pages (Linux).
    ///
    /// Advises the kernel to back the region with huge pages if possible.
    public static var hugePage: Self {
        Self(rawValue: MADV_HUGEPAGE)
    }

    /// Disable huge pages (Linux).
    ///
    /// Advises the kernel not to use huge pages for this region.
    public static var noHugePage: Self {
        Self(rawValue: MADV_NOHUGEPAGE)
    }
}
#endif

#endif
