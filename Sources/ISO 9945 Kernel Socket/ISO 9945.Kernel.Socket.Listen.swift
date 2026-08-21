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
        "ISO_9945.Kernel.Socket.Listen: unsupported platform (no Darwin, Glibc, Musl, or Android)"
    )
#endif

extension ISO_9945.Kernel.Socket {

    public enum Listen {}
}

extension ISO_9945.Kernel.Socket.Listen {

    public static func listen(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        backlog: ISO_9945.Kernel.Socket.Backlog = .max
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try listen(fd: descriptor._rawValue, backlog: backlog)
    }
}

extension ISO_9945.Kernel.Socket.Listen {

    internal static func listen(
        fd: Int32,
        backlog: ISO_9945.Kernel.Socket.Backlog = .max
    ) throws(ISO_9945.Kernel.Socket.Error) {
        let rc = platformListen(fd, backlog.rawValue)

        guard rc == 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }
    }
}

private func platformListen(_ fd: Int32, _ backlog: Int32) -> Int32 {
    #if canImport(Darwin)
        Darwin.listen(fd, backlog)
    #elseif canImport(Glibc)
        unsafe Glibc.listen(fd, backlog)
    #elseif canImport(Musl)
        unsafe Musl.listen(fd, backlog)
    #elseif canImport(Android)
        unsafe Android.listen(fd, backlog)
    #else
        #error(
            "ISO_9945.Kernel.Socket.Listen: unsupported platform (no Darwin, Glibc, Musl, or Android)"
        )
    #endif
}
