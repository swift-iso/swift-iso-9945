#if canImport(Darwin)
    internal import Darwin
    internal import POSIX_Process_Shims
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Process.Fork {

    public enum Result: Sendable, Equatable {

        case child

        case parent(child: ISO_9945.Kernel.Process.ID)
    }
}
