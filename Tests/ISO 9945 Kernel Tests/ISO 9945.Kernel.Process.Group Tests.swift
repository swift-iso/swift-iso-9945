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
import Tagged_Primitives_Test_Support

@testable import ISO_9945_Kernel

extension Kernel.Process.Group {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension Kernel.Process.Group.Test.Unit {
    @Test
    func `Group.ID is type alias for Tagged`() {
        let id = Kernel.Process.Group.ID(__unchecked: (), 123)
        #expect(id.rawValue == 123)
    }

    @Test
    func `Group.Process cases are distinct`() {
        let pid = Kernel.Process.ID(42)
        #expect(Kernel.Process.Group.Process.current != Kernel.Process.Group.Process.id(pid))
    }

    @Test
    func `Group.Target cases are distinct`() {
        let pgid = Kernel.Process.Group.ID(__unchecked: (), 42)
        #expect(Kernel.Process.Group.Target.same != Kernel.Process.Group.Target.id(pgid))
    }
}

// MARK: - Integration Tests

extension Kernel.Process.Group.Test.Integration {
    @Test
    func `getpgid returns current process group`() throws {
        let currentPID = Kernel.Process.ID.current
        let pgid = try Kernel.Process.Group.id(of: currentPID)
        #expect(pgid.rawValue > 0)
    }

    @Test
    func `spawned child can create new process group with setpgid(0,0)`() throws {
        let child = try POSIXTestHelper.spawn("become-group-leader")
        let result = try Kernel.Process.Wait.wait(.process(child))
        #expect(result?.status.exit.code == 0, "Child should become process group leader")
    }

    @Test
    func `setpgid with explicit IDs works`() throws {
        let child = try POSIXTestHelper.spawn("setpgid-explicit")
        let result = try Kernel.Process.Wait.wait(.process(child))
        #expect(result?.status.exit.code == 0, "setpgid with explicit IDs should work")
    }

    @Test
    func `getpgid for nonexistent process throws ESRCH`() throws {
        let unlikelyPID = Kernel.Process.ID(999999)
        do throws(ISO_9945.Kernel.Process.Error) {
            _ = try Kernel.Process.Group.id(of: unlikelyPID)
            Issue.record("Expected ESRCH error")
        } catch {
            #expect(error.semantic == .noSuchProcess)
        }
    }
}

#endif
