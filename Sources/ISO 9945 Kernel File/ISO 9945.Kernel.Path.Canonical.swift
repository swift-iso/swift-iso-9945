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
@_spi(Syscall) import Kernel_File_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Borrow-First APIs

extension ISO_9945.Kernel.Path.Canonical {

    /// Canonical primitive: scoped access to canonicalized path bytes.
    ///
    /// This is the most primitive API. It provides zero-copy access to the
    /// raw bytes returned by `realpath(3)`. The closure receives a `Span`
    /// that does NOT include the NUL terminator.
    ///
    /// - Parameters:
    ///   - path: The path to canonicalize.
    ///   - body: A closure that processes the canonical path bytes. Non-throwing.
    /// - Returns: The result of the closure.
    /// - Throws: ``Kernel.Path.Canonical.Error`` on syscall failure.
    public static func withCanonicalBytes<R: ~Copyable>(
        _ path: borrowing Kernel.Path.View,
        _ body: (Span<Path.Char>) -> R
    ) throws(Kernel.Path.Canonical.Error) -> R {
        try unsafe path.withUnsafePointer { cString throws(Kernel.Path.Canonical.Error) in
            let unsafePath = unsafe UnsafePointer<CChar>(cString)

            #if canImport(Darwin)
                let result = unsafe Darwin.realpath(unsafePath, nil)
            #elseif canImport(Musl)
                let result = Musl.realpath(unsafePath, nil)
            #elseif canImport(Glibc)
                let result = Glibc.realpath(unsafePath, nil)
            #endif

            guard let result = unsafe result else {
                throw .current()
            }

            defer { unsafe free(result) }

            // Find length (realpath NUL-terminates)
            var length = 0
            while (unsafe result[length]) != 0 {
                length += 1
            }

            let u8Ptr = unsafe UnsafePointer<UInt8>(result)
            let span = unsafe Span(_unsafeStart: u8Ptr, count: length)
            return body(span)
        }
    }

    /// Convenience: scoped access as NUL-terminated view.
    ///
    /// This API provides a `Kernel.String.View` for APIs that expect
    /// NUL-terminated strings. The underlying buffer already includes
    /// the NUL terminator from `realpath(3)`.
    ///
    /// - Parameters:
    ///   - path: The path to canonicalize.
    ///   - body: A closure that processes the canonical path view. Non-throwing.
    /// - Returns: The result of the closure.
    /// - Throws: ``Kernel.Path.Canonical.Error`` on syscall failure.
    public static func withCanonical<R: ~Copyable>(
        _ path: borrowing Kernel.Path.View,
        _ body: (borrowing Kernel.String.View) -> R
    ) throws(Kernel.Path.Canonical.Error) -> R {
        try unsafe path.withUnsafePointer { cString throws(Kernel.Path.Canonical.Error) in
            let unsafePath = unsafe UnsafePointer<CChar>(cString)

            #if canImport(Darwin)
                let result = unsafe Darwin.realpath(unsafePath, nil)
            #elseif canImport(Musl)
                let result = unsafe Musl.realpath(unsafePath, nil)
            #elseif canImport(Glibc)
                let result = unsafe Glibc.realpath(unsafePath, nil)
            #endif

            guard let result = unsafe result else {
                throw .current()
            }

            defer { unsafe free(result) }

            let u8Ptr = unsafe UnsafePointer<UInt8>(result)
            let view = unsafe Kernel.String.View(u8Ptr, count: Kernel.String.length(of: u8Ptr))
            return body(view)
        }
    }

    /// Owned convenience: resolves a path to its canonical absolute form.
    ///
    /// This is the simplest API but involves allocation. For callers that
    /// need to transform the result (e.g., into a `File.Path`), prefer
    /// `withCanonicalBytes` or `withCanonical` to avoid intermediate allocations.
    ///
    /// Resolves all symlinks, eliminates `.` and `..` components,
    /// and returns the absolute path.
    ///
    /// ## Errors
    /// - `.path(.notFound)`: A component of the path does not exist
    /// - `.path(.loop)`: Too many symlinks encountered
    /// - `.path(.nameTooLong)`: Path exceeds system limit
    /// - `.permission`: Permission denied for a path component
    ///
    /// - Parameter path: The path to canonicalize.
    /// - Returns: The canonical absolute path as a `Kernel.String`.
    /// - Throws: ``Kernel.Path.Canonical.Error`` on failure.
    public static func canonicalize(
        _ path: borrowing Kernel.Path.View
    ) throws(Kernel.Path.Canonical.Error) -> Kernel.String {
        try withCanonical(path) { view in
            Kernel.String(copying: view)
        }
    }
}

// MARK: - Error Current

extension ISO_9945.Kernel.Path.Canonical.Error {
    /// Creates an error from the current errno value.

    static func current() -> Kernel.Path.Canonical.Error {
        let e = errno
        let code = Kernel.Error.Code.posix(e)
        if let pathError = Kernel.Path.Resolution.Error(code: code) {
            return .path(pathError)
        }
        if let permError = Kernel.Permission.Error(code: code) {
            return .permission(permError)
        }
        return .platform(Kernel.Error(code: code))
    }
}
