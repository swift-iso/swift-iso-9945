public enum Interrupt: Swift.Error, Sendable, Hashable {

    case occurred

    case cancelled
}

extension Interrupt: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .occurred:
            return "interrupted"

        case .cancelled:
            return "cancelled"
        }
    }
}
