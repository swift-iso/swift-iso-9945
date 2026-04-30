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
import Kernel_Primitives_Core
import Kernel_File_Primitives
import Path_Primitives
import Error_Primitives
// Tests use Apple native Testing framework
import Testing

@testable import ISO_9945_Kernel

extension Kernel.File.Handle {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Helpers

/// Deletes the file at path only (Handle owns the descriptor).
private func cleanup(path: Swift.String) {
    try? Path.scope(path) { p in
        try ISO_9945.Kernel.File.Delete.delete(p)
    }
}

// MARK: - Handle Tests


    extension Kernel.File.Handle.Test.Unit {
        @Test
        func `init stores descriptor and mode`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "handle-test")
            let fd = try KernelIOTest.open(at: path)
            // Handle takes ownership of fd; only clean up the file path
            defer { cleanup(path: path) }

            let handle = Kernel.File.Handle(
                descriptor: fd,
                direct: .buffered,
                requirements: .unknown(reason: .platformUnsupported)
            )

            #expect(handle.direct == .buffered)

            // Handle will close on deinit
            _ = consume handle
        }

        @Test
        func `read returns bytes from file`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "handle-test")
            let fd = try KernelIOTest.open(at: path)
            defer { cleanup(path: path) }
            KernelIOTest.write("Hello, Handle!", to: fd)

            _ = try Kernel.File.Seek.seek(fd, offset: 0, whence: .start)

            let handle = Kernel.File.Handle(
                descriptor: fd,
                direct: .buffered,
                requirements: .unknown(reason: .platformUnsupported)
            )

            var buffer = [UInt8](repeating: 0, count: 14)
            let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
                try handle.read(into: ptr)
            }

            #expect(bytesRead == 14)
            #expect(Swift.String(decoding: buffer, as: UTF8.self) == "Hello, Handle!")
        }

        @Test
        func `write writes bytes to file`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "handle-test")
            let fd = try KernelIOTest.open(at: path)
            defer { cleanup(path: path) }

            let handle = Kernel.File.Handle(
                descriptor: fd,
                direct: .buffered,
                requirements: .unknown(reason: .platformUnsupported)
            )

            let content = Array("Handle write!".utf8)
            let bytesWritten = try content.withUnsafeBytes { ptr in
                try handle.write(from: ptr)
            }

            #expect(bytesWritten == 13)

            // Verify by seeking back and reading via the handle
            _ = try Kernel.File.Seek.seek(handle.descriptor, offset: 0, whence: .start)
            var buffer = [UInt8](repeating: 0, count: 13)
            let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
                try handle.read(into: ptr)
            }
            #expect(Swift.String(decoding: buffer, as: UTF8.self) == "Handle write!")
        }

        @Test
        func `close explicitly closes handle`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "handle-test")
            let fd = try KernelIOTest.open(at: path)
            defer { cleanup(path: path) }

            let handle = Kernel.File.Handle(
                descriptor: fd,
                direct: .buffered,
                requirements: .unknown(reason: .platformUnsupported)
            )

            try handle.close()

            // After explicit close, re-opening confirms the file still exists
            // (close closed the fd, not the file).
            let fd2 = try Path.scope(path) { p in
                try Kernel.File.Open.open(
                    path: p,
                    mode: .read,
                    options: [],
                    permissions: .ownerReadWrite
                )
            }
            let fd2IsValid = fd2.isValid
            #expect(fd2IsValid)
        }

        @Test
        func `descriptor property provides borrowing access`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "handle-test")
            let fd = try KernelIOTest.open(at: path)
            defer { cleanup(path: path) }

            let handle = Kernel.File.Handle(
                descriptor: fd,
                direct: .buffered,
                requirements: .unknown(reason: .platformUnsupported)
            )

            // ~Copyable property access is the borrowing mechanism;
            // no withDescriptor closure needed.
            let isValid = handle.descriptor.isValid
            #expect(isValid)

            _ = consume handle
        }

        @Test
        func `handle closes on deinit`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "handle-test")
            let fd = try KernelIOTest.open(at: path)
            defer { cleanup(path: path) }

            // Create and immediately drop handle
            do {
                let handle = Kernel.File.Handle(
                    descriptor: fd,
                    direct: .buffered,
                    requirements: .unknown(reason: .platformUnsupported)
                )
                _ = consume handle
            }

            // After deinit, descriptor should be closed.
            // Re-open to verify the file still exists (handle closed the fd, not the file).
            let fd2 = try Path.scope(path) { p in
                try Kernel.File.Open.open(
                    path: p,
                    mode: .read,
                    options: [],
                    permissions: .ownerReadWrite
                )
            }
            let fd2IsValid = fd2.isValid
            #expect(fd2IsValid)
        }
    }

    // MARK: - Direct Mode Tests

    extension Kernel.File.Handle.Test.Unit {
        @Test
        func `direct mode enum is equatable`() {
            #expect(Kernel.File.Direct.Mode.Resolved.buffered == .buffered)
            #expect(Kernel.File.Direct.Mode.Resolved.direct == .direct)
            #expect(Kernel.File.Direct.Mode.Resolved.uncached == .uncached)
            #expect(Kernel.File.Direct.Mode.Resolved.buffered != .direct)
        }

        @Test
        func `requirements known case`() {
            let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
            let requirements = Kernel.File.Direct.Requirements.known(alignment)

            if case .known(let a) = requirements {
                #expect(a.bufferAlignment == .`4096`)
            } else {
                Issue.record("Expected .known case")
            }
        }

        @Test
        func `requirements unknown case`() {
            let requirements = Kernel.File.Direct.Requirements.unknown(reason: .platformUnsupported)

            if case .unknown(let reason) = requirements {
                #expect(reason == .platformUnsupported)
            } else {
                Issue.record("Expected .unknown case")
            }
        }
    }

