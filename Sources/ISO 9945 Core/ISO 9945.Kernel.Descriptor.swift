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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel {
    /// POSIX file descriptor.
    ///
    /// `~Copyable` move-only wrapper around the POSIX `int` file descriptor.
    /// The `deinit` closes the underlying kernel resource via `close(2)`
    /// when the value is dropped without explicit close.
    ///
    /// Use ``Kernel/Close/close(_:)`` for explicit close with error reporting.
    ///
    /// ## Design
    ///
    /// This type is intentionally opaque. Raw value access is available only
    /// via `@_spi(Syscall)` for syscall implementation layers. Application
    /// code should use the unified API in swift-kernel, where
    /// `ISO_9945.Kernel.Descriptor` is a typealias to this type on POSIX platforms.
    ///
    /// ## Thread Safety
    ///
    /// `Sendable` (just an integer). Sharing a descriptor across threads
    /// requires external synchronization for sequential I/O; positional I/O
    /// (`pread`/`pwrite`) is concurrency-safe by itself.
    public struct Descriptor: ~Copyable, Sendable {
        @usableFromInline
        package var _raw: Int32

        @usableFromInline
        package init(_raw: Int32) {
            self._raw = _raw
        }

        deinit {
            guard isValid else { return }
            #if canImport(Darwin)
                _ = Darwin.close(_raw)
            #elseif canImport(Glibc)
                _ = unsafe Glibc.close(_raw)
            #elseif canImport(Musl)
                _ = unsafe Musl.close(_raw)
            #endif
        }
    }
}

extension ISO_9945.Kernel.Descriptor {
    /// Invalid descriptor sentinel (`-1`).
    public static var invalid: Self {
        Self(_raw: -1)
    }

    /// Whether the descriptor is valid (not the sentinel).
    @inlinable
    public var isValid: Bool {
        _raw >= 0
    }
}

// MARK: - SPI for Syscall Layers

extension ISO_9945.Kernel.Descriptor {
    /// Creates a descriptor from a raw POSIX `int` file descriptor.
    @_spi(Syscall)
    @inlinable
    public init(_rawValue: Int32) {
        self._raw = _rawValue
    }

    /// The raw POSIX `int` file descriptor.
    @_spi(Syscall)
    @inlinable
    public var _rawValue: Int32 { _raw }
}
