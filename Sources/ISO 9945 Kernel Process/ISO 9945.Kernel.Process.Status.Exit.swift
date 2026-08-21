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

    public struct Exit: Sendable {
        let status: ISO_9945.Kernel.Process.Status
        init(_ status: ISO_9945.Kernel.Process.Status) { self.status = status }
    }
}

extension ISO_9945.Kernel.Process.Status.Exit {

    public var code: Int32? {
        guard status.exited else { return nil }
        return swift_WEXITSTATUS(status.rawValue)
    }
}
