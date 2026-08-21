#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#elseif canImport(Android)
    internal import Android
#else
    #error(
        "ISO_9945.Kernel.Socket.Backlog: unsupported platform (no Darwin, Glibc, Musl, or Android)"
    )
#endif

extension ISO_9945.Kernel.Socket.Backlog {

    public static var max: ISO_9945.Kernel.Socket.Backlog {
        #if canImport(Darwin)
            ISO_9945.Kernel.Socket.Backlog(Darwin.SOMAXCONN)
        #elseif canImport(Musl)
            ISO_9945.Kernel.Socket.Backlog(Musl.SOMAXCONN)
        #elseif canImport(Glibc)
            ISO_9945.Kernel.Socket.Backlog(Glibc.SOMAXCONN)
        #elseif canImport(Android)
            ISO_9945.Kernel.Socket.Backlog(Android.SOMAXCONN)
        #else
            #error(
                "ISO_9945.Kernel.Socket.Backlog.max: unsupported platform (no Darwin, Glibc, Musl, or Android)"
            )
        #endif
    }
}
