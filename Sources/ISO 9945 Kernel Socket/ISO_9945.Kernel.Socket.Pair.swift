#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#elseif canImport(Android)
    internal import Android
#else
    #error("ISO_9945.Kernel.Socket.Pair: unsupported platform (no Darwin, Glibc, Musl, or Android)")
#endif

extension ISO_9945.Kernel.Socket {

    public enum Pair: Sendable {}
}

extension ISO_9945.Kernel.Socket.Pair {

    public typealias Descriptors = Pair<Int32, Int32>

    @_spi(Syscall)
    public static func create() throws(Error) -> Descriptors {
        var fds: [Int32] = [0, 0]
        #if canImport(Darwin)
            let result = unsafe Darwin.socketpair(AF_UNIX, SOCK_STREAM, 0, &fds)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.socketpair(AF_UNIX, Int32(SOCK_STREAM.rawValue), 0, &fds)
        #elseif canImport(Musl)
            let result = unsafe Musl.socketpair(AF_UNIX, SOCK_STREAM, 0, &fds)
        #elseif canImport(Android)
            let result = unsafe Android.socketpair(AF_UNIX, Int32(SOCK_STREAM.rawValue), 0, &fds)
        #else
            #error(
                "ISO_9945.Kernel.Socket.Pair.create: unsupported platform (no Darwin, Glibc, Musl, or Android)"
            )
        #endif
        guard result == 0 else {
            throw currentError()
        }
        return Descriptors(fds[0], fds[1])
    }
}
