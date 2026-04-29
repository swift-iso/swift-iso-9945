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

import Testing
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
@testable import ISO_9945_Kernel

@Suite("Kernel.Thread.Yield")
struct KernelThreadYieldTests {

    @Test
    func `yield completes without error`() {
        // Basic smoke test - yield should complete without crashing
        Kernel.Thread.yield()
    }

    @Test
    func `yield can be called repeatedly`() {
        // Verify repeated yields don't cause issues
        for _ in 0..<100 {
            Kernel.Thread.yield()
        }
    }

    @Test
    func `yield from concurrent tasks`() async {
        // Verify yield works correctly when called from concurrent tasks
        // Note: This tests concurrent task execution, not necessarily
        // multiple OS threads (Swift runtime decides thread mapping)
        let iterations = 100
        let taskCount = 4

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<taskCount {
                group.addTask {
                    for _ in 0..<iterations {
                        Kernel.Thread.yield()
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
        // Test yield from actual OS threads using pthread
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
                        Kernel.Thread.yield()
                    }

                    return nil
                },
                contextPtr
            )

            guard result == 0 else {
                // Clean up any threads that were created
                for j in 0..<i {
                    if let thread = threads[j] {
                        pthread_join(thread, nil)
                    }
                }
                throw TestError.threadCreationFailed(errno: result)
            }
        }

        // Join all threads
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
