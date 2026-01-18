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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX link() syscall

extension ISO_9945.Kernel.Link {
    /// Creates a hard link.
    ///
    /// - Parameters:
    ///   - linkPath: The path where the hard link will be created.
    ///   - existingPath: The path to the existing file.
    /// - Throws: `Kernel.Link.Error` on failure.

    public static func create(
        at linkPath: UnsafePointer<Kernel.Path.Char>,
        to existingPath: UnsafePointer<Kernel.Path.Char>
    ) throws(Error) {
        let cLinkPath = unsafe UnsafeRawPointer(linkPath).assumingMemoryBound(to: CChar.self)
        let cExistingPath = unsafe UnsafeRawPointer(existingPath).assumingMemoryBound(to: CChar.self)

        #if canImport(Darwin)
            let result = Darwin.link(cExistingPath, cLinkPath)
        #elseif canImport(Musl)
            let result = Musl.link(cExistingPath, cLinkPath)
        #elseif canImport(Glibc)
            let result = Glibc.link(cExistingPath, cLinkPath)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }

    /// Creates a hard link relative to directory descriptors.
    ///
    /// - Parameters:
    ///   - existingDescriptor: Directory descriptor for the existing file.
    ///   - existingPath: The path to the existing file.
    ///   - linkDescriptor: Directory descriptor for the link location.
    ///   - linkPath: The path where the hard link will be created.
    ///   - flags: Flags to control the operation.
    /// - Throws: `Kernel.Link.Error` on failure.

    public static func create(
        from existingDescriptor: Kernel.Descriptor,
        existingPath: UnsafePointer<Kernel.Path.Char>,
        at linkDescriptor: Kernel.Descriptor,
        linkPath: UnsafePointer<Kernel.Path.Char>,
        flags: Int32 = 0
    ) throws(Error) {
        let cExistingPath = unsafe UnsafeRawPointer(existingPath).assumingMemoryBound(to: CChar.self)
        let cLinkPath = unsafe UnsafeRawPointer(linkPath).assumingMemoryBound(to: CChar.self)

        #if canImport(Darwin)
            let result = Darwin.linkat(
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

    // MARK: - Ergonomic Kernel.Path Overloads

    /// Creates a hard link using `Kernel.Path`.
    ///
    /// This is the preferred entry point.
    ///
    /// - Parameters:
    ///   - linkPath: The path where the hard link will be created.
    ///   - existingPath: The path to the existing file.
    /// - Throws: `Kernel.Link.Error` on failure.
    public static func create(
        at linkPath: borrowing Kernel.Path,
        to existingPath: borrowing Kernel.Path
    ) throws(Error) {
        try unsafe linkPath.withUnsafeCString { (linkPtr: UnsafePointer<Kernel.Path.Char>) throws(Error) in
            try existingPath.withUnsafeCString { (existingPtr: UnsafePointer<Kernel.Path.Char>) throws(Error) in
                try create(at: linkPtr, to: existingPtr)
            }
        }
    }
}

// MARK: - Error

extension ISO_9945.Kernel.Link {
    public typealias Error = Kernel.Link.Error
}

extension Kernel.Link.Error {
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
