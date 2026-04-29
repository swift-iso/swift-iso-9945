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
import Kernel_File_Primitives
import Path_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_Thread_Primitives
import Error_Primitives
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

extension Kernel.Thread.Condition {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - API Unit Tests

extension Kernel.Thread.Condition.Test.Unit {
    @Test
    func `init creates valid condition`() {
        let condition = Kernel.Thread.Condition()
        _ = condition
    }

    @Test
    func `signal with no waiters is no-op`() {
        let condition = Kernel.Thread.Condition()
        condition.signal()
    }

    @Test
    func `broadcast with no waiters is no-op`() {
        let condition = Kernel.Thread.Condition()
        condition.broadcast()
    }

    @Test
    func `wait with timeout can return false`() {
        // NOTE: We cannot assert a single timed wait MUST return false because
        // both POSIX pthread_cond_timedwait and Windows SleepConditionVariableSRW
        // allow spurious wakeups (returning success without being signaled).
        //
        // This test verifies the timeout path is reachable by attempting multiple
        // short waits. At least one should time out within a reasonable bound.
        let mutex = Kernel.Thread.Mutex()
        let condition = Kernel.Thread.Condition()

        var sawTimeout = false
        let attempts = 10

        mutex.lock()
        for _ in 0..<attempts {
            let wasSignaled = condition.wait(mutex: mutex, timeout: .milliseconds(5))
            if !wasSignaled {
                sawTimeout = true
                break
            }
            // Spurious wake - try again
        }
        mutex.unlock()

        #expect(sawTimeout == true, "Should observe at least one timeout within \(attempts) attempts")
    }

    @Test
    func `multiple conditions are independent`() {
        // Same note about spurious wakes - we verify independence structurally
        // by checking that signaling one condition doesn't affect the other.
        let mutex = Kernel.Thread.Mutex()
        let condition1 = Kernel.Thread.Condition()
        let condition2 = Kernel.Thread.Condition()

        // Both should eventually timeout (allowing for spurious wakes)
        var sawTimeout1 = false
        var sawTimeout2 = false

        mutex.lock()
        for _ in 0..<10 {
            if !condition1.wait(mutex: mutex, timeout: .milliseconds(1)) {
                sawTimeout1 = true
                break
            }
        }
        for _ in 0..<10 {
            if !condition2.wait(mutex: mutex, timeout: .milliseconds(1)) {
                sawTimeout2 = true
                break
            }
        }
        mutex.unlock()

        #expect(sawTimeout1 == true)
        #expect(sawTimeout2 == true)
    }

    @Test
    func `signal and broadcast can be called repeatedly`() {
        let condition = Kernel.Thread.Condition()

        for _ in 0..<100 {
            condition.signal()
            condition.broadcast()
        }
    }
}

// MARK: - Condition Variable Semantics Tests (require threading)
//
// These tests use KernelThreadTest.Harness to coordinate between threads
// without data races or timing-based assertions.

// NOTE: These tests use Darwin-specific pthread API.
// Linux pthread API differs (non-optional pthread_t, different closure signature).
// TODO: Add Linux-compatible threading tests to swift-linux package.
#if canImport(Darwin)

