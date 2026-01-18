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
internal import ISO_9945_ABI

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX Path Canonicalization

extension ISO_9945.Kernel.Path.Canonical {
    /// Resolves a path to its canonical absolute form.
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
        _ path: borrowing Kernel.Path
    ) throws(Kernel.Path.Canonical.Error) -> Kernel.String {
        let cPath = unsafe UnsafePointer<CChar>(path.unsafeCString)
        return try canonicalize(unsafePath: cPath)
    }

    /// Resolves a path to its canonical absolute form using an unsafe C string.
    ///
    /// Low-level variant for callers that already have a null-terminated path.
    ///
    /// - Parameter unsafePath: Null-terminated path string.
    /// - Returns: The canonical absolute path as a `Kernel.String`.
    /// - Throws: ``Kernel.Path.Canonical.Error`` on failure.
    public static func canonicalize(
        unsafePath: UnsafePointer<CChar>
    ) throws(Kernel.Path.Canonical.Error) -> Kernel.String {
        #if canImport(Darwin)
            let result = Darwin.realpath(unsafePath, nil)
        #elseif canImport(Musl)
            let result = Musl.realpath(unsafePath, nil)
        #elseif canImport(Glibc)
            let result = Glibc.realpath(unsafePath, nil)
        #endif

        guard let result else {
            throw .current()
        }

        defer { free(result) }

        // Project CChar* → UInt8*, create View, copy to owned Kernel.String
        let u8Ptr = unsafe UnsafePointer<UInt8>(result)
        let view = unsafe Kernel.String.View(u8Ptr)
        return unsafe Kernel.String(copying: view)
    }
}

// MARK: - Error Current

extension Kernel.Path.Canonical.Error {
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
