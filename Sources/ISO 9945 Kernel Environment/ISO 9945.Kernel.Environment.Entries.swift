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

// MARK: - POSIX Environment Entries Iterator

extension ISO_9945.Kernel.Environment {
    /// Iterator over all environment variables.
    ///
    /// Provides zero-copy iteration over the process environment. Each entry
    /// borrows directly from the `environ` global, avoiding allocations.
    ///
    /// This type is `~Escapable` with an immortal lifetime, meaning it borrows
    /// from the process-global `environ` which exists for the process lifetime.
    ///
    /// ## Thread Safety
    ///
    /// Iteration is read-only: `environ` is never mutated, so abandoning
    /// iteration cannot corrupt the process environment and concurrent
    /// read-only environment access (`getenv`) stays safe, as POSIX
    /// permits. Concurrent environment *mutation* remains the caller's
    /// responsibility to exclude, as with `getenv` itself.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var entries = ISO_9945.Kernel.Environment.entries()
    /// while let entry = entries.next() {
    ///     // entry.name and entry.value are valid only within this iteration
    ///     print(
    ///         String(decoding: entry.name, as: UTF8.self),
    ///         String(decoding: entry.value, as: UTF8.self)
    ///     )
    /// }
    /// ```
    @safe
    public struct Entries: ~Copyable, ~Escapable {
        @usableFromInline
        internal var index: Int

        /// Creates an iterator over all environment variables.
        @_lifetime(immortal)
        internal init() {
            self.index = 0
        }
    }
}

// MARK: - Factory

extension ISO_9945.Kernel.Environment {
    /// Returns an iterator over all environment variables.
    ///
    /// The iterator provides zero-copy access to environment entries by
    /// borrowing directly from the process environment block.
    ///
    /// - Returns: An iterator that yields `Entry` values.

    @_lifetime(immortal)
    public static func entries() -> Entries {
        Entries()
    }
}

// MARK: - Iteration

extension ISO_9945.Kernel.Environment.Entries {
    /// Advances to the next environment variable.
    ///
    /// Scans the entry non-destructively: the name and value are exposed
    /// as counted spans over the live `environ` string, so no separator
    /// is ever overwritten.
    ///
    /// - Returns: The next entry, or `nil` if iteration is complete.
    ///
    /// - Note: The returned `Entry` is only valid until the next call to `next()`.
    @_lifetime(copy self)
    public mutating func next() -> ISO_9945.Kernel.Environment.Entry? {
        // Get next entry from environ
        guard let entry = unsafe environ[index] else {
            return nil
        }
        index += 1

        // Find '=' separator (0x3D) and the total length
        var separator = -1
        var length = 0
        while unsafe (entry[length] != 0) {
            let byte = unsafe entry[length]
            if separator == -1 && byte == 0x3D {
                separator = length
            }
            length += 1
        }

        guard separator != -1 else {
            // Malformed entry (no '='), skip it
            return next()
        }

        // Convert CChar pointer to UInt8 pointer at the boundary
        let basePtr = unsafe UnsafePointer<UInt8>(UnsafePointer(entry))

        return unsafe _overrideLifetime(
            ISO_9945.Kernel.Environment.Entry(base: basePtr, separator: separator, length: length),
            copying: self
        )
    }
}
