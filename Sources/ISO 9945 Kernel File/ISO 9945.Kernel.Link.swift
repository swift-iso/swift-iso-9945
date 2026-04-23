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

// MARK: - POSIX link() syscall

extension ISO_9945.Kernel.Link {
    /// Creates a hard link using `Kernel.Path`.
    ///
    /// This is the preferred entry point.
    ///
    /// - Parameters:
    ///   - linkPath: The path where the hard link will be created.
    ///   - existingPath: The path to the existing file.
    /// - Throws: `Kernel.Link.Error` on failure.
    public static func create(
        at linkPath: borrowing Kernel.Path.Borrowed,
        to existingPath: borrowing Kernel.Path.Borrowed
    ) throws(Error) {
        try unsafe linkPath.withUnsafePointer { (linkPtr: UnsafePointer<Path.Char>) throws(Error) in
            try unsafe existingPath.withUnsafePointer { (existingPtr: UnsafePointer<Path.Char>) throws(Error) in
                try unsafe _create(at: linkPtr, to: existingPtr)
            }
        }
    }

    /// Internal implementation for creating a hard link using unsafe path pointers.
    @usableFromInline
    internal static func _create(
        at linkPath: UnsafePointer<Path.Char>,
        to existingPath: UnsafePointer<Path.Char>
    ) throws(Error) {
        let cLinkPath = unsafe UnsafePointer<CChar>(linkPath)
        let cExistingPath = unsafe UnsafePointer<CChar>(existingPath)

        #if canImport(Darwin)
            let result = unsafe Darwin.link(cExistingPath, cLinkPath)
        #elseif canImport(Musl)
            let result = Musl.link(cExistingPath, cLinkPath)
        #elseif canImport(Glibc)
            let result = Glibc.link(cExistingPath, cLinkPath)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }

    /// Internal implementation for creating a hard link relative to directory descriptors.
    @usableFromInline
    internal static func _create(
        from existingDescriptor: borrowing Kernel.Descriptor,
        existingPath: UnsafePointer<Path.Char>,
        at linkDescriptor: borrowing Kernel.Descriptor,
        linkPath: UnsafePointer<Path.Char>,
        flags: Int32 = 0
    ) throws(Error) {
        let cExistingPath = unsafe UnsafePointer<CChar>(existingPath)
        let cLinkPath = unsafe UnsafePointer<CChar>(linkPath)

        #if canImport(Darwin)
            let result = unsafe Darwin.linkat(
                existingDescriptor._rawValue, cExistingPath,
                linkDescriptor._rawValue, cLinkPath,
                flags
            )
        #elseif canImport(Musl)
            let result = Musl.linkat(
                existingDescriptor._rawValue, cExistingPath,
                linkDescriptor._rawValue, cLinkPath,
                flags
            )
        #elseif canImport(Glibc)
            let result = Glibc.linkat(
                existingDescriptor._rawValue, cExistingPath,
                linkDescriptor._rawValue, cLinkPath,
                flags
            )
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

// MARK: - Error

extension ISO_9945.Kernel.Link {
    public typealias Error = Kernel.Link.Error
}

extension ISO_9945.Kernel.Link.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Kernel.Error.Code.current()
        switch code {
        case .ENOENT:
            return .notFound
        case .EACCES, .EPERM:
            return .permission
        case .EEXIST:
            return .exists
        case .EXDEV:
            return .crossDevice
        case .EISDIR:
            return .isDirectory
        case .ENOTDIR:
            return .notDirectory
        case .EROFS:
            return .readOnly
        case .EMLINK:
            return .tooManyLinks
        case .ENOSPC:
            return .noSpace
        case .ELOOP:
            return .loop
        case .ENAMETOOLONG:
            return .nameTooLong
        default:
            return .platform(Kernel.Error(code: code))
        }
    }
}
