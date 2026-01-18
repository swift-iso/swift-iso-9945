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

import ISO_9945
import ISO_9945_Kernel_Test_Support
import Kernel_Primitives
import Test_Primitives
import Testing
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.File.Open {
    #Tests
}

// MARK: - Integration Tests (require full POSIX module for file I/O)

extension ISO_9945.Kernel.File.Open.Test.Integration {
    @Test("open and close file")
    func openAndClose() throws {
        let pathString = ISO_9945.Kernel.Temporary.filePath(prefix: "posix-io-test")

        try ISO_9945.Kernel.Path.scope(pathString) { path in
            // Create and open
            let fd = try ISO_9945.Kernel.File.Open.open(
                path: path,
                mode: [.read, .write],
                options: [.create, .truncate],
                permissions: .standard
            )

            #expect(fd.isValid)

            // Close
            try ISO_9945.Kernel.Close.close(fd)

            // Cleanup
            try? ISO_9945.Kernel.File.Delete.delete(path)
        }
    }

    @Test("open nonexistent file throws")
    func openNonexistent() throws {
        let pathString = "/nonexistent/path/that/does/not/exist/file.txt"

        var threwError = false
        do {
            try ISO_9945.Kernel.Path.scope(pathString) { path in
                _ = try ISO_9945.Kernel.File.Open.open(
                    path: path,
                    mode: [.read],
                    options: [],
                    permissions: 0
                )
            }
        } catch {
            threwError = true
        }
        #expect(threwError)
    }

    @Test("write and read data")
    func writeAndRead() throws {
        let pathString = ISO_9945.Kernel.Temporary.filePath(prefix: "posix-io-test-rw")
        let testData: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F]  // "Hello"

        try ISO_9945.Kernel.Path.scope(pathString) { path in
            // Create file
            let fd = try ISO_9945.Kernel.File.Open.open(
                path: path,
                mode: [.read, .write],
                options: [.create, .truncate],
                permissions: .standard
            )

            defer {
                try? ISO_9945.Kernel.Close.close(fd)
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

    @Test("read returns 0 on EOF")
    func readEOF() throws {
        let pathString = ISO_9945.Kernel.Temporary.filePath(prefix: "posix-io-test-eof")

        try ISO_9945.Kernel.Path.scope(pathString) { path in
            // Create empty file
            let fd = try ISO_9945.Kernel.File.Open.open(
                path: path,
                mode: [.read, .write],
                options: [.create, .truncate],
                permissions: .standard
            )

            defer {
                try? ISO_9945.Kernel.Close.close(fd)
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

extension ISO_9945.Kernel.File.Open.Test.EdgeCase {
    @Test("close invalid descriptor throws")
    func closeInvalid() {
        var threwError = false
        do {
            try ISO_9945.Kernel.Close.close(.invalid)
        } catch {
            threwError = true
        }
        #expect(threwError)
    }

    @Test("read from invalid descriptor throws")
    func readInvalid() {
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

    @Test("write to invalid descriptor throws")
    func writeInvalid() {
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

#endif
