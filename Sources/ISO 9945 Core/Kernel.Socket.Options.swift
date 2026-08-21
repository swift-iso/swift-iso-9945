extension ISO_9945.Kernel.Socket {

    public struct Options: OptionSet, Sendable {
        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Socket.Options {

    public static let none = Self([])
}
