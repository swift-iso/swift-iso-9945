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
internal import ISO_9945_ABI

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
    internal import CLinuxShim
#elseif canImport(Musl)
    internal import Musl
#endif

internal import ISO_9899_Core

// MARK: - Capability Probing

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

extension ISO_9945.Kernel.File.Clone.Capability {
    /// Probes whether the filesystem at the given path supports cloning.
    public static func probe(at path: borrowing Kernel.Path.View) throws(Kernel.File.Clone.Error.Syscall) -> Kernel.File.Clone.Capability {
        try unsafe path.withUnsafePointer { cString throws(Kernel.File.Clone.Error.Syscall) in
            var statfsBuf = Darwin.statfs()
            let result = unsafe statfs(UnsafePointer<CChar>(cString), &statfsBuf)

            guard result == 0 else {
                throw Kernel.File.Clone.Error.Syscall.platform(code: .posix(errno), operation: .statfs)
            }

            // APFS supports cloning
            let isAPFS = unsafe withUnsafeBytes(of: statfsBuf.f_fstypename) { buf in
                unsafe ISO_9899.String.Comparison.equals(
                    buf.baseAddress!.assumingMemoryBound(to: ISO_9899.String.Char.self),
                    "apfs"
                )
            }
            if isAPFS {
                return .reflink
            }

            return .none
        }
    }
}

#elseif os(Linux)

extension ISO_9945.Kernel.File.Clone.Capability {
    /// Probes whether the filesystem at the given path supports cloning.
    public static func probe(at path: borrowing Kernel.Path.View) throws(Kernel.File.Clone.Error.Syscall) -> Kernel.File.Clone.Capability {
        try unsafe path.withUnsafePointer { cString throws(Kernel.File.Clone.Error.Syscall) in
            var statfsBuf = statfs()
            let result = statfs(UnsafePointer<CChar>(cString), &statfsBuf)

            guard result == 0 else {
                throw Kernel.File.Clone.Error.Syscall.platform(code: .posix(errno), operation: .statfs)
            }

            // Known filesystems that support FICLONE
            // Btrfs: 0x9123683E
            // XFS: 0x58465342 (with reflink enabled)
            let fsMagic = statfsBuf.f_type
            if fsMagic == 0x9123683E || fsMagic == 0x58465342 {
                return .reflink
            }

            return .none
        }
    }
}

#endif

// MARK: - File Size Operations

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

extension ISO_9945.Kernel.File.Clone.Metadata {
    /// Gets the size of a file.
    public static func size(at path: borrowing Kernel.Path.View) throws(Kernel.File.Clone.Error.Syscall) -> Int {
        try unsafe path.withUnsafePointer { cString throws(Kernel.File.Clone.Error.Syscall) in
            var statBuf = Darwin.stat()
            let result = unsafe stat(UnsafePointer<CChar>(cString), &statBuf)

            guard result == 0 else {
                throw Kernel.File.Clone.Error.Syscall.platform(code: .posix(errno), operation: .stat)
            }

            return Int(statBuf.st_size)
        }
    }
}

#elseif os(Linux)

extension ISO_9945.Kernel.File.Clone.Metadata {
    /// Gets the size of a file.
    public static func size(at path: borrowing Kernel.Path.View) throws(Kernel.File.Clone.Error.Syscall) -> Int {
        try unsafe path.withUnsafePointer { cString throws(Kernel.File.Clone.Error.Syscall) in
            var statBuf = Glibc.stat()
            let result = stat(UnsafePointer<CChar>(cString), &statBuf)

            guard result == 0 else {
                throw Kernel.File.Clone.Error.Syscall.platform(code: .posix(errno), operation: .stat)
            }

            return Int(statBuf.st_size)
        }
    }
}

#endif

// MARK: - macOS clonefile Implementation

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

extension ISO_9945.Kernel.File.Clone {
    /// macOS clonefile() operations.
    public enum Clonefile {
        /// Attempts to clone a file using clonefile().
        ///
        /// - Parameters:
        ///   - source: Source file path.
        ///   - destination: Destination file path.
        /// - Returns: `true` if cloned, `false` if not supported.
        /// - Throws: `Kernel.File.Clone.Error.Syscall` for other errors.
        public static func attempt(
            source: borrowing Kernel.Path.View,
            destination: borrowing Kernel.Path.View
        ) throws(Kernel.File.Clone.Error.Syscall) -> Bool {
            try unsafe source.withUnsafePointer { srcCString throws(Kernel.File.Clone.Error.Syscall) in
                try unsafe destination.withUnsafePointer { dstCString throws(Kernel.File.Clone.Error.Syscall) in
                    let result = unsafe clonefile(UnsafePointer<CChar>(srcCString), UnsafePointer<CChar>(dstCString), 0)

                    if result == 0 {
                        return true
                    }

                    let err = errno
                    // ENOTSUP means filesystem doesn't support cloning
                    if err == ENOTSUP {
                        return false
                    }

                    throw Kernel.File.Clone.Error.Syscall.platform(code: .posix(err), operation: .clonefile)
                }
            }
        }
    }

