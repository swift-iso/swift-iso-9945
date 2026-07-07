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

#if os(macOS)

    import Testing
    import Tagged_Primitives_Standard_Library_Integration
    import ISO_9945_Kernel_Test_Support
    import Path_Primitives
    import Error_Primitives

    @testable import ISO_9945_Kernel

    extension ISO_9945.Kernel.Process.Group {
        @Suite
        struct Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension ISO_9945.Kernel.Process.Group.Test.Unit {
        @Test
        func `Group.ID is type alias for Tagged`() {
            let id = ISO_9945.Kernel.Process.Group.ID(_unchecked: 123)
            #expect(id.underlying == 123)
        }

        @Test
        func `Group.Process cases are distinct`() {
            let pid = ISO_9945.Kernel.Process.ID(42)
            #expect(ISO_9945.Kernel.Process.Group.Process.current != ISO_9945.Kernel.Process.Group.Process.id(pid))
        }

        @Test
        func `Group.Target cases are distinct`() {
            let pgid = ISO_9945.Kernel.Process.Group.ID(_unchecked: 42)
            #expect(ISO_9945.Kernel.Process.Group.Target.same != ISO_9945.Kernel.Process.Group.Target.id(pgid))
        }
    }

    // MARK: - Integration Tests

    extension ISO_9945.Kernel.Process.Group.Test.Integration {
        @Test
        func `getpgid returns current process group`() throws {
            let currentPID = ISO_9945.Kernel.Process.ID.current
            let pgid = try ISO_9945.Kernel.Process.Group.id(of: currentPID)
            #expect(pgid.underlying > 0)
        }

        @Test
        func `spawned child can create new process group with setpgid(0,0)`() throws {
            let child = try POSIXTestHelper.spawn("become-group-leader")
            let result = try ISO_9945.Kernel.Process.Wait.wait(.process(child))
            #expect(result?.status.exit.code == 0, "Child should become process group leader")
        }

        @Test
        func `setpgid with explicit IDs works`() throws {
            let child = try POSIXTestHelper.spawn("setpgid-explicit")
            let result = try ISO_9945.Kernel.Process.Wait.wait(.process(child))
            #expect(result?.status.exit.code == 0, "setpgid with explicit IDs should work")
        }

        @Test
        func `getpgid for nonexistent process throws ESRCH`() throws {
            let unlikelyPID = ISO_9945.Kernel.Process.ID(999999)
            do throws(ISO_9945.Kernel.Process.Error) {
                _ = try ISO_9945.Kernel.Process.Group.id(of: unlikelyPID)
                Issue.record("Expected ESRCH error")
            } catch {
                #expect(error.semantic == .noSuchProcess)
            }
        }
    }

#endif
