extension ISO_9945.Kernel.Socket {

    public enum Error: Swift.Error, Sendable {

        case platform(Error_Primitives.Error)

        case interrupted
    }
}

extension ISO_9945.Kernel.Socket.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.platform(let l), .platform(let r)): return l == r
        case (.interrupted, .interrupted): return true
        default: return false
        }
    }
}

extension ISO_9945.Kernel.Socket.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .platform(let e): return "\(e)"
        case .interrupted: return "connect interrupted; attempt continues asynchronously"
        }
    }
}
