extension ISO_9945.Kernel.Environment {

    public enum Error: Swift.Error, Sendable {
        case permission(ISO_9945.Kernel.Permission.Error)
        case invalid(Invalid)
        case platform(Error_Primitives.Error)
    }
}

extension ISO_9945.Kernel.Environment.Error {

    public enum Invalid: Swift.Error, Sendable, Equatable, Hashable {

        case emptyName

        case nameContainsEquals
    }
}

extension ISO_9945.Kernel.Environment.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.permission(let l), .permission(let r)): return l == r
        case (.invalid(let l), .invalid(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

extension ISO_9945.Kernel.Environment.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .permission(let e): return "permission: \(e)"
        case .invalid(let e): return "invalid: \(e)"
        case .platform(let e): return "\(e)"
        }
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
