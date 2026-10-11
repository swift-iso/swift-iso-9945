extension ISO_9945.Kernel.File.Direct.Error {

    public enum Operation: Sendable, Equatable {
        case open
        case cache(Cache)
        case sector(Sector)
        case read
        case write
    }
}
