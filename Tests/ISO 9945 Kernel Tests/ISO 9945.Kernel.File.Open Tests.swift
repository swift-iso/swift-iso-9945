// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
import Kernel_Primitives_Core
import Kernel_Event_Primitives
import Kernel_File_Primitives
import Path_Primitives
import Kernel_Process_Primitives
import Error_Primitives
// Tests use Apple native Testing framework
import Testing

@testable import ISO_9945_Kernel

extension Kernel.File.Open {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Mode Unit Tests
// (Mode is no longer an OptionSet — see File.Open.Mode Tests.swift for
// current struct-based API tests.)

// MARK: - Options Unit Tests

extension Kernel.File.Open.Test.Unit {
    @Test
    func `Options is OptionSet`() {
        let options: Kernel.File.Open.Options = [.create, .truncate]
        #expect(options.contains(.create))
        #expect(options.contains(.truncate))
        #expect(!options.contains(.append))
    }

    @Test
    func `Options is Sendable`() {
        let options: any Sendable = Kernel.File.Open.Options.create
        #expect(options is Kernel.File.Open.Options)
    }

    @Test
    func `Options can be combined`() {
        let combined = Kernel.File.Open.Options.create.union(.exclusive)
        #expect(combined.contains(.create))
        #expect(combined.contains(.exclusive))
    }

    @Test
    func `all standard options are distinct`() {
        let options: [Kernel.File.Open.Options] = [
            .create,
            .truncate,
            .append,
            .exclusive,
        ]

        for (i, a) in options.enumerated() {
            for (j, b) in options.enumerated() {
                if i != j {
                    #expect(!a.intersection(b).contains(a), "Options at index \(i) and \(j) should be distinct")
                }
            }
        }
    }
}

// MARK: - Edge Cases

extension Kernel.File.Open.Test.EdgeCase {
    @Test
    func `empty options has zero raw value`() {
        let empty = Kernel.File.Open.Options()
        #expect(empty.rawValue == 0)
    }

    @Test
    func `exclusive without create is valid but semantically requires create`() {
        // exclusive alone is valid at the API level
        let options = Kernel.File.Open.Options.exclusive
        #expect(options.contains(.exclusive))
        #expect(!options.contains(.create))
    }
}

// MARK: - Actual File Open Tests


    extension Kernel.File.Open.Test.Unit {
        @Test
        func `open existing file for read succeeds`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "open-test")
            defer { KernelIOTest.cleanup(path: path) }
            let fd = try KernelIOTest.open(at: path)
            KernelIOTest.write("test", to: fd)

            let readFd = try Path.scope(path) { p in
                try Kernel.File.Open.open(
                    path: p,
                    mode: .read,
                    options: [],
                    permissions: .standard
                )
            }

            let isValid = readFd.isValid
            #expect(isValid)
        }

        @Test
        func `open with create creates new file`() throws {
            let pathString = Kernel.Temporary.filePath(prefix: "open-create-test")
            let fd = try Path.scope(pathString) { path in
                try Kernel.File.Open.open(
                    path: path,
                    mode: .readWrite,
                    options: .create,
                    permissions: .standard
                )
            }
            defer { KernelIOTest.cleanup(path: pathString) }

            let fdIsValid = fd.isValid
            #expect(fdIsValid)

            // Verify file exists by checking stats
            let stats = try Kernel.File.Stats.get(descriptor: fd)
            #expect(stats.type == .regular, "File should exist after create")
        }

        @Test
        func `open with truncate truncates existing file`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "open-test")
            defer { KernelIOTest.cleanup(path: path) }

            do {
                let fd = try KernelIOTest.open(at: path)
                KernelIOTest.write("original content", to: fd)
                try Kernel.Close.close(fd)
            }

            // Re-open with truncate
            let truncFd = try Path.scope(path) { p in
                try Kernel.File.Open.open(
                    path: p,
                    mode: .readWrite,
                    options: .truncate,
                    permissions: .standard
                )
            }

            // Check file size is 0 using stats
            let stats = try Kernel.File.Stats.get(descriptor: truncFd)
            #expect(stats.size == 0, "File should be truncated to 0 bytes")
        }

        @Test
        func `open with append positions at end`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "open-test")
            defer { KernelIOTest.cleanup(path: path) }

            do {
                let fd = try KernelIOTest.open(at: path)
                KernelIOTest.write("initial", to: fd)
                try Kernel.Close.close(fd)
            }

            // Re-open with append
            let appendFd = try Path.scope(path) { p in
                try Kernel.File.Open.open(
                    path: p,
                    mode: .write,
                    options: .append,
                    permissions: .standard
                )
            }

            // Write more data
            var extra = Array("_extra".utf8)
            _ = try? extra.withUnsafeMutableBytes { ptr in
                try Kernel.IO.Write.write(appendFd, from: UnsafeRawBufferPointer(ptr))
            }

            // Verify total content by re-reading
            let readFd = try Path.scope(path) { p in
                try Kernel.File.Open.open(path: p, mode: .read, options: [], permissions: .privateFile)
            }
            var buffer = [UInt8](repeating: 0, count: 20)
            let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
                try Kernel.IO.Read.read(readFd, into: ptr)
            }
            let content = Swift.String(decoding: buffer.prefix(bytesRead), as: UTF8.self)
            #expect(content == "initial_extra")
        }

        @Test
        func `open with exclusive fails if file exists`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "open-test")
            defer { KernelIOTest.cleanup(path: path) }

            do {
                let fd = try KernelIOTest.open(at: path)
                try Kernel.Close.close(fd)
            }

            // Path.scope wraps inner throws into its own error
            // type (e.g., .body(inner)), so the caller sees a ScopeError
            // rather than Kernel.File.Open.Error directly. Accept any
            // error — the test's semantic is "open fails", not "open
            // fails with a specific unwrapped type".
            do {
                _ = try Path.scope(path) { p in
                    try Kernel.File.Open.open(
                        path: p,
                        mode: .readWrite,
                        options: [.create, .exclusive],
                        permissions: .standard
                    )
                }
                Issue.record("Expected open to fail with .exclusive on existing file")
            } catch {
                // Expected — open failed because file exists.
            }
        }
    }

    extension Kernel.File.Open.Test.EdgeCase {
        @Test
        func `open nonexistent file without create throws`() throws {
            try Path.scope("/nonexistent/path/to/file") { path in
                #expect(throws: Kernel.File.Open.Error.self) {
                    _ = try Kernel.File.Open.open(
                        path: path,
                        mode: .read,
                        options: [],
                        permissions: .standard
                    )
                }
            }
        }

        @Test
        func `open directory for write throws`() throws {
            try Path.scope("/tmp") { path in
                #expect(throws: Kernel.File.Open.Error.self) {
                    _ = try Kernel.File.Open.open(
                        path: path,
                        mode: .write,
                        options: [],
                        permissions: .standard
                    )
                }
            }
        }
    }

