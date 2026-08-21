#if os(macOS) || os(Linux)

    import Testing
    import Path_Primitives
    @testable import ISO_9945_Kernel

    @Suite("ISO_9945.Kernel.Process.Spawn.Actions")
    struct ISO9945KernelProcessSpawnActionsTests {

        @Test("Actions() succeeds and deinit cleans up")
        func initAndDeinit() throws {

            _ = try ISO_9945.Kernel.Process.Spawn.Actions()

            _ = try ISO_9945.Kernel.Process.Spawn.Actions()
            _ = try ISO_9945.Kernel.Process.Spawn.Actions()
        }

        @Test("Target constants are distinct and Equatable")
        func targetConstants() {
            let stdin = ISO_9945.Kernel.Process.Spawn.Actions.Target.stdin
            let stdout = ISO_9945.Kernel.Process.Spawn.Actions.Target.stdout
            let stderr = ISO_9945.Kernel.Process.Spawn.Actions.Target.stderr
            #expect(stdin != stdout)
            #expect(stdout != stderr)
            #expect(stdin != stderr)

            #expect(stdin == ISO_9945.Kernel.Process.Spawn.Actions.Target.stdin)
        }

        @Test("add(close: .stdin) succeeds")
        func addCloseStdin() throws {
            var actions = try ISO_9945.Kernel.Process.Spawn.Actions()
            try actions.add(close: .stdin)
        }

        @Test("add(dup2: …, to: .stdout) succeeds")
        func addDup2ToStdout() throws {
            var actions = try ISO_9945.Kernel.Process.Spawn.Actions()
            let pipe = try ISO_9945.Kernel.Pipe.pipe()
            try actions.add(dup2: pipe.write, to: .stdout)
            try actions.add(close: .init(pipe.read))
        }

        @Test("add(chdir: …) accepts a NUL-terminated path")
        func addChdir() throws {
            var actions = try ISO_9945.Kernel.Process.Spawn.Actions()
            try Path.scope("/tmp") {
                (borrowed: borrowing Path.Borrowed) throws(ISO_9945.Kernel.Process.Error) in
                try unsafe actions.add(chdir: borrowed.pointer)
            }
        }

        @Test("Spawn /bin/echo with stdout redirected to a pipe captures the output")
        func integrationStdoutPipe() throws {
            let pipe = try ISO_9945.Kernel.Pipe.pipe()
            var actions = try ISO_9945.Kernel.Process.Spawn.Actions()
            try actions.add(dup2: pipe.write, to: .stdout)
            try actions.add(close: .init(pipe.read))

            let argv: [Swift.String] = ["/bin/echo", "hello-from-spawn"]
            let envp: [Swift.String] = []
            let pid: ISO_9945.Kernel.Process.ID = try unsafe Path.scope.array(argv, envp) {
                (
                    argvPtr: UnsafePointer<UnsafePointer<Path.Char>?>,
                    envpPtr: UnsafePointer<UnsafePointer<Path.Char>?>
                ) throws(ISO_9945.Kernel.Process.Error) -> ISO_9945.Kernel.Process.ID in
                try unsafe ISO_9945.Kernel.Process.Spawn.spawn(
                    path: argvPtr[0]!,
                    argv: argvPtr,
                    envp: envpPtr,
                    actions: actions
                )
            }

            let readEnd = try ISO_9945.Kernel.Pipe.Close.write(pipe)

            var bytes: [UInt8] = []
            var chunk = [UInt8](repeating: 0, count: 256)
            while true {
                let n = try unsafe chunk.withUnsafeMutableBufferPointer {
                    (
                        raw: inout UnsafeMutableBufferPointer<UInt8>
                    ) throws(ISO_9945.Kernel.IO.Read.Error) -> Int in
                    let buf = UnsafeMutableRawBufferPointer(raw)
                    return try unsafe ISO_9945.Kernel.IO.Read.read(readEnd, into: buf)
                }
                if n == 0 { break }
                bytes.append(contentsOf: chunk.prefix(n))
            }
            let captured = Swift.String(decoding: bytes, as: UTF8.self)
            #expect(captured == "hello-from-spawn\n")

            let result = try ISO_9945.Kernel.Process.Wait.wait(.process(pid))
            #expect(result?.status.exit.code == 0)
        }

        @Test("Spawn /bin/pwd with addchdir → child's cwd is the supplied path")
        func integrationChdir() throws {
            let pipe = try ISO_9945.Kernel.Pipe.pipe()
            var actions = try ISO_9945.Kernel.Process.Spawn.Actions()
            try actions.add(dup2: pipe.write, to: .stdout)
            try actions.add(close: .init(pipe.read))
            try Path.scope("/tmp") {
                (borrowed: borrowing Path.Borrowed) throws(ISO_9945.Kernel.Process.Error) in
                try unsafe actions.add(chdir: borrowed.pointer)
            }

            let argv: [Swift.String] = ["/bin/pwd"]
            let envp: [Swift.String] = []
            let pid: ISO_9945.Kernel.Process.ID = try unsafe Path.scope.array(argv, envp) {
                (
                    argvPtr: UnsafePointer<UnsafePointer<Path.Char>?>,
                    envpPtr: UnsafePointer<UnsafePointer<Path.Char>?>
                ) throws(ISO_9945.Kernel.Process.Error) -> ISO_9945.Kernel.Process.ID in
                try unsafe ISO_9945.Kernel.Process.Spawn.spawn(
                    path: argvPtr[0]!,
                    argv: argvPtr,
                    envp: envpPtr,
                    actions: actions
                )
            }

            let readEnd = try ISO_9945.Kernel.Pipe.Close.write(pipe)

            var bytes: [UInt8] = []
            var chunk = [UInt8](repeating: 0, count: 256)
            while true {
                let n = try unsafe chunk.withUnsafeMutableBufferPointer {
                    (
                        raw: inout UnsafeMutableBufferPointer<UInt8>
                    ) throws(ISO_9945.Kernel.IO.Read.Error) -> Int in
                    let buf = UnsafeMutableRawBufferPointer(raw)
                    return try unsafe ISO_9945.Kernel.IO.Read.read(readEnd, into: buf)
                }
                if n == 0 { break }
                bytes.append(contentsOf: chunk.prefix(n))
            }
            var text = Swift.String(decoding: bytes, as: UTF8.self)
            while text.last == "\n" || text.last == "\r" { text.removeLast() }

            #expect(text == "/tmp" || text == "/private/tmp", "got: \(text)")

            let result = try ISO_9945.Kernel.Process.Wait.wait(.process(pid))
            #expect(result?.status.exit.code == 0)
        }
    }

#endif
