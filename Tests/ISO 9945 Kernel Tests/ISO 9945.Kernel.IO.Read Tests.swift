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
@_spi(Syscall) import Path_Primitives
@_spi(Syscall) import Error_Primitives
// Tests use Apple native Testing framework
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.IO.Read {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Read Tests


    extension ISO_9945.Kernel.IO.Read.Test.Unit {
        @Test
        func `read returns bytes from file`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "read-test")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }
            KernelIOTest.write("Hello, World!", to: fd)

            // Seek to start
            _ = try ISO_9945.Kernel.File.Seek.seek(fd, offset: 0, whence: .start)

            var buffer = [UInt8](repeating: 0, count: 13)
            let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
                try ISO_9945.Kernel.IO.Read.read(fd, into: ptr)
            }

            #expect(bytesRead == 13)
            #expect(Swift.String(decoding: buffer, as: UTF8.self) == "Hello, World!")
        }

        @Test
        func `read returns 0 on EOF`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "read-test")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }
            KernelIOTest.write("Hi", to: fd)

            // Seek to start and read all content
            _ = try ISO_9945.Kernel.File.Seek.seek(fd, offset: 0, whence: .start)
            var buffer = [UInt8](repeating: 0, count: 10)
            _ = try buffer.withUnsafeMutableBytes { ptr in
                try ISO_9945.Kernel.IO.Read.read(fd, into: ptr)
            }

            // Now at EOF, next read should return 0
            let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
                try ISO_9945.Kernel.IO.Read.read(fd, into: ptr)
            }

            #expect(bytesRead == 0)
        }

        @Test
        func `read with empty buffer returns 0`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "read-test")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }
            KernelIOTest.write("content", to: fd)

            let emptyBuffer = UnsafeMutableRawBufferPointer(start: nil, count: 0)
            let bytesRead = try ISO_9945.Kernel.IO.Read.read(fd, into: emptyBuffer)

            #expect(bytesRead == 0)
        }

        @Test
        func `read partial buffer`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "read-test")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }
            KernelIOTest.write("Short", to: fd)

            _ = try ISO_9945.Kernel.File.Seek.seek(fd, offset: 0, whence: .start)

            // Request more bytes than available
            var buffer = [UInt8](repeating: 0, count: 100)
            let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
                try ISO_9945.Kernel.IO.Read.read(fd, into: ptr)
            }

            #expect(bytesRead == 5)
            #expect(Swift.String(decoding: buffer.prefix(5), as: UTF8.self) == "Short")
        }

        @Test
        func `pread reads at offset without changing position`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "read-test")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }
            KernelIOTest.write("0123456789", to: fd)

            // Record initial position
            let initialPos = try ISO_9945.Kernel.File.Seek.tell(fd)

            // Read 3 bytes starting at offset 5
            var buffer = [UInt8](repeating: 0, count: 3)
            let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
                try ISO_9945.Kernel.IO.Read.pread(fd, into: ptr, at: ISO_9945.Kernel.File.Offset(5))
            }

            #expect(bytesRead == 3)
            #expect(Swift.String(decoding: buffer, as: UTF8.self) == "567")

            // Position should be unchanged
            let finalPos = try ISO_9945.Kernel.File.Seek.tell(fd)
            #expect(finalPos == initialPos)
        }

        @Test
        func `pread at end of file returns 0`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "read-test")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }
            KernelIOTest.write("data", to: fd)

            var buffer = [UInt8](repeating: 0, count: 10)
            let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
                try ISO_9945.Kernel.IO.Read.pread(fd, into: ptr, at: ISO_9945.Kernel.File.Offset(100))
            }

            #expect(bytesRead == 0)
        }

        @Test
        func `pread with empty buffer returns 0`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "read-test")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }
            KernelIOTest.write("content", to: fd)

            let emptyBuffer = UnsafeMutableRawBufferPointer(start: nil, count: 0)
            let bytesRead = try ISO_9945.Kernel.IO.Read.pread(fd, into: emptyBuffer, at: ISO_9945.Kernel.File.Offset(0))

            #expect(bytesRead == 0)
        }
    }

    // MARK: - Error Tests

    extension ISO_9945.Kernel.IO.Read.Test.EdgeCase {
        @Test
        func `read throws on invalid descriptor`() {
            var buffer = [UInt8](repeating: 0, count: 10)

            #expect(throws: ISO_9945.Kernel.IO.Read.Error.self) {
                try buffer.withUnsafeMutableBytes { ptr in
                    try ISO_9945.Kernel.IO.Read.read(ISO_9945.Kernel.Descriptor(_rawValue: -1), into: ptr)
                }
            }
        }

        @Test
        func `pread throws on invalid descriptor`() {
            var buffer = [UInt8](repeating: 0, count: 10)

            #expect(throws: ISO_9945.Kernel.IO.Read.Error.self) {
                try buffer.withUnsafeMutableBytes { ptr in
                    try ISO_9945.Kernel.IO.Read.pread(ISO_9945.Kernel.Descriptor(_rawValue: -1), into: ptr, at: ISO_9945.Kernel.File.Offset(0))
                }
            }
        }
    }

