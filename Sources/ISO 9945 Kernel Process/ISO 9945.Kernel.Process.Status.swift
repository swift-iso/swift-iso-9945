#if canImport(Darwin)
    internal import Darwin
    internal import POSIX_Process_Shims
#elseif canImport(Glibc)
    internal import Glibc
    internal import POSIX_Process_Shims
#elseif canImport(Musl)
    internal import Musl
    internal import POSIX_Process_Shims
#endif

extension ISO_9945.Kernel.Process {

    public struct Status: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Process.Status {

    public var exited: Bool {
        swift_WIFEXITED(rawValue) != 0
    }

    public var signaled: Bool {
        swift_WIFSIGNALED(rawValue) != 0
    }

    public var stopped: Bool {
        swift_WIFSTOPPED(rawValue) != 0
    }

    public var continued: Bool {
        swift_WIFCONTINUED(rawValue) != 0
    }
}

extension ISO_9945.Kernel.Process.Status {

    public var exit: Exit { Exit(self) }

    public var terminating: Terminating { Terminating(self) }

    public var stop: Stop { Stop(self) }

    public var core: Core { Core(self) }
}
