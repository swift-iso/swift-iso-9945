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

extension ISO_9945.Kernel.Socket.Message.Header {
    /// Ancillary data (control message) component of a message header.
    public struct Control {
        /// Borrowed buffer covering the ancillary data region.
        ///
        /// The buffer's `baseAddress` maps to `msghdr.msg_control` and its
        /// `count` to `msghdr.msg_controllen`. Storage is borrowed — the
        /// descriptor does not own the pointed-to memory.
        public var pointer: UnsafeMutableRawBufferPointer?

        /// Creates an ancillary data descriptor.
        ///
        /// - Parameter pointer: Borrowed buffer covering the ancillary data region.
        @unsafe
        public init(pointer: UnsafeMutableRawBufferPointer? = nil) {
            unsafe self.pointer = pointer
        }
    }
}
