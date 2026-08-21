#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension System {

    public static var pathMax: System.Path.Length {
        System.Path.Length(_unchecked: Cardinal(UInt(PATH_MAX)))
    }

    public static var pageSize: System.Page.Size {
        System.Page.Size(_unchecked: Cardinal(UInt(sysconf(Int32(_SC_PAGESIZE)))))
    }

    public static var processorCount: System.Processor.Count {
        let count = sysconf(Int32(_SC_NPROCESSORS_ONLN))
        return System.Processor.Count(_unchecked: Cardinal(UInt(count > 0 ? count : 1)))
    }

    public static func sleep(_ duration: Duration) {
        guard duration > .zero else { return }
        let (seconds, attoseconds) = duration.components
        var ts = timespec()
        ts.tv_sec = Int(seconds)
        ts.tv_nsec = Int(attoseconds / 1_000_000_000)
        var rem = timespec()
        while unsafe nanosleep(&ts, &rem) == -1, errno == EINTR {
            ts = rem
        }
    }
}
