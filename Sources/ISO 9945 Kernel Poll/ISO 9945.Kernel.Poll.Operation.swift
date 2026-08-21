#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#elseif canImport(Android)
    internal import Android
#else
    #error("ISO_9945.Kernel.Poll: unsupported platform (no Darwin, Glibc, Musl, or Android)")
#endif

extension ISO_9945.Kernel.Poll {

    public static func poll(
        _ entries: inout [Entry],
        timeout: Int32
    ) throws(Error_Primitives.Error) -> Int {
        let count = entries.withUnsafeMutableBufferPointer { buffer in
            guard let base = buffer.baseAddress else { return Int32(0) }
            return unsafe base.withMemoryRebound(to: pollfd.self, capacity: buffer.count) {
                pollfdPtr in
                unsafe platformPoll(pollfdPtr, nfds_t(buffer.count), timeout)
            }
        }

        guard count >= 0 else {
            throw Error_Primitives.Error.current(operation: "poll")
        }

        return Int(count)
    }
}

private func platformPoll(
    _ fds: UnsafeMutablePointer<pollfd>,
    _ nfds: nfds_t,
    _ timeout: Int32
) -> Int32 {
    #if canImport(Darwin)
        unsafe Darwin.poll(fds, nfds, timeout)
    #elseif canImport(Glibc)
        unsafe Glibc.poll(fds, nfds, timeout)
    #elseif canImport(Musl)
        unsafe Musl.poll(fds, nfds, timeout)
    #elseif canImport(Android)
        unsafe Android.poll(fds, nfds, timeout)
    #else
        #error(
            "ISO_9945.Kernel.Poll.poll: unsupported platform (no Darwin, Glibc, Musl, or Android)"
        )
    #endif
}
