#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel {

    /// A resource whose use `getrlimit` and `setrlimit` bound (`<sys/resource.h>`).
    public struct Resource: RawRepresentable, Sendable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Resource {

    #if canImport(Glibc)
        /// Glibc declares the `RLIMIT_*` constants as members of `enum __rlimit_resource`.
        private init(_ resource: __rlimit_resource) {
            self.init(rawValue: Int32(resource.rawValue))
        }
    #else
        private init(_ resource: Int32) {
            self.init(rawValue: resource)
        }
    #endif
}

extension ISO_9945.Kernel.Resource {

    /// `RLIMIT_CORE`: the largest core file, in bytes.
    public static let core = Self(RLIMIT_CORE)

    /// `RLIMIT_CPU`: processor time, in seconds.
    public static let cpu = Self(RLIMIT_CPU)

    /// `RLIMIT_DATA`: the largest data segment, in bytes.
    public static let data = Self(RLIMIT_DATA)

    /// `RLIMIT_FSIZE`: the largest file the process may create, in bytes.
    public static let file = Self(RLIMIT_FSIZE)

    /// `RLIMIT_NOFILE`: one more than the highest descriptor the process may open.
    public static let descriptors = Self(RLIMIT_NOFILE)

    /// `RLIMIT_STACK`: the largest main-thread stack, in bytes.
    public static let stack = Self(RLIMIT_STACK)

    /// `RLIMIT_AS`: the largest address space, in bytes.
    public static let address = Self(RLIMIT_AS)
}
