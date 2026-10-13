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
    }
}

extension ISO_9945.Kernel.File.System.Kind: CustomStringConvertible {
    public var description: Swift::String {
        "\(rawValue)"
    }
}
