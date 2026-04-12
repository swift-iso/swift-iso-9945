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
import Kernel_Outcome_Primitives
import Algebra_Primitives

// MARK: - POSIX read operations on Kernel.File.Handle

extension Kernel.File.Handle {
    /// Reads bytes from the file at the current offset.
    ///
    /// For Direct I/O handles, validates buffer alignment before the syscall.
    /// The file offset advances by the number of bytes read.
    ///
    /// - Parameter buffer: The buffer to read into.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Either<Error, Kernel.Interrupt>` — `.left` for domain errors,
    ///   `.right(.occurred)` for EINTR.
    public borrowing func read(
        into buffer: UnsafeMutableRawBufferPointer
    ) throws(Either<Error, Kernel.Interrupt>) -> Int {
        do {
            return try unsafe ISO_9945.Kernel.IO.Read.read(descriptor, into: buffer)
        } catch {
            if error.code.isInterrupted {
                throw .right(.occurred)
            }
            throw .left(Error(from: error, operation: .read))
        }
    }

    /// Reads bytes from the file at a specific offset without changing the file position.
    ///
    /// For Direct I/O handles, validates buffer and offset alignment before the syscall.
    /// The file position is not modified. Safe for concurrent reads on non-overlapping regions.
    ///
    /// - Parameters:
    ///   - buffer: The buffer to read into.
    ///   - offset: The file offset to read from.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Either<Error, Kernel.Interrupt>` — `.left` for domain errors,
    ///   `.right(.occurred)` for EINTR.
    public borrowing func pread(
        into buffer: UnsafeMutableRawBufferPointer,
        at offset: Kernel.File.Offset
    ) throws(Either<Error, Kernel.Interrupt>) -> Int {
        do {
            return try unsafe ISO_9945.Kernel.IO.Read.pread(descriptor, into: buffer, at: offset)
        } catch {
            if error.code.isInterrupted {
                throw .right(.occurred)
            }
            throw .left(Error(from: error, operation: .read))
        }
    }
}

// MARK: - Span Adapters

extension Kernel.File.Handle {
    /// Reads bytes from the file at the current offset into a mutable span.
    ///
    /// - Parameter span: The mutable span to read into.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Either<Error, Kernel.Interrupt>` — `.left` for domain errors,
    ///   `.right(.occurred)` for EINTR.
    public borrowing func read(
        into span: inout MutableSpan<UInt8>
    ) throws(Either<Error, Kernel.Interrupt>) -> Int {
        do {
            return try ISO_9945.Kernel.IO.Read.read(descriptor, into: &span)
        } catch {
            if error.code.isInterrupted {
                throw .right(.occurred)
            }
            throw .left(Error(from: error, operation: .read))
        }
    }

    /// Reads bytes from the file at a specific offset into a mutable span.
    ///
    /// - Parameters:
    ///   - span: The mutable span to read into.
    ///   - offset: The file offset to read from.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Either<Error, Kernel.Interrupt>` — `.left` for domain errors,
    ///   `.right(.occurred)` for EINTR.
    public borrowing func pread(
        into span: inout MutableSpan<UInt8>,
        at offset: Kernel.File.Offset
    ) throws(Either<Error, Kernel.Interrupt>) -> Int {
        do {
            return try ISO_9945.Kernel.IO.Read.pread(descriptor, into: &span, at: offset)
        } catch {
            if error.code.isInterrupted {
                throw .right(.occurred)
            }
            throw .left(Error(from: error, operation: .read))
        }
    }
}
