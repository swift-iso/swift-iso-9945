import Memory_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Memory.Allocation {

    public static var system: Memory.Allocation.Granularity {
        let raw = sysconf(Int32(_SC_PAGESIZE))

        let pageSize = raw > 0 ? Int(raw) : 4096

        return Memory.Allocation.Granularity(_unchecked: try! Memory.Alignment(pageSize))
    }
}
