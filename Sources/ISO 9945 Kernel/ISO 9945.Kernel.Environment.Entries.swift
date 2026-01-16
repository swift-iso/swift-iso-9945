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

@_spi(Syscall) public import Kernel_Primitives
public import ISO_9945
public import String_Primitives

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
    /// Not thread-safe. Use `Environment.lock` at higher levels for synchronization.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var entries = POSIX.Kernel.Environment.entries()
    /// while let entry = entries.next() {
    ///     // entry.name and entry.value are valid only within this iteration
    ///     print(String(cString: entry.name), String(cString: entry.value))
    /// }
    /// ```
    public struct Entries: ~Copyable, ~Escapable {
        @usableFromInline
        internal var index: Int

        /// Temporary buffer for null-terminated name (we modify environ entry in-place).
        /// Stores the original '=' character to restore after yielding entry.
        @usableFromInline
        internal var savedSeparator: Kernel.String.Char

        /// Pointer to the separator position for restoration.
        @usableFromInline
        internal var separatorPtr: UnsafeMutablePointer<Kernel.String.Char>?

        /// Creates an iterator over all environment variables.

        @_lifetime(immortal)
        internal init() {
            self.index = 0
            self.savedSeparator = 0
            self.separatorPtr = nil
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
    /// - Returns: The next entry, or `nil` if iteration is complete.
    ///
    /// - Note: The returned `Entry` is only valid until the next call to `next()`.
    @_lifetime(copy self)
    public mutating func next() -> Kernel.Environment.Entry? {
        // Restore previous separator if we modified it
        if let ptr = separatorPtr {
            ptr.pointee = savedSeparator
            separatorPtr = nil
        }

        // Get next entry from environ
        guard let entry = environ[index] else {
            return nil
        }
        index += 1

        // Find '=' separator (0x3D)
        var j = 0
        while entry[j] != 0 && entry[j] != 0x3D {
            j += 1
        }

        guard entry[j] == 0x3D else {
            // Malformed entry (no '='), skip it
            return next()
        }

        // Save and replace '=' with null terminator
        let sepPtr = entry + j
        savedSeparator = sepPtr.pointee
        separatorPtr = sepPtr
        sepPtr.pointee = 0

        let namePtr = UnsafePointer(entry)
        let valuePtr = UnsafePointer(entry + j + 1)

        return unsafe _overrideLifetime(
            Kernel.Environment.Entry(name: namePtr, value: valuePtr),
            copying: self
        )
    }
}
