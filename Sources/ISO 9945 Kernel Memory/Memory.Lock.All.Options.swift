import Memory

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Memory.Lock.All {

    public struct Options: Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension Memory.Lock.All.Options {

    public static func | (lhs: Self, rhs: Self) -> Self {
        Self(rawValue: lhs.rawValue | rhs.rawValue)
    }

    public func contains(_ other: Self) -> Bool {
        (rawValue & other.rawValue) == other.rawValue
    }
}

extension Memory.Lock.All.Options {

    public static let current = Self(rawValue: MCL_CURRENT)

    public static let future = Self(rawValue: MCL_FUTURE)
}
