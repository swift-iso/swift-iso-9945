extension ISO_9945.Kernel.Device {

    public struct Major: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Device.Major: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt32) {
        self.init(rawValue: value)
    }
}

extension ISO_9945.Kernel.Device.Major: CustomStringConvertible {
    public var description: Swift.String {
        "\(rawValue)"
    }
}
