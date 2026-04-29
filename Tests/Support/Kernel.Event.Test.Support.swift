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

public import Kernel_Primitives_Core
public import Kernel_Descriptor_Primitives
public import Kernel_Event_Primitives
public import Kernel_File_Primitives
public import Path_Primitives
public import Kernel_Process_Primitives
public import Error_Primitives
public import ISO_9945_Kernel
public import ISO_9945_Kernel

extension Kernel.Event {
    /// Test utilities for eventing operations (kqueue, epoll, io_uring).
    public enum Test {
        /// Error thrown when pipe creation fails.
        public struct PipeError: Swift.Error, Sendable {
            public init() {}
        }

        /// Creates a pipe, returning (read, write) descriptors.
        ///
        /// - Returns: Tuple of (read descriptor, write descriptor)
        /// - Throws: `PipeError` if pipe creation fails
        public static func makePipe() throws -> ISO_9945.Kernel.Pipe.Descriptors {
            do {
                return try ISO_9945.Kernel.Pipe.pipe()
            } catch {
                throw PipeError()
            }
        }

        /// Writes one byte to a descriptor.
        public static func writeByte(_ fd: borrowing Kernel.Descriptor, value: UInt8 = 1) {
            var byte = value
            _ = withUnsafeBytes(of: &byte) { buffer in
                try? ISO_9945.Kernel.IO.Write.write(fd, from: buffer)
            }
        }

        /// Drains one byte from a descriptor.
        public static func readDrain(_ fd: borrowing Kernel.Descriptor) {
            var byte: UInt8 = 0
            _ = withUnsafeMutableBytes(of: &byte) { buffer in
                try? ISO_9945.Kernel.IO.Read.read(fd, into: buffer)
            }
        }
    }
}
