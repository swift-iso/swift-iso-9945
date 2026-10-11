#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Process.Wait {

    public struct Result: Sendable, Equatable {

        public let pid: ISO_9945.Kernel.Process.ID

        public let status: ISO_9945.Kernel.Process.Status

        public init(pid: ISO_9945.Kernel.Process.ID, status: ISO_9945.Kernel.Process.Status) {
            self.pid = pid
            self.status = status
        }
    }
}
