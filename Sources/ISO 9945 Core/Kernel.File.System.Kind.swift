extension ISO_9945.Kernel.File.System {

    public struct Kind: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: UInt64

        @inlinable
        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }

        @inlinable
        public init(_ value: UInt64) {
            self.rawValue = value
        }

        #if os(Linux)

            public static let ext4 = Kind(rawValue: 0xEF53)

            public static let btrfs = Kind(rawValue: 0x9123_683E)

            public static let xfs = Kind(rawValue: 0x5846_5342)

            public static let tmpfs = Kind(rawValue: 0x0102_1994)

            public static let proc = Kind(rawValue: 0x9FA0)

            public static let sysfs = Kind(rawValue: 0x6265_6572)

            public static let nfs = Kind(rawValue: 0x6969)

            public static let cifs = Kind(rawValue: 0xFF53_4D42)
        #endif
    }
}

extension ISO_9945.Kernel.File.System.Kind: CustomStringConvertible {
    public var description: Swift.String {
        #if os(Linux)
            switch self {
            case .ext4: return "ext4"
            case .btrfs: return "btrfs"
            case .xfs: return "xfs"
            case .tmpfs: return "tmpfs"
            case .proc: return "proc"
            case .sysfs: return "sysfs"
            case .nfs: return "nfs"
            case .cifs: return "cifs"
            default: return "0x\(String(rawValue, radix: 16))"
            }
        #else
            return "\(rawValue)"
        #endif
    }
}
