extension ISO_9945.Kernel.File.Direct {

    public enum Capability: Sendable, Equatable {

        case directSupported(Requirements.Alignment)

        case uncachedOnly

        case bufferedOnly
    }
}

extension ISO_9945.Kernel.File.Direct.Capability {

    public var alignment: ISO_9945.Kernel.File.Direct.Requirements.Alignment? {
        if case .directSupported(let alignment) = self {
            return alignment
        }
        return nil
    }
}
