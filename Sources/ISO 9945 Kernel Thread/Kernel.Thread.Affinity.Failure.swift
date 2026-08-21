extension ISO_9945.Kernel.Thread.Affinity {

    public enum Failure: Sendable, Equatable {

        case ignore

        case report

        case fatal
    }
}
