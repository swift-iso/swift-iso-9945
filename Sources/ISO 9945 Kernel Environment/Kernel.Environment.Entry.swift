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

public import String_Primitives

extension ISO_9945.Kernel.Environment {
    /// A single environment variable entry with borrowed name and value.
    ///
    /// This type is `~Escapable`, meaning it cannot outlive the iterator
    /// that produced it. The pointers borrow directly from the process
    /// environment block — read-only: iteration never mutates `environ`,
    /// so concurrent `getenv` calls (which POSIX permits) stay safe.
    @safe public struct Entry: ~Copyable, ~Escapable {
        /// Internal pointer to the `NAME=VALUE` string in `environ`.
        @usableFromInline
        internal let _base: UnsafePointer<String.Char>

        /// Offset of the `=` separator within the entry.
        @usableFromInline
        internal let _separator: Int

        /// Total length of the entry in code units, excluding the null
        /// terminator.
        @usableFromInline
        internal let _length: Int

        /// Creates an entry from the `NAME=VALUE` base pointer and the
        /// separator position.
        ///
        /// - Parameters:
        ///   - base: Pointer to the null-terminated `NAME=VALUE` string.
        ///   - separator: Offset of the `=` within the string.
        ///   - length: Total string length, excluding the terminator.
        @_spi(Syscall)
        @inlinable
        @_lifetime(borrow base)
        @unsafe
        public init(
            base: UnsafePointer<String.Char>,
            separator: Int,
            length: Int
        ) {
            unsafe (self._base = base)
            self._separator = separator
            self._length = length
        }
    }
}

// MARK: - Access

extension ISO_9945.Kernel.Environment.Entry {
    /// The name as a Span.
    @inlinable
    public var name: Swift.Span<String.Char> {
        @_lifetime(copy self) borrowing get {
            let s = unsafe Span(_unsafeStart: _base, count: _separator)
            return unsafe _overrideLifetime(s, copying: self)
        }
    }

    /// The value as a Span.
    @inlinable
    public var value: Swift.Span<String.Char> {
        @_lifetime(copy self) borrowing get {
            let s = unsafe Span(_unsafeStart: _base + _separator + 1, count: _length - _separator - 1)
            return unsafe _overrideLifetime(s, copying: self)
        }
    }
}

// MARK: - Convenience

extension ISO_9945.Kernel.Environment.Entry {
    /// The length of the name in code units, excluding the null terminator.
    @inlinable
    public var nameLength: Int {
        _separator
    }

    /// The length of the value in code units, excluding the null terminator.
    @inlinable
    public var valueLength: Int {
        _length - _separator - 1
    }
}
