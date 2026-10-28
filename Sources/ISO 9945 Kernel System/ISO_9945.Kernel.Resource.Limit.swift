#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Resource {

    /// A resource's soft and hard limits (`struct rlimit`).
    public struct Limit: Sendable, Hashable {

        /// `rlim_cur`: the limit the kernel enforces, which the process may raise up to `maximum`.
        public var current: UInt64

        /// `rlim_max`: the ceiling for `current`; only a privileged process may raise it.
        public var maximum: UInt64

        public init(current: UInt64, maximum: UInt64) {
            self.current = current
            self.maximum = maximum
        }
    }
}

extension ISO_9945.Kernel.Resource.Limit {

    /// `RLIM_INFINITY`: no limit. Swift does not import the C macro.
    public static var infinity: UInt64 {
        #if canImport(Darwin)
            UInt64(Int64.max)
        #else
            UInt64.max
        #endif
    }
}

extension ISO_9945.Kernel.Resource.Limit {

    /// `getrlimit(2)`.
    public static func get(
        _ resource: ISO_9945.Kernel.Resource
    ) throws(Error) -> Self {
        var limit = rlimit()
        guard unsafe Self.getrlimit(resource, &limit) == 0 else {
            throw Error(code: .posix(errno))
        }
        return Self(current: UInt64(limit.rlim_cur), maximum: UInt64(limit.rlim_max))
    }

    /// `setrlimit(2)`.
    public static func set(
        _ limit: Self,
        for resource: ISO_9945.Kernel.Resource
    ) throws(Error) {
        var value = rlimit(rlim_cur: rlim_t(limit.current), rlim_max: rlim_t(limit.maximum))
        guard unsafe Self.setrlimit(resource, &value) == 0 else {
            throw Error(code: .posix(errno))
        }
    }
}

extension ISO_9945.Kernel.Resource.Limit {

    private static func getrlimit(
        _ resource: ISO_9945.Kernel.Resource,
        _ limit: UnsafeMutablePointer<rlimit>
    ) -> Int32 {
        #if canImport(Glibc)
            unsafe Glibc.getrlimit(__rlimit_resource_t(UInt32(resource.rawValue)), limit)
        #elseif canImport(Musl)
            unsafe Musl.getrlimit(resource.rawValue, limit)
        #else
            unsafe Darwin.getrlimit(resource.rawValue, limit)
        #endif
    }

    private static func setrlimit(
        _ resource: ISO_9945.Kernel.Resource,
        _ limit: UnsafeMutablePointer<rlimit>
    ) -> Int32 {
        #if canImport(Glibc)
            unsafe Glibc.setrlimit(__rlimit_resource_t(UInt32(resource.rawValue)), limit)
        #elseif canImport(Musl)
            unsafe Musl.setrlimit(resource.rawValue, limit)
        #else
            unsafe Darwin.setrlimit(resource.rawValue, limit)
        #endif
    }
}
