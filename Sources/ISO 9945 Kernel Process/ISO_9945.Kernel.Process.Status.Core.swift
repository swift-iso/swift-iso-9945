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

    public struct Core: Sendable {
        let status: ISO_9945.Kernel.Process.Status
        init(_ status: ISO_9945.Kernel.Process.Status) { self.status = status }
    }
}

extension ISO_9945.Kernel.Process.Status.Core {

    public var dumped: Bool {
        #if canImport(Darwin)
            guard status.signaled else { return false }
            return swift_WCOREDUMP(status.rawValue) != 0
        #elseif canImport(Glibc)
            guard status.signaled else { return false }
            return swift_WCOREDUMP(status.rawValue) != 0
        #else
            return false
        #endif
    }
}
