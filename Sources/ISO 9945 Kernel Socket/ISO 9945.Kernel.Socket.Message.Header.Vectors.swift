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

public import ISO_9945_Kernel_File

extension ISO_9945.Kernel.Socket.Message.Header {
    /// I/O vector component of a message header.
    ///
    /// Wraps a borrowed pointer to an array of ``Kernel/IO/Vector/Segment``
    /// (layout-compatible with POSIX `struct iovec`) and the element count.
    /// Pointer-equivalent to `msghdr.msg_iov` + `msghdr.msg_iovlen`.
    public struct Vectors {
        /// Pointer to the I/O vector array.
        public var pointer: UnsafeMutablePointer<ISO_9945.Kernel.IO.Vector.Segment>?

        /// Number of I/O vectors.
        public var count: Int

        /// Creates an I/O vector descriptor.
        ///
        /// - Parameters:
        ///   - pointer: Pointer to the I/O vector array.
        ///   - count: Number of I/O vectors.
        @unsafe
        public init(pointer: UnsafeMutablePointer<ISO_9945.Kernel.IO.Vector.Segment>? = nil, count: Int = 0) {
            unsafe self.pointer = pointer
            self.count = count
        }
    }
}
