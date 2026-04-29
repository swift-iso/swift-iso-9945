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
import Tagged_Primitives_Test_Support

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
import ISO_9945_Kernel

    extension Kernel.Process.Wait {
        @Suite
        struct Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Selector Tests

    extension Kernel.Process.Wait.Test.Unit {
        @Test
        func `Selector cases are distinct`() {
            let pid = Kernel.Process.ID(123)
            let pgid = Kernel.Process.Group.ID(456)

            let cases: [Kernel.Process.Wait.Selector] = [
                .any,
                .process(pid),
                .group(pgid),
                .current,
            ]

            for (i, a) in cases.enumerated() {
                for (j, b) in cases.enumerated() {
                    if i != j {
                        #expect(a != b, "Cases at index \(i) and \(j) should be different")
                    }
                }
            }
        }

        @Test
        func `Selector is Sendable`() {
            let selector: any Sendable = Kernel.Process.Wait.Selector.any
            #expect(selector is Kernel.Process.Wait.Selector)
        }

        @Test
        func `Selector is Equatable`() {
            let pid = Kernel.Process.ID(42)
            #expect(Kernel.Process.Wait.Selector.any == Kernel.Process.Wait.Selector.any)
            #expect(
                Kernel.Process.Wait.Selector.process(pid)
                    == Kernel.Process.Wait.Selector.process(pid)
            )
        }
    }

    // MARK: - Options Tests

    extension Kernel.Process.Wait.Test.Unit {
        @Test
        func `Options is OptionSet`() {
            let options: Kernel.Process.Wait.Options = [.untraced, .continued]
            #expect(options.contains(.untraced))
            #expect(options.contains(.continued))
        }

        @Test
        func `no.hang accessor works`() {
            let noHang = Kernel.Process.Wait.Options.no.hang
            #expect(noHang.rawValue != 0)
        }
    }

    // MARK: - Result Tests

    extension Kernel.Process.Wait.Test.Unit {
        @Test
        func `Result is Sendable`() {
            let result: any Sendable = Kernel.Process.Wait.Result(
                pid: Kernel.Process.ID(1),
                status: Kernel.Process.Status(rawValue: 0)
            )
            #expect(result is Kernel.Process.Wait.Result)
        }

        @Test
        func `Result is Equatable`() {
            let result1 = Kernel.Process.Wait.Result(
                pid: Kernel.Process.ID(42),
                status: Kernel.Process.Status(rawValue: 0)
            )
            let result2 = Kernel.Process.Wait.Result(
                pid: Kernel.Process.ID(42),
                status: Kernel.Process.Status(rawValue: 0)
            )
            let result3 = Kernel.Process.Wait.Result(
                pid: Kernel.Process.ID(99),
                status: Kernel.Process.Status(rawValue: 0)
            )

            #expect(result1 == result2)
            #expect(result1 != result3)
        }
    }

    // MARK: - Integration Tests
    //
    // NOTE: These tests use posix_spawn via POSIXTestHelper instead of fork() directly
    // to avoid Swift runtime lock corruption in multithreaded test environments.

    extension Kernel.Process.Wait.Test.Integration {
        @Test
        func `wait(.process) collects specific child status`() throws {
            // Spawn helper that exits with code 99
            let childPID = try POSIXTestHelper.spawn("exit", "99")

            // Use .process(childPID) instead of .any for determinism
            let result = try Kernel.Process.Wait.wait(.process(childPID))
            #expect(result != nil)
            #expect(result?.pid == childPID)
            #expect(result?.status.exit.code == 99)
        }

        @Test
        func `wait(.process(id)) waits for specific child`() throws {
            // Spawn helper that exits with code 77
            let child = try POSIXTestHelper.spawn("exit", "77")

            let result = try Kernel.Process.Wait.wait(.process(child))
            #expect(result?.pid == child)
            #expect(result?.status.exit.code == 77)
        }

        @Test
        func `wait with no.hang returns nil when child exists but is not reportable`() throws {
            // Deterministic test using SIGSTOP/WUNTRACED:
            // 1. Child self-stops with SIGSTOP (deterministic "not exited" state)
            // 2. Parent confirms stop via WUNTRACED (blocking, deterministic)
            // 3. WNOHANG without WUNTRACED must return nil (child stopped, not exited)
            // 4. Parent continues child with SIGCONT
            // 5. Parent reaps exited child

            // Spawn helper that stops itself, then exits with code 42 when continued
            let child = try POSIXTestHelper.spawn("stop-exit", "42")

            // Deterministically observe stopped state
            let stopped = try Kernel.Process.Wait.wait(
                .process(child),
                options: [.untraced]
            )
            #expect(stopped?.pid == child, "Should observe child stop")

            // Child exists but is stopped (not exited); WNOHANG must return nil
            // Note: .no.hang without .untraced means stopped state is not reportable
            let noHang = try Kernel.Process.Wait.wait(
                .process(child),
                options: [.no.hang]
            )
            #expect(noHang == nil, "WNOHANG should return nil for stopped (non-reportable) child")

            // Resume child so it can exit
            try ISO_9945.Kernel.Signal.Send.toProcess(.continue, pid: child)

            // Reap exited child
            let exited = try Kernel.Process.Wait.wait(.process(child))
            #expect(exited?.pid == child)
            #expect(exited?.status.exit.code == 42)
        }

        @Test
        func `ECHILD when no children exist`() throws {
            // Spawn a child that exits immediately, then wait for it
            // After that, waiting again should give ECHILD
            let child = try POSIXTestHelper.spawn("exit", "0")

            // First collect the child
            _ = try Kernel.Process.Wait.wait(.process(child))

            // Now try to wait again - should fail with ECHILD
            do {
                _ = try Kernel.Process.Wait.wait(.process(child))
                Issue.record("Expected ECHILD error")
            } catch {
                #expect(error.semantic == .noSuchProcess)
            }
        }

        @Test
        func `status classification matches exited`() throws {
            // Spawn helper that exits with code 55
            let child = try POSIXTestHelper.spawn("exit", "55")

            let result = try Kernel.Process.Wait.wait(.process(child))
            #expect(result != nil)
            if case .exited(let code) = result?.status.classification {
                #expect(code == 55)
            } else {
                Issue.record("Expected .exited classification")
            }
        }
    }

#endif
