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
import Kernel_Primitives_Core
import Kernel_Descriptor_Primitives
import Kernel_Event_Primitives
import Kernel_IO_Primitives
import Kernel_File_Primitives
import Path_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_Thread_Primitives
import Error_Primitives
import Synchronization
import Testing

@testable import ISO_9945_Kernel

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#endif

// MARK: - Test Suites for POSIX Thread Synchronization

@Suite("POSIX Thread Synchronization")
struct POSIXThreadSynchronizationTests {}

// MARK: - Mutex Unit Tests

extension POSIXThreadSynchronizationTests {
    @Suite("Mutex Unit")
    struct MutexUnit {}
}

extension POSIXThreadSynchronizationTests.MutexUnit {
    @Test
    func `mutex can be locked and unlocked`() {
        let mutex = ISO_9945.Kernel.Thread.Mutex()
        mutex.lock()
        mutex.unlock()
        // No error means success
    }

    @Test
    func `withLock executes body under lock`() {
        let mutex = ISO_9945.Kernel.Thread.Mutex()
        var executed = false

        mutex.withLock {
            executed = true
        }

        #expect(executed == true)
    }

    @Test
    func `withLock returns value from body`() {
        let mutex = ISO_9945.Kernel.Thread.Mutex()

        let result = mutex.withLock {
            42
        }

        #expect(result == 42)
    }

    @Test
    func `lock.immediate fails when mutex held`() throws {
        let mutex = ISO_9945.Kernel.Thread.Mutex()
        let held = Atomic<Bool>(false)
        let tryResult = Atomic<Bool>(false)
        let done = Atomic<Bool>(false)

        // Hold the mutex in another thread
        let handle = try ISO_9945.Kernel.Thread.create {
            mutex.lock()
            held.store(true, ordering: .releasing)
            // Wait until main thread has tried
            while !done.load(ordering: .acquiring) {
                ISO_9945.Kernel.Thread.yield()
            }
            mutex.unlock()
        }

        // Wait for thread to hold mutex
        while !held.load(ordering: .acquiring) {
            ISO_9945.Kernel.Thread.yield()
        }

        // Try immediate lock - should fail
        do {
            try mutex.lock.immediate()
            tryResult.store(true, ordering: .releasing)
            mutex.unlock()
        } catch {
            tryResult.store(false, ordering: .releasing)
        }

        done.store(true, ordering: .releasing)
        handle.join()

        #expect(tryResult.load(ordering: .acquiring) == false)
    }
}

// MARK: - Condition Unit Tests

extension POSIXThreadSynchronizationTests {
    @Suite("Condition Unit")
    struct ConditionUnit {}
}

extension POSIXThreadSynchronizationTests.ConditionUnit {
    @Test
    func `condition can signal without waiters`() {
        let condition = ISO_9945.Kernel.Thread.Condition()
        condition.signal()
        // No error means success
    }

    @Test
    func `condition can broadcast without waiters`() {
        let condition = ISO_9945.Kernel.Thread.Condition()
        condition.broadcast()
        // No error means success
    }

    @Test
    func `wait with timeout returns false on timeout`() {
        let mutex = ISO_9945.Kernel.Thread.Mutex()
        let condition = ISO_9945.Kernel.Thread.Condition()

        mutex.lock()
        let result = condition.wait(mutex: mutex, timeout: .milliseconds(10))
        mutex.unlock()

        #expect(result == false)  // Timed out
    }
}

// MARK: - Integration Tests

extension POSIXThreadSynchronizationTests {
    @Suite("Integration")
    struct Integration {}
}

/// Small sleep helper using usleep
private func smallSleep(milliseconds: UInt32) {
    #if canImport(Darwin)
        usleep(milliseconds * 1000)
    #elseif canImport(Glibc)
        usleep(milliseconds * 1000)
    #endif
}

extension POSIXThreadSynchronizationTests.Integration {
    @Test
    func `signal wakes one waiter`() throws {
        let mutex = ISO_9945.Kernel.Thread.Mutex()
        let condition = ISO_9945.Kernel.Thread.Condition()
        let waiterReady = Atomic<Bool>(false)
        let waiterWoken = Atomic<Bool>(false)

        let handle = try ISO_9945.Kernel.Thread.create {
            mutex.lock()
            waiterReady.store(true, ordering: .releasing)
            condition.wait(mutex: mutex)
            waiterWoken.store(true, ordering: .releasing)
            mutex.unlock()
        }

        // Wait for thread to enter wait
        while !waiterReady.load(ordering: .acquiring) {
            smallSleep(milliseconds: 1)
        }
        smallSleep(milliseconds: 20)

        // Signal
        mutex.lock()
        condition.signal()
        mutex.unlock()

        handle.join()

        #expect(waiterWoken.load(ordering: .acquiring) == true)
    }

