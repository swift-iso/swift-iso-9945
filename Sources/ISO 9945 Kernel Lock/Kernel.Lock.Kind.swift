extension ISO_9945.Kernel.Lock {

    public enum Kind: Sendable, Equatable, Hashable {

        case shared

        case exclusive
    }
}
