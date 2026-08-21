#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Process {

    public enum Exit {}
}

extension ISO_9945.Kernel.Process.Exit {

    public static func now(_ status: Int32) -> Never {
        _exit(status)
    }

    public static func normal(_ status: Int32) -> Never {
        exit(status)
    }
}
