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


import ISO_9945_Kernel
import ISO_9945_Kernel_Test_Support
import Kernel_Primitives_Core
import Kernel_Descriptor_Primitives
import Kernel_Event_Primitives
import Kernel_IO_Primitives
import Kernel_File_Primitives
import Kernel_Path_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_Thread_Primitives
import Kernel_Error_Primitives
import Testing

@testable import ISO_9945_Kernel

@Suite("File I/O Integration")
struct FileIOIntegrationTests {
    @Test
    func `open and close file`() throws {
        let pathString = ISO_9945.Kernel.Temporary.filePath(prefix: "posix-io-test")

        try ISO_9945.Kernel.Path.scope(pathString) { path in
            // Create and open
            let fd = try ISO_9945.Kernel.File.Open.open(
                path: path,
                mode: .readWrite,
                options: [.create, .truncate],
                permissions: .standard
            )

            let fdIsValid = fd.isValid
            #expect(fdIsValid)

            // Close
            try ISO_9945.Kernel.Close.close(fd)

            // Cleanup
            try? ISO_9945.Kernel.File.Delete.delete(path)
        }
    }

    @Test
    func `open nonexistent file throws`() throws {
        let pathString = "/nonexistent/path/that/does/not/exist/file.txt"

        var threwError = false
        do {
            try ISO_9945.Kernel.Path.scope(pathString) { path in
                _ = try ISO_9945.Kernel.File.Open.open(
                    path: path,
                    mode: .read,
                    options: [],
                    permissions: 0
                )
            }
        } catch {
            threwError = true
        }
        #expect(threwError)
    }

    @Test
    func `write and read data`() throws {
        let pathString = ISO_9945.Kernel.Temporary.filePath(prefix: "posix-io-test-rw")
        let testData: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F]  // "Hello"

        try ISO_9945.Kernel.Path.scope(pathString) { path in
            // Create file
            let fd = try ISO_9945.Kernel.File.Open.open(
                path: path,
                mode: .readWrite,
                options: [.create, .truncate],
                permissions: .standard
            )

            defer {
                try? ISO_9945.Kernel.File.Delete.delete(path)
            }

            // Write
            let written = try testData.withUnsafeBytes { buffer in
                try ISO_9945.Kernel.IO.Write.write(fd, from: buffer)
            }
            #expect(written == testData.count)

            // Read using pread (positional read from offset 0)
            var readBuffer = [UInt8](repeating: 0, count: testData.count)
            let bytesRead = try readBuffer.withUnsafeMutableBytes { buffer in
                try ISO_9945.Kernel.IO.Read.pread(fd, into: buffer, at: 0)
            }

            #expect(bytesRead == testData.count)
            #expect(readBuffer == testData)
        }
    }

    @Test
    func `read returns 0 on EOF`() throws {
        let pathString = ISO_9945.Kernel.Temporary.filePath(prefix: "posix-io-test-eof")

        try ISO_9945.Kernel.Path.scope(pathString) { path in
            // Create empty file
            let fd = try ISO_9945.Kernel.File.Open.open(
                path: path,
                mode: .readWrite,
                options: [.create, .truncate],
                permissions: .standard
            )

            defer {
                try? ISO_9945.Kernel.File.Delete.delete(path)
            }

            // Read from empty file using pread at offset 0
            var buffer = [UInt8](repeating: 0, count: 100)
            let bytesRead = try buffer.withUnsafeMutableBytes { buf in
                try ISO_9945.Kernel.IO.Read.pread(fd, into: buf, at: 0)
            }

            #expect(bytesRead == 0)  // EOF returns 0, not error
        }
    }
}

// MARK: - Edge Cases (Integration)

extension FileIOIntegrationTests {
    @Test
    func `close invalid descriptor throws`() {
        var threwError = false
        do {
            try ISO_9945.Kernel.Close.close(.invalid)
        } catch {
            threwError = true
        }
        #expect(threwError)
    }

    @Test
    func `read from invalid descriptor throws`() {
        var buffer = [UInt8](repeating: 0, count: 10)
        var threwError = false
        do {
            try buffer.withUnsafeMutableBytes { buf in
                try ISO_9945.Kernel.IO.Read.read(.invalid, into: buf)
            }
        } catch {
            threwError = true
        }
        #expect(threwError)
    }

    @Test
    func `write to invalid descriptor throws`() {
        let data: [UInt8] = [1, 2, 3]
        var threwError = false
        do {
            try data.withUnsafeBytes { buf in
                try ISO_9945.Kernel.IO.Write.write(.invalid, from: buf)
            }
        } catch {
            threwError = true
        }
        #expect(threwError)
    }
}