    extension Kernel.Thread.Condition.Test.Unit {
        @Test
        func `signal wakes waiting thread`() throws {
            let mutex = Kernel.Thread.Mutex()
            let condition = Kernel.Thread.Condition()

            struct State {
                var phase: Phase = .initial
                var wokeWithoutTimeout = false

                enum Phase {
                    case initial
                    case aboutToWait
                    case doneWaiting
                }
            }
            let harness = KernelThreadTest.Harness(State())

            var thread: pthread_t? = nil

            // Pack both mutex, condition, and harness into a context
            final class Context: @unchecked Sendable {
                let mutex: Kernel.Thread.Mutex
                let condition: Kernel.Thread.Condition
                let harness: KernelThreadTest.Harness<State>

                init(mutex: Kernel.Thread.Mutex, condition: Kernel.Thread.Condition, harness: KernelThreadTest.Harness<State>) {
                    self.mutex = mutex
                    self.condition = condition
                    self.harness = harness
                }
            }
            let context = Context(mutex: mutex, condition: condition, harness: harness)
            let contextPtr = Unmanaged.passRetained(context).toOpaque()

            let rc = pthread_create(
                &thread,
                nil,
                { raw -> UnsafeMutableRawPointer? in
                    let ctx = Unmanaged<Context>.fromOpaque(raw).takeRetainedValue()

                    ctx.mutex.lock()

                    // Signal that we're about to wait
                    ctx.harness.update { $0.phase = .aboutToWait }

                    // Wait for signal (with timeout as deadlock guard)
                    // Loop to handle spurious wakeups - we wait until actually signaled
                    // In a proper condvar usage, we'd check a predicate here
                    let woke = ctx.condition.wait(mutex: ctx.mutex, timeout: .seconds(5))

                    ctx.harness.update {
                        $0.wokeWithoutTimeout = woke
                        $0.phase = .doneWaiting
                    }

                    ctx.mutex.unlock()
                    return nil
                },
                contextPtr
            )

            #expect(rc == 0, "pthread_create should succeed")

            // Wait for worker to be in wait state
            try harness.wait(until: { $0.phase == .aboutToWait })

            // Small yield to ensure thread has entered the actual wait syscall
            // This is still a heuristic but better than nothing
            #if canImport(Darwin)
                sched_yield()
            #else
                pthread_yield()
            #endif

            // Signal the condition
            mutex.lock()
            condition.signal()
            mutex.unlock()

            // Wait for worker to finish
            try harness.wait(until: { $0.phase == .doneWaiting })

            let result = harness.withLocked { $0.wokeWithoutTimeout }
            #expect(result == true, "Thread should have woken without timeout after signal")

            if let t = thread {
                pthread_join(t, nil)
            }
        }

        @Test
        func `broadcast wakes all waiting threads`() throws {
            let mutex = Kernel.Thread.Mutex()
            let condition = Kernel.Thread.Condition()
            let threadCount = 3

            struct State {
                var threadsWaiting = 0
                var threadsWoken = 0
            }
            let harness = KernelThreadTest.Harness(State())

            final class Context: @unchecked Sendable {
                let mutex: Kernel.Thread.Mutex
                let condition: Kernel.Thread.Condition
                let harness: KernelThreadTest.Harness<State>

                init(mutex: Kernel.Thread.Mutex, condition: Kernel.Thread.Condition, harness: KernelThreadTest.Harness<State>) {
                    self.mutex = mutex
                    self.condition = condition
                    self.harness = harness
                }
            }
            let context = Context(mutex: mutex, condition: condition, harness: harness)

            var threads: [pthread_t?] = Array(repeating: nil, count: threadCount)

            for i in 0..<threadCount {
                let contextPtr = Unmanaged.passRetained(context).toOpaque()
                let rc = pthread_create(
                    &threads[i],
                    nil,
                    { raw -> UnsafeMutableRawPointer? in
                        let ctx = Unmanaged<Context>.fromOpaque(raw).takeRetainedValue()

                        ctx.mutex.lock()

                        ctx.harness.update { $0.threadsWaiting += 1 }

                        // Wait with timeout as deadlock guard
                        let woke = ctx.condition.wait(mutex: ctx.mutex, timeout: .seconds(5))

                        if woke {
                            ctx.harness.update { $0.threadsWoken += 1 }
                        }

                        ctx.mutex.unlock()
                        return nil
                    },
                    contextPtr
                )

                #expect(rc == 0, "pthread_create should succeed for thread \(i)")
            }

            // Wait for all threads to be waiting
            try harness.wait(until: { $0.threadsWaiting >= threadCount })

            // Yield to help ensure threads have entered wait syscall
            #if canImport(Darwin)
                sched_yield()
            #else
                pthread_yield()
            #endif

            // Broadcast to wake all
            mutex.lock()
            condition.broadcast()
            mutex.unlock()

            // Wait for all threads to wake
            try harness.wait(until: { $0.threadsWoken >= threadCount })

            for i in 0..<threadCount {
                if let t = threads[i] {
                    pthread_join(t, nil)
                }
            }

            let woken = harness.withLocked { $0.threadsWoken }
            #expect(woken == threadCount, "All \(threadCount) threads should wake, got \(woken)")
        }

