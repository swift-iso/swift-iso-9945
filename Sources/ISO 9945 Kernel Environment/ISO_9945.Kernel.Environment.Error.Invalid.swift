extension ISO_9945.Kernel.Environment.Error {

    public enum Invalid: Swift.Error, Sendable, Equatable, Hashable {

        case emptyName

        case nameContainsEquals
    }
}

extension ISO_9945.Kernel.Environment.Error.Invalid: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .emptyName: return "empty variable name"
        case .nameContainsEquals: return "variable name contains '='"
        }
    }
}
