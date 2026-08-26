import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

@Suite("ISO_9945.Kernel.Thread.Yield")
struct KernelThreadYieldTests {

    @Test
    func `yield completes without error`() {

        ISO_9945.Kernel.Thread.yield()
    }

    @Test
    func `yield can be called repeatedly`() {

        for _ in 0..<100 {
            ISO_9945.Kernel.Thread.yield()
        }
    }

    @Test
    func `yield from concurrent tasks`() async {

        let iterations = 100
        let taskCount = 4

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<taskCount {
                group.addTask {
                    for _ in 0..<iterations {
                        ISO_9945.Kernel.Thread.yield()
                    }
                }
            }
        }
    }
}

#if canImport(Darwin)
    import Darwin

    extension KernelThreadYieldTests {
        @Test
        func `yield from multiple OS threads`() throws {

            let threadCount = 4
            let iterations = 100
            var threads: [pthread_t?] = Array(repeating: nil, count: threadCount)

            final class Context: @unchecked Sendable {
                let iterations: Int
                init(iterations: Int) { self.iterations = iterations }
            }

            for i in 0..<threadCount {
                let context = Context(iterations: iterations)
                let contextPtr = Unmanaged.passRetained(context).toOpaque()

                let result = pthread_create(
                    &threads[i],
                    nil,
                    { raw -> UnsafeMutableRawPointer? in
                        let ctx = Unmanaged<Context>.fromOpaque(raw).takeRetainedValue()

                        for _ in 0..<ctx.iterations {
                            ISO_9945.Kernel.Thread.yield()
                        }

                        return nil
                    },
                    contextPtr
                )

                guard result == 0 else {

                    for j in 0..<i {
                        if let thread = threads[j] {
                            pthread_join(thread, nil)
                        }
                    }
                    throw TestError.threadCreationFailed(errno: result)
                }
            }

            for thread in threads {
                if let thread {
                    pthread_join(thread, nil)
                }
            }
        }

        enum TestError: Swift.Error {
            case threadCreationFailed(errno: Int32)
        }
    }
#endif
