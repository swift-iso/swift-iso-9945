// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
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
#elseif canImport(Android)
    internal import Android
    internal import CISO9945Shim
#endif

extension ISO_9945.Kernel.File.Access {
    /// Checks whether the calling process can access a path using its effective
    /// user and group identities.
    ///
    /// This binds POSIX `faccessat` with `AT_EACCESS`. On Android, where Bionic
    /// rejects that flag, it invokes the kernel's `faccessat2` operation
    /// directly. The kernel and C library therefore apply ownership,
    /// supplementary-group, privilege, mount, and access-control-list rules
    /// available on the platform. A denied request returns `false`;
    /// path-resolution and other failures remain typed errors. An Android
    /// kernel without `faccessat2` support reports ``Error/unsupported``. The
    /// result is advisory because the file-system state can change before a
    /// subsequent operation uses the path.
    ///
    /// - Parameters:
    ///   - mode: The access requirements to check.
    ///   - path: The path to check.
    /// - Returns: `true` when every requested access is allowed, or `false`
    ///   when the request is denied.
    /// - Throws: ``Error`` when the path cannot be resolved, the operation is
    ///   unavailable, or the platform reports another failure.
    public static func check(
        _ mode: Mode,
        at path: borrowing Path.Borrowed
    ) throws(Error) -> Bool {
        try unsafe path.withUnsafePointer { pointer throws(Error) in
            try unsafe check(mode, at: pointer)
        }
    }

    @usableFromInline
    internal static func check(
        _ mode: Mode,
        at path: UnsafePointer<Path.Char>
    ) throws(Error) -> Bool {
        #if canImport(Darwin) || canImport(Glibc) || canImport(Musl) || canImport(Android)
            var requested: Int32 = F_OK
            if mode.readable {
                requested |= R_OK
            }
            if mode.writable {
                requested |= W_OK
            }
            if mode.executable {
                requested |= X_OK
            }

            let cPath = unsafe UnsafePointer<CChar>(path)
            #if canImport(Darwin)
                let result = unsafe Darwin.faccessat(AT_FDCWD, cPath, requested, AT_EACCESS)
            #elseif canImport(Glibc)
                let result = Glibc.faccessat(AT_FDCWD, cPath, requested, AT_EACCESS)
            #elseif canImport(Musl)
                let result = Musl.faccessat(AT_FDCWD, cPath, requested, AT_EACCESS)
            #elseif canImport(Android)
                let result = iso9945_android_faccessat2(cPath, requested)
            #endif

            if result == 0 {
                return true
            }

            let code = Error_Primitives.Error.Code.current()
            #if canImport(Android)
                if code == .posix(Android.ENOSYS) {
                    throw .unsupported
                }
            #endif
            if code == .POSIX.EACCES {
                return false
            }
            throw Error(code: code)
        #else
            throw .unsupported
        #endif
    }
}

extension ISO_9945.Kernel.File.Access.Error {
    @usableFromInline
    internal init(code: Error_Primitives.Error.Code) {
        if let error = Path.Resolution.Error(code: code) {
            self = .path(error)
            return
        }
        self = .platform(Error_Primitives.Error(code: code))
    }
}
