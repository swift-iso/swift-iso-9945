#if os(macOS)

    import Testing
    import Tagged_Standard_Library_Integration

    import Path
    import Error
    @testable import ISO_9945_Kernel
    import ISO_9945_Kernel_Test_Support

    extension ISO_9945.Kernel.Process.Wait {
        @Suite
        struct Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    extension ISO_9945.Kernel.Process.Wait.Test.Unit {
        @Test
        func `Selector cases are distinct`() {
            let pid = ISO_9945.Kernel.Process.ID(123)
            let pgid = ISO_9945.Kernel.Process.Group.ID(456)

            let cases: [ISO_9945.Kernel.Process.Wait.Selector] = [
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
            let selector: any Sendable = ISO_9945.Kernel.Process.Wait.Selector.any
            #expect(selector is ISO_9945.Kernel.Process.Wait.Selector)
        }

        @Test
        func `Selector is Equatable`() {
            let pid = ISO_9945.Kernel.Process.ID(42)
            #expect(
                ISO_9945.Kernel.Process.Wait.Selector.any
                    == ISO_9945.Kernel.Process.Wait.Selector.any
            )
            #expect(
                ISO_9945.Kernel.Process.Wait.Selector.process(pid)
                    == ISO_9945.Kernel.Process.Wait.Selector.process(pid)
            )
        }
    }

    extension ISO_9945.Kernel.Process.Wait.Test.Unit {
        @Test
        func `Options is OptionSet`() {
            let options: ISO_9945.Kernel.Process.Wait.Options = [.untraced, .continued]
            #expect(options.contains(.untraced))
            #expect(options.contains(.continued))
        }

        @Test
        func `no.hang accessor works`() {
            let noHang = ISO_9945.Kernel.Process.Wait.Options.no.hang
            #expect(noHang.rawValue != 0)
        }
    }

    extension ISO_9945.Kernel.Process.Wait.Test.Unit {
        @Test
        func `Result is Sendable`() {
            let result: any Sendable = ISO_9945.Kernel.Process.Wait.Result(
                pid: ISO_9945.Kernel.Process.ID(1),
                status: ISO_9945.Kernel.Process.Status(rawValue: 0)
            )
            #expect(result is ISO_9945.Kernel.Process.Wait.Result)
        }

        @Test
        func `Result is Equatable`() {
            let result1 = ISO_9945.Kernel.Process.Wait.Result(
                pid: ISO_9945.Kernel.Process.ID(42),
                status: ISO_9945.Kernel.Process.Status(rawValue: 0)
            )
            let result2 = ISO_9945.Kernel.Process.Wait.Result(
                pid: ISO_9945.Kernel.Process.ID(42),
                status: ISO_9945.Kernel.Process.Status(rawValue: 0)
            )
            let result3 = ISO_9945.Kernel.Process.Wait.Result(
                pid: ISO_9945.Kernel.Process.ID(99),
                status: ISO_9945.Kernel.Process.Status(rawValue: 0)
            )

            #expect(result1 == result2)
            #expect(result1 != result3)
        }
    }

    extension ISO_9945.Kernel.Process.Wait.Test.Integration {
        @Test
        func `wait(.process) collects specific child status`() throws {

            let childPID = try POSIXTestHelper.spawn("exit", "99")

            let result = try ISO_9945.Kernel.Process.Wait.wait(.process(childPID))
            #expect(result != nil)
            #expect(result?.pid == childPID)
            #expect(result?.status.exit.code == 99)
        }

        @Test
        func `wait(.process(id)) waits for specific child`() throws {

            let child = try POSIXTestHelper.spawn("exit", "77")

            let result = try ISO_9945.Kernel.Process.Wait.wait(.process(child))
            #expect(result?.pid == child)
            #expect(result?.status.exit.code == 77)
        }

        @Test
        func `wait with no.hang returns nil when child exists but is not reportable`() throws {

            let child = try POSIXTestHelper.spawn("stop-exit", "42")

            let stopped = try ISO_9945.Kernel.Process.Wait.wait(
                .process(child),
                options: [.untraced]
            )
            #expect(stopped?.pid == child, "Should observe child stop")

            let noHang = try ISO_9945.Kernel.Process.Wait.wait(
                .process(child),
                options: [.no.hang]
            )
            #expect(noHang == nil, "WNOHANG should return nil for stopped (non-reportable) child")

            try ISO_9945.Kernel.Signal.Send.toProcess(.continue, pid: child)

            let exited = try ISO_9945.Kernel.Process.Wait.wait(.process(child))
            #expect(exited?.pid == child)
            #expect(exited?.status.exit.code == 42)
        }

        @Test
        func `ECHILD when no children exist`() throws {

            let child = try POSIXTestHelper.spawn("exit", "0")

            _ = try ISO_9945.Kernel.Process.Wait.wait(.process(child))

            do {
                _ = try ISO_9945.Kernel.Process.Wait.wait(.process(child))
                Issue.record("Expected ECHILD error")
            } catch {
                #expect(error.semantic == .noSuchProcess)
            }
        }

        @Test
        func `status classification matches exited`() throws {

            let child = try POSIXTestHelper.spawn("exit", "55")

            let result = try ISO_9945.Kernel.Process.Wait.wait(.process(child))
            #expect(result != nil)
            if case .exited(let code) = result?.status.classification {
                #expect(code == 55)
            } else {
                Issue.record("Expected .exited classification")
            }
        }
    }

#endif
