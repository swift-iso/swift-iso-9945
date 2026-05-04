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
import ISO_9945_Kernel
import Path_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Process.Session {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Process.Session.Test.Unit {
    @Test
    func `Session.ID is type alias for Tagged`() {
        let id = ISO_9945.Kernel.Process.Session.ID(_unchecked: 123)
        #expect(id.underlying == 123)
    }
}

// MARK: - Integration Tests

extension ISO_9945.Kernel.Process.Session.Test.Integration {
    @Test
    func `getsid returns current session ID`() throws {
        let currentPID = ISO_9945.Kernel.Process.ID.current
        let sessionID = try ISO_9945.Kernel.Process.Session.id(of: currentPID)
        #expect(sessionID.underlying > 0)
    }

    @Test
    func `spawned child can create new session`() throws {
        let child = try POSIXTestHelper.spawn("create-session")
        let result = try ISO_9945.Kernel.Process.Wait.wait(.process(child))
        #expect(result?.status.exit.code == 0, "Child should successfully create new session")
    }

    @Test
    func `setsid fails if already group leader`() throws {
        let child = try POSIXTestHelper.spawn("double-setsid")
        let result = try ISO_9945.Kernel.Process.Wait.wait(.process(child))
        #expect(result?.status.exit.code == 0, "Second setsid should fail with EPERM")
    }
}

#endif
