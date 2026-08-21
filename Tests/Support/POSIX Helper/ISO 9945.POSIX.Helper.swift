#if os(macOS) || os(Linux)

    #if canImport(Darwin)
        import Darwin
    #elseif canImport(Glibc)
        import Glibc
    #endif

    @main
    enum POSIXHelper {

        private static func printStatus(_ status: String, exitCode: Int32) {
            print(
                "\(status) pid=\(getpid()) ppid=\(getppid()) pgid=\(getpgid(0)) sid=\(getsid(0)) exit=\(exitCode)"
            )
            fflush(nil)
        }

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

        private static func exitCommand(_ arguments: [String]) -> Int32 {
            let code = arguments.count >= 3 ? (Int32(arguments[2]) ?? 0) : 0
            printStatus("OK", exitCode: code)
            return code
        }

        private static func stopExitCommand(_ arguments: [String]) -> Int32 {
            let code = arguments.count >= 3 ? (Int32(arguments[2]) ?? 0) : 0

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
