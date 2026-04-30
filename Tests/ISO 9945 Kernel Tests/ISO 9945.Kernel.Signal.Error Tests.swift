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

// Signal.Error only exists on POSIX platforms
#if canImport(Darwin) || canImport(Glibc) || canImport(Musl)

import Testing

    import Path_Primitives
    import Error_Primitives
    @testable import ISO_9945_Kernel

    extension Kernel.Signal.Error {
        @Suite
        struct Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Signal.Error Tests

    extension Kernel.Signal.Error.Test.Unit {
        @Test
        func `interrupted case exists`() {
            let error = Kernel.Signal.Error.interrupted
            if case .interrupted = error {
                // Expected
            } else {
                Issue.record("Expected .interrupted case")
            }
        }

        @Test
        func `Signal.Error conforms to Swift.Error`() {
            let error: any Swift.Error = Kernel.Signal.Error.interrupted
            #expect(error is Kernel.Signal.Error)
        }

        @Test
        func `Signal.Error is Sendable`() {
            let error: any Sendable = Kernel.Signal.Error.interrupted
            #expect(error is Kernel.Signal.Error)
        }

        @Test
        func `Signal.Error is Equatable`() {
            let a = Kernel.Signal.Error.interrupted
            let b = Kernel.Signal.Error.interrupted

            #expect(a == b)
        }

        @Test
        func `Signal.Error is Hashable`() {
            var set = Set<Kernel.Signal.Error>()
            set.insert(.interrupted)
            set.insert(.interrupted)  // duplicate

            #expect(set.count == 1)
            #expect(set.contains(.interrupted))
        }

        @Test
        func `description returns meaningful string`() {
            let error = Kernel.Signal.Error.interrupted
            #expect(error.description == "interrupted by signal")
        }

        @Test
        func `CustomStringConvertible conformance`() {
            let error = Kernel.Signal.Error.interrupted
            let description = Swift.String(describing: error)
            #expect(!description.isEmpty)
            #expect(description.contains("interrupt"))
        }
    }

#endif
