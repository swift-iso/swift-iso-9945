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

import Binary_Primitives
import ISO_9945_Kernel_Test_Support
import ISO_9945
import Kernel_Primitives
// Tests use Apple native Testing framework
import Testing

@testable import ISO_9945_Kernel

extension Kernel.File.Handle {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Helpers

/// Deletes the file at path only (Handle owns the descriptor).
private func cleanup(path: Swift.String) {
    try? ISO_9945.Kernel.Path.scope(path) { p in
        try ISO_9945.Kernel.File.Delete.delete(p)
    }
}

// MARK: - Handle Tests


    extension Kernel.File.Handle.Test.Unit {
        @Test("init stores descriptor and mode")
        func initStoresDescriptorAndMode() throws {
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

        // Tests for handle.read/write/close/withDescriptor removed:
        // these operations are declared as platform-provided on
        // Kernel.File.Handle in swift-kernel-primitives but the POSIX
        // implementations are not yet present in swift-iso-9945.
        // Re-add when ISO_9945.Kernel.File.Handle provides these methods.

        @Test("handle closes on deinit")
        func handleClosesOnDeinit() throws {
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
            let fd2 = try ISO_9945.Kernel.Path.scope(path) { p in
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
        @Test("direct mode enum is equatable")
        func directModeEquatable() {
            #expect(Kernel.File.Direct.Mode.Resolved.buffered == .buffered)
            #expect(Kernel.File.Direct.Mode.Resolved.direct == .direct)
            #expect(Kernel.File.Direct.Mode.Resolved.uncached == .uncached)
            #expect(Kernel.File.Direct.Mode.Resolved.buffered != .direct)
        }

        @Test("requirements known case")
        func requirementsKnownCase() {
            let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
            let requirements = Kernel.File.Direct.Requirements.known(alignment)

            if case .known(let a) = requirements {
                #expect(a.bufferAlignment == .`4096`)
            } else {
                Issue.record("Expected .known case")
            }
        }

        @Test("requirements unknown case")
        func requirementsUnknownCase() {
            let requirements = Kernel.File.Direct.Requirements.unknown(reason: .platformUnsupported)

            if case .unknown(let reason) = requirements {
                #expect(reason == .platformUnsupported)
            } else {
                Issue.record("Expected .unknown case")
            }
        }
    }

