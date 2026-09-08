public import ISO_9945_Core

extension ISO_9945.Utility {

    public enum Argument: Hashable, Sendable {
        case option(Option)
        case endOfOptions
        case operand(Operand)
    }
}

extension ISO_9945.Utility.Argument {

    public static let delimiter = "--"
}
