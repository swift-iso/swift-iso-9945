public import ISO_9945_Core

extension ISO_9945.Utility.Option {

    public struct Argument: Hashable, Sendable {

        public let rawValue: String

        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Utility.Option.Argument: CustomStringConvertible {

    public var description: String {
        rawValue
    }
}
