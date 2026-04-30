// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Kernel {
    /// TTY (terminal) related types and operations.
    ///
    /// Provides raw syscall wrappers for terminal queries:
    /// - ``isTTY(fd:)`` — Check if descriptor refers to a terminal
    /// - ``Size`` — Terminal dimensions query (`ioctl(TIOCGWINSZ)`)
    public enum TTY: Sendable {}
}

extension ISO_9945.Kernel.TTY {
    /// Terminal window size in rows and columns.
    ///
    /// Obtained via `ioctl(fd, TIOCGWINSZ, &ws)` on POSIX systems.
    public struct Size: Sendable, Hashable {
        /// Number of rows (lines).
        public let rows: UInt16

        /// Number of columns (characters per line).
        public let columns: UInt16

        /// Creates a size value.
        @inlinable
        public init(rows: UInt16, columns: UInt16) {
            self.rows = rows
            self.columns = columns
        }
    }
}
