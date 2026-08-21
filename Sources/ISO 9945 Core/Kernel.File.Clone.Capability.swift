extension ISO_9945.Kernel.File.Clone {

    public enum Capability: Sendable, Equatable {

        case reflink

        case none
    }
}
