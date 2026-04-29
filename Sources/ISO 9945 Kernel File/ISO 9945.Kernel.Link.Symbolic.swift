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

// MARK: - POSIX symlink() syscall

extension ISO_9945.Kernel.Link.Symbolic {
    /// Internal implementation for creating a symbolic link.
    @usableFromInline
    internal static func _create(
        target: UnsafePointer<Path.Char>,
        at linkPath: UnsafePointer<Path.Char>
    ) throws(Error) {
        let cTarget = unsafe UnsafePointer<CChar>(target)
        let cLinkPath = unsafe UnsafePointer<CChar>(linkPath)

        #if canImport(Darwin)
            let result = unsafe Darwin.symlink(cTarget, cLinkPath)
        #elseif canImport(Musl)
            let result = Musl.symlink(cTarget, cLinkPath)
        #elseif canImport(Glibc)
            let result = Glibc.symlink(cTarget, cLinkPath)
        #endif

        guard result == 0 else {
            throw Error.currentCreate()
        }
    }

    /// Internal implementation for reading the target into a provided buffer.
    @usableFromInline
    internal static func _readTarget(
        at path: UnsafePointer<Path.Char>,
        into buffer: UnsafeMutableBufferPointer<CChar>
    ) throws(Error) -> Int {
        let cPath = unsafe UnsafePointer<CChar>(path)

        #if canImport(Darwin)
            let count = unsafe Darwin.readlink(cPath, buffer.baseAddress!, buffer.count)
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

// MARK: - POSIX symlinkat() syscall (raw @_spi(Syscall))

extension ISO_9945.Kernel.Link.Symbolic {
    /// Creates a symbolic link relative to a raw directory descriptor.
    ///
    /// Spec-literal raw `symlinkat(2)`. The typed L2 internal-only convenience
    /// (`ISO_9945.Kernel.Link.Symbolic._create(target:relativeTo:linkPath:)`
    /// taking `borrowing Kernel.Descriptor`) delegates to this raw SPI
    /// internally.
    ///
    /// - Parameters:
    ///   - target: The path the symlink points to.
    ///   - fd: Raw directory descriptor for the link path.
    ///   - linkPath: The path where the symlink will be created.
    /// - Throws: `Kernel.Link.Symbolic.Error` on failure.
    @_spi(Syscall)
    public static func create(
        target: UnsafePointer<Path.Char>,
        relativeToFd fd: Int32,
        linkPath: UnsafePointer<Path.Char>
    ) throws(Error) {
        let cTarget = unsafe UnsafePointer<CChar>(target)
        let cLinkPath = unsafe UnsafePointer<CChar>(linkPath)

        #if canImport(Darwin)
            let result = unsafe Darwin.symlinkat(cTarget, fd, cLinkPath)
        #elseif canImport(Musl)
            let result = unsafe Musl.symlinkat(cTarget, fd, cLinkPath)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.symlinkat(cTarget, fd, cLinkPath)
        #endif

        guard result == 0 else {
            throw Error.currentCreate()
        }
    }
}

// MARK: - Typed Convenience (internal)

extension ISO_9945.Kernel.Link.Symbolic {
    /// Internal implementation for creating a symbolic link relative to a directory descriptor.
    ///
    /// Internal typed L2 form. Delegates to the raw
    /// `create(target:relativeToFd:linkPath:)` SPI via
    /// `descriptor._rawValue`.
    @usableFromInline
    internal static func _create(
        target: UnsafePointer<Path.Char>,
        relativeTo descriptor: borrowing Kernel.Descriptor,
        linkPath: UnsafePointer<Path.Char>
    ) throws(Error) {
        try unsafe create(
            target: target,
            relativeToFd: descriptor._rawValue,
            linkPath: linkPath
        )
    }
}

// MARK: - Ergonomic Path Overloads

extension ISO_9945.Kernel.Link.Symbolic {
    /// Creates a symbolic link using `Path`.
    ///
    /// This is the preferred entry point.
    ///
    /// - Parameters:
    ///   - target: The path the symlink points to.
    ///   - linkPath: The path where the symlink will be created.
    /// - Throws: `Kernel.Link.Symbolic.Error` on failure.
    public static func create(
        target: borrowing Path.Borrowed,
        at linkPath: borrowing Path.Borrowed
    ) throws(Error) {
        try unsafe target.withUnsafePointer { (targetPtr: UnsafePointer<Path.Char>) throws(Error) in
            try unsafe linkPath.withUnsafePointer { (linkPtr: UnsafePointer<Path.Char>) throws(Error) in
                try unsafe _create(target: targetPtr, at: linkPtr)
            }
        }
    }
}

// MARK: - Borrow-First APIs

extension ISO_9945.Kernel.Link.Symbolic {

    /// Canonical primitive: scoped access to symlink target bytes.
    ///
    /// This is the most primitive API. It provides zero-copy access to the
    /// raw bytes returned by `readlink(2)`. The closure receives a `Span`
    /// that does NOT include a NUL terminator (readlink returns a count).
    ///
    /// - Parameters:
    ///   - path: The path to the symbolic link.
    ///   - body: A closure that processes the target bytes. Non-throwing.
    /// - Returns: The result of the closure.
    /// - Throws: `Kernel.Link.Symbolic.Error` on syscall failure.
    public static func withTargetBytes<R: ~Copyable>(
        at path: borrowing Path.Borrowed,
        _ body: (Span<Path.Char>) -> R
    ) throws(Error) -> R {
        try unsafe path.withUnsafePointer { cPath throws(Error) in
            var bufferSize = 256

            while bufferSize <= 65536 {
                let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize)
                defer { unsafe buffer.deallocate() }

                #if canImport(Darwin)
                    let count = unsafe Darwin.readlink(cPath, buffer, bufferSize)
                #elseif canImport(Musl)
                    let count = unsafe Musl.readlink(cPath, buffer, bufferSize)
                #elseif canImport(Glibc)
                    let count = unsafe Glibc.readlink(cPath, buffer, bufferSize)
                #endif

                guard count >= 0 else {
                    throw Error.currentRead()
                }

                if count < bufferSize {
                    let u8Ptr = unsafe UnsafePointer<UInt8>(buffer)
                    let span = unsafe Span(_unsafeStart: u8Ptr, count: count)
                    return body(span)
                }

                bufferSize *= 2
            }

            throw .bufferTooSmall
        }
    }

    /// Convenience: scoped access as NUL-terminated view.
    ///
    /// This API adds a NUL terminator internally and provides a
    /// `String.Borrowed` for APIs that expect NUL-terminated strings.
    ///
    /// - Parameters:
    ///   - path: The path to the symbolic link.
    ///   - body: A closure that processes the target view. Non-throwing.
    /// - Returns: The result of the closure.
    /// - Throws: `Kernel.Link.Symbolic.Error` on syscall failure.
    public static func withTarget<R: ~Copyable>(
        at path: borrowing Path.Borrowed,
        _ body: (borrowing String.Borrowed) -> R
    ) throws(Error) -> R {
        try unsafe path.withUnsafePointer { cPath throws(Error) in
            var bufferSize = 256

            while bufferSize <= 65536 {
                // Allocate extra byte for NUL terminator
                let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize + 1)
                defer { unsafe buffer.deallocate() }

                #if canImport(Darwin)
                    let count = unsafe Darwin.readlink(cPath, buffer, bufferSize)
                #elseif canImport(Musl)
                    let count = unsafe Musl.readlink(cPath, buffer, bufferSize)
                #elseif canImport(Glibc)
                    let count = unsafe Glibc.readlink(cPath, buffer, bufferSize)
                #endif

                guard count >= 0 else {
                    throw Error.currentRead()
                }

                if count < bufferSize {
                    unsafe (buffer[count] = 0)  // NUL terminate
                    let u8Ptr = unsafe UnsafePointer<UInt8>(buffer)
                    let view = unsafe String.Borrowed(u8Ptr, count: count)
                    return body(view)
                }

                bufferSize *= 2
            }

            throw .bufferTooSmall
        }
    }

    /// Owned convenience: returns allocated string.
    ///
    /// This is the simplest API but involves allocation. For callers that
    /// need to transform the result (e.g., into a `File.Path`), prefer
    /// `withTargetBytes` or `withTarget` to avoid intermediate allocations.
    ///
    /// - Parameter path: The path to the symbolic link.
    /// - Returns: The target path as a `String`.
    /// - Throws: `Kernel.Link.Symbolic.Error` on failure.
    public static func readTarget(at path: borrowing Path.Borrowed) throws(Error) -> String {
        try withTarget(at: path) { view in
            String(copying: view)
        }
    }
}

// MARK: - Error

extension ISO_9945.Kernel.Link.Symbolic {
    public typealias Error = Kernel.Link.Symbolic.Error
}

extension ISO_9945.Kernel.Link.Symbolic.Error {
    /// Creates an error from the current errno for create operations.
    internal static func currentCreate() -> Self {
        let code = Error_Primitives.Error.Code.current()
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
            return .platform(Error_Primitives.Error(code: code))
        }
    }

    /// Creates an error from the current errno for read operations.
    internal static func currentRead() -> Self {
        let code = Error_Primitives.Error.Code.current()
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
            return .platform(Error_Primitives.Error(code: code))
        }
    }
}