    @Test
    func `broadcast wakes all waiters`() throws {
        let mutex = ISO_9945.Kernel.Thread.Mutex()
        let condition = ISO_9945.Kernel.Thread.Condition()
        let waitersReady = Atomic<Int>(0)
        let waitersWoken = Atomic<Int>(0)
        let numWaiters = 3

        // Spawn threads and join sequentially since Handle is ~Copyable
        let handle1 = try ISO_9945.Kernel.Thread.create {
            mutex.lock()
            waitersReady.wrappingAdd(1, ordering: .releasing)
            condition.wait(mutex: mutex)
            waitersWoken.wrappingAdd(1, ordering: .releasing)
            mutex.unlock()
        }
        let handle2 = try ISO_9945.Kernel.Thread.create {
            mutex.lock()
            waitersReady.wrappingAdd(1, ordering: .releasing)
            condition.wait(mutex: mutex)
            waitersWoken.wrappingAdd(1, ordering: .releasing)
            mutex.unlock()
        }
        let handle3 = try ISO_9945.Kernel.Thread.create {
            mutex.lock()
            waitersReady.wrappingAdd(1, ordering: .releasing)
            condition.wait(mutex: mutex)
            waitersWoken.wrappingAdd(1, ordering: .releasing)
            mutex.unlock()
        }

        // Wait for all threads to enter wait
        while waitersReady.load(ordering: .acquiring) < numWaiters {
            smallSleep(milliseconds: 1)
        }
        smallSleep(milliseconds: 30)

        // Broadcast
        mutex.lock()
        condition.broadcast()
        mutex.unlock()

        handle1.join()
        handle2.join()
        handle3.join()

        #expect(waitersWoken.load(ordering: .acquiring) == numWaiters)
    }

    @Test
    func `wait with timeout eventually times out`() throws {
        let mutex = ISO_9945.Kernel.Thread.Mutex()
        let condition = ISO_9945.Kernel.Thread.Condition()
        let timedOut = Atomic<Bool>(false)

        let handle = try ISO_9945.Kernel.Thread.create {
            mutex.lock()
            let result = condition.wait(mutex: mutex, timeout: .milliseconds(10))
            timedOut.store(!result, ordering: .releasing)  // false = timeout
            mutex.unlock()
        }

        handle.join()

        #expect(timedOut.load(ordering: .acquiring) == true)
    }

    @Test
    func `mutex protects shared state`() throws {
        let mutex = ISO_9945.Kernel.Thread.Mutex()
        let counter = Atomic<Int>(0)
        let iterations = 1000
        let numThreads = 4

        // Create and join threads sequentially since Handle is ~Copyable
        for _ in 0..<numThreads {
            let handle = try ISO_9945.Kernel.Thread.create {
                for _ in 0..<iterations {
                    mutex.lock()
                    counter.wrappingAdd(1, ordering: .relaxed)
                    mutex.unlock()
                }
            }
            handle.join()
        }

        #expect(counter.load(ordering: .acquiring) == numThreads * iterations)
    }

    @Test
    func `condition variable wait/signal ping-pong`() throws {
        let mutex = ISO_9945.Kernel.Thread.Mutex()
        let condition = ISO_9945.Kernel.Thread.Condition()
        let turn = Atomic<Int>(0)  // 0 = ping's turn, 1 = pong's turn
        let pingCount = Atomic<Int>(0)
        let pongCount = Atomic<Int>(0)
        let maxRounds = 5

        // Ping thread
        let ping = try ISO_9945.Kernel.Thread.create {
            mutex.lock()
            while pingCount.load(ordering: .acquiring) < maxRounds {
                while turn.load(ordering: .acquiring) != 0 {
                    condition.wait(mutex: mutex)
                }
                pingCount.wrappingAdd(1, ordering: .releasing)
                turn.store(1, ordering: .releasing)
                condition.signal()
            }
            mutex.unlock()
        }

        // Pong thread
        let pong = try ISO_9945.Kernel.Thread.create {
            mutex.lock()
            while pongCount.load(ordering: .acquiring) < maxRounds {
                while turn.load(ordering: .acquiring) != 1 {
                    condition.wait(mutex: mutex)
                }
                pongCount.wrappingAdd(1, ordering: .releasing)
                turn.store(0, ordering: .releasing)
                condition.signal()
            }
            mutex.unlock()
        }

        ping.join()
        pong.join()

        #expect(pingCount.load(ordering: .acquiring) == maxRounds)
        #expect(pongCount.load(ordering: .acquiring) == maxRounds)
    }
}

