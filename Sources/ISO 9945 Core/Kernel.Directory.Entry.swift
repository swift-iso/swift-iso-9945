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
        public init(rawName: [UInt8], inode: ISO_9945.Kernel.Inode? = nil, type: ISO_9945.Kernel.File.Stats.Kind? = nil) {
            self.rawName = rawName
            self.inode = inode
            self.type = type
        }
        #endif

        /// The name as a String, or nil if not valid UTF-8 (POSIX) or UTF-16 (Windows).
        ///
        /// `rawName` is null-terminated. This property decodes the bytes
        /// excluding the trailing null terminator.
        public var name: Swift.String? {
            #if os(Windows)
            // Validate UTF-16: reject lone surrogates
            let codeUnits = rawName.dropLast()  // exclude NUL
            var utf16 = UTF16()
            var iterator = codeUnits.makeIterator()
            while true {
                switch utf16.decode(&iterator) {
                case .scalarValue(_): continue
                case .emptyInput:
                    return Swift.String(decoding: codeUnits, as: UTF16.self)
                case .error:
                    return nil
                }
            }
            #else
            // Validate UTF-8
            let bytes = rawName.dropLast()  // exclude NUL
            var utf8 = UTF8()
            var iterator = bytes.makeIterator()
            var scalars: [Unicode.Scalar] = []
            scalars.reserveCapacity(bytes.count)
            while true {
                switch utf8.decode(&iterator) {
                case .scalarValue(let s): scalars.append(s)
                case .emptyInput:
                    return Swift.String(Swift.String.UnicodeScalarView(scalars))
                case .error:
                    return nil
                }
            }
            #endif
        }

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
        /// heap buffer directly — the view cannot outlive `self`.
        @inlinable
        public var nameView: Path.Borrowed {
            @_lifetime(borrow self)
            borrowing get {
                let ptr = unsafe rawName.withUnsafeBufferPointer { $0.baseAddress! }
                let view = unsafe Path.Borrowed(ptr, count: rawName.count - 1)
                return unsafe _overrideLifetime(view, borrowing: self)
            }
        }
    }
}

