@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Lock {

    public enum Immediate {}
}

extension ISO_9945.Kernel.Lock.Immediate {

    @_spi(Syscall)
    public static func lock(
        fd: Int32,
        range: ISO_9945.Kernel.Lock.Range,
        kind: ISO_9945.Kernel.Lock.Kind
    ) throws(ISO_9945.Kernel.Lock.Error) {
        guard try ISO_9945.Kernel.Lock.validate(range) else { return }
        var fl = ISO_9945.Kernel.Lock.makeFlock(range: range, kind: kind)

        let result = unsafe fcntl(fd, F_SETLK, &fl)
        if result == -1 {

            if errno == EAGAIN || errno == EACCES {
                throw .contention
            }
            throw ISO_9945.Kernel.Lock.Error(Error::Error.Code.captureErrno())
        }
    }
}

extension ISO_9945.Kernel.Lock.Immediate {

    public static func lock(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        range: ISO_9945.Kernel.Lock.Range,
        kind: ISO_9945.Kernel.Lock.Kind
    ) throws(ISO_9945.Kernel.Lock.Error) {
        try lock(fd: descriptor._rawValue, range: range, kind: kind)
    }
}
