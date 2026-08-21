extension ISO_9945.Kernel.Lock.Scope {

    public enum Error<E: Swift.Error>: Swift.Error, Sendable {

        case lock(ISO_9945.Kernel.Lock.Error)

        case body(E)
    }
}
