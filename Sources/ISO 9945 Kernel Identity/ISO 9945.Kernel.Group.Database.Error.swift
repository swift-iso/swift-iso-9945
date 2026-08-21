extension ISO_9945.Kernel.Group.Database {

    public enum Error: Swift.Error, Sendable, Equatable {
        case lookup(Error_Primitives.Error.Code)
    }
}

extension ISO_9945.Kernel.Group.Database.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .lookup(let code):
            return "group database lookup failed: \(code)"
        }
    }
}
