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
    /// Terminal I/O settings (termios) operations.
    ///
    /// Provides raw syscall wrappers for terminal attribute manipulation:
    /// - ``Attributes`` — Terminal configuration state
    /// - Get/set terminal attributes via `tcgetattr` / `tcsetattr`
    public enum Termios: Sendable {}
}

extension ISO_9945.Kernel.Termios {
    /// Terminal attributes wrapper.
    ///
    /// Opaque storage for the platform termios structure. Use
    /// ``get(fd:)`` to capture and ``set(_:fd:action:)`` to apply.
    ///
    /// ## Raw Mode
    ///
    /// ```swift
    /// let original = try ISO_9945.Kernel.Termios.Attributes.get(fd: 0)
    /// let raw = original.withRaw()
    /// try ISO_9945.Kernel.Termios.Attributes.set(raw, fd: 0)
    /// defer { try? ISO_9945.Kernel.Termios.Attributes.set(original, fd: 0) }
    /// ```
    public struct Attributes: Sendable {
        /// Opaque storage for the underlying termios structure.
        @usableFromInline
        internal var _storage: Storage

        /// Platform-specific opaque storage.
        ///
        /// Sized to hold any conformant POSIX termios layout
        /// (macOS: ~72 bytes, Linux: ~60 bytes).
        public struct Storage: Sendable {
            public var bytes: (
                UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
                UInt64, UInt64, UInt64, UInt64
            ) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

            public init() {}
        }

        @usableFromInline
        internal init() {
            self._storage = Storage()
        }
    }
}

// MARK: - SPI for Syscall Layers

extension ISO_9945.Kernel.Termios.Attributes {
    /// Creates attributes from raw bytes.
    @_spi(Syscall)
    @inlinable
    public init(_storage: Storage) {
        self._storage = _storage
    }

    /// Access to the raw storage.
    @_spi(Syscall)
    @inlinable
    public var _rawStorage: Storage {
        get { _storage }
        set { _storage = newValue }
    }

    /// Mutating access to storage bytes for platform bridging.
    @_spi(Syscall)
    @inlinable
    public mutating func withUnsafeMutableStorageBytes<T, E: Swift.Error>(
        _ body: (UnsafeMutableRawBufferPointer) throws(E) -> T
    ) throws(E) -> T {
        try unsafe withUnsafeMutableBytes(of: &_storage.bytes) { (buffer: UnsafeMutableRawBufferPointer) throws(E) -> T in
            try unsafe body(buffer)
        }
    }

    /// Read-only access to storage bytes.
    @_spi(Syscall)
    @inlinable
    public func withUnsafeStorageBytes<T, E: Swift.Error>(
        _ body: (UnsafeRawBufferPointer) throws(E) -> T
    ) throws(E) -> T {
        try unsafe withUnsafeBytes(of: _storage.bytes) { (buffer: UnsafeRawBufferPointer) throws(E) -> T in
            try unsafe body(buffer)
        }
    }
}

// MARK: - Action

extension ISO_9945.Kernel.Termios.Attributes {
    /// When to apply terminal attribute changes.
    public struct Action: Sendable, Hashable {
        @usableFromInline
        internal let _rawValue: Int32

        @_spi(Syscall)
        @inlinable
        public init(_rawValue: Int32) {
            self._rawValue = _rawValue
        }

        @_spi(Syscall)
        @inlinable
        public var rawValue: Int32 { _rawValue }
    }
}
