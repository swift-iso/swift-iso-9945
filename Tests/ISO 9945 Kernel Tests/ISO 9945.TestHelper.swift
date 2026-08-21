#if os(macOS) || os(Linux)

    #if canImport(Darwin)
        import Darwin
    #elseif canImport(Glibc)
        import Glibc
    #endif

    import Path_Primitives
    import Error_Primitives
    @testable import ISO_9945_Kernel

    enum POSIXTestHelper {

        static func executablePath() -> Swift.String? {
            TestExecutable.path(
                "iso-9945-test-helper",
                overrides: ["ISO_9945_TEST_HELPER", "POSIX_TEST_HELPER"]
            )
        }

        private static func isExecutable(_ path: Swift.String) -> Bool {
            path.withCString { cPath in
                access(cPath, X_OK) == 0
            }
        }

        static func spawn(_ args: Swift.String...) throws -> ISO_9945.Kernel.Process.ID {
            try spawn(args)
        }

        static func spawn(_ args: [Swift.String]) throws -> ISO_9945.Kernel.Process.ID {
            guard let path = executablePath() else {
                throw TestExecutable.NotFound(name: "iso-9945-test-helper")
            }
            let allArgs = [path] + args
            let envp: [Swift.String] = []

            return try Path.scope.array(allArgs, envp) { argvPtr, envpPtr in

                try unsafe ISO_9945.Kernel.Process.Spawn.spawn(
                    path: argvPtr[0]!,
                    argv: argvPtr,
                    envp: envpPtr
                )
            }
        }
    }

#endif
