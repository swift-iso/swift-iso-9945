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

@Suite("ISO_9945.Kernel.File.Clone")
struct POSIXKernelFileCloneTests {

    // MARK: - Type Tests

    @Suite("Types")
    struct TypeTests {

        @Test
        func `Capability enum values`() {
            let reflink = ISO_9945.Kernel.File.Clone.Capability.reflink
            let none = ISO_9945.Kernel.File.Clone.Capability.none

            #expect(reflink != none)
            #expect(reflink == .reflink)
            #expect(none == .none)
        }

        @Test
        func `Behavior enum values`() {
            let reflinkOrFail = ISO_9945.Kernel.File.Clone.Behavior.reflinkOrFail
            let reflinkOrCopy = ISO_9945.Kernel.File.Clone.Behavior.reflinkOrCopy
            let copyOnly = ISO_9945.Kernel.File.Clone.Behavior.copyOnly

            #expect(reflinkOrFail != reflinkOrCopy)
            #expect(reflinkOrCopy != copyOnly)
            #expect(reflinkOrFail != copyOnly)
        }

        @Test
        func `Result enum values`() {
            let reflinked = ISO_9945.Kernel.File.Clone.Result.reflinked
            let copied = ISO_9945.Kernel.File.Clone.Result.copied

            #expect(reflinked != copied)
        }

        @Test
        func `types are Sendable`() {
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

        @Test
        func `error descriptions are meaningful`() {
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

        @Test
        func `error is Equatable`() {
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
    //
    // Disabled: Capability.probe(at:) POSIX implementation has not landed
    // in swift-iso-9945. The L1 type exists in swift-kernel-primitives but
    // the platform-specific probe logic (clonefile test, ioctl, etc.) is missing.

    #if os(macOS)
        @Suite("Capability Probing")
        struct CapabilityProbingTests {

            @Test(.disabled("pending: Capability.probe POSIX implementation"))
            func `probe capability returns valid result`() throws {
            }

            @Test(.disabled("pending: Capability.probe POSIX implementation"))
            func `probe nonexistent path throws`() {
            }
        }
    #endif

    // MARK: - Clone Operation Tests
    //
    // Disabled: Copyfile, CopyRange, and Metadata POSIX implementations have
    // not landed in swift-iso-9945. The L1 namespace types exist in
    // swift-kernel-primitives but the platform syscall wrappers (copyfile(),
    // clonefile(), copy_file_range(), stat()) are missing.

    @Suite("Clone Operations")
    struct CloneOperationTests {

        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
        @Test(.disabled("pending: Copyfile POSIX implementation"))
        func `copyfile creates file copy`() throws {}

        @Test(.disabled("pending: Copyfile POSIX implementation"))
        func `clonefile with clone flag attempts reflink`() throws {}

        @Test(.disabled("pending: Copyfile POSIX implementation"))
        func `clonefile to existing destination fails`() throws {}

        @Test(.disabled("pending: Copyfile + Metadata.size POSIX implementation"))
        func `clone empty file`() throws {}
        #endif

        #if os(Linux)
        @Test(.disabled("pending: CopyRange POSIX implementation"))
        func `copy_file_range copies data`() throws {}
        #endif
    }

    // MARK: - Metadata Tests

    @Suite("Metadata")
    struct MetadataTests {

        @Test(.disabled("pending: Metadata.size POSIX implementation"))
        func `size returns correct file size`() throws {}
    }
}
