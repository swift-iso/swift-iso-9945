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
@_spi(Syscall) import Kernel_IO_Primitives

// MARK: - POSIX write operations on Kernel.File.Handle

extension Kernel.File.Handle {
    /// Writes bytes to the file at the current offset.
    ///
    /// For Direct I/O handles, validates buffer alignment before the syscall.
    /// May return fewer bytes than `buffer.count` (partial write). The file
    /// offset advances by the number of bytes written.
    ///
    /// - Parameter buffer: The buffer to write from.
    /// - Returns: Number of bytes written.
    /// - Throws: `Kernel.File.Handle.Error` on failure or alignment violation.
    public borrowing func write(
        from buffer: UnsafeRawBufferPointer
    ) throws(Error) -> Int {
        do {
            return try unsafe ISO_9945.Kernel.IO.Write.write(descriptor, from: buffer)
        } catch {
            throw Error(from: error, operation: .write)
        }
    }

    /// Writes bytes to the file at a specific offset without changing the file position.
    ///
    /// For Direct I/O handles, validates buffer and offset alignment before the syscall.
    /// May return fewer bytes than `buffer.count` (partial write). The file position
    /// is not modified. Safe for concurrent writes on non-overlapping regions.
    ///
    /// - Parameters:
    ///   - buffer: The buffer to write from.
    ///   - offset: The file offset to write at.
    /// - Returns: Number of bytes written.
    /// - Throws: `Kernel.File.Handle.Error` on failure or alignment violation.
    public borrowing func pwrite(
        from buffer: UnsafeRawBufferPointer,
        at offset: Kernel.File.Offset
    ) throws(Error) -> Int {
        do {
            return try unsafe ISO_9945.Kernel.IO.Write.pwrite(descriptor, from: buffer, at: offset)
        } catch {
            throw Error(from: error, operation: .write)
        }
    }
}

// MARK: - Write All

extension Kernel.File.Handle {
    /// Writes all bytes to the file, handling partial writes.
    ///
    /// Loops until all bytes are written or an error occurs.
    ///
    /// - Parameter buffer: The buffer to write from.
    /// - Throws: `Kernel.File.Handle.Error` on failure.
    public borrowing func writeAll(
        from buffer: UnsafeRawBufferPointer
    ) throws(Error) {
        do {
            try unsafe ISO_9945.Kernel.IO.Write.writeAll(descriptor, from: buffer)
        } catch {
            throw Error(from: error, operation: .write)
        }
    }
}

// MARK: - Span Adapters

extension Kernel.File.Handle {
    /// Writes bytes from a span to the file at the current offset.
    ///
    /// - Parameter span: The span containing bytes to write.
    /// - Returns: Number of bytes written.
    /// - Throws: `Kernel.File.Handle.Error` on failure.
    public borrowing func write(
        from span: Span<UInt8>
    ) throws(Error) -> Int {
        do {
            return try ISO_9945.Kernel.IO.Write.write(descriptor, from: span)
        } catch {
            throw Error(from: error, operation: .write)
        }
    }

    /// Writes bytes from a span at a specific offset.
    ///
    /// - Parameters:
    ///   - span: The span containing bytes to write.
    ///   - offset: The file offset to write at.
    /// - Returns: Number of bytes written.
    /// - Throws: `Kernel.File.Handle.Error` on failure.
    public borrowing func pwrite(
        from span: Span<UInt8>,
        at offset: Kernel.File.Offset
    ) throws(Error) -> Int {
        do {
            return try ISO_9945.Kernel.IO.Write.pwrite(descriptor, from: span, at: offset)
        } catch {
            throw Error(from: error, operation: .write)
        }
    }

    /// Writes all bytes from a span to the file.
    ///
    /// - Parameter span: The span containing bytes to write.
    /// - Throws: `Kernel.File.Handle.Error` on failure.
    public borrowing func writeAll(
        from span: Span<UInt8>
    ) throws(Error) {
        do {
            try ISO_9945.Kernel.IO.Write.writeAll(descriptor, from: span)
        } catch {
            throw Error(from: error, operation: .write)
        }
    }
}
