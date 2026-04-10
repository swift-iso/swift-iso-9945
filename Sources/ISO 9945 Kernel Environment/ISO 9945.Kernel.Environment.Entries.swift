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

@_spi(Syscall) import Kernel_Descriptor_Primitives
@_spi(Syscall) import Kernel_Environment_Primitives

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
    /// var entries = ISO_9945.Kernel.Environment.entries()
    /// while let entry = entries.next() {
    ///     // entry.name and entry.value are valid only within this iteration
    ///     print(String(cString: entry.name), String(cString: entry.value))
    /// }
    /// ```
    @safe
    public struct Entries: ~Copyable, ~Escapable {
        @usableFromInline
        internal var index: Int

        /// Temporary buffer for null-terminated name (we modify environ entry in-place).
        /// Stores the original '=' character to restore after yielding entry.
        /// Uses `CChar` because `environ` provides `CChar*` pointers.
        @usableFromInline
        internal var savedSeparator: CChar

        /// Pointer to the separator position for restoration.
        /// Uses `CChar` because `environ` provides `CChar*` pointers.
        @usableFromInline
        internal var separatorPtr: UnsafeMutablePointer<CChar>?

        /// Creates an iterator over all environment variables.

        @_lifetime(immortal)
        internal init() {
            self.index = 0
            self.savedSeparator = 0
            unsafe (self.separatorPtr = nil)
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
        if let ptr = unsafe separatorPtr {
            unsafe (ptr.pointee = savedSeparator)
            unsafe (separatorPtr = nil)
        }

        // Get next entry from environ
        guard let entry = unsafe environ[index] else {
            return nil
        }
        index += 1

        // Find '=' separator (0x3D)
        var j = 0
        while unsafe (entry[j] != 0 && entry[j] != 0x3D) {
            j += 1
        }

        guard unsafe (entry[j] == 0x3D) else {
            // Malformed entry (no '='), skip it
            return next()
        }

        // Save and replace '=' with null terminator
        let sepPtr = unsafe entry + j
        unsafe (savedSeparator = sepPtr.pointee)
        unsafe (separatorPtr = sepPtr)
        unsafe (sepPtr.pointee = 0)

        // Convert CChar pointers to UInt8 pointers at the boundary
        let namePtr = unsafe UnsafePointer<UInt8>(UnsafePointer(entry))
        let valuePtr = unsafe UnsafePointer<UInt8>(UnsafePointer(entry + j + 1))

        return unsafe _overrideLifetime(
            Kernel.Environment.Entry(name: namePtr, value: valuePtr),
            copying: self
        )
    }
}
