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

@_spi(Syscall) import ISO_9945_Core


#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX link() syscall

extension ISO_9945.Kernel.Link {
    /// Creates a hard link using `Path`.
    ///
    /// This is the preferred entry point.
    ///
    /// - Parameters:
    ///   - linkPath: The path where the hard link will be created.
    ///   - existingPath: The path to the existing file.
    /// - Throws: `Kernel.Link.Error` on failure.
    public static func create(
        at linkPath: borrowing Path.Borrowed,
        to existingPath: borrowing Path.Borrowed
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
}

// MARK: - POSIX linkat() syscall (raw @_spi(Syscall))

extension ISO_9945.Kernel.Link {
    /// Creates a hard link relative to raw directory descriptors.
    ///
    /// Spec-literal raw `linkat(2)`. The typed L2 internal-only convenience
    /// (`ISO_9945.Kernel.Link._create(from:existingPath:at:linkPath:flags:)`
    /// taking `borrowing Kernel.Descriptor`) delegates to this raw SPI
    /// internally.
    ///
    /// - Parameters:
    ///   - existingFd: Raw directory descriptor for the existing path.
    ///   - existingPath: The path to the existing file.
    ///   - linkFd: Raw directory descriptor for the link path.
    ///   - linkPath: The path where the hard link will be created.
    ///   - flags: Resolution flags (e.g., AT_SYMLINK_FOLLOW).
    /// - Throws: `Kernel.Link.Error` on failure.
    @_spi(Syscall)
    public static func create(
        fromFd existingFd: Int32,
        existingPath: UnsafePointer<Path.Char>,
        atFd linkFd: Int32,
        linkPath: UnsafePointer<Path.Char>,
        flags: Int32 = 0
    ) throws(Error) {
        let cExistingPath = unsafe UnsafePointer<CChar>(existingPath)
        let cLinkPath = unsafe UnsafePointer<CChar>(linkPath)

        #if canImport(Darwin)
            let result = unsafe Darwin.linkat(existingFd, cExistingPath, linkFd, cLinkPath, flags)
        #elseif canImport(Musl)
            let result = unsafe Musl.linkat(existingFd, cExistingPath, linkFd, cLinkPath, flags)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.linkat(existingFd, cExistingPath, linkFd, cLinkPath, flags)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

// MARK: - Typed Convenience (internal)

extension ISO_9945.Kernel.Link {
    /// Internal implementation for creating a hard link relative to directory descriptors.
    ///
    /// Internal typed L2 form. Delegates to the raw
    /// `create(fromFd:existingPath:atFd:linkPath:flags:)` SPI via
    /// `descriptor._rawValue`.
    @usableFromInline
    internal static func _create(
        from existingDescriptor: borrowing Kernel.Descriptor,
        existingPath: UnsafePointer<Path.Char>,
        at linkDescriptor: borrowing Kernel.Descriptor,
        linkPath: UnsafePointer<Path.Char>,
        flags: Int32 = 0
    ) throws(Error) {
        try unsafe create(
            fromFd: existingDescriptor._rawValue,
            existingPath: existingPath,
            atFd: linkDescriptor._rawValue,
            linkPath: linkPath,
            flags: flags
        )
    }
}

// MARK: - Error

extension ISO_9945.Kernel.Link {
    public typealias Error = Kernel.Link.Error
}

extension ISO_9945.Kernel.Link.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Error_Primitives.Error.Code.current()
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
            return .platform(Error_Primitives.Error(code: code))
        }
    }
}
