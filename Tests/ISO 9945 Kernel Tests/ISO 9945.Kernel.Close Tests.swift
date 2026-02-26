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
import ISO_9945
import Kernel_Primitives
// Tests use Apple native Testing framework
import Testing

@testable import ISO_9945_Kernel

extension Kernel.Close {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Close Tests

#if !os(Windows)

    extension Kernel.Close.Test.Unit {
        @Test("close succeeds on valid descriptor")
        func closeSucceedsOnValidDescriptor() throws {
            try KernelIOTest.withTempFile(prefix: "close-test") { _, fd in
                // Close should succeed
                try Kernel.Close.close(fd)

                // Note: cleanup in defer will try to close again, but fd is already closed
                // This is fine - the defer will fail silently
            }
        }

        @Test("close is idempotent in practice")
        func closeIdempotentBehavior() throws {
            // NOTE: POSIX says closing an already-closed fd is undefined behavior.
            // However, Kernel.Close checks isValid before calling the syscall.
            // This test verifies that the isValid check catches invalid descriptors.
            let invalidFd = Kernel.Descriptor(_raw: -1)

            // Should throw because descriptor is invalid
            #expect(throws: Kernel.Close.Error.self) {
                try Kernel.Close.close(invalidFd)
            }
        }
    }

    // MARK: - Error Tests

    extension Kernel.Close.Test.EdgeCase {
        @Test("close throws on invalid descriptor")
        func closeThrowsOnInvalidDescriptor() {
            let invalidFd = Kernel.Descriptor(_raw: -1)

            #expect(throws: Kernel.Close.Error.self) {
                try Kernel.Close.close(invalidFd)
            }
        }

        @Test("close with negative descriptor throws")
        func closeNegativeDescriptorThrows() {
            let negativeFd = Kernel.Descriptor(_raw: -100)

            #expect(throws: Kernel.Close.Error.self) {
                try Kernel.Close.close(negativeFd)
            }
        }
    }

#endif
