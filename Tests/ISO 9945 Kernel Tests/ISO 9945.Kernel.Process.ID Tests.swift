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

    import Kernel_Primitives_Core
    import Kernel_Descriptor_Primitives
    import Kernel_Event_Primitives
    import Kernel_IO_Primitives
    import Kernel_File_Primitives
    import Kernel_Path_Primitives
    import Kernel_Environment_Primitives
    import Kernel_Process_Primitives
    import Kernel_Thread_Primitives
    import Error_Primitives
    @testable import ISO_9945_Kernel

    // Note: Kernel.Process.ID already has Test struct pattern from elsewhere.
    // We add tests in a separate file to test the .parent accessor.

    // MARK: - Parent Accessor Tests
    //
    // NOTE: These tests use posix_spawn via POSIXTestHelper instead of fork() directly
    // to avoid Swift runtime lock corruption in multithreaded test environments.

    @Suite("Kernel.Process.ID Parent Tests")
    struct KernelProcessIDParentTests {
        @Test
        func `parent returns positive PID`() {
            let parent = Kernel.Process.ID.parent
            #expect(parent.rawValue > 0)
        }

        @Test
        func `spawned child's parent matches spawner's current`() throws {
            #if os(macOS)
                let ourPID = Kernel.Process.ID.current

                // Spawn helper that verifies its parent PID matches ours
                let child = try POSIXTestHelper.spawn("verify-parent", "\(ourPID.rawValue)")

                let result = try Kernel.Process.Wait.wait(.process(child))
                #expect(result?.status.exit.code == 0, "Child's parent should match spawner's PID")
            #endif
        }
    }

