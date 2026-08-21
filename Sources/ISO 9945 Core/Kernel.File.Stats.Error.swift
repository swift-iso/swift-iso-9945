extension ISO_9945.Kernel.File.Stats {

    public enum Error: Swift.Error, Sendable, Equatable {

        case handle(ISO_9945.Kernel.Descriptor.Validity.Error)

        case platform(Error_Primitives.Error)
    }
}

extension ISO_9945.Kernel.File.Stats.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .handle(let e): return "handle: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}
