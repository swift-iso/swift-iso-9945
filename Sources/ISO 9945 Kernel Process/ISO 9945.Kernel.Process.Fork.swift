#if canImport(Darwin)
    internal import Darwin
    internal import POSIX_Process_Shims
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Process {

    public enum Fork {}
}

extension ISO_9945.Kernel.Process.Fork {

    public static func fork() throws(ISO_9945.Kernel.Process.Error) -> Result {
        #if canImport(Darwin)
            let pid = swift_fork()
        #elseif canImport(Glibc)
            let pid = Glibc.fork()
        #elseif canImport(Musl)
            let pid = Musl.fork()
        #endif

        switch pid {
        case -1:
            throw .fork(Error_Primitives.Error.captureErrno())

        case 0:
            return .child

        default:
            return .parent(child: ISO_9945.Kernel.Process.ID(pid))
        }
    }
}
