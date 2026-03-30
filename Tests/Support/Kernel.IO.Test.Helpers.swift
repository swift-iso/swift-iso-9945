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

    public import Kernel_Primitives
    public import ISO_9945
    public import ISO_9945_Kernel

    /// Test utilities for I/O operations.
    ///
    /// With borrowing `close()`, tests manage descriptors directly:
    /// ```swift
    /// let path = KernelIOTest.makeTempPath()
    /// let fd = try KernelIOTest.open(at: path)
    /// defer { KernelIOTest.cleanup(path: path, fd: fd) }
    /// // ... use fd ...
    /// ```
    public enum KernelIOTest {
        /// Generates a unique temporary file path.
        public static func makeTempPath(prefix: Swift.String = "io-test") -> Swift.String {
            ISO_9945.Kernel.Temporary.filePath(prefix: prefix)
        }

        /// Opens a new file at the given path for read/write.
        public static func open(at path: Swift.String) throws -> Kernel.Descriptor {
            try ISO_9945.Kernel.Path.scope(path) { p in
                try ISO_9945.Kernel.File.Open.open(
                    path: p,
                    mode: .readWrite,
                    options: [.create, .truncate, .exclusive],
                    permissions: .ownerReadWrite
                )
            }
        }

        /// Writes string content to a descriptor.
        public static func write(_ content: Swift.String, to fd: borrowing Kernel.Descriptor) {
            var bytes = Array(content.utf8)
            _ = try? bytes.withUnsafeMutableBytes { ptr in
                try ISO_9945.Kernel.IO.Write.write(fd, from: UnsafeRawBufferPointer(ptr))
            }
        }

        /// Closes a descriptor and deletes the file. Safe for defer blocks.
        public static func cleanup(path: Swift.String, fd: borrowing Kernel.Descriptor) {
            try? ISO_9945.Kernel.Close.close(fd)
            try? ISO_9945.Kernel.Path.scope(path) { p in
                try ISO_9945.Kernel.File.Delete.delete(p)
            }
        }
    }

#endif
