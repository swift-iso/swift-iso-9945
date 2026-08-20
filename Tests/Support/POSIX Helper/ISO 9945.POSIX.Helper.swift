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

/// POSIX test helper - performs process operations in a spawned child process.
///
/// Tests spawn this helper via `posix_spawn` to observe process behaviour from a
/// separate process image, so that fork, session, and process-group operations are
/// never performed inside the multithreaded test process itself.
///
/// The helper calls the platform C library directly rather than the kernel modules
/// under test: it is the positive control for those modules and must not depend on
/// them.
///
/// ## Output Protocol
///
/// Machine-readable key/value pairs on stdout:
///
/// ```
/// OK pid=123 ppid=456 pgid=123 sid=123 exit=0
/// ERR errno=1 msg=operation_failed
/// ```
///
/// ## Usage
///
/// ```
/// iso-9945-test-helper <command> [args...]
/// ```
///
/// - `exit <code>` - Exit with the specified code
/// - `stop-exit <code>` - SIGSTOP self, exit with code when continued
/// - `verify-parent <ppid>` - Verify `getppid()` matches the expected value
/// - `create-session` - `setsid()`
/// - `double-setsid` - `setsid()` twice, verify the second fails with EPERM
/// - `become-group-leader` - `setpgid(0, 0)`
/// - `setpgid-explicit` - `setpgid(pid, pid)`

#if os(macOS) || os(Linux)

    #if canImport(Darwin)
        import Darwin
    #elseif canImport(Glibc)
        import Glibc
    #endif

    @main
    enum POSIXHelper {

        // MARK: - Output

        /// Prints a status line carrying the current process identifiers.
        private static func printStatus(_ status: String, exitCode: Int32) {
            print(
                "\(status) pid=\(getpid()) ppid=\(getppid()) pgid=\(getpgid(0)) sid=\(getsid(0)) exit=\(exitCode)"
            )
            fflush(nil)
        }

        /// Prints an error line carrying `errno` and a stable message token.
        private static func printError(_ code: Int32, _ message: String) {
            print("ERR errno=\(code) msg=\(message)")
            fflush(nil)
        }

        private static func printUsage() {
            let usage = """
                Usage: iso-9945-test-helper <command> [args...]
                Commands:
                  exit <code>           Exit with specified code
                  stop-exit <code>      SIGSTOP, then exit when continued
                  verify-parent <ppid>  Verify parent PID
                  create-session        Create new session (setsid)
                  double-setsid         setsid twice, verify EPERM
                  become-group-leader   setpgid(0,0)
                  setpgid-explicit      setpgid(pid, pid)
                """
            FileHandleWriter.standardError(usage)
        }

        /// Minimal standard-error writer; the helper deliberately avoids Foundation.
        ///
        /// Writes to descriptor 2 directly rather than through the `stderr` stream
        /// pointer, which is a mutable global on some platforms and therefore not
        /// available from concurrency-checked code.
        private enum FileHandleWriter {
            static func standardError(_ text: String) {
                var line = text
                line.append("\n")
                let bytes = Array(line.utf8)
                bytes.withUnsafeBytes { buffer in
                    guard let base = buffer.baseAddress else { return }
                    _ = unsafe write(2, base, buffer.count)
                }
            }
        }

        // MARK: - Commands

        private static func exitCommand(_ arguments: [String]) -> Int32 {
            let code = arguments.count >= 3 ? (Int32(arguments[2]) ?? 0) : 0
            printStatus("OK", exitCode: code)
            return code
        }

        private static func stopExitCommand(_ arguments: [String]) -> Int32 {
            let code = arguments.count >= 3 ? (Int32(arguments[2]) ?? 0) : 0
            // Stop self; the parent sends SIGCONT.
            _ = raise(SIGSTOP)
            printStatus("OK", exitCode: code)
            return code
        }

        private static func verifyParentCommand(_ arguments: [String]) -> Int32 {
            guard arguments.count >= 3, let expected = pid_t(arguments[2]) else {
                FileHandleWriter.standardError("verify-parent requires <ppid> argument")
                return 1
            }
            let actual = getppid()
            guard actual == expected else {
                print("ERR errno=0 msg=ppid_mismatch expected=\(expected) actual=\(actual)")
                fflush(nil)
                return 1
            }
            printStatus("OK", exitCode: 0)
            return 0
        }

        private static func createSessionCommand() -> Int32 {
            guard setsid() > 0 else {
                printError(errno, "setsid_failed")
                return 1
            }
            printStatus("OK", exitCode: 0)
            return 0
        }

        private static func doubleSetsidCommand() -> Int32 {
            guard setsid() > 0 else {
                printError(errno, "first_setsid_failed")
                return 1
            }
            // The second call must fail: the process is already a session leader.
            let second = setsid()
            guard second < 0, errno == EPERM else {
                printError(errno, "second_setsid_should_fail_eperm")
                return 1
            }
            printStatus("OK", exitCode: 0)
            return 0
        }

        private static func becomeGroupLeaderCommand() -> Int32 {
            guard setpgid(0, 0) == 0 else {
                printError(errno, "setpgid_failed")
                return 1
            }
            let pid = getpid()
            let pgid = getpgid(0)
            guard pgid == pid else {
                print("ERR errno=0 msg=not_group_leader pid=\(pid) pgid=\(pgid)")
                fflush(nil)
                return 1
            }
            printStatus("OK", exitCode: 0)
            return 0
        }

        private static func setpgidExplicitCommand() -> Int32 {
            let pid = getpid()
            guard setpgid(pid, pid) == 0 else {
                printError(errno, "setpgid_explicit_failed")
                return 1
            }
            let pgid = getpgid(pid)
            guard pgid == pid else {
                print("ERR errno=0 msg=pgid_not_set pid=\(pid) pgid=\(pgid)")
                fflush(nil)
                return 1
            }
            printStatus("OK", exitCode: 0)
            return 0
        }

        // MARK: - Entry Point

        static func main() {
            let arguments = CommandLine.arguments

            guard arguments.count >= 2 else {
                printUsage()
                exit(1)
            }

            let code: Int32

            switch arguments[1] {
            case "exit":
                code = exitCommand(arguments)

            case "stop-exit":
                code = stopExitCommand(arguments)

            case "verify-parent":
                code = verifyParentCommand(arguments)

            case "create-session":
                code = createSessionCommand()

            case "double-setsid":
                code = doubleSetsidCommand()

            case "become-group-leader":
                code = becomeGroupLeaderCommand()

            case "setpgid-explicit":
                code = setpgidExplicitCommand()

            case let command:
                FileHandleWriter.standardError("Unknown command: \(command)")
                code = 1
            }

            exit(code)
        }
    }

#endif
