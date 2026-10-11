extension ISO_9945.Kernel.File.Clone {

    public enum Capability: Sendable, Equatable {

        case reflink

        case none
    }
}

extension ISO_9945.Kernel.File.Clone.Capability {

    public static func probeDefault(
        at path: borrowing Path
    ) -> ISO_9945.Kernel.File.Clone.Capability {
        _ = path
        return .none
    }
}
