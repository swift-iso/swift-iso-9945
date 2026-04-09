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

import ISO_9945
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

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#endif

@testable import ISO_9945_Kernel

// MARK: - Cross-Platform Test Helpers

/// Creates a temporary file with content and returns its path.
private func createTempFileWithContent(prefix: Swift.String, content: Swift.String) -> Swift.String {
    let path = KernelIOTest.makeTempPath(prefix: prefix)
    if let fd = try? KernelIOTest.open(at: path) {
        KernelIOTest.write(content, to: fd)
        // fd closes via deinit
    }
    return path
}

/// Reads content from a file using the Kernel API.
private func readFileContent(_ path: Swift.String) -> Swift.String? {
    guard let fd = try? ISO_9945.Kernel.Path.scope(path, { p in
        try ISO_9945.Kernel.File.Open.open(
            path: p,
            mode: .read,
            options: [],
            permissions: .ownerReadWrite
        )
    }) else { return nil }

    var buffer = [UInt8](repeating: 0, count: 4096)
    guard let bytesRead = try? buffer.withUnsafeMutableBytes({ ptr in
        try ISO_9945.Kernel.IO.Read.read(fd, into: ptr)
    }), bytesRead > 0 else { return nil }

    return Swift.String(decoding: buffer.prefix(bytesRead), as: UTF8.self)
}

/// Cleans up a temp file.
private func cleanup(_ path: Swift.String) {
    try? ISO_9945.Kernel.Path.scope(path) { p in
        try ISO_9945.Kernel.File.Delete.delete(p)
    }
}

@Suite("POSIX.Kernel.File.Clone")
struct POSIXKernelFileCloneTests {

    // MARK: - Type Tests

    @Suite("Types")
    struct TypeTests {

        @Test("Capability enum values")
        func capabilityValues() {
            let reflink = ISO_9945.Kernel.File.Clone.Capability.reflink
            let none = ISO_9945.Kernel.File.Clone.Capability.none

            #expect(reflink != none)
            #expect(reflink == .reflink)
            #expect(none == .none)
        }

        @Test("Behavior enum values")
        func behaviorValues() {
            let reflinkOrFail = ISO_9945.Kernel.File.Clone.Behavior.reflinkOrFail
            let reflinkOrCopy = ISO_9945.Kernel.File.Clone.Behavior.reflinkOrCopy
            let copyOnly = ISO_9945.Kernel.File.Clone.Behavior.copyOnly

            #expect(reflinkOrFail != reflinkOrCopy)
            #expect(reflinkOrCopy != copyOnly)
            #expect(reflinkOrFail != copyOnly)
        }

        @Test("Result enum values")
        func resultValues() {
            let reflinked = ISO_9945.Kernel.File.Clone.Result.reflinked
            let copied = ISO_9945.Kernel.File.Clone.Result.copied

            #expect(reflinked != copied)
        }

        @Test("types are Sendable")
        func typesAreSendable() {
            let cap: ISO_9945.Kernel.File.Clone.Capability = .reflink
            let behavior: ISO_9945.Kernel.File.Clone.Behavior = .reflinkOrCopy
            let result: ISO_9945.Kernel.File.Clone.Result = .copied

            Task.detached {
                _ = cap
                _ = behavior
                _ = result
            }
        }
    }

    // MARK: - Error Tests

    @Suite("Error")
    struct ErrorTests {

        @Test("error descriptions are meaningful")
        func errorDescriptions() {
            let errors: [ISO_9945.Kernel.File.Clone.Error] = [
                .notSupported,
                .crossDevice,
                .sourceNotFound,
                .destinationExists,
                .permissionDenied,
                .isDirectory,
                .platform(code: .posix(42), operation: .copy),
            ]

            for error in errors {
                let description = error.description
                #expect(!description.isEmpty)
            }

            #expect(ISO_9945.Kernel.File.Clone.Error.notSupported.description.contains("not supported"))
            #expect(ISO_9945.Kernel.File.Clone.Error.crossDevice.description.contains("different"))
        }

        @Test("error is Equatable")
        func errorEquatable() {
            #expect(ISO_9945.Kernel.File.Clone.Error.notSupported == .notSupported)
            #expect(ISO_9945.Kernel.File.Clone.Error.crossDevice != .notSupported)

            let p1 = ISO_9945.Kernel.File.Clone.Error.platform(code: .posix(1), operation: .copy)
            let p2 = ISO_9945.Kernel.File.Clone.Error.platform(code: .posix(1), operation: .copy)
            let p3 = ISO_9945.Kernel.File.Clone.Error.platform(code: .posix(2), operation: .copy)

            #expect(p1 == p2)
            #expect(p1 != p3)
        }
    }

    // MARK: - Capability Probing Tests (Darwin-specific)

    #if os(macOS)
        @Suite("Capability Probing")
        struct CapabilityProbingTests {

            @Test("probe capability returns valid result")
            func probeCapability() throws {
                // Probe /tmp which is on the boot volume (typically APFS)
                let cap = try ISO_9945.Kernel.Path.scope("/tmp") { path in
                    try ISO_9945.Kernel.File.Clone.Capability.probe(at: path)
                }

                // On modern macOS with APFS, should be .reflink
                // On older systems or HFS+, would be .none
                #expect(cap == .reflink || cap == .none)
            }

