#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Process.Wait {

    public struct Kind: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Process.Wait.Kind {

    public static let all = Self(rawValue: Int32(bitPattern: UInt32(P_ALL.rawValue)))

    public static let pid = Self(rawValue: Int32(bitPattern: UInt32(P_PID.rawValue)))

    public static let processGroup = Self(rawValue: Int32(bitPattern: UInt32(P_PGID.rawValue)))
}
