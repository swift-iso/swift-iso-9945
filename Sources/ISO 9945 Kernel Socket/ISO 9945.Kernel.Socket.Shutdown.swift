@_spi(Syscall) public import ISO_9945_Core

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
        "ISO_9945.Kernel.Socket.Shutdown: unsupported platform (no Darwin, Glibc, Musl, or Android)"
    )
#endif

extension ISO_9945.Kernel.Socket.Shutdown {

    public static func shutdown(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        how: How
    ) throws(Error) {
        try shutdown(fd: descriptor._rawValue, how: how)
    }
}

extension ISO_9945.Kernel.Socket.Shutdown {

    internal static func shutdown(
        fd: Int32,
        how: How
    ) throws(Error) {
        #if canImport(Darwin)
            let result = Darwin.shutdown(fd, how.rawValue)
        #elseif canImport(Musl)
            let result = Musl.shutdown(fd, how.rawValue)
        #elseif canImport(Glibc)
            let result = Glibc.shutdown(fd, how.rawValue)
        #elseif canImport(Android)
            let result = Android.shutdown(fd, how.rawValue)
        #else
            #error(
                "ISO_9945.Kernel.Socket.Shutdown.shutdown: unsupported platform (no Darwin, Glibc, Musl, or Android)"
            )
        #endif

        guard result == 0 else {
            throw ISO_9945.Kernel.Socket.Shutdown.Error.current()
        }
    }
}

extension ISO_9945.Kernel.Socket.Shutdown.Error {

    internal static func current() -> Self {
        let code = Error.Error.Code.current()
        return .platform(Error.Error(code: code))
    }
}
