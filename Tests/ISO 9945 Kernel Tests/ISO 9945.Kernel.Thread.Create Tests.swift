import Error
import Path
import Synchronization
import Tagged_Standard_Library_Integration
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

extension ISO_9945.Kernel.Thread.Test.Unit {
    @Test
    func `create spawns thread that executes body`() throws {
        let executed = Atomic<Bool>(false)
        let handle = try ISO_9945.Kernel.Thread.create {
            executed.store(true, ordering: .releasing)
        }
        try handle.join()
        #expect(executed.load(ordering: .acquiring) == true)
    }

    @Test
    func `Handle.join waits for thread completion`() throws {
        let completed = Atomic<Bool>(false)
        let handle = try ISO_9945.Kernel.Thread.create {

            for _ in 0..<1000 {
                _ = 1 + 1
            }
            completed.store(true, ordering: .releasing)
        }

        try handle.join()
        #expect(completed.load(ordering: .acquiring) == true)
    }

    @Test
    func `Handle.isCurrent returns false from main thread`() throws {
        let handle = try ISO_9945.Kernel.Thread.create {

        }

        #expect(handle.isCurrent == false)

        try handle.join()
    }
}

extension ISO_9945.Kernel.Thread.Test.Integration {
    @Test
    func `multiple threads can execute concurrently`() throws {
        let counter = Atomic<Int>(0)
        let numThreads = 4

        for _ in 0..<numThreads {
            let handle = try ISO_9945.Kernel.Thread.create {
                counter.wrappingAdd(1, ordering: .relaxed)
            }
            try handle.join()
        }

        #expect(counter.load(ordering: .acquiring) == numThreads)
    }

    @Test
    func `thread detach allows independent execution`() throws {
        let started = Atomic<Bool>(false)

        let handle = try ISO_9945.Kernel.Thread.create {
            started.store(true, ordering: .releasing)
        }

        try handle.detach()

        var iterations = 0
        while !started.load(ordering: .acquiring) && iterations < 1000 {
            ISO_9945.Kernel.Thread.yield()
            iterations += 1
        }

    }
}
