public import Memory

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Memory.Page {

    /// The page size, `sysconf(_SC_PAGESIZE)`.
    public static var size: Size {
        let value = sysconf(Int32(_SC_PAGESIZE))
        guard let size = UInt(exactly: value), size > 0 else {
            preconditionFailure("sysconf(_SC_PAGESIZE) reported no page size")
        }
        return Size(_unchecked: Cardinal(size))
    }
}
