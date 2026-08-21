extension ISO_9945.Kernel.IO.Write {

    public enum Error: Swift.Error, Sendable {
        case handle(ISO_9945.Kernel.Descriptor.Validity.Error)
        case blocking(ISO_9945.Kernel.IO.Blocking.Error)
        case platform(Error_Primitives.Error)
    }
}

extension ISO_9945.Kernel.IO.Write.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.handle(let l), .handle(let r)): return l == r
        case (.blocking(let l), .blocking(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

extension ISO_9945.Kernel.IO.Write.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .handle(let e): return "handle: \(e)"
        case .blocking(let e): return "blocking: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}
