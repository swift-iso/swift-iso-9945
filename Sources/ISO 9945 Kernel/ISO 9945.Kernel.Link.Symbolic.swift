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

// MARK: - POSIX symlink() syscall

extension ISO_9945.Kernel.Link.Symbolic {
    /// Creates a symbolic link.
    ///
    /// - Parameters:
    ///   - target: The path the symlink points to.
    ///   - linkPath: The path where the symlink will be created.
    /// - Throws: `Kernel.Link.Symbolic.Error` on failure.

    public static func create(
        target: UnsafePointer<Kernel.Path.Char>,
        at linkPath: UnsafePointer<Kernel.Path.Char>
    ) throws(Error) {
        let cTarget = unsafe UnsafeRawPointer(target).assumingMemoryBound(to: CChar.self)
        let cLinkPath = unsafe UnsafeRawPointer(linkPath).assumingMemoryBound(to: CChar.self)

        #if canImport(Darwin)
            let result = Darwin.symlink(cTarget, cLinkPath)
        #elseif canImport(Musl)
            let result = Musl.symlink(cTarget, cLinkPath)
        #elseif canImport(Glibc)
            let result = Glibc.symlink(cTarget, cLinkPath)
        #endif

        guard result == 0 else {
            throw Error.currentCreate()
        }
    }

    /// Creates a symbolic link relative to a directory descriptor.
    ///
    /// - Parameters:
    ///   - target: The path the symlink points to.
    ///   - descriptor: The directory descriptor.
    ///   - linkPath: The path where the symlink will be created.
    /// - Throws: `Kernel.Link.Symbolic.Error` on failure.

    public static func create(
        target: UnsafePointer<Kernel.Path.Char>,
        relativeTo descriptor: Kernel.Descriptor,
        linkPath: UnsafePointer<Kernel.Path.Char>
    ) throws(Error) {
        let cTarget = unsafe UnsafeRawPointer(target).assumingMemoryBound(to: CChar.self)
        let cLinkPath = unsafe UnsafeRawPointer(linkPath).assumingMemoryBound(to: CChar.self)

        #if canImport(Darwin)
            let result = Darwin.symlinkat(cTarget, descriptor._rawValue, cLinkPath)
        #elseif canImport(Musl)
            let result = Musl.symlinkat(cTarget, descriptor._rawValue, cLinkPath)
        #elseif canImport(Glibc)
            let result = Glibc.symlinkat(cTarget, descriptor._rawValue, cLinkPath)
        #endif

        guard result == 0 else {
            throw Error.currentCreate()
        }
    }

    /// Reads the target of a symbolic link.
    ///
    /// - Parameter path: The path to the symbolic link.
    /// - Returns: The target path as a string.
    /// - Throws: `Kernel.Link.Symbolic.Error` on failure.
    public static func readTarget(at path: UnsafePointer<Kernel.Path.Char>) throws(Error) -> String {
        let cPath = unsafe UnsafeRawPointer(path).assumingMemoryBound(to: CChar.self)

        // Start with a reasonable buffer size
        var bufferSize = 256

        while bufferSize <= 65536 {
            let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize)
            defer { buffer.deallocate() }

            #if canImport(Darwin)
                let count = Darwin.readlink(cPath, buffer, bufferSize)
            #elseif canImport(Musl)
                let count = Musl.readlink(cPath, buffer, bufferSize)
            #elseif canImport(Glibc)
                let count = Glibc.readlink(cPath, buffer, bufferSize)
            #endif

            guard count >= 0 else {
                throw Error.currentRead()
            }

            // If the result fits in the buffer, we're done
            if count < bufferSize {
                buffer[count] = 0  // Null-terminate
                return String(cString: buffer)
            }

            // Otherwise, double the buffer and try again
            bufferSize *= 2
        }

        throw .bufferTooSmall
    }

    /// Reads the target of a symbolic link into a provided buffer.
    ///
    /// - Parameters:
    ///   - path: The path to the symbolic link.
    ///   - buffer: Buffer to read into.
    /// - Returns: Number of bytes read.
    /// - Throws: `Kernel.Link.Symbolic.Error` on failure.

    public static func readTarget(
        at path: UnsafePointer<Kernel.Path.Char>,
        into buffer: UnsafeMutableBufferPointer<CChar>
    ) throws(Error) -> Int {
        let cPath = unsafe UnsafeRawPointer(path).assumingMemoryBound(to: CChar.self)

        #if canImport(Darwin)
            let count = Darwin.readlink(cPath, buffer.baseAddress!, buffer.count)
        #elseif canImport(Musl)
            let count = Musl.readlink(cPath, buffer.baseAddress!, buffer.count)
        #elseif canImport(Glibc)
            let count = Glibc.readlink(cPath, buffer.baseAddress!, buffer.count)
        #endif

        guard count >= 0 else {
            throw Error.currentRead()
        }

        return count
    }
}

// MARK: - Error

extension ISO_9945.Kernel.Link.Symbolic {
    public typealias Error = Kernel.Link.Symbolic.Error
}

extension Kernel.Link.Symbolic.Error {
    /// Creates an error from the current errno for create operations.
    internal static func currentCreate() -> Self {
        let code = Kernel.Error.Code.current()
        switch code {
        case .ENOENT:
            return .notFound
        case .EACCES, .EPERM:
            return .permission
        case .EEXIST:
            return .exists
        case .ENOTDIR:
            return .notDirectory
        case .EROFS:
            return .readOnly
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

    /// Creates an error from the current errno for read operations.
    internal static func currentRead() -> Self {
        let code = Kernel.Error.Code.current()
        switch code {
        case .ENOENT:
            return .notFound
        case .EACCES:
            return .permission
        case .EINVAL:
            return .notSymbolicLink
        case .ENOTDIR:
            return .notDirectory
        case .ELOOP:
            return .loop
        case .ENAMETOOLONG:
            return .nameTooLong
        default:
            return .platform(Kernel.Error(code: code))
        }
    }
}
