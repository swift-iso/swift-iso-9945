extension ISO_9945.Kernel.User.Database {

    public enum Error: Swift.Error, Sendable, Equatable {
        case lookup(Error.Error.Code)
    }
}

extension ISO_9945.Kernel.User.Database.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .lookup(let code):
            return "user database lookup failed: \(code)"
        }
    }
}
