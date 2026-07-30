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
            /// - Precondition: `rawName` is non-empty and null-terminated.
            public init(rawName: [UInt16], inode: ISO_9945.Kernel.Inode? = nil, type: ISO_9945.Kernel.File.Stats.Kind? = nil) {
                precondition(rawName.last == 0, "Directory.Entry rawName must be a non-empty, null-terminated sequence")
                self.rawName = rawName
                self.inode = inode
                self.type = type
            }
        #else
            /// - Precondition: `rawName` is non-empty and null-terminated.
            @_spi(Syscall)
            public init(rawName: [UInt8], inode: ISO_9945.Kernel.Inode? = nil, type: ISO_9945.Kernel.File.Stats.Kind? = nil) {
                precondition(rawName.last == 0, "Directory.Entry rawName must be a non-empty, null-terminated sequence")
                self.rawName = rawName
                self.inode = inode
                self.type = type
            }
        #endif

    }
}

extension ISO_9945.Kernel.Directory.Entry {
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

    /// Calls `body` with the entry name as a `Path.Borrowed`. Zero allocation.
    ///
    /// `rawName` is non-empty and null-terminated (enforced by the
    /// initializer). The borrowed view is valid only for the duration of
    /// `body`; the underlying buffer pointer never escapes the scope of
    /// `withUnsafeBufferPointer`, honouring its lifetime contract.
    /// Decoding to a Swift String is consumer responsibility (e.g.,
    /// `Swift.String(decoding: view.span, as: UTF8.self)`).
    ///
    /// Not `@inlinable`: its body references the `@_spi(Syscall)` `rawName`
    /// storage; Swift forbids `@inlinable` bodies from naming SPI
    /// declarations. The cross-module function-call cost is negligible
    /// relative to the syscall (readdir) driving directory iteration.
    public func withName<R, E: Swift.Error>(
        _ body: (borrowing Path.Borrowed) throws(E) -> R
    ) throws(E) -> R {
        let result: Swift.Result<R, E> = unsafe rawName.withUnsafeBufferPointer { buffer in
            let view = unsafe Path.Borrowed(buffer.baseAddress!, count: buffer.count - 1)
            do throws(E) {
                return .success(try body(view))
            } catch {
                return .failure(error)
            }
        }
        return try result.get()
    }
}
