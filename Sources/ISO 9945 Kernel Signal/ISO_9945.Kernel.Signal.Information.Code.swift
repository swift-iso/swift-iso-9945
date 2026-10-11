#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Signal.Information {

    public struct Code: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Signal.Information.Code {

    public static let exited = Self(rawValue: Int32(CLD_EXITED))

    public static let killed = Self(rawValue: Int32(CLD_KILLED))

    public static let dumped = Self(rawValue: Int32(CLD_DUMPED))

    public static let trapped = Self(rawValue: Int32(CLD_TRAPPED))

    public static let stopped = Self(rawValue: Int32(CLD_STOPPED))

    public static let continued = Self(rawValue: Int32(CLD_CONTINUED))
}
