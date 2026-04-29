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
import Algebra_Primitives

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
    /// - Throws: `Either<Error, Interrupt>` — `.left` for domain errors,
    ///   `.right(.occurred)` for EINTR.
    ///
    /// ## See Also
    /// - ``POSIX/Kernel/File/Handle/writeAll(from:)`` — L3 partial-IO
    ///   convenience that loops this method in swift-posix, surfacing EINTR
    ///   identically to this method.
    public borrowing func write(
        from buffer: UnsafeRawBufferPointer
    ) throws(Either<Error, Interrupt>) -> Int {
        do {
            return try unsafe ISO_9945.Kernel.IO.Write.write(descriptor, from: buffer)
        } catch {
            if error.code.isInterrupted {
                throw .right(.occurred)
            }
            throw .left(Error(from: error, operation: .write))
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
    /// - Throws: `Either<Error, Interrupt>` — `.left` for domain errors,
    ///   `.right(.occurred)` for EINTR.
    public borrowing func pwrite(
        from buffer: UnsafeRawBufferPointer,
        at offset: Kernel.File.Offset
    ) throws(Either<Error, Interrupt>) -> Int {
        do {
            return try unsafe ISO_9945.Kernel.IO.Write.pwrite(descriptor, from: buffer, at: offset)
        } catch {
            if error.code.isInterrupted {
                throw .right(.occurred)
            }
            throw .left(Error(from: error, operation: .write))
        }
    }
}

// MARK: - Span Adapters

extension Kernel.File.Handle {
    /// Writes bytes from a span to the file at the current offset.
    ///
    /// - Parameter span: The span containing bytes to write.
    /// - Returns: Number of bytes written.
    /// - Throws: `Either<Error, Interrupt>` — `.left` for domain errors,
    ///   `.right(.occurred)` for EINTR.
    ///
    /// ## See Also
    /// - ``POSIX/Kernel/File/Handle/writeAll(from:)`` — L3 partial-IO
    ///   convenience that loops this method in swift-posix, surfacing EINTR
    ///   identically to this method.
    public borrowing func write(
        from span: Span<UInt8>
    ) throws(Either<Error, Interrupt>) -> Int {
        do {
            return try ISO_9945.Kernel.IO.Write.write(descriptor, from: span)
        } catch {
            if error.code.isInterrupted {
                throw .right(.occurred)
            }
            throw .left(Error(from: error, operation: .write))
        }
    }

    /// Writes bytes from a span at a specific offset.
    ///
    /// - Parameters:
    ///   - span: The span containing bytes to write.
    ///   - offset: The file offset to write at.
    /// - Returns: Number of bytes written.
    /// - Throws: `Either<Error, Interrupt>` — `.left` for domain errors,
    ///   `.right(.occurred)` for EINTR.
    public borrowing func pwrite(
        from span: Span<UInt8>,
        at offset: Kernel.File.Offset
    ) throws(Either<Error, Interrupt>) -> Int {
        do {
            return try ISO_9945.Kernel.IO.Write.pwrite(descriptor, from: span, at: offset)
        } catch {
            if error.code.isInterrupted {
                throw .right(.occurred)
            }
            throw .left(Error(from: error, operation: .write))
        }
    }
}
