#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Thread {

    /// One `nanosleep(2)` call on the calling thread.
    ///
    /// - Returns: `nil` when the full duration elapsed, or the unslept remainder
    ///   when a signal interrupted the call (`EINTR`). Resuming is the caller's choice.
    public static func sleep(_ duration: Duration) -> Duration? {
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
