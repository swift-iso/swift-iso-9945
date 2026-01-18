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

// MARK: - POSIX symlink() syscall

extension ISO_9945.Kernel.Link.Symbolic {
    /// Internal implementation for creating a symbolic link.
    @usableFromInline
    internal static func _create(
        target: UnsafePointer<Kernel.Path.Char>,
        at linkPath: UnsafePointer<Kernel.Path.Char>
    ) throws(Error) {
        let cTarget = unsafe UnsafePointer<CChar>(target)
        let cLinkPath = unsafe UnsafePointer<CChar>(linkPath)

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

    /// Internal implementation for creating a symbolic link relative to a directory descriptor.
    @usableFromInline
    internal static func _create(
        target: UnsafePointer<Kernel.Path.Char>,
        relativeTo descriptor: Kernel.Descriptor,
        linkPath: UnsafePointer<Kernel.Path.Char>
    ) throws(Error) {
        let cTarget = unsafe UnsafePointer<CChar>(target)
        let cLinkPath = unsafe UnsafePointer<CChar>(linkPath)

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

    /// Internal implementation for reading the target of a symbolic link.
    @usableFromInline
    internal static func _readTarget(at path: UnsafePointer<Kernel.Path.Char>) throws(Error) -> Kernel.String {
        let cPath = unsafe UnsafePointer<CChar>(path)

        // Start with a reasonable buffer size
        var bufferSize = 256

        while bufferSize <= 65536 {
            // Allocate bufferSize + 1 to have room for the NUL terminator we'll add
            let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize + 1)
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
                // readlink does NOT NUL-terminate — we must add it
                buffer[count] = 0

                let u8Ptr = unsafe UnsafePointer<UInt8>(buffer)
                let view = unsafe Kernel.String.View(u8Ptr)
                return unsafe Kernel.String(copying: view)
            }

            // Otherwise, double the buffer and try again
            bufferSize *= 2
        }

        throw .bufferTooSmall
    }

    /// Internal implementation for reading the target into a provided buffer.
    @usableFromInline
    internal static func _readTarget(
        at path: UnsafePointer<Kernel.Path.Char>,
        into buffer: UnsafeMutableBufferPointer<CChar>
    ) throws(Error) -> Int {
        let cPath = unsafe UnsafePointer<CChar>(path)

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

    // MARK: - Ergonomic Kernel.Path Overloads

    /// Creates a symbolic link using `Kernel.Path`.
    ///
    /// This is the preferred entry point.
    ///
    /// - Parameters:
    ///   - target: The path the symlink points to.
    ///   - linkPath: The path where the symlink will be created.
    /// - Throws: `Kernel.Link.Symbolic.Error` on failure.
    public static func create(
        target: borrowing Kernel.Path,
        at linkPath: borrowing Kernel.Path
    ) throws(Error) {
        try unsafe target.withUnsafeCString { (targetPtr: UnsafePointer<Kernel.Path.Char>) throws(Error) in
            try linkPath.withUnsafeCString { (linkPtr: UnsafePointer<Kernel.Path.Char>) throws(Error) in
                try _create(target: targetPtr, at: linkPtr)
            }
        }
    }

    /// Reads the target of a symbolic link using `Kernel.Path`.
    ///
    /// This is the preferred entry point.
    ///
    /// - Parameter path: The path to the symbolic link.
    /// - Returns: The target path as a `Kernel.String`.
    /// - Throws: `Kernel.Link.Symbolic.Error` on failure.
    public static func readTarget(at path: borrowing Kernel.Path) throws(Error) -> Kernel.String {
        try unsafe path.withUnsafeCString { (ptr: UnsafePointer<Kernel.Path.Char>) throws(Error) in
            try _readTarget(at: ptr)
        }
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
