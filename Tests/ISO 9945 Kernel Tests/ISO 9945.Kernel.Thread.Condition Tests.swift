import Error_Primitives
import ISO_9945_Kernel_Test_Support
import Path_Primitives
import Tagged_Primitives_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension ISO_9945.Kernel.Thread.Condition {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.Thread.Condition.Test.Unit {
    @Test
    func `init creates valid condition`() {
        let condition = ISO_9945.Kernel.Thread.Condition()
        _ = condition
    }

    @Test
    func `signal with no waiters is no-op`() {
        let condition = ISO_9945.Kernel.Thread.Condition()
        condition.signal()
    }

    @Test
    func `broadcast with no waiters is no-op`() {
        let condition = ISO_9945.Kernel.Thread.Condition()
        condition.broadcast()
    }

    @Test
    func `wait with timeout can return false`() {

        let mutex = ISO_9945.Kernel.Thread.Mutex()
        let condition = ISO_9945.Kernel.Thread.Condition()

        var sawTimeout = false
        let attempts = 10

        mutex.lock()
        for _ in 0..<attempts {
            let wasSignaled = condition.wait(mutex: mutex, timeout: .milliseconds(5))
            if !wasSignaled {
                sawTimeout = true
                break
            }

        }
        mutex.unlock()

        #expect(
            sawTimeout == true,
            "Should observe at least one timeout within \(attempts) attempts"
        )
    }

    @Test
    func `multiple conditions are independent`() {

        let mutex = ISO_9945.Kernel.Thread.Mutex()
        let condition1 = ISO_9945.Kernel.Thread.Condition()
        let condition2 = ISO_9945.Kernel.Thread.Condition()

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
        let condition = ISO_9945.Kernel.Thread.Condition()

        for _ in 0..<100 {
            condition.signal()
            condition.broadcast()
        }
    }
}

