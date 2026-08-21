extension ISO_9945.Kernel.File.Direct.Mode {

    public enum Resolved: Sendable, Equatable {

        case direct

        case uncached

        case buffered
    }
}
