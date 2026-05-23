// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//


extension ISO_9945.Kernel.Directory {
    /// A directory entry returned by iteration.
    ///
    /// Preserves raw bytes (POSIX) or UTF-16 code units (Windows) to support
    /// filesystems with names that cannot be decoded to valid Unicode.
    public struct Entry: Sendable {
        #if os(Windows)
        /// Raw UTF-16 code units of the name.
        public let rawName: [UInt16]
        #else
        /// Raw bytes of the name.
        ///
        /// Available via `@_spi(Syscall)` for syscall-implementation
        /// layers (e.g., `ISO_9945.Kernel.Directory.Stream.next()` and
        /// directory iteration internals). Application-layer consumers
        /// should use `nameView` for byte access without depending on
        /// the array storage shape.
        @_spi(Syscall)
        public let rawName: [UInt8]
        #endif

        /// The inode number (POSIX only, nil on Windows).
        public let inode: ISO_9945.Kernel.Inode?

        /// The type of entry, if known.
        public let type: ISO_9945.Kernel.File.Stats.Kind?

        #if os(Windows)
        public init(rawName: [UInt16], inode: ISO_9945.Kernel.Inode? = nil, type: ISO_9945.Kernel.File.Stats.Kind? = nil) {
            self.rawName = rawName
            self.inode = inode
            self.type = type
        }
        #else
        @_spi(Syscall)
        public init(rawName: [UInt8], inode: ISO_9945.Kernel.Inode? = nil, type: ISO_9945.Kernel.File.Stats.Kind? = nil) {
            self.rawName = rawName
            self.inode = inode
            self.type = type
        }
        #endif

        /// Returns true if this entry is "." or "..".
        ///
        /// `rawName` is null-terminated, so "." is `[0x2E, 0x00]`
        /// and ".." is `[0x2E, 0x2E, 0x00]`.
        public var isDotOrDotDot: Bool {
            #if os(Windows)
            rawName == [0x002E, 0x0000] || rawName == [0x002E, 0x002E, 0x0000]
            #else
            rawName == [0x2E, 0x00] || rawName == [0x2E, 0x2E, 0x00]
            #endif
        }

        /// The entry name as a `Path.Borrowed`. Zero allocation.
        ///
        /// `rawName` is null-terminated. This property borrows the array's
        /// heap buffer directly — the view cannot outlive `self`. Consumers
        /// reach byte content via `name.span` (Span<Path.Char>) or
        /// `name.pointer` (UnsafePointer<Path.Char>). Decoding to a Swift
        /// String is consumer responsibility (e.g.,
        /// `Swift.String(decoding: entry.name.span, as: UTF8.self)`).
        ///
        /// Not `@inlinable`: its body references the `@_spi(Syscall)` `rawName`
        /// storage; Swift forbids `@inlinable` bodies from naming SPI
        /// declarations. The cross-module function-call cost is negligible
        /// relative to the syscall (readdir) driving directory iteration.
        public var name: Path.Borrowed {
            @_lifetime(borrow self)
            borrowing get {
                let ptr = unsafe rawName.withUnsafeBufferPointer { $0.baseAddress! }
                let view = unsafe Path.Borrowed(ptr, count: rawName.count - 1)
                return unsafe _overrideLifetime(view, borrowing: self)
            }
        }
    }
}

