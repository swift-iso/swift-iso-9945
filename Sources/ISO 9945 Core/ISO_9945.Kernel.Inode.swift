extension ISO_9945.Kernel {

    public struct Inode: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: UInt64

        @inlinable
        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }

        @inlinable
        public init(_ value: UInt64) {
            self.rawValue = value
        }
    }
}

extension ISO_9945.Kernel.Inode: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: UInt64) {
        self.rawValue = value
    }
}

extension ISO_9945.Kernel.Inode: CustomStringConvertible {
    public var description: Swift.String {
        "\(rawValue)"
    }
}
