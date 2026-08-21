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

extension ISO_9945.Kernel.Process.Status {

    public struct Terminating: Sendable {
        let status: ISO_9945.Kernel.Process.Status
        init(_ status: ISO_9945.Kernel.Process.Status) { self.status = status }
    }
}

extension ISO_9945.Kernel.Process.Status.Terminating {

    public var signal: ISO_9945.Kernel.Signal.Number? {
        guard status.signaled else { return nil }
        return ISO_9945.Kernel.Signal.Number(rawValue: swift_WTERMSIG(status.rawValue))
    }
}
