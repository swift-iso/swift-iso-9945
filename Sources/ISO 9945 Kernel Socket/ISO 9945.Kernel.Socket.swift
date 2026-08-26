@_spi(Syscall) public import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket {

    public static func getError(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor
    ) throws(ISO_9945.Kernel.Socket.Error) -> Error.Error.Code {
        try getError(fd: descriptor._rawValue)
    }
}

extension ISO_9945.Kernel.Socket {

    internal static func getError(
        fd: Int32
    ) throws(ISO_9945.Kernel.Socket.Error) -> Error.Error.Code {
        var err: Int32 = 0
        var len = socklen_t(MemoryLayout<Int32>.size)

        let rc = unsafe getsockopt(
            fd,
            SOL_SOCKET,
            SO_ERROR,
            &err,
            &len
        )

        guard rc == 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }

        return .posix(err)
    }
}

extension ISO_9945.Kernel.Socket.Error {

    internal static func current() -> Self {
        let code = Error.Error.Code.current()
        return .platform(Error.Error(code: code))
    }
}
