public import System_Primitives

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

    /// The signed platform result; invalid page sizes are rejected by Memory.Alignment.
    public static var pageSize: Int {
        let raw = sysconf(Int32(_SC_PAGESIZE))
        guard let size = Int(exactly: raw) else {
            preconditionFailure("Platform page size is not representable as Int")
        }
        return size
    }

    public static var processorCount: Int {
        let count = sysconf(Int32(_SC_NPROCESSORS_ONLN))
        guard count > 0 else { return 1 }
        guard let result = Int(exactly: count) else {
            preconditionFailure("Processor count is not representable as Int")
        }
        return result
    }

    /// One `nanosleep(2)` call.
    ///
    /// - Returns: `nil` when the full duration elapsed, or the unslept remainder
    ///   when a signal interrupted the call (`EINTR`). Resuming is the caller's choice.
    public static func nanosleep(_ duration: Duration) -> Duration? {
        guard duration > .zero else { return nil }
        let (seconds, attoseconds) = duration.components
        var ts = timespec()
        ts.tv_sec = Int(seconds)
        ts.tv_nsec = Int(attoseconds / 1_000_000_000)
        var rem = timespec()
        guard unsafe _nanosleep(&ts, &rem) == -1, errno == EINTR else { return nil }
        return .seconds(rem.tv_sec) + .nanoseconds(rem.tv_nsec)
    }
}

private func _nanosleep(
    _ request: UnsafePointer<timespec>,
    _ remaining: UnsafeMutablePointer<timespec>
) -> Int32 {
    unsafe nanosleep(request, remaining)
}
