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

#if os(macOS)

import Testing

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
    @testable import ISO_9945_Kernel

    extension Kernel.Process.Fork {
        @Suite
        struct Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.Process.Fork.Test.Unit {
        @Test
        func `Result.child is distinct from Result.parent`() {
            let child = Kernel.Process.Fork.Result.child
            let parent = Kernel.Process.Fork.Result.parent(child: Kernel.Process.ID(123))

            #expect(child != parent)
        }

        @Test
        func `Result is Sendable`() {
            let result: any Sendable = Kernel.Process.Fork.Result.child
            #expect(result is Kernel.Process.Fork.Result)
        }

        @Test
        func `Result is Equatable`() {
            let pid = Kernel.Process.ID(42)
            #expect(Kernel.Process.Fork.Result.child == Kernel.Process.Fork.Result.child)
            #expect(
                Kernel.Process.Fork.Result.parent(child: pid)
                    == Kernel.Process.Fork.Result.parent(child: pid)
            )
            #expect(
                Kernel.Process.Fork.Result.parent(child: pid)
                    != Kernel.Process.Fork.Result.parent(child: Kernel.Process.ID(99))
            )
        }
    }

    // MARK: - Integration Tests
    //
    // NOTE: These tests use posix_spawn via POSIXTestHelper instead of fork() directly
    // to avoid Swift runtime lock corruption in multithreaded test environments.

    extension Kernel.Process.Fork.Test.Integration {
        @Test
        func `spawned child process can exit with code`() throws {
            // Spawn helper that exits with code 42
            let child = try POSIXTestHelper.spawn("exit", "42")

            // Wait for child and verify exit code
            let result = try Kernel.Process.Wait.wait(.process(child))
            #expect(result != nil)
            #expect(result?.pid == child)
            #expect(result?.status.exited == true)
            #expect(result?.status.exit.code == 42)
        }

        @Test
        func `spawned child PID is positive`() throws {
            // Spawn helper that exits with code 0
            let child = try POSIXTestHelper.spawn("exit", "0")

            // Child PID must be positive
            #expect(child.rawValue > 0)

            // Clean up
            _ = try? Kernel.Process.Wait.wait(.process(child))
        }

        @Test
        func `child PID matches wait result PID`() throws {
            // Spawn helper that exits with code 0
            let child = try POSIXTestHelper.spawn("exit", "0")

            let result = try Kernel.Process.Wait.wait(.process(child))
            #expect(result?.pid == child)
        }
    }

#endif
