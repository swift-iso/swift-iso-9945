extension ISO_9945.Kernel.Thread.Affinity {

    public enum Support: Sendable, Equatable {

        case none

        case advisory

        case enforced
    }
}
