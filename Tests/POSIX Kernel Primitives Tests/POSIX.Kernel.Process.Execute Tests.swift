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

    import Darwin
    import Test_Primitives
    import Testing_Extras

    import Kernel_Primitives
    @testable import POSIX_Kernel_Primitives
    import POSIX_Primitives

    extension Kernel.Process.Execute {
        #TestSuites
    }

    // MARK: - Integration Tests
    //
    // NOTE: These tests use posix_spawn instead of fork+exec to avoid Swift runtime
    // lock corruption in multithreaded test environments. posix_spawn does NOT
    // duplicate the parent's address space, making it safe for concurrent tests.

    extension Kernel.Process.Execute.Test.Integration {
        /// Finds an executable "true" command, trying common paths.
        private static func findTruePath() -> Swift.String {
            for path in ["/usr/bin/true", "/bin/true"] {
                if access(path, X_OK) == 0 {
                    return path
                }
            }
            return "/usr/bin/true"  // Fallback, may fail
        }

        /// Helper to spawn a process using Swift.String arrays
        private static func spawnHelper(
            path: Swift.String,
            argv: [Swift.String],
            envp: [Swift.String]
        ) throws -> Kernel.Process.ID {
            return try unsafe path.withCString { pathCStr in
                // Build argv array
                var argvStorage: [ContiguousArray<CChar>] = []
                for arg in argv {
                    var chars = ContiguousArray<CChar>(arg.utf8.map { CChar(bitPattern: $0) })
                    chars.append(0)
                    argvStorage.append(chars)
                }

                var argvPtrs: [UnsafePointer<CChar>?] = []
                for i in argvStorage.indices {
                    argvPtrs.append(argvStorage[i].withUnsafeBufferPointer { $0.baseAddress })
                }
                argvPtrs.append(nil)

                // Build envp array
                var envpStorage: [ContiguousArray<CChar>] = []
                for env in envp {
                    var chars = ContiguousArray<CChar>(env.utf8.map { CChar(bitPattern: $0) })
                    chars.append(0)
                    envpStorage.append(chars)
                }

                var envpPtrs: [UnsafePointer<CChar>?] = []
                for i in envpStorage.indices {
                    envpPtrs.append(envpStorage[i].withUnsafeBufferPointer { $0.baseAddress })
                }
                envpPtrs.append(nil)

                return try unsafe argvPtrs.withUnsafeBufferPointer { argvBuf in
                    try unsafe envpPtrs.withUnsafeBufferPointer { envpBuf in
                        try unsafe POSIX.Kernel.Process.Spawn.spawn(
                            path: pathCStr,
                            argv: argvBuf.baseAddress!,
                            envp: envpBuf.baseAddress!
                        )
                    }
                }
            }
        }

        @Test("spawn with /usr/bin/true or /bin/true succeeds")
        func spawnTrue() throws {
            let path = Self.findTruePath()
            let argv = [path]
            let envp: [Swift.String] = []

            let child = try Self.spawnHelper(path: path, argv: argv, envp: envp)

            let result = try Kernel.Process.Wait.wait(.process(child))
            #expect(result != nil, "Wait should return a result")
            #expect(result?.status.exit.code == 0, "true should exit with 0")
        }

        @Test("spawn with invalid path throws ENOENT")
        func spawnInvalidPath() throws {
            let path = "/nonexistent/path/to/binary"
            let argv = [path]
            let envp: [Swift.String] = []

            do {
                _ = try Self.spawnHelper(path: path, argv: argv, envp: envp)
                Issue.record("Expected spawn to throw for invalid path")
            } catch let error as POSIX.Kernel.Process.Error {
                guard case .spawn(let code) = error else {
                    Issue.record("Expected .spawn(...), got \(error)")
                    return
                }
                #expect(code.posix == ENOENT, "Expected ENOENT, got \(code)")
            }
        }

        @Test("spawn passes arguments to program")
        func spawnPassesArguments() throws {
            let path = "/bin/sh"
            let argv = ["/bin/sh", "-c", "exit 42"]
            let envp: [Swift.String] = []

            let child = try Self.spawnHelper(path: path, argv: argv, envp: envp)

            let result = try Kernel.Process.Wait.wait(.process(child))
            #expect(result?.status.exit.code == 42, "Shell should exit with code 42")
        }

        @Test("spawn passes environment to program")
        func spawnPassesEnvironment() throws {
            // Use sh -c with direct variable expansion
            // The shell reads TEST_EXIT_CODE from its environment and uses it as exit code
            let path = "/bin/sh"
            let argv = ["/bin/sh", "-c", "exit ${TEST_EXIT_CODE:-99}"]
            let envp = ["TEST_EXIT_CODE=77"]

            let child = try Self.spawnHelper(path: path, argv: argv, envp: envp)

            let result = try Kernel.Process.Wait.wait(.process(child))
            #expect(result?.status.exit.code == 77, "Shell should exit with env value 77")
        }
    }

#endif