    /// macOS copyfile() operations.
    public enum Copyfile {
        /// Copies a file using copyfile() with COPYFILE_CLONE flag.
        ///
        /// This attempts CoW clone first, falls back to copy.
        public static func clone(
            source: borrowing Kernel.Path.View,
            destination: borrowing Kernel.Path.View
        ) throws(Kernel.File.Clone.Error.Syscall) {
            try unsafe source.withUnsafePointer { srcCString throws(Kernel.File.Clone.Error.Syscall) in
                try unsafe destination.withUnsafePointer { dstCString throws(Kernel.File.Clone.Error.Syscall) in
                    let srcPtr = unsafe UnsafePointer<CChar>(srcCString)
                    let dstPtr = unsafe UnsafePointer<CChar>(dstCString)

                    // Check if destination exists first (copyfile doesn't fail by default)
                    var statBuf = Darwin.stat()
                    let destExists = unsafe (stat(dstPtr, &statBuf) == 0)
                    if destExists {
                        throw Kernel.File.Clone.Error.Syscall.platform(code: .posix(EEXIST), operation: .copyfile)
                    }

                    let result = unsafe copyfile(srcPtr, dstPtr, nil, copyfile_flags_t(COPYFILE_CLONE | COPYFILE_ALL))

                    guard result == 0 else {
                        throw Kernel.File.Clone.Error.Syscall.platform(code: .posix(errno), operation: .copyfile)
                    }
                }
            }
        }

        /// Copies a file using copyfile() without clone attempt.
        public static func data(
            source: borrowing Kernel.Path.View,
            destination: borrowing Kernel.Path.View
        ) throws(Kernel.File.Clone.Error.Syscall) {
            try unsafe source.withUnsafePointer { srcCString throws(Kernel.File.Clone.Error.Syscall) in
                try unsafe destination.withUnsafePointer { dstCString throws(Kernel.File.Clone.Error.Syscall) in
                    let srcPtr = unsafe UnsafePointer<CChar>(srcCString)
                    let dstPtr = unsafe UnsafePointer<CChar>(dstCString)

                    // Check if destination exists first (copyfile doesn't fail by default)
                    var statBuf = Darwin.stat()
                    let destExists = unsafe (stat(dstPtr, &statBuf) == 0)
                    if destExists {
                        throw Kernel.File.Clone.Error.Syscall.platform(code: .posix(EEXIST), operation: .copyfile)
                    }

                    let result = unsafe copyfile(srcPtr, dstPtr, nil, copyfile_flags_t(COPYFILE_DATA))

                    guard result == 0 else {
                        throw Kernel.File.Clone.Error.Syscall.platform(code: .posix(errno), operation: .copyfile)
                    }
                }
            }
        }
    }
}

#endif

// MARK: - Linux FICLONE Implementation

#if os(Linux)

// ioctl request code for FICLONE
private let FICLONE: UInt = 0x4004_9409

extension ISO_9945.Kernel.File.Clone {
    /// Linux FICLONE operations.
    public enum Ficlone {
        /// Attempts to clone a file using ioctl(FICLONE).
        ///
        /// - Parameters:
        ///   - source: Source file descriptor.
        ///   - destination: Destination file descriptor.
        /// - Returns: `true` if cloned, `false` if not supported.
        /// - Throws: `Kernel.File.Clone.Error.Syscall` for other errors.
        public static func attempt(
            source: borrowing Kernel.Descriptor,
            destination: borrowing Kernel.Descriptor
        ) throws(Kernel.File.Clone.Error.Syscall) -> Bool {
            let result = ioctl(destination._rawValue, FICLONE, source._rawValue)

            if result == 0 {
                return true
            }

            let err = errno
            // EOPNOTSUPP/ENOTSUP means filesystem doesn't support cloning
            if err == EOPNOTSUPP || err == ENOTSUP || err == EINVAL || err == EXDEV {
                return false
            }

            throw .platform(code: .posix(err), operation: .ficlone)
        }
    }

    /// Linux copy_file_range operations.
    public enum CopyRange {
        /// Copies file data using copy_file_range().
        ///
        /// This may use server-side copy or reflink on supported filesystems.
        public static func copy(
            source: borrowing Kernel.Descriptor,
            destination: borrowing Kernel.Descriptor,
            length: Int
        ) throws(Kernel.File.Clone.Error.Syscall) {
            var remaining = Kernel.File.Size(length)
            var srcOffset = Kernel.File.Offset(0)
            var dstOffset = Kernel.File.Offset(0)

            while remaining > .zero {
                let copied: Kernel.File.Size
                do {
                    copied = try ISO_9945.Kernel.Copy.Range.copy(
                        from: source,
                        sourceOffset: &srcOffset,
                        to: destination,
                        destOffset: &dstOffset,
                        length: remaining
                    )
                } catch {
                    throw .platform(code: .posix(errno), operation: .copyFileRange)
                }

                if copied == .zero {
                    break  // EOF
                }

                remaining -= copied
            }
        }
    }
}

#endif

#endif
