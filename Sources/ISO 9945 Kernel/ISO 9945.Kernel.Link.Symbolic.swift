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

@_spi(Syscall) public import Kernel_Primitives_Core
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_IO_Primitives
@_spi(Syscall) public import Kernel_Socket_Primitives
@_spi(Syscall) public import Kernel_Memory_Primitives
@_spi(Syscall) public import Kernel_Process_Primitives
@_spi(Syscall) public import Kernel_Permission_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives
@_spi(Syscall) public import Kernel_Thread_Primitives
@_spi(Syscall) public import Kernel_System_Primitives
@_spi(Syscall) public import Kernel_Time_Primitives
@_spi(Syscall) public import Kernel_Clock_Primitives
@_spi(Syscall) public import Kernel_Random_Primitives
@_spi(Syscall) public import Kernel_Environment_Primitives
@_spi(Syscall) public import Kernel_Syscall_Primitives
@_spi(Syscall) public import Kernel_Terminal_Primitives
public import Kernel_String_Primitives
public import String_Primitives
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

    /// Internal implementation for creating a symbolic link relative to a directory descriptor.
    @usableFromInline
    internal static func _create(
        target: UnsafePointer<Path.Char>,
        relativeTo descriptor: borrowing Kernel.Descriptor,
        linkPath: UnsafePointer<Path.Char>
    ) throws(Error) {
        let cTarget = unsafe UnsafePointer<CChar>(target)
        let cLinkPath = unsafe UnsafePointer<CChar>(linkPath)

        #if canImport(Darwin)
            let result = unsafe Darwin.symlinkat(cTarget, descriptor._rawValue, cLinkPath)
        #elseif canImport(Musl)
            let result = Musl.symlinkat(cTarget, descriptor._rawValue, cLinkPath)
        #elseif canImport(Glibc)
            let result = Glibc.symlinkat(cTarget, descriptor._rawValue, cLinkPath)
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
        target: borrowing Kernel.Path.View,
        at linkPath: borrowing Kernel.Path.View
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
        at path: borrowing Kernel.Path.View,
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
    /// `Kernel.String.View` for APIs that expect NUL-terminated strings.
    ///
    /// - Parameters:
    ///   - path: The path to the symbolic link.
    ///   - body: A closure that processes the target view. Non-throwing.
    /// - Returns: The result of the closure.
    /// - Throws: `Kernel.Link.Symbolic.Error` on syscall failure.
    public static func withTarget<R: ~Copyable>(
        at path: borrowing Kernel.Path.View,
        _ body: (borrowing Kernel.String.View) -> R
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
                    let view = unsafe Kernel.String.View(u8Ptr, count: count)
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
    /// - Returns: The target path as a `Kernel.String`.
    /// - Throws: `Kernel.Link.Symbolic.Error` on failure.
    public static func readTarget(at path: borrowing Kernel.Path.View) throws(Error) -> Kernel.String {
        try withTarget(at: path) { view in
            Kernel.String(copying: view)
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
