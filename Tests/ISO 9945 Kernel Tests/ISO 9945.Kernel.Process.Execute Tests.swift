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
    import Testing

    import Kernel_Primitives_Core
    import Kernel_Descriptor_Primitives
    import Kernel_Event_Primitives
    import Kernel_File_Primitives
    import Path_Primitives
    import Kernel_Process_Primitives
    import Error_Primitives
    @testable import ISO_9945_Kernel
    import ISO_9945_Kernel

    extension Kernel.Process.Execute {
        @Suite
        struct Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
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

        @Test
        func `spawn with /usr/bin/true or /bin/true succeeds`() throws {
            let path = Self.findTruePath()
            let argv = [path]
            let envp: [Swift.String] = []

            let child = try Path.scope.array(argv, envp) { argvPtr, envpPtr in
                try unsafe ISO_9945.Kernel.Process.Spawn.spawn(
                    path: argvPtr[0]!,
                    argv: argvPtr,
                    envp: envpPtr
                )
            }

            let result = try Kernel.Process.Wait.wait(.process(child))
            #expect(result != nil, "Wait should return a result")
            #expect(result?.status.exit.code == 0, "true should exit with 0")
        }

        @Test
        func `spawn with invalid path throws ENOENT`() throws {
            let path = "/nonexistent/path/to/binary"
            let argv = [path]
            let envp: [Swift.String] = []

            func doSpawn() throws(Path.String.Error<ISO_9945.Kernel.Process.Error>) -> Kernel.Process.ID {
                try Path.scope.array(argv, envp) {
                    (argvPtr: UnsafePointer<UnsafePointer<Path.Char>?>,
                     envpPtr: UnsafePointer<UnsafePointer<Path.Char>?>) throws(ISO_9945.Kernel.Process.Error) -> Kernel.Process.ID in
                    // argv[0] is already the path, use it directly
                    try unsafe ISO_9945.Kernel.Process.Spawn.spawn(
                        path: argvPtr[0]!,
                        argv: argvPtr,
                        envp: envpPtr
                    )
                }
            }

            do {
                _ = try doSpawn()
                Issue.record("Expected spawn to throw for invalid path")
            } catch {
                guard case .body(.spawn(let code)) = error else {
                    Issue.record("Expected .body(.spawn(...)), got \(error)")
                    return
                }
                #expect(code.posix == ENOENT, "Expected ENOENT, got \(code)")
            }
        }

        @Test
        func `spawn passes arguments to program`() throws {
            let path = "/bin/sh"
            let argv = ["/bin/sh", "-c", "exit 42"]
            let envp: [Swift.String] = []

            let child = try Path.scope.array(argv, envp) { argvPtr, envpPtr in
                try unsafe ISO_9945.Kernel.Process.Spawn.spawn(
                    path: argvPtr[0]!,
                    argv: argvPtr,
                    envp: envpPtr
                )
            }

            let result = try Kernel.Process.Wait.wait(.process(child))
            #expect(result?.status.exit.code == 42, "Shell should exit with code 42")
        }

        @Test
        func `spawn passes environment to program`() throws {
            // Use sh -c with direct variable expansion
            // The shell reads TEST_EXIT_CODE from its environment and uses it as exit code
            let path = "/bin/sh"
            let argv = ["/bin/sh", "-c", "exit ${TEST_EXIT_CODE:-99}"]
            let envp = ["TEST_EXIT_CODE=77"]

            let child = try Path.scope.array(argv, envp) { argvPtr, envpPtr in
                try unsafe ISO_9945.Kernel.Process.Spawn.spawn(
                    path: argvPtr[0]!,
                    argv: argvPtr,
                    envp: envpPtr
                )
            }

            let result = try Kernel.Process.Wait.wait(.process(child))
            #expect(result?.status.exit.code == 77, "Shell should exit with env value 77")
        }
    }

#endif
