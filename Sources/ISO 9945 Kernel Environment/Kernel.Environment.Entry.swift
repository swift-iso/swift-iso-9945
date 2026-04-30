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

public import String_Primitives



extension ISO_9945.Kernel.Environment {
    /// A single environment variable entry with borrowed name and value.
    ///
    /// This type is `~Escapable`, meaning it cannot outlive the iterator
    /// that produced it. The pointers borrow directly from the process
    /// environment block and are accessed through scoped closures.
    @safe public struct Entry: ~Copyable, ~Escapable {
        /// Internal pointer to the null-terminated variable name.
        @usableFromInline
        internal let _name: UnsafePointer<String.Char>

        /// Internal pointer to the null-terminated variable value.
        @usableFromInline
        internal let _value: UnsafePointer<String.Char>

        /// Creates an entry from name and value pointers.
        ///
        /// - Parameters:
        ///   - name: Pointer to null-terminated name.
        ///   - value: Pointer to null-terminated value.
        @_spi(Syscall)
        @inlinable
        @_lifetime(borrow name, borrow value)
        @unsafe
        public init(
            name: UnsafePointer<String.Char>,
            value: UnsafePointer<String.Char>
        ) {
            unsafe (self._name = name)
            unsafe (self._value = value)
        }
    }
}

// MARK: - Access

extension ISO_9945.Kernel.Environment.Entry {
    /// The name as a Span.
    @inlinable
    public var name: Span<String.Char> {
        @_lifetime(copy self) borrowing get {
            let s = unsafe Span(_unsafeStart: _name, count: nameLength)
            return unsafe _overrideLifetime(s, copying: self)
        }
    }

    /// The value as a Span.
    @inlinable
    public var value: Span<String.Char> {
        @_lifetime(copy self) borrowing get {
            let s = unsafe Span(_unsafeStart: _value, count: valueLength)
            return unsafe _overrideLifetime(s, copying: self)
        }
    }
}

// MARK: - Convenience

extension ISO_9945.Kernel.Environment.Entry {
    /// The length of the name in code units, excluding the null terminator.
    @inlinable
    public var nameLength: Int {
        unsafe String.length(of: _name)
    }

    /// The length of the value in code units, excluding the null terminator.
    @inlinable
    public var valueLength: Int {
        unsafe String.length(of: _value)
    }
}

