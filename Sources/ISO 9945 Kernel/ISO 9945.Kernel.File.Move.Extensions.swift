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

#if canImport(CLinuxShim)
    internal import CLinuxShim
#endif

// MARK: - Extended Move Operations

extension ISO_9945.Kernel.File.Move {
    /// Extended atomic move operations (noClobber, exchange).
    public enum Extended {
        /// Error type for extended move operations.
        ///
        /// Uses `Kernel.File.Rename.Error` which has appropriate cases for
        /// atomic rename operations.
        public typealias Error = Kernel.File.Rename.Error
    }
}

// MARK: - Darwin Implementation

#if canImport(Darwin)

extension ISO_9945.Kernel.File.Move {
    /// Atomically moves a file, failing if destination exists.
    ///
    /// Uses `renamex_np` with `RENAME_EXCL` flag on Darwin.
    ///
    /// - Parameters:
    ///   - oldPath: Source path.
    ///   - newPath: Destination path.
    /// - Throws: `ExtendedError` if the move fails.
    public static func noClobber(
        from oldPath: UnsafePointer<CChar>,
        to newPath: UnsafePointer<CChar>
    ) throws(Extended.Error) {
        let result = renamex_np(oldPath, newPath, UInt32(RENAME_EXCL))

        guard result == 0 else {
            let code = Kernel.Error.Code.captureErrno()
            switch code.posix {
            case EEXIST:
                throw .exists
            case EPERM, EACCES:
                throw .permission(code)
            default:
                throw .platform(code)
            }
        }
    }

    /// Atomically exchanges two files.
    ///
    /// Uses `renamex_np` with `RENAME_SWAP` flag on Darwin.
    /// Both paths must exist.
    ///
    /// - Parameters:
    ///   - path1: First path.
    ///   - path2: Second path.
    /// - Throws: `ExtendedError` on failure.
    public static func exchange(
        _ path1: UnsafePointer<CChar>,
        _ path2: UnsafePointer<CChar>
    ) throws(Extended.Error) {
        let result = renamex_np(path1, path2, UInt32(RENAME_SWAP))

        guard result == 0 else {
            let code = Kernel.Error.Code.captureErrno()
            switch code.posix {
            case EPERM, EACCES:
                throw .permission(code)
            default:
                throw .platform(code)
            }
        }
    }
}

// MARK: - Linux Implementation

#elseif canImport(Glibc) || canImport(Musl)

extension ISO_9945.Kernel.File.Move {
    /// Atomically moves a file, failing if destination exists.
    ///
    /// Uses `renameat2` with `RENAME_NOREPLACE` flag on Linux.
    /// Falls back to `link` + `unlink` if renameat2 is not supported.
    ///
    /// - Parameters:
    ///   - oldPath: Source path.
    ///   - newPath: Destination path.
    /// - Throws: `ExtendedError` if the move fails.
    public static func noClobber(
        from oldPath: UnsafePointer<CChar>,
        to newPath: UnsafePointer<CChar>
    ) throws(Extended.Error) {
        #if canImport(CLinuxShim)
        // Try renameat2 first
        let result = swift_renameat2(
            AT_FDCWD,
            oldPath,
            AT_FDCWD,
            newPath,
            UInt32(RENAME_NOREPLACE)
        )

        if result == 0 {
            return
        }

        let code = Kernel.Error.Code.captureErrno()
        switch code.posix {
        case EEXIST:
            throw .exists
        case ENOSYS, EINVAL, EOPNOTSUPP:
            // renameat2 not available, fall back to link+unlink
            try linkUnlinkFallback(from: oldPath, to: newPath)
        case EPERM:
            // EPERM could be permission error OR filesystem rejecting flag
            // Try fallback first
            do {
                try linkUnlinkFallback(from: oldPath, to: newPath)
            } catch {
                // Fallback also failed - report original EPERM
                throw .permission(code)
            }
        case EACCES:
            throw .permission(code)
        default:
            throw .platform(code)
        }
        #else
        // No CLinuxShim, use link+unlink fallback directly
        try linkUnlinkFallback(from: oldPath, to: newPath)
        #endif
    }

    /// Atomically exchanges two files.
    ///
    /// Uses `renameat2` with `RENAME_EXCHANGE` flag on Linux.
    /// Both paths must exist.
    ///
    /// - Parameters:
    ///   - path1: First path.
    ///   - path2: Second path.
    /// - Throws: `ExtendedError` on failure.
    public static func exchange(
        _ path1: UnsafePointer<CChar>,
        _ path2: UnsafePointer<CChar>
    ) throws(Extended.Error) {
        #if canImport(CLinuxShim)
        let result = swift_renameat2(
            AT_FDCWD,
            path1,
            AT_FDCWD,
            path2,
            UInt32(RENAME_EXCHANGE)
        )

        guard result == 0 else {
            let code = Kernel.Error.Code.captureErrno()
            switch code.posix {
            case ENOSYS, EINVAL, EOPNOTSUPP:
                throw .notSupported
            case EPERM, EACCES:
                throw .permission(code)
            default:
                throw .platform(code)
            }
        }
        #else
        throw .notSupported
        #endif
    }

    /// Fallback implementation using link + unlink.
    ///
    /// - link() is atomic and fails with EEXIST if dest exists
    /// - unlink() removes the source name after successful link
    private static func linkUnlinkFallback(
        from oldPath: UnsafePointer<CChar>,
        to newPath: UnsafePointer<CChar>
    ) throws(Extended.Error) {
        #if canImport(Musl)
        let linkResult = Musl.link(oldPath, newPath)
        #else
        let linkResult = Glibc.link(oldPath, newPath)
        #endif

        guard linkResult == 0 else {
            let code = Kernel.Error.Code.captureErrno()
            switch code.posix {
            case EEXIST:
                throw .exists
            case EPERM, EACCES:
                throw .permission(code)
            default:
                throw .platform(code)
            }
        }

        // Both names now point to same inode
        // Remove the old name; new name remains
        #if canImport(Musl)
        _ = Musl.unlink(oldPath)  // Ignore errors - write succeeded
        #else
        _ = Glibc.unlink(oldPath)  // Ignore errors - write succeeded
        #endif
    }
}

#endif
