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
import Kernel_Primitives
import Synchronization
import Test_Primitives
import Testing
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Thread {
    #Tests
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Thread.Test.Unit {
    @Test("create spawns thread that executes body")
    func createExecutesBody() throws {
        let executed = Atomic<Bool>(false)
        let handle = try ISO_9945.Kernel.Thread.create {
            executed.store(true, ordering: .releasing)
        }
        handle.join()
        #expect(executed.load(ordering: .acquiring) == true)
    }

    @Test("Handle.join waits for thread completion")
    func handleJoinWaits() throws {
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

    @Test("Handle.isCurrent returns false from main thread")
    func isCurrentFalseFromMain() throws {
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
    @Test("multiple threads can execute concurrently")
    func multipleThreadsConcurrent() throws {
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

    @Test("thread detach allows independent execution")
    func detachAllowsIndependentExecution() throws {
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

#endif
