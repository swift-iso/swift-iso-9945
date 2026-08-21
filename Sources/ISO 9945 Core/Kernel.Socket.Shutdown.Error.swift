extension ISO_9945.Kernel.Socket.Shutdown {

    public enum Error: Swift.Error, Sendable {

        case platform(Error_Primitives.Error)
    }
}

extension ISO_9945.Kernel.Socket.Shutdown.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.platform(let l), .platform(let r)): return l == r
        }
    }
}

extension ISO_9945.Kernel.Socket.Shutdown.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .platform(let e): return "\(e)"
        }
    }
}
