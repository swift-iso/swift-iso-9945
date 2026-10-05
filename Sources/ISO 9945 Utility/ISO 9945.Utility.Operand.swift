public import ISO_9945_Core

extension ISO_9945.Utility {

    public struct Operand: Hashable, Sendable {

        public let rawValue: String

        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Utility.Operand {

    public var requiresDelimiter: Bool {
        rawValue.count > 1 && rawValue.first == ISO_9945.Utility.Option.delimiter
    }
}

extension ISO_9945.Utility.Operand: CustomStringConvertible {

    public var description: String {
        rawValue
    }
}

extension ISO_9945.Utility.Operand: LosslessStringConvertible {}