            @Test("probe nonexistent path throws")
            func probeNonexistent() {
                typealias E = ISO_9945.Kernel.Path.String.Error<ISO_9945.Kernel.File.Clone.Error.Syscall>

                var threwError = false
                do throws(E) {
                    _ = try ISO_9945.Kernel.Path.scope("/nonexistent/path/that/does/not/exist") {
                        (path) throws(ISO_9945.Kernel.File.Clone.Error.Syscall) in
                        try ISO_9945.Kernel.File.Clone.Capability.probe(at: path)
                    }
                } catch {
                    threwError = true
                }
                #expect(threwError)
            }
        }
    #endif

    // MARK: - Clone Operation Tests

    @Suite("Clone Operations")
    struct CloneOperationTests {

        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
        @Test("copyfile creates file copy")
        func copyfileCreatesFileCopy() throws {
            let content = "Hello, World! This is test content for cloning."
            let source = createTempFileWithContent(prefix: "clone-src", content: content)
            let dest = "/tmp/clone-dst-\(getpid())-\(Int.random(in: 0..<Int.max))"

            defer {
                cleanup(source)
                cleanup(dest)
            }

            try ISO_9945.Kernel.Path.scope(source) { srcPath in
                try ISO_9945.Kernel.Path.scope(dest) { dstPath in
                    try ISO_9945.Kernel.File.Clone.Copyfile.data(
                        source: srcPath,
                        destination: dstPath
                    )
                }
            }

            // Verify content matches
            let readContent = readFileContent(dest)
            #expect(readContent == content)
        }

        @Test("clonefile with clone flag attempts reflink")
        func clonefileWithCloneFlag() throws {
            let content = "Test content for reflink or copy"
            let source = createTempFileWithContent(prefix: "clone-src", content: content)
            let dest = "/tmp/clone-dst-\(getpid())-\(Int.random(in: 0..<Int.max))"

            defer {
                cleanup(source)
                cleanup(dest)
            }

            try ISO_9945.Kernel.Path.scope(source) { srcPath in
                try ISO_9945.Kernel.Path.scope(dest) { dstPath in
                    try ISO_9945.Kernel.File.Clone.Copyfile.clone(
                        source: srcPath,
                        destination: dstPath
                    )
                }
            }

            // Verify content matches
            let readContent = readFileContent(dest)
            #expect(readContent == content)
        }

        @Test("clonefile to existing destination fails")
        func cloneToExistingFails() throws {
            let content = "Source content"
            let source = createTempFileWithContent(prefix: "clone-src", content: content)
            let dest = createTempFileWithContent(prefix: "clone-dst", content: "Existing")

            defer {
                cleanup(source)
                cleanup(dest)
            }

            var threwError = false
            do {
                try ISO_9945.Kernel.Path.scope(source, dest) { srcPath, dstPath in
                    try ISO_9945.Kernel.File.Clone.Copyfile.data(
                        source: srcPath,
                        destination: dstPath
                    )
                }
            } catch {
                threwError = true
            }
            #expect(threwError)
        }

        @Test("clone empty file")
        func cloneEmptyFile() throws {
            let source = createTempFileWithContent(prefix: "clone-empty-src", content: "")
            let dest = "/tmp/clone-empty-dst-\(getpid())-\(Int.random(in: 0..<Int.max))"

            defer {
                cleanup(source)
                cleanup(dest)
            }

            try ISO_9945.Kernel.Path.scope(source) { srcPath in
                try ISO_9945.Kernel.Path.scope(dest) { dstPath in
                    try ISO_9945.Kernel.File.Clone.Copyfile.data(
                        source: srcPath,
                        destination: dstPath
                    )
                }
            }

            // Verify destination exists and is empty
            let destSize = try ISO_9945.Kernel.Path.scope(dest) { dstPath in
                try ISO_9945.Kernel.File.Clone.Metadata.size(at: dstPath)
            }
            #expect(destSize == 0)
        }
        #endif

        #if os(Linux)
        @Test("copy_file_range copies data")
        func copyFileRangeCopiesData() throws {
            let content = "Test content for copy_file_range"
            let source = createTempFileWithContent(prefix: "clone-src", content: content)
            let dest = KernelIOTest.makeTempPath(prefix: "clone-dst")

            defer {
                cleanup(source)
                cleanup(dest)
            }

            // Open source for reading
            let srcFd = try ISO_9945.Kernel.Path.scope(source) { p in
                try ISO_9945.Kernel.File.Open.open(
                    path: p,
                    mode: .read,
                    options: [],
                    permissions: .ownerReadWrite
                )
            }

            // Create destination
            let dstFd = try KernelIOTest.open(at: dest)

            // Copy using copy_file_range
            try ISO_9945.Kernel.File.Clone.CopyRange.copy(
                source: srcFd,
                destination: dstFd,
                length: content.count
            )

            // Verify content matches
            let readContent = readFileContent(dest)
            #expect(readContent == content)
        }
        #endif
    }

    // MARK: - Metadata Tests

    @Suite("Metadata")
    struct MetadataTests {

        @Test("size returns correct file size")
        func sizeReturnsCorrectSize() throws {
            let content = "12345"  // 5 bytes
            let source = createTempFileWithContent(prefix: "size-test", content: content)

            defer {
                cleanup(source)
            }

            let size = try ISO_9945.Kernel.Path.scope(source) { path in
                try ISO_9945.Kernel.File.Clone.Metadata.size(at: path)
            }

            #expect(size == 5)
        }
    }
}
