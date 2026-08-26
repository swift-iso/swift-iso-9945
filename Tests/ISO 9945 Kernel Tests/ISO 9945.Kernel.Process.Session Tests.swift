#if os(macOS)

    import Testing
    import Tagged_Standard_Library_Integration
    import ISO_9945_Kernel_Test_Support
    import Path
    import Error

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

    extension ISO_9945.Kernel.Process.Session.Test.Unit {
        @Test
        func `Session.ID is type alias for Tagged`() {
            let id = ISO_9945.Kernel.Process.Session.ID(_unchecked: 123)
            #expect(id.underlying == 123)
        }
    }

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
