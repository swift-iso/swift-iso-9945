// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

@_spi(Internal) public import Tagged_Primitives

extension ISO_9945.Kernel.Event {
    /// Event source identifier.
    ///
    /// Identifies the source of an event, which may be a file descriptor,
    /// timer ID, signal number, or other platform-specific identifier.
    ///
    /// ## Platform Notes
    ///
    /// - **epoll**: File descriptor (`int`)
    /// - **kqueue**: Identifier type depends on filter (fd, pid, signal, etc.)
    /// - **io_uring**: File descriptor for most operations
    public typealias ID = Tagged<ISO_9945.Kernel.Event, UInt>
}

// MARK: - Event.ID Conversions

extension Tagged where Tag == ISO_9945.Kernel.Event, Underlying == UInt {
    /// Creates an identifier from an Int32 (for signals, etc.).
    @inlinable
    public init(_ value: Int32) {
        self.init(_unchecked: UInt(bitPattern: Int(value)))
    }
}
