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

/// Test helper utilities for spawning the posix-test-helper executable.
///
/// The posix-test-helper is a pure C executable that performs process operations
/// (fork, setsid, setpgid, etc.) without Swift runtime involvement, making it
/// safe to use from multithreaded Swift Testing environments.
///
/// ## Usage
///
/// ```swift
/// let child = try POSIXTestHelper.spawn("exit", "42")
/// let result = try ISO_9945.Kernel.Process.Wait.wait(.process(child))
/// #expect(result?.status.exit.code == 42)
/// ```

#if os(macOS) || os(Linux)

    #if canImport(Darwin)
        import Darwin
    #elseif canImport(Glibc)
        import Glibc
    #endif

    import Path_Primitives
    import Error_Primitives
    @testable import ISO_9945_Kernel

    // MARK: - POSIXTestHelper

    enum POSIXTestHelper {
        /// Path to the posix-test-helper executable.
        ///
        /// Derived from the running test binary's own directory — see
        /// ``TestExecutable``. Previously this hardcoded `.build/debug/`, which
        /// resolved only in a debug SwiftPM build and then fell through to a bare
        /// executable name; spawning that with an empty `envp` failed as an opaque
        /// `ENOENT` (`posix(2)`) because `posix_spawn` does not search `PATH`.
        static func executablePath() -> Swift.String? {
            TestExecutable.path(
                "iso-9945-test-helper",
                overrides: ["ISO_9945_TEST_HELPER", "POSIX_TEST_HELPER"]
            )
        }

        /// Check if path is an executable file using withCString for proper C interop.
        private static func isExecutable(_ path: Swift.String) -> Bool {
            path.withCString { cPath in
                access(cPath, X_OK) == 0
            }
        }

        /// Spawns the test helper with the given arguments.
        ///
        /// - Parameter args: Command and arguments (e.g., "exit", "42").
        /// - Returns: The process ID of the spawned helper.
        /// - Throws: `ISO_9945.Kernel.Process.Error.spawn` on failure.
        ///
        /// ## Commands
        ///
        /// - `exit <code>` - Exit with specified code
        /// - `stop-exit <code>` - SIGSTOP, then exit when continued
        /// - `verify-parent <ppid>` - Verify parent PID
        /// - `create-session` - setsid()
        /// - `double-setsid` - setsid twice, verify EPERM
        /// - `become-group-leader` - setpgid(0,0)
        /// - `setpgid-explicit` - setpgid(pid, pid)
        ///
        /// ## Example
        ///
        /// ```swift
        /// // Test exit code handling
        /// let child = try POSIXTestHelper.spawn("exit", "77")
        /// let result = try ISO_9945.Kernel.Process.Wait.wait(.process(child))
        /// #expect(result?.status.exit.code == 77)
        ///
        /// // Test stop/continue handling
        /// let child = try POSIXTestHelper.spawn("stop-exit", "42")
        /// let stopped = try ISO_9945.Kernel.Process.Wait.wait(.process(child), options: [.untraced])
        /// #expect(stopped?.status.stopped == true)
        /// try ISO_9945.Kernel.Signal.Send.toProcess(.cont, pid: child)
        /// let exited = try ISO_9945.Kernel.Process.Wait.wait(.process(child))
        /// #expect(exited?.status.exit.code == 42)
        /// ```
        static func spawn(_ args: Swift.String...) throws -> ISO_9945.Kernel.Process.ID {
            try spawn(args)
        }

        /// Spawns the test helper with the given arguments array.
        ///
        /// - Parameter args: Command and arguments.
        /// - Returns: The process ID of the spawned helper.
        /// - Throws: `ISO_9945.Kernel.Process.Error.spawn` on failure.
        static func spawn(_ args: [Swift.String]) throws -> ISO_9945.Kernel.Process.ID {
            guard let path = executablePath() else {
                throw TestExecutable.NotFound(name: "iso-9945-test-helper")
            }
            let allArgs = [path] + args
            let envp: [Swift.String] = []

            return try Path.scope.array(allArgs, envp) { argvPtr, envpPtr in
                // argv[0] is the path, use it directly
                try unsafe ISO_9945.Kernel.Process.Spawn.spawn(
                    path: argvPtr[0]!,
                    argv: argvPtr,
                    envp: envpPtr
                )
            }
        }
    }

#endif