        @Test
        func `wait releases mutex while waiting`() throws {
            let mutex = Kernel.Thread.Mutex()
            let condition = Kernel.Thread.Condition()

            struct State {
                var phase: Phase = .initial
                var mainAcquiredMutex = false

                enum Phase {
                    case initial
                    case hasLocked
                    case isWaiting
                    case doneWaiting
                }
            }
            let harness = KernelThreadTest.Harness(State())

            final class Context: @unchecked Sendable {
                let mutex: Kernel.Thread.Mutex
                let condition: Kernel.Thread.Condition
                let harness: KernelThreadTest.Harness<State>

                init(mutex: Kernel.Thread.Mutex, condition: Kernel.Thread.Condition, harness: KernelThreadTest.Harness<State>) {
                    self.mutex = mutex
                    self.condition = condition
                    self.harness = harness
                }
            }
            let context = Context(mutex: mutex, condition: condition, harness: harness)
            let contextPtr = Unmanaged.passRetained(context).toOpaque()

            var waiterThread: pthread_t? = nil

            let rc = pthread_create(
                &waiterThread,
                nil,
                { raw -> UnsafeMutableRawPointer? in
                    let ctx = Unmanaged<Context>.fromOpaque(raw).takeRetainedValue()

                    ctx.mutex.lock()
                    ctx.harness.update { $0.phase = .hasLocked }

                    // Signal we're about to wait, then immediately enter wait
                    ctx.harness.update { $0.phase = .isWaiting }
                    _ = ctx.condition.wait(mutex: ctx.mutex, timeout: .seconds(5))

                    ctx.harness.update { $0.phase = .doneWaiting }
                    ctx.mutex.unlock()
                    return nil
                },
                contextPtr
            )

            #expect(rc == 0, "pthread_create should succeed")

            // Wait for waiter to be in wait state
            try harness.wait(until: { $0.phase == .isWaiting })

            // Poll lock.immediate with retries - the waiter needs time to actually enter
            // the wait syscall after setting the phase flag
            var acquired = false
            for _ in 0..<100 {
                do {
                    try mutex.lock.immediate()
                    acquired = true
                    break
                } catch {
                    // Small delay between retries (1ms)
                    #if canImport(Darwin)
                        usleep(1000)
                    #else
                        usleep(1000)
                    #endif
                }
            }
            harness.update { $0.mainAcquiredMutex = acquired }

            #expect(acquired == true, "Mutex should be released while thread is waiting on condition")

            if acquired {
                // Signal to let waiter proceed, then unlock
                condition.signal()
                mutex.unlock()
            }

            // Wait for waiter to finish
            try harness.wait(until: { $0.phase == .doneWaiting })

            if let t = waiterThread {
                pthread_join(t, nil)
            }
        }

        @Test
        func `wait reacquires mutex before returning`() throws {
            let mutex = Kernel.Thread.Mutex()
            let condition = Kernel.Thread.Condition()

            struct State {
                var phase: Phase = .initial
                var mainObservedHolding = false

                enum Phase {
                    case initial
                    case isWaiting
                    case returnedAndHoldingMutex
                    case acknowledged
                    case released
                }
            }
            let harness = KernelThreadTest.Harness(State())

            final class Context: @unchecked Sendable {
                let mutex: Kernel.Thread.Mutex
                let condition: Kernel.Thread.Condition
                let harness: KernelThreadTest.Harness<State>

                init(mutex: Kernel.Thread.Mutex, condition: Kernel.Thread.Condition, harness: KernelThreadTest.Harness<State>) {
                    self.mutex = mutex
                    self.condition = condition
                    self.harness = harness
                }
            }
            let context = Context(mutex: mutex, condition: condition, harness: harness)
            let contextPtr = Unmanaged.passRetained(context).toOpaque()

            var thread: pthread_t? = nil

            let rc = pthread_create(
                &thread,
                nil,
                { raw -> UnsafeMutableRawPointer? in
                    let ctx = Unmanaged<Context>.fromOpaque(raw).takeRetainedValue()

                    ctx.mutex.lock()
                    ctx.harness.update { $0.phase = .isWaiting }

                    _ = ctx.condition.wait(mutex: ctx.mutex, timeout: .seconds(5))

                    // Immediately after wait returns, we should hold the mutex
                    ctx.harness.update { $0.phase = .returnedAndHoldingMutex }

                    // Wait for main thread to acknowledge it observed this phase
                    // while we still hold the mutex
                    do {
                        try ctx.harness.wait(until: { $0.phase == .acknowledged })
                    } catch {
                        // Timeout - proceed anyway
                    }

                    ctx.mutex.unlock()
                    ctx.harness.update { $0.phase = .released }
                    return nil
                },
                contextPtr
            )

            #expect(rc == 0, "pthread_create should succeed")

            // Wait for thread to be waiting
            try harness.wait(until: { $0.phase == .isWaiting })

            // Yield and signal
            #if canImport(Darwin)
                sched_yield()
            #else
                pthread_yield()
            #endif

            mutex.lock()
            condition.signal()
            mutex.unlock()

            // Wait for thread to report it's holding mutex after wait returned
            try harness.wait(until: { $0.phase == .returnedAndHoldingMutex })

            // Verify thread is holding mutex by checking lock.immediate throws
            var mainCanAcquire = false
            do {
                try mutex.lock.immediate()
                mainCanAcquire = true
                mutex.unlock()
            } catch {
                mainCanAcquire = false
            }

            harness.update {
                $0.mainObservedHolding = !mainCanAcquire
                $0.phase = .acknowledged
            }

            // Wait for thread to finish
            try harness.wait(until: { $0.phase == .released })

            if let t = thread {
                pthread_join(t, nil)
            }

            let observed = harness.withLocked { $0.mainObservedHolding }
            #expect(observed == true, "Thread should hold mutex immediately after wait returns")
        }

