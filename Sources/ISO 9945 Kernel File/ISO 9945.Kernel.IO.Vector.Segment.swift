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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.IO.Vector {
    /// A single buffer descriptor for scatter/gather I/O.
    ///
    /// Binary-compatible with POSIX `struct iovec` from `<sys/uio.h>`.
    /// An `UnsafePointer<Segment>` can be passed to any interface expecting
    /// `const struct iovec *`.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// var segments = [
    ///     Kernel.IO.Vector.Segment(base: buf1, length: 4096),
    ///     Kernel.IO.Vector.Segment(base: buf2, length: 1024),
    /// ]
    /// segments.withUnsafeBufferPointer { vecs in
    ///     try Kernel.IO.Vector.read(descriptor, buffers: vecs)
    /// }
    /// ```
    public struct Segment: @unchecked Sendable {
        /// Base address of the buffer.
        public var base: UnsafeMutableRawPointer?

        /// Length of the buffer in bytes.
        public var length: Int

        /// Creates a segment from a base pointer and length.
        @unsafe
        public init(base: UnsafeMutableRawPointer?, length: Int) {
            self.base = unsafe base
            self.length = length
        }

        /// Creates a segment from a mutable raw buffer pointer.
        @unsafe
        public init(_ buffer: UnsafeMutableRawBufferPointer) {
            self.base = unsafe buffer.baseAddress
            self.length = buffer.count
        }

        /// Creates a read-only segment from a raw buffer pointer.
        ///
        /// The base pointer is cast to mutable for kernel ABI compatibility;
        /// the kernel does not write to segments used in write operations.
        @unsafe
        public init(_ buffer: UnsafeRawBufferPointer) {
            self.base = unsafe UnsafeMutableRawPointer(mutating: buffer.baseAddress)
            self.length = buffer.count
        }
    }
}

// MARK: - C Bridge

extension ISO_9945.Kernel.IO.Vector.Segment {
    /// The underlying C iovec representation.
    ///
    /// Binary-compatible — same layout as `struct iovec`.
    var cValue: iovec {
        iovec(iov_base: unsafe base, iov_len: length)
    }

    /// Creates a Segment from a C iovec.
    @unsafe
    init(_ cValue: iovec) {
        self.base = unsafe cValue.iov_base
        self.length = cValue.iov_len
    }
}
