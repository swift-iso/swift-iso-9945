@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Lock {

    package static func lock(
        fd: Int32,
        range: ISO_9945.Kernel.Lock.Range,
        kind: ISO_9945.Kernel.Lock.Kind
    ) throws(ISO_9945.Kernel.Lock.Error) {
        guard try validate(range) else { return }
        var fl = makeFlock(range: range, kind: kind)

        let result = unsafe fcntl(fd, F_SETLKW, &fl)
        guard result != -1 else {
            throw ISO_9945.Kernel.Lock.Error(Error.Error.Code.captureErrno())
        }
    }

    static func validate(
        _ range: ISO_9945.Kernel.Lock.Range
    ) throws(ISO_9945.Kernel.Lock.Error) -> Bool {
        guard case .bytes(let start, let end) = range else { return true }
        if end.underlying < start.underlying {
            throw .invalidRange(start: start.underlying, end: end.underlying)
        }
        return end.underlying != start.underlying
    }

    package static func unlock(
        fd: Int32,
        range: ISO_9945.Kernel.Lock.Range
    ) throws(ISO_9945.Kernel.Lock.Error) {
        guard try validate(range) else { return }
        var fl = flock()
        fl.l_type = Int16(F_UNLCK)
        fl.l_whence = Int16(SEEK_SET)

        switch range {
        case .file:
            fl.l_start = 0
            fl.l_len = 0

        case .bytes(let start, let end):
            fl.l_start = off_t(start.underlying)
            fl.l_len = off_t((end - start).underlying)
        }

        let result = unsafe fcntl(fd, F_SETLK, &fl)
        guard result != -1 else {
            throw ISO_9945.Kernel.Lock.Error(Error.Error.Code.captureErrno())
        }
    }

    static func makeFlock(
        range: ISO_9945.Kernel.Lock.Range,
        kind: ISO_9945.Kernel.Lock.Kind
    ) -> flock {
        var fl = flock()

        fl.l_type = kind == .shared ? Int16(F_RDLCK) : Int16(F_WRLCK)
        fl.l_whence = Int16(SEEK_SET)

        switch range {
        case .file:

            fl.l_start = 0
            fl.l_len = 0

        case .bytes(let start, let end):
            fl.l_start = off_t(start.underlying)
            fl.l_len = off_t((end - start).underlying)
        }

        return fl
    }
}

extension ISO_9945.Kernel.Lock {

    public static func lock(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        range: ISO_9945.Kernel.Lock.Range,
        kind: ISO_9945.Kernel.Lock.Kind
    ) throws(ISO_9945.Kernel.Lock.Error) {
        try lock(fd: descriptor._rawValue, range: range, kind: kind)
    }

    public static func unlock(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        range: ISO_9945.Kernel.Lock.Range
    ) throws(ISO_9945.Kernel.Lock.Error) {
        try unlock(fd: descriptor._rawValue, range: range)
    }
}

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
            throw ISO_9945.Kernel.Lock.Error(Error.Error.Code.captureErrno())
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

extension ISO_9945.Kernel.Lock.Error {

    init(_ code: Error.Error.Code) {
        switch code {
        case .posix(let errno):
            switch errno {
            case EDEADLK:
                self = .deadlock

            case ENOLCK:
                self = .unavailable

            case EINTR:
                self = .interrupted

            case EAGAIN, EACCES:

                self = .contention

            default:

                self = .platform(code: code)
            }

        case .win32:
            self = .platform(code: code)
        }
    }
}
