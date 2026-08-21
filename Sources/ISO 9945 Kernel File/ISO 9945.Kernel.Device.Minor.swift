extension ISO_9945.Kernel.Device {

    public struct Minor: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Device.Minor: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt32) {
        self.init(rawValue: value)
    }
}

extension ISO_9945.Kernel.Device.Minor: CustomStringConvertible {
    public var description: Swift.String {
        "\(rawValue)"
    }
}
