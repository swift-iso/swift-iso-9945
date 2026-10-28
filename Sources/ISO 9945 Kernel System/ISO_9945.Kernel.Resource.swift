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

    /// `RLIMIT_CORE`: the largest core file, in bytes.
    public static let core = Self(rawValue: Int32(RLIMIT_CORE))

    /// `RLIMIT_CPU`: processor time, in seconds.
    public static let cpu = Self(rawValue: Int32(RLIMIT_CPU))

    /// `RLIMIT_DATA`: the largest data segment, in bytes.
    public static let data = Self(rawValue: Int32(RLIMIT_DATA))

    /// `RLIMIT_FSIZE`: the largest file the process may create, in bytes.
    public static let file = Self(rawValue: Int32(RLIMIT_FSIZE))

    /// `RLIMIT_NOFILE`: one more than the highest descriptor the process may open.
    public static let descriptors = Self(rawValue: Int32(RLIMIT_NOFILE))

    /// `RLIMIT_STACK`: the largest main-thread stack, in bytes.
    public static let stack = Self(rawValue: Int32(RLIMIT_STACK))

    /// `RLIMIT_AS`: the largest address space, in bytes.
    public static let address = Self(rawValue: Int32(RLIMIT_AS))
}
