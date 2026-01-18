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

// MARK: - POSIX rmdir() syscall

extension ISO_9945.Kernel.Directory.Remove {
    /// Removes an empty directory using `Kernel.Path`.
    ///
    /// This is the preferred entry point.
    ///
    /// - Parameter path: The path to remove.
    /// - Throws: `Kernel.Directory.Remove.Error` on failure.
    public static func remove(_ path: borrowing Kernel.Path) throws(Error) {
        try unsafe path.withUnsafeCString { (ptr: UnsafePointer<Kernel.Path.Char>) throws(Error) in
            try _remove(ptr)
        }
    }

    /// Internal implementation for removing an empty directory using an unsafe path pointer.
    @usableFromInline
    @unsafe
    internal static func _remove(_ path: UnsafePointer<Kernel.Path.Char>) throws(Error) {
        let cPath = unsafe UnsafePointer<CChar>(path)

        #if canImport(Darwin)
            let result = unsafe Darwin.rmdir(cPath)
        #elseif canImport(Musl)
            let result = unsafe Musl.rmdir(cPath)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.rmdir(cPath)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

// MARK: - Error

extension ISO_9945.Kernel.Directory.Remove {
    public typealias Error = Kernel.Directory.Remove.Error
}

extension Kernel.Directory.Remove.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Kernel.Error.Code.current()
        switch code {
        case .ENOENT:
            return .notFound
        case .EACCES, .EPERM:
            return .permission
        case .ENOTEMPTY:
            return .notEmpty
        case .ENOTDIR:
            return .notDirectory
        case .EBUSY:
            return .busy
        case .EROFS:
            return .readOnly
        case .ELOOP:
            return .loop
        case .ENAMETOOLONG:
            return .nameTooLong
        default:
            return .platform(Kernel.Error(code: code))
        }
    }
}
