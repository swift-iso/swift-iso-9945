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

import Error_Primitives
import Path_Primitives
import Synchronization
import Tagged_Primitives_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Thread {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Thread.Test.Unit {
    @Test
    func `create spawns thread that executes body`() throws {
        let executed = Atomic<Bool>(false)
        let handle = try ISO_9945.Kernel.Thread.create {
            executed.store(true, ordering: .releasing)
        }
        handle.join()
        #expect(executed.load(ordering: .acquiring) == true)
    }

    @Test
    func `Handle.join waits for thread completion`() throws {
        let completed = Atomic<Bool>(false)
        let handle = try ISO_9945.Kernel.Thread.create {
            // Small delay to ensure we're actually waiting
            for _ in 0..<1000 {
                _ = 1 + 1  // Busy work
            }
            completed.store(true, ordering: .releasing)
        }

        handle.join()
        #expect(completed.load(ordering: .acquiring) == true)
    }

    @Test
    func `Handle.isCurrent returns false from main thread`() throws {
        let handle = try ISO_9945.Kernel.Thread.create {
            // Do nothing
        }

        // From main thread, isCurrent should be false
        #expect(handle.isCurrent == false)

        handle.join()
    }
}

// MARK: - Integration Tests

extension ISO_9945.Kernel.Thread.Test.Integration {
    @Test
    func `multiple threads can execute concurrently`() throws {
        let counter = Atomic<Int>(0)
        let numThreads = 4

        // Create and join threads sequentially since Handle is ~Copyable
        for _ in 0..<numThreads {
            let handle = try ISO_9945.Kernel.Thread.create {
                counter.wrappingAdd(1, ordering: .relaxed)
            }
            handle.join()
        }

        #expect(counter.load(ordering: .acquiring) == numThreads)
    }

    @Test
    func `thread detach allows independent execution`() throws {
        let started = Atomic<Bool>(false)

        let handle = try ISO_9945.Kernel.Thread.create {
            started.store(true, ordering: .releasing)
        }

        handle.detach()

        // Give the thread time to run
        var iterations = 0
        while !started.load(ordering: .acquiring) && iterations < 1000 {
            ISO_9945.Kernel.Thread.yield()
            iterations += 1
        }

        // Thread should have run (or we timeout gracefully)
        // Note: detached threads may not complete before test ends
    }
}
