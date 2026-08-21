#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension ISO_9945.Kernel.Signal.Mask {

    public struct How: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Signal.Mask.How {

    public static let block = Self(rawValue: SIG_BLOCK)

    public static let unblock = Self(rawValue: SIG_UNBLOCK)

    public static let set = Self(rawValue: SIG_SETMASK)
}

extension ISO_9945.Kernel.Signal.Mask.How: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .block: return "block"
        case .unblock: return "unblock"
        case .set: return "set"
        default: return "how(\(rawValue))"
        }
    }
}