        @Test
        func `producer-consumer pattern works correctly`() throws {
            let mutex = Kernel.Thread.Mutex()
            let condition = Kernel.Thread.Condition()
            let itemCount = 100

            struct State {
                var buffer: [Int] = []
                var produced = 0
                var consumed = 0
                var producerDone = false
            }
            let harness = KernelThreadTest.Harness(State())

            final class Context: @unchecked Sendable {
                let mutex: Kernel.Thread.Mutex
                let condition: Kernel.Thread.Condition
                let harness: KernelThreadTest.Harness<State>
                let itemCount: Int

                init(mutex: Kernel.Thread.Mutex, condition: Kernel.Thread.Condition, harness: KernelThreadTest.Harness<State>, itemCount: Int) {
                    self.mutex = mutex
                    self.condition = condition
                    self.harness = harness
                    self.itemCount = itemCount
                }
            }
            let context = Context(mutex: mutex, condition: condition, harness: harness, itemCount: itemCount)

            var producerThread: pthread_t? = nil
            var consumerThread: pthread_t? = nil

            // Consumer thread
            let consumerPtr = Unmanaged.passRetained(context).toOpaque()
            let consumerRc = pthread_create(
                &consumerThread,
                nil,
                { raw -> UnsafeMutableRawPointer? in
                    let ctx = Unmanaged<Context>.fromOpaque(raw).takeRetainedValue()

                    for _ in 0..<ctx.itemCount {
                        ctx.mutex.lock()

                        // Proper condvar pattern: loop on predicate to handle spurious wakes
                        while ctx.harness.withLocked({ $0.buffer.isEmpty && !$0.producerDone }) {
                            _ = ctx.condition.wait(mutex: ctx.mutex, timeout: .milliseconds(100))
                        }

                        let isEmpty = ctx.harness.withLocked { $0.buffer.isEmpty }
                        if !isEmpty {
                            ctx.harness.update {
                                _ = $0.buffer.removeFirst()
                                $0.consumed += 1
                            }
                        }

                        ctx.mutex.unlock()
                    }
                    return nil
                },
                consumerPtr
            )

            #expect(consumerRc == 0, "pthread_create should succeed for consumer")

            // Producer thread
            let producerPtr = Unmanaged.passRetained(context).toOpaque()
            let producerRc = pthread_create(
                &producerThread,
                nil,
                { raw -> UnsafeMutableRawPointer? in
                    let ctx = Unmanaged<Context>.fromOpaque(raw).takeRetainedValue()

                    for i in 0..<ctx.itemCount {
                        ctx.mutex.lock()
                        ctx.harness.update {
                            $0.buffer.append(i)
                            $0.produced += 1
                        }
                        ctx.condition.signal()
                        ctx.mutex.unlock()

                        // Small yield to allow consumer to run
                        #if canImport(Darwin)
                            sched_yield()
                        #else
                            pthread_yield()
                        #endif
                    }

                    ctx.mutex.lock()
                    ctx.harness.update { $0.producerDone = true }
                    ctx.condition.broadcast()
                    ctx.mutex.unlock()
                    return nil
                },
                producerPtr
            )

            #expect(producerRc == 0, "pthread_create should succeed for producer")

            if let t = producerThread {
                pthread_join(t, nil)
            }
            if let t = consumerThread {
                pthread_join(t, nil)
            }

            let (produced, consumed) = harness.withLocked { ($0.produced, $0.consumed) }
            #expect(produced == itemCount, "Should produce \(itemCount) items, got \(produced)")
            #expect(consumed == itemCount, "Should consume \(itemCount) items, got \(consumed)")
        }
    }

#endif
