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

#if !os(Windows)

@_spi(Syscall) public import Kernel_Primitives
public import ISO_9945

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
    internal import CLinuxShim
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Linux FICLONE Implementation

#if os(Linux)

extension ISO_9945.Kernel.Copy.Clone {
    /// Clones a file using FICLONE ioctl, creating a copy-on-write duplicate.
    ///
    /// Both files share the same data blocks until one is modified, making this
    /// extremely fast for large files on supported filesystems.
    ///
    /// ## Threading
    /// This call blocks until the clone operation completes. The clone is atomic
    /// from the filesystem's perspective.
    ///
    /// ## Filesystem Support
    /// Only works on filesystems with reflink capability:
    /// - Btrfs (full support)
    /// - XFS (with reflink enabled)
    ///
    /// ## Errors
    /// - ``Kernel/Copy/Error/invalidDescriptor``: Source or destination is invalid
    /// - ``Kernel/Copy/Error/unsupported``: Filesystem doesn't support FICLONE
    /// - ``Kernel/Copy/Error/crossDevice``: Source and destination on different filesystems
    /// - ``Kernel/Copy/Error/notEmpty``: Destination file is not empty
    ///
    /// - Parameters:
    ///   - source: Source file descriptor (open for reading).
    ///   - destination: Destination file descriptor (must be empty, open for writing).
    /// - Throws: ``Kernel/Copy/Error`` on failure.

    public static func perform(
        from source: Kernel.Descriptor,
        to destination: Kernel.Descriptor
    ) throws(Kernel.Copy.Error) {
        guard source.isValid else { throw .invalid }
        guard destination.isValid else { throw .invalid }

        let result = swift_ficlone(destination._rawValue, source._rawValue)
        guard result == 0 else {
            throw Kernel.Copy.Error(posixErrno: errno)
        }
    }
}

#endif

// MARK: - macOS clonefile Implementation

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

extension ISO_9945.Kernel.Copy.Clone {
    /// Clones a file using clonefile(2), creating a copy-on-write duplicate.
    ///
    /// Both files share the same data blocks until one is modified, making this
    /// extremely fast for large files on APFS.
    ///
    /// ## Threading
    /// This call blocks until the clone operation completes. The clone is atomic.
    ///
    /// ## Filesystem Support
    /// Only works on APFS. Falls back to regular copy on HFS+ or other filesystems.
    ///
    /// ## Errors
    /// - ``Kernel/Copy/Error/notFound``: Source file doesn't exist
    /// - ``Kernel/Copy/Error/exists``: Destination path already exists
    /// - ``Kernel/Copy/Error/permission``: Insufficient permissions
    /// - ``Kernel/Copy/Error/unsupported``: Filesystem doesn't support clonefile
    ///
    /// - Parameters:
    ///   - sourcePath: Path to source file.
    ///   - destPath: Path for destination file (must not exist).
    /// - Throws: ``Kernel/Copy/Error`` on failure.

    public static func file(
        from sourcePath: borrowing Kernel.Path,
        to destPath: borrowing Kernel.Path
    ) throws(Kernel.Copy.Error) {
        let srcCString = UnsafeRawPointer(sourcePath.unsafeCString).assumingMemoryBound(to: CChar.self)
        let dstCString = UnsafeRawPointer(destPath.unsafeCString).assumingMemoryBound(to: CChar.self)

        let result = Darwin.clonefile(srcCString, dstCString, 0)
        guard result == 0 else {
            throw Kernel.Copy.Error(posixErrno: errno)
        }
    }
}

#endif

#endif
