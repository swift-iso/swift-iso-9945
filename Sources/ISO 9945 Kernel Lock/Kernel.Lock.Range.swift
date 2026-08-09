// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Kernel.Lock {
    /// The range of bytes to lock within a file.
    ///
    /// File locking operates on byte ranges, allowing fine-grained concurrency
    /// control. Different processes can hold non-overlapping locks on the same
    /// file simultaneously.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Lock entire file (most common)
    /// try ISO_9945.Kernel.Lock.lock(fd, range: .file, kind: .exclusive)
    /// defer { do throws(ISO_9945.Kernel.Lock.Error) { try ISO_9945.Kernel.Lock.unlock(fd, range: .file) } catch {} }
    ///
    /// // Lock specific byte range (database pages, etc.)
    /// let pageRange = Lock.Range.bytes(start: 4096, length: 4096)
    /// try ISO_9945.Kernel.Lock.lock(fd, range: pageRange, kind: .shared)
    ///
    /// // Lock from offset to end of file
    /// let toEnd = Lock.Range.bytes(start: offset, end: .max)
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``Kernel/Lock/Kind``
    /// - ``Kernel/Lock/lock(_:range:kind:)``
    /// - ``Kernel/Lock/unlock(_:range:)``
    public enum Range: Sendable, Equatable, Hashable {
        /// Locks the entire file, including any bytes appended later.
        ///
        /// Emits `l_len == 0` ("lock from start to end of file"), which
        /// covers future growth. `.bytes(start: 0, end: .max)` is a bounded
        /// range that does not. Use `.file` for simple mutual exclusion
        /// when you don't need fine-grained locking.
        case file

        /// Locks a specific byte range.
        ///
        /// - Parameters:
        ///   - start: The starting byte offset (inclusive).
        ///   - end: The ending byte offset (exclusive). Use `.max` to lock to EOF.
        ///
        /// Follows Swift's `Range` semantics (half-open interval). Locks on
        /// non-overlapping ranges don't conflict, enabling concurrent access
        /// to different parts of a file.
        case bytes(start: ISO_9945.Kernel.File.Offset, end: ISO_9945.Kernel.File.Offset)

        /// Creates a lock range suitable for a memory mapping.
        ///
        /// The range is rounded up to the specified allocation granularity
        /// to ensure the lock covers every byte that could be faulted.
        ///
        /// - Parameters:
        ///   - offset: The aligned start offset of the mapping.
        ///   - length: The mapping length.
        ///   - granularity: The system allocation granularity. Use
        ///     `Memory.Allocation.system` from platform packages.
        @inlinable
        public init(
            forMappingAt offset: ISO_9945.Kernel.File.Offset,
            length: ISO_9945.Kernel.File.Size,
            granularity: Memory.Allocation.Granularity
        ) {
            // Saturate rather than trap: a sum beyond Int64.max clamps to
            // the maximum representable offset ("to end of file" in effect).
            let (sum, overflow) = offset.underlying.addingReportingOverflow(length.underlying)
            guard !overflow else {
                self = .bytes(start: offset, end: .max)
                return
            }
            let roundedEnd = granularity.underlying.alignUp(ISO_9945.Kernel.File.Offset(sum))
            self = .bytes(start: offset, end: roundedEnd)
        }
    }
}

extension ISO_9945.Kernel.Lock.Range {
    /// Creates a byte range from start to end offsets.
    ///
    /// - Parameters:
    ///   - start: The starting byte offset (inclusive).
    ///   - length: The number of bytes to lock.
    @inlinable
    public static func bytes(start: ISO_9945.Kernel.File.Offset, length: ISO_9945.Kernel.File.Size) -> Self {
        // Saturate rather than trap: a sum beyond Int64.max clamps to the
        // maximum representable offset ("to end of file" in effect).
        let (sum, overflow) = start.underlying.addingReportingOverflow(length.underlying)
        return .bytes(start: start, end: overflow ? .max : ISO_9945.Kernel.File.Offset(sum))
    }
}
