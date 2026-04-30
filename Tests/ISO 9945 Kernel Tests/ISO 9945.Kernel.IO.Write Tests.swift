// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
@_spi(Syscall) import Kernel_File_Primitives
@_spi(Syscall) import Path_Primitives
@_spi(Syscall) import Error_Primitives
// Tests use Apple native Testing framework
import Testing

@testable import ISO_9945_Kernel

extension Kernel.IO.Write {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Write Tests


    extension Kernel.IO.Write.Test.Unit {
        @Test
        func `write writes bytes to file`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "write-test")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }

            let content = Array("Hello, World!".utf8)
            let bytesWritten = try content.withUnsafeBytes { ptr in
                try Kernel.IO.Write.write(fd, from: ptr)
            }

            #expect(bytesWritten == 13)

            // Verify by reading back
            _ = try Kernel.File.Seek.seek(fd, offset: 0, whence: .start)
            var buffer = [UInt8](repeating: 0, count: 13)
            _ = try buffer.withUnsafeMutableBytes { ptr in
                try Kernel.IO.Read.read(fd, into: ptr)
            }
            #expect(Swift.String(decoding: buffer, as: UTF8.self) == "Hello, World!")
        }

        @Test
        func `write with empty buffer returns 0`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "write-test")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }

            let emptyBuffer = UnsafeRawBufferPointer(start: nil, count: 0)
            let bytesWritten = try Kernel.IO.Write.write(fd, from: emptyBuffer)

            #expect(bytesWritten == 0)
        }

        @Test
        func `write advances file position`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "write-test")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }

            let initialPos = try Kernel.File.Seek.tell(fd)

            let content = Array("12345".utf8)
            _ = try content.withUnsafeBytes { ptr in
                try Kernel.IO.Write.write(fd, from: ptr)
            }

            let finalPos = try Kernel.File.Seek.tell(fd)
            #expect(finalPos == initialPos + 5)
        }

        @Test
        func `multiple writes append correctly`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "write-test")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }

            let first = Array("First".utf8)
            let second = Array("Second".utf8)

            _ = try first.withUnsafeBytes { try Kernel.IO.Write.write(fd, from: $0) }
            _ = try second.withUnsafeBytes { try Kernel.IO.Write.write(fd, from: $0) }

            // Verify combined content
            _ = try Kernel.File.Seek.seek(fd, offset: 0, whence: .start)
            var buffer = [UInt8](repeating: 0, count: 11)
            _ = try buffer.withUnsafeMutableBytes { ptr in
                try Kernel.IO.Read.read(fd, into: ptr)
            }
            #expect(Swift.String(decoding: buffer, as: UTF8.self) == "FirstSecond")
        }

        @Test
        func `pwrite writes at offset without changing position`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "write-test")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }

            // Write initial content
            let initial = Array("XXXXXXXXXX".utf8)
            _ = try initial.withUnsafeBytes { try Kernel.IO.Write.write(fd, from: $0) }

            // Record position after write
            let posAfterWrite = try Kernel.File.Seek.tell(fd)

            // pwrite "ABC" at offset 3
            let patch = Array("ABC".utf8)
            let bytesWritten = try patch.withUnsafeBytes { ptr in
                try Kernel.IO.Write.pwrite(fd, from: ptr, at: Kernel.File.Offset(3))
            }

            #expect(bytesWritten == 3)

            // Position should be unchanged
            let posAfterPwrite = try Kernel.File.Seek.tell(fd)
            #expect(posAfterPwrite == posAfterWrite)

            // Verify content
            _ = try Kernel.File.Seek.seek(fd, offset: 0, whence: .start)
            var buffer = [UInt8](repeating: 0, count: 10)
            _ = try buffer.withUnsafeMutableBytes { ptr in
                try Kernel.IO.Read.read(fd, into: ptr)
            }
            #expect(Swift.String(decoding: buffer, as: UTF8.self) == "XXXABCXXXX")
        }

        @Test
        func `pwrite with empty buffer returns 0`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "write-test")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }

            let emptyBuffer = UnsafeRawBufferPointer(start: nil, count: 0)
            let bytesWritten = try Kernel.IO.Write.pwrite(fd, from: emptyBuffer, at: Kernel.File.Offset(0))

            #expect(bytesWritten == 0)
        }

        @Test
        func `pwrite can extend file`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "write-test")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }

            // Write at offset 10 in empty file
            let content = Array("End".utf8)
            let bytesWritten = try content.withUnsafeBytes { ptr in
                try Kernel.IO.Write.pwrite(fd, from: ptr, at: Kernel.File.Offset(10))
            }

            #expect(bytesWritten == 3)

            // File should be 13 bytes (10 zeros + "End")
            let size = try Kernel.File.Seek.seek(fd, offset: 0, whence: .end)
            #expect(size == 13)
        }
    }

    // MARK: - Error Tests

    extension Kernel.IO.Write.Test.EdgeCase {
        @Test
        func `write throws on invalid descriptor`() {
            let content = Array("test".utf8)

            #expect(throws: Kernel.IO.Write.Error.self) {
                try content.withUnsafeBytes { ptr in
                    try Kernel.IO.Write.write(Kernel.Descriptor(_rawValue: -1), from: ptr)
                }
            }
        }

        @Test
        func `pwrite throws on invalid descriptor`() {
            let content = Array("test".utf8)

            #expect(throws: Kernel.IO.Write.Error.self) {
                try content.withUnsafeBytes { ptr in
                    try Kernel.IO.Write.pwrite(Kernel.Descriptor(_rawValue: -1), from: ptr, at: Kernel.File.Offset(0))
                }
            }
        }
    }