#if canImport(Darwin)

    extension ISO_9945.Kernel.Thread.Condition.Test.Unit {
        @Test
        func `signal wakes waiting thread`() throws {
            let mutex = ISO_9945.Kernel.Thread.Mutex()
            let condition = ISO_9945.Kernel.Thread.Condition()

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

            final class Context: @unchecked Sendable {
                let mutex: ISO_9945.Kernel.Thread.Mutex
                let condition: ISO_9945.Kernel.Thread.Condition
                let harness: KernelThreadTest.Harness<State>

                init(
                    mutex: ISO_9945.Kernel.Thread.Mutex,
                    condition: ISO_9945.Kernel.Thread.Condition,
                    harness: KernelThreadTest.Harness<State>
                ) {
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

                    ctx.harness.update { $0.phase = .aboutToWait }

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

            try harness.wait(until: { $0.phase == .aboutToWait })

            #if canImport(Darwin)
                sched_yield()
            #else
                pthread_yield()
            #endif

            mutex.lock()
            condition.signal()
            mutex.unlock()

            try harness.wait(until: { $0.phase == .doneWaiting })

            let result = harness.withLocked { $0.wokeWithoutTimeout }
            #expect(result == true, "Thread should have woken without timeout after signal")

            if let t = thread {
                pthread_join(t, nil)
            }
        }

        @Test
        func `broadcast wakes all waiting threads`() throws {
            let mutex = ISO_9945.Kernel.Thread.Mutex()
            let condition = ISO_9945.Kernel.Thread.Condition()
            let threadCount = 3

            struct State {
                var threadsWaiting = 0
                var threadsWoken = 0
            }
            let harness = KernelThreadTest.Harness(State())

            final class Context: @unchecked Sendable {
                let mutex: ISO_9945.Kernel.Thread.Mutex
                let condition: ISO_9945.Kernel.Thread.Condition
                let harness: KernelThreadTest.Harness<State>

                init(
                    mutex: ISO_9945.Kernel.Thread.Mutex,
                    condition: ISO_9945.Kernel.Thread.Condition,
                    harness: KernelThreadTest.Harness<State>
                ) {
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

            try harness.wait(until: { $0.threadsWaiting >= threadCount })

            #if canImport(Darwin)
                sched_yield()
            #else
                pthread_yield()
            #endif

            mutex.lock()
            condition.broadcast()
            mutex.unlock()

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
            let mutex = ISO_9945.Kernel.Thread.Mutex()
            let condition = ISO_9945.Kernel.Thread.Condition()

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
                let mutex: ISO_9945.Kernel.Thread.Mutex
                let condition: ISO_9945.Kernel.Thread.Condition
                let harness: KernelThreadTest.Harness<State>

                init(
                    mutex: ISO_9945.Kernel.Thread.Mutex,
                    condition: ISO_9945.Kernel.Thread.Condition,
                    harness: KernelThreadTest.Harness<State>
                ) {
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

                    ctx.harness.update { $0.phase = .isWaiting }
                    _ = ctx.condition.wait(mutex: ctx.mutex, timeout: .seconds(5))

                    ctx.harness.update { $0.phase = .doneWaiting }
                    ctx.mutex.unlock()
                    return nil
                },
                contextPtr
            )

            #expect(rc == 0, "pthread_create should succeed")

            try harness.wait(until: { $0.phase == .isWaiting })

            var acquired = false
            for _ in 0..<100 {
                do {
                    try mutex.lock.immediate()
                    acquired = true
                    break
                } catch {

                    #if canImport(Darwin)
                        usleep(1000)
                    #else
                        usleep(1000)
                    #endif
                }
            }
            harness.update { $0.mainAcquiredMutex = acquired }

            #expect(
                acquired == true,
                "Mutex should be released while thread is waiting on condition"
            )

            if acquired {

                condition.signal()
                mutex.unlock()
            }

            try harness.wait(until: { $0.phase == .doneWaiting })

            if let t = waiterThread {
                pthread_join(t, nil)
            }
        }

        @Test
        func `wait reacquires mutex before returning`() throws {
            let mutex = ISO_9945.Kernel.Thread.Mutex()
            let condition = ISO_9945.Kernel.Thread.Condition()

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
                let mutex: ISO_9945.Kernel.Thread.Mutex
                let condition: ISO_9945.Kernel.Thread.Condition
                let harness: KernelThreadTest.Harness<State>

                init(
                    mutex: ISO_9945.Kernel.Thread.Mutex,
                    condition: ISO_9945.Kernel.Thread.Condition,
                    harness: KernelThreadTest.Harness<State>
                ) {
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

                    ctx.harness.update { $0.phase = .returnedAndHoldingMutex }

                    do {
                        try ctx.harness.wait(until: { $0.phase == .acknowledged })
                    } catch {

                    }

                    ctx.mutex.unlock()
                    ctx.harness.update { $0.phase = .released }
                    return nil
                },
                contextPtr
            )

            #expect(rc == 0, "pthread_create should succeed")

            try harness.wait(until: { $0.phase == .isWaiting })

            #if canImport(Darwin)
                sched_yield()
            #else
                pthread_yield()
            #endif

            mutex.lock()
            condition.signal()
            mutex.unlock()

            try harness.wait(until: { $0.phase == .returnedAndHoldingMutex })

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

            try harness.wait(until: { $0.phase == .released })

            if let t = thread {
                pthread_join(t, nil)
            }

            let observed = harness.withLocked { $0.mainObservedHolding }
            #expect(observed == true, "Thread should hold mutex immediately after wait returns")
        }

        @Test
        func `producer-consumer pattern works correctly`() throws {
            let mutex = ISO_9945.Kernel.Thread.Mutex()
            let condition = ISO_9945.Kernel.Thread.Condition()
            let itemCount = 100

            struct State {
                var buffer: [Int] = []
                var produced = 0
                var consumed = 0
                var producerDone = false
            }
            let harness = KernelThreadTest.Harness(State())

            final class Context: @unchecked Sendable {
                let mutex: ISO_9945.Kernel.Thread.Mutex
                let condition: ISO_9945.Kernel.Thread.Condition
                let harness: KernelThreadTest.Harness<State>
                let itemCount: Int

                init(
                    mutex: ISO_9945.Kernel.Thread.Mutex,
                    condition: ISO_9945.Kernel.Thread.Condition,
                    harness: KernelThreadTest.Harness<State>,
                    itemCount: Int
                ) {
                    self.mutex = mutex
                    self.condition = condition
                    self.harness = harness
                    self.itemCount = itemCount
                }
            }
            let context = Context(
                mutex: mutex,
                condition: condition,
                harness: harness,
                itemCount: itemCount
            )

            var producerThread: pthread_t? = nil
            var consumerThread: pthread_t? = nil

            let consumerPtr = Unmanaged.passRetained(context).toOpaque()
            let consumerRc = pthread_create(
                &consumerThread,
                nil,
                { raw -> UnsafeMutableRawPointer? in
                    let ctx = Unmanaged<Context>.fromOpaque(raw).takeRetainedValue()

                    for _ in 0..<ctx.itemCount {
                        ctx.mutex.lock()

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
