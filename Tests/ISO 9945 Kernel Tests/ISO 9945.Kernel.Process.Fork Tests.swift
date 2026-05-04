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
import Tagged_Primitives_Standard_Library_Integration

    import Path_Primitives
    import Error_Primitives
    @testable import ISO_9945_Kernel

    extension ISO_9945.Kernel.Process.Fork {
        @Suite
        struct Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension ISO_9945.Kernel.Process.Fork.Test.Unit {
        @Test
        func `Result.child is distinct from Result.parent`() {
            let child = ISO_9945.Kernel.Process.Fork.Result.child
            let parent = ISO_9945.Kernel.Process.Fork.Result.parent(child: ISO_9945.Kernel.Process.ID(123))

            #expect(child != parent)
        }

        @Test
        func `Result is Sendable`() {
            let result: any Sendable = ISO_9945.Kernel.Process.Fork.Result.child
            #expect(result is ISO_9945.Kernel.Process.Fork.Result)
        }

        @Test
        func `Result is Equatable`() {
            let pid = ISO_9945.Kernel.Process.ID(42)
            #expect(ISO_9945.Kernel.Process.Fork.Result.child == ISO_9945.Kernel.Process.Fork.Result.child)
            #expect(
                ISO_9945.Kernel.Process.Fork.Result.parent(child: pid)
                    == ISO_9945.Kernel.Process.Fork.Result.parent(child: pid)
            )
            #expect(
                ISO_9945.Kernel.Process.Fork.Result.parent(child: pid)
                    != ISO_9945.Kernel.Process.Fork.Result.parent(child: ISO_9945.Kernel.Process.ID(99))
            )
        }
    }

    // MARK: - Integration Tests
    //
    // NOTE: These tests use posix_spawn via POSIXTestHelper instead of fork() directly
    // to avoid Swift runtime lock corruption in multithreaded test environments.

    extension ISO_9945.Kernel.Process.Fork.Test.Integration {
        @Test
        func `spawned child process can exit with code`() throws {
            // Spawn helper that exits with code 42
            let child = try POSIXTestHelper.spawn("exit", "42")

            // Wait for child and verify exit code
            let result = try ISO_9945.Kernel.Process.Wait.wait(.process(child))
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
            _ = try? ISO_9945.Kernel.Process.Wait.wait(.process(child))
        }

        @Test
        func `child PID matches wait result PID`() throws {
            // Spawn helper that exits with code 0
            let child = try POSIXTestHelper.spawn("exit", "0")

            let result = try ISO_9945.Kernel.Process.Wait.wait(.process(child))
            #expect(result?.pid == child)
        }
    }

#endif
