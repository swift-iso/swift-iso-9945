public import CPU

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension CPU.Logical {

    /// The logical processors currently online, `sysconf(_SC_NPROCESSORS_ONLN)`.
    ///
    /// `_SC_NPROCESSORS_ONLN` is an extension that Darwin, glibc and musl share, not a
    /// POSIX-specified name. A failed call reports one processor.
    public static var count: Count {
        let value = sysconf(Int32(_SC_NPROCESSORS_ONLN))
        guard value > 0, let count = UInt(exactly: value) else {
            return Count(_unchecked: Cardinal(1 as UInt))
        }
        return Count(_unchecked: Cardinal(count))
    }
}
