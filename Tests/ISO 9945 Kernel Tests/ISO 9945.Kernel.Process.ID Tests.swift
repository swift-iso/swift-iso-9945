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

import Error_Primitives
import Path_Primitives
import Tagged_Primitives_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

// Note: ISO_9945.Kernel.Process.ID already has Test struct pattern from elsewhere.
// We add tests in a separate file to test the .parent accessor.

// MARK: - Parent Accessor Tests
//
// NOTE: These tests use posix_spawn via POSIXTestHelper instead of fork() directly
// to avoid Swift runtime lock corruption in multithreaded test environments.

@Suite("ISO_9945.Kernel.Process.ID Parent Tests")
struct KernelProcessIDParentTests {
    @Test
    func `parent returns positive PID`() {
        let parent = ISO_9945.Kernel.Process.ID.parent
        #expect(parent.rawValue > 0)
    }

    @Test
    func `spawned child's parent matches spawner's current`() throws {
        #if os(macOS)
            let ourPID = ISO_9945.Kernel.Process.ID.current

            // Spawn helper that verifies its parent PID matches ours
            let child = try POSIXTestHelper.spawn("verify-parent", "\(ourPID.rawValue)")

            let result = try ISO_9945.Kernel.Process.Wait.wait(.process(child))
            #expect(result?.status.exit.code == 0, "Child's parent should match spawner's PID")
        #endif
    }
}
