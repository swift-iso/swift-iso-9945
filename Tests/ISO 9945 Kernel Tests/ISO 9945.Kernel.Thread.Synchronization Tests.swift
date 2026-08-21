import Error_Primitives
import Path_Primitives
import Synchronization
import Tagged_Primitives_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#endif

@Suite("POSIX Thread Synchronization")
struct POSIXThreadSynchronizationTests {}

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

        let handle = try ISO_9945.Kernel.Thread.create {
            mutex.lock()
            held.store(true, ordering: .releasing)

            while !done.load(ordering: .acquiring) {
                ISO_9945.Kernel.Thread.yield()
            }
            mutex.unlock()
        }

        while !held.load(ordering: .acquiring) {
            ISO_9945.Kernel.Thread.yield()
        }

        do {
            try mutex.lock.immediate()
            tryResult.store(true, ordering: .releasing)
            mutex.unlock()
        } catch {
            tryResult.store(false, ordering: .releasing)
        }

        done.store(true, ordering: .releasing)
        try handle.join()

        #expect(tryResult.load(ordering: .acquiring) == false)
    }
}

extension POSIXThreadSynchronizationTests {
    @Suite("Condition Unit")
    struct ConditionUnit {}
}

extension POSIXThreadSynchronizationTests.ConditionUnit {
    @Test
    func `condition can signal without waiters`() {
        let condition = ISO_9945.Kernel.Thread.Condition()
        condition.signal()

    }

    @Test
    func `condition can broadcast without waiters`() {
        let condition = ISO_9945.Kernel.Thread.Condition()
        condition.broadcast()

    }

    @Test
    func `wait with timeout returns false on timeout`() {
        let mutex = ISO_9945.Kernel.Thread.Mutex()
        let condition = ISO_9945.Kernel.Thread.Condition()

        mutex.lock()
        let result = condition.wait(mutex: mutex, timeout: .milliseconds(10))
        mutex.unlock()

        #expect(result == false)
    }
}

extension POSIXThreadSynchronizationTests {
    @Suite("Integration")
    struct Integration {}
}

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

        while !waiterReady.load(ordering: .acquiring) {
            smallSleep(milliseconds: 1)
        }
        smallSleep(milliseconds: 20)

        mutex.lock()
        condition.signal()
        mutex.unlock()

        try handle.join()

        #expect(waiterWoken.load(ordering: .acquiring) == true)
    }

    @Test
    func `broadcast wakes all waiters`() throws {
        let mutex = ISO_9945.Kernel.Thread.Mutex()
        let condition = ISO_9945.Kernel.Thread.Condition()
        let waitersReady = Atomic<Int>(0)
        let waitersWoken = Atomic<Int>(0)
        let numWaiters = 3

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

        while waitersReady.load(ordering: .acquiring) < numWaiters {
            smallSleep(milliseconds: 1)
        }
        smallSleep(milliseconds: 30)

        mutex.lock()
        condition.broadcast()
        mutex.unlock()

        try handle1.join()
        try handle2.join()
        try handle3.join()

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
            timedOut.store(!result, ordering: .releasing)
            mutex.unlock()
        }

        try handle.join()

        #expect(timedOut.load(ordering: .acquiring) == true)
    }

    @Test
    func `mutex protects shared state`() throws {
        let mutex = ISO_9945.Kernel.Thread.Mutex()
        let counter = Atomic<Int>(0)
        let iterations = 1000
        let numThreads = 4

        for _ in 0..<numThreads {
            let handle = try ISO_9945.Kernel.Thread.create {
                for _ in 0..<iterations {
                    mutex.lock()
                    counter.wrappingAdd(1, ordering: .relaxed)
                    mutex.unlock()
                }
            }
            try handle.join()
        }

        #expect(counter.load(ordering: .acquiring) == numThreads * iterations)
    }

    @Test
    func `condition variable wait/signal ping-pong`() throws {
        let mutex = ISO_9945.Kernel.Thread.Mutex()
        let condition = ISO_9945.Kernel.Thread.Condition()
        let turn = Atomic<Int>(0)
        let pingCount = Atomic<Int>(0)
        let pongCount = Atomic<Int>(0)
        let maxRounds = 5

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

        try ping.join()
        try pong.join()

        #expect(pingCount.load(ordering: .acquiring) == maxRounds)
        #expect(pongCount.load(ordering: .acquiring) == maxRounds)
    }
}
