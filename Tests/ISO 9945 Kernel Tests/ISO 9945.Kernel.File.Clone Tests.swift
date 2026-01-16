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
import Testing_Extras

@testable import ISO_9945_Kernel

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#endif

// MARK: - Cross-Platform Test Helpers

/// Creates a temporary file with content and returns its path
private func createTempFile(prefix: String, content: String) -> String {
    let path = "/tmp/\(prefix)-\(getpid())-\(Int.random(in: 0..<Int.max))"
    let fd = open(path, O_CREAT | O_WRONLY, 0o644)
    guard fd >= 0 else { return path }
    defer { close(fd) }

    _ = content.withCString { ptr in
        write(fd, ptr, content.count)
    }

    return path
}

/// Reads content from a file
private func readFileContent(_ path: String) -> String? {
    let fd = open(path, O_RDONLY)
    guard fd >= 0 else { return nil }
    defer { close(fd) }

    var buffer = [CChar](repeating: 0, count: 4096)
    let bytesRead = read(fd, &buffer, buffer.count - 1)
    guard bytesRead > 0 else { return nil }

    return String(cString: buffer)
}

/// Cleans up a temp file
private func cleanup(_ path: String) {
    _ = path.withCString { unlink($0) }
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
            let source = createTempFile(prefix: "clone-src", content: content)
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
            let source = createTempFile(prefix: "clone-src", content: content)
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
            let source = createTempFile(prefix: "clone-src", content: content)
            let dest = createTempFile(prefix: "clone-dst", content: "Existing")

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
            let source = createTempFile(prefix: "clone-empty-src", content: "")
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
            var statBuf = stat()
            let statResult = dest.withCString { stat($0, &statBuf) }
            #expect(statResult == 0)
            #expect(statBuf.st_size == 0)
        }
        #endif

        #if os(Linux)
        @Test("copy_file_range copies data")
        func copyFileRangeCopiesData() throws {
            let content = "Test content for copy_file_range"
            let source = createTempFile(prefix: "clone-src", content: content)
            let dest = "/tmp/clone-dst-\(getpid())-\(Int.random(in: 0..<Int.max))"

            defer {
                cleanup(source)
                cleanup(dest)
            }

            // Open source for reading
            let srcFd = open(source, O_RDONLY)
            guard srcFd >= 0 else { throw POSIXError(.ENOENT) }
            defer { close(srcFd) }

            // Create destination
            let dstFd = open(dest, O_CREAT | O_WRONLY | O_TRUNC, 0o644)
            guard dstFd >= 0 else { throw POSIXError(.EACCES) }
            defer { close(dstFd) }

            // Copy using copy_file_range
            try ISO_9945.Kernel.File.Clone.CopyRange.copy(
                source: ISO_9945.Kernel.Descriptor(_rawValue: srcFd),
                destination: ISO_9945.Kernel.Descriptor(_rawValue: dstFd),
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
            let source = createTempFile(prefix: "size-test", content: content)

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

#endif
