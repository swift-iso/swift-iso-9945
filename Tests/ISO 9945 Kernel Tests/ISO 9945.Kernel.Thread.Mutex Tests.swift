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
import Kernel_Descriptor_Primitives
import Kernel_Event_Primitives
import Kernel_IO_Primitives
import Kernel_File_Primitives
import Kernel_Path_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_Thread_Primitives
import Kernel_Error_Primitives
// Tests use Apple native Testing framework
import Testing

@testable import ISO_9945_Kernel

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension Kernel.Thread.Mutex {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - API Unit Tests

extension Kernel.Thread.Mutex.Test.Unit {
    @Test
    func `init creates valid mutex`() {
        let mutex = Kernel.Thread.Mutex()
        _ = mutex
    }

    @Test
    func `lock and unlock complete successfully`() {
        let mutex = Kernel.Thread.Mutex()
        mutex.lock()
        mutex.unlock()
    }

    @Test
    func `lock.immediate succeeds when available`() throws {
        let mutex = Kernel.Thread.Mutex()
        try mutex.lock.immediate()
        mutex.unlock()
    }

    @Test
    func `lock.immediate and unlock cycle works repeatedly`() throws {
        let mutex = Kernel.Thread.Mutex()
        let iterations = 100

        for _ in 0..<iterations {
            try mutex.lock.immediate()
            mutex.unlock()
        }
    }

    @Test
    func `withLock executes body`() {
        let mutex = Kernel.Thread.Mutex()
        var executed = false

        mutex.withLock {
            executed = true
        }

        #expect(executed == true)
    }

    @Test
    func `withLock returns value from body`() {
        let mutex = Kernel.Thread.Mutex()

        let result = mutex.withLock {
            return 42
        }

        #expect(result == 42)
    }

    @Test
    func `withLock releases mutex after body`() throws {
        let mutex = Kernel.Thread.Mutex()

        mutex.withLock {}

        try mutex.lock.immediate()
        mutex.unlock()
    }

    @Test
    func `withLock releases mutex on throw`() throws {
        let mutex = Kernel.Thread.Mutex()

        struct TestError: Swift.Error {}

        do {
            try mutex.withLock {
                throw TestError()
            }
        } catch is TestError {}

        try mutex.lock.immediate()
        mutex.unlock()
    }

    @Test
    func `multiple mutexes are independent`() throws {
        let mutex1 = Kernel.Thread.Mutex()
        let mutex2 = Kernel.Thread.Mutex()

        mutex1.lock()
        try mutex2.lock.immediate()
        mutex2.unlock()
        mutex1.unlock()
    }

    @Test
    func `nested withLock on different mutexes`() {
        let mutex1 = Kernel.Thread.Mutex()
        let mutex2 = Kernel.Thread.Mutex()
        var innerExecuted = false

        mutex1.withLock {
            mutex2.withLock {
                innerExecuted = true
            }
        }

        #expect(innerExecuted == true)
    }
}

// MARK: - Mutual Exclusion Tests (require threading)
//
// These tests use KernelThreadTest.Harness to coordinate between threads
// without data races or cross-thread mutex unlock.

// NOTE: These tests use Darwin-specific pthread API.
// Linux pthread API differs (non-optional pthread_t, different closure signature).
// TODO: Add Linux-compatible threading tests to swift-linux package.
#if canImport(Darwin)

    extension Kernel.Thread.Mutex.Test.Unit {
        @Test
        func `lock.immediate throws contention when held by another thread`() throws {
            let mutex = Kernel.Thread.Mutex()

            struct State {
                var workerAttempting = false
                var lockImmediateThrew: Bool? = nil
                var workerDone = false
            }
            let harness = KernelThreadTest.Harness(State())

            // Context to pass both mutex and harness through the C function pointer
            final class Context: @unchecked Sendable {
                let mutex: Kernel.Thread.Mutex
                let harness: KernelThreadTest.Harness<State>

                init(mutex: Kernel.Thread.Mutex, harness: KernelThreadTest.Harness<State>) {
                    self.mutex = mutex
                    self.harness = harness
                }
            }
            let context = Context(mutex: mutex, harness: harness)

            // Main thread holds the mutex
            mutex.lock()
            defer { mutex.unlock() }

            var thread: pthread_t? = nil
            let contextPtr = Unmanaged.passRetained(context).toOpaque()

            let rc = pthread_create(
                &thread,
                nil,
                { raw -> UnsafeMutableRawPointer? in
                    let ctx = Unmanaged<Context>.fromOpaque(raw).takeRetainedValue()

                    ctx.harness.update { $0.workerAttempting = true }

                    // This should throw because main thread holds the mutex
                    var didThrow = false
                    do {
                        try ctx.mutex.lock.immediate()
                        ctx.mutex.unlock()
                    } catch {
                        didThrow = true
                    }

                    ctx.harness.update {
                        $0.lockImmediateThrew = didThrow
                        $0.workerDone = true
                    }
                    return nil
                },
                contextPtr
            )

            #expect(rc == 0, "pthread_create should succeed")

            // Wait for worker to attempt lock.immediate
            try harness.wait(until: { $0.workerAttempting })
            try harness.wait(until: { $0.workerDone })

            let result = harness.withLocked { $0.lockImmediateThrew }
            #expect(result == true, "lock.immediate must throw when mutex is held by another thread")

            if let t = thread {
                pthread_join(t, nil)
            }
        }

        @Test
        func `lock blocks until mutex is available`() throws {
            let mutex = Kernel.Thread.Mutex()

            struct State {
                var workerAttempting = false
                var workerAcquired = false
            }
            let harness = KernelThreadTest.Harness(State())

            final class Context: @unchecked Sendable {
                let mutex: Kernel.Thread.Mutex
                let harness: KernelThreadTest.Harness<State>

                init(mutex: Kernel.Thread.Mutex, harness: KernelThreadTest.Harness<State>) {
                    self.mutex = mutex
                    self.harness = harness
                }
            }
            let context = Context(mutex: mutex, harness: harness)

            // Main thread holds the mutex
            mutex.lock()

            var thread: pthread_t? = nil
            let contextPtr = Unmanaged.passRetained(context).toOpaque()

            let rc = pthread_create(
                &thread,
                nil,
                { raw -> UnsafeMutableRawPointer? in
                    let ctx = Unmanaged<Context>.fromOpaque(raw).takeRetainedValue()

                    ctx.harness.update { $0.workerAttempting = true }

                    // This should block until main thread unlocks
                    ctx.mutex.lock()
                    ctx.harness.update { $0.workerAcquired = true }
                    ctx.mutex.unlock()

                    return nil
                },
                contextPtr
            )

            #expect(rc == 0, "pthread_create should succeed")

            // Wait for worker to start attempting
            try harness.wait(until: { $0.workerAttempting })

            // Worker should NOT have acquired yet (it should be blocked)
            #expect(
                harness.withLocked { $0.workerAcquired } == false,
                "Worker should be blocked waiting for mutex"
            )

            // Release the mutex
            mutex.unlock()

            // Now worker should acquire
            try harness.wait(until: { $0.workerAcquired })

            if let t = thread {
                pthread_join(t, nil)
            }
        }

        @Test
        func `mutex protects shared counter from data races`() throws {
            let mutex = Kernel.Thread.Mutex()

            struct State {
                var counter: Int = 0
                var threadsCompleted: Int = 0
            }
            let harness = KernelThreadTest.Harness(State())

            final class Context: @unchecked Sendable {
                let mutex: Kernel.Thread.Mutex
                let harness: KernelThreadTest.Harness<State>
                let iterations: Int

                init(mutex: Kernel.Thread.Mutex, harness: KernelThreadTest.Harness<State>, iterations: Int) {
                    self.mutex = mutex
                    self.harness = harness
                    self.iterations = iterations
                }
            }

            let iterations = 10_000
            let threadCount = 4
            let context = Context(mutex: mutex, harness: harness, iterations: iterations)

            var threads: [pthread_t?] = Array(repeating: nil, count: threadCount)

            for i in 0..<threadCount {
                let contextPtr = Unmanaged.passRetained(context).toOpaque()
                let rc = pthread_create(
                    &threads[i],
                    nil,
                    { raw -> UnsafeMutableRawPointer? in
                        let ctx = Unmanaged<Context>.fromOpaque(raw).takeRetainedValue()

                        for _ in 0..<ctx.iterations {
                            ctx.mutex.withLock {
                                ctx.harness.update { $0.counter += 1 }
                            }
                        }

                        ctx.harness.update { $0.threadsCompleted += 1 }
                        return nil
                    },
                    contextPtr
                )

                #expect(rc == 0, "pthread_create should succeed for thread \(i)")
            }

            // Wait for all threads to complete
            try harness.wait(until: { $0.threadsCompleted >= threadCount })

            for i in 0..<threadCount {
                if let t = threads[i] {
                    pthread_join(t, nil)
                }
            }

            let finalCount = harness.withLocked { $0.counter }
            #expect(
                finalCount == iterations * threadCount,
                "Counter should be exactly \(iterations * threadCount), got \(finalCount)"
            )
        }
    }

#endif
