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

// MARK: - POSIX rmdir() syscall

extension ISO_9945.Kernel.Rmdir {
    /// Removes an empty directory.
    ///
    /// - Parameter path: The path to remove.
    /// - Throws: `Kernel.Rmdir.Error` on failure.

    public static func rmdir(_ path: UnsafePointer<Kernel.Path.Char>) throws(Error) {
        let cPath = unsafe UnsafeRawPointer(path).assumingMemoryBound(to: CChar.self)

        #if canImport(Darwin)
            let result = Darwin.rmdir(cPath)
        #elseif canImport(Musl)
            let result = Musl.rmdir(cPath)
        #elseif canImport(Glibc)
            let result = Glibc.rmdir(cPath)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

// MARK: - Error

extension ISO_9945.Kernel.Rmdir {
    public typealias Error = Kernel.Rmdir.Error
}

extension Kernel.Rmdir.Error {
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
