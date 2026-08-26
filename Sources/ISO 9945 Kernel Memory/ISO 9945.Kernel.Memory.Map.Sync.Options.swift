import Memory

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Memory.Map.Sync {

    public struct Options: Sendable, Equatable, Hashable {
        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension Memory.Map.Sync.Options {

    @inlinable
    public static func | (
        lhs: Memory.Map.Sync.Options,
        rhs: Memory.Map.Sync.Options
    ) -> Memory.Map.Sync.Options {
        Memory.Map.Sync.Options(rawValue: lhs.rawValue | rhs.rawValue)
    }
}

extension Memory.Map.Sync.Options {

    public static let sync = Self(rawValue: MS_SYNC)

    public static let async = Self(rawValue: MS_ASYNC)

    public static let invalidate = Self(rawValue: MS_INVALIDATE)
}
