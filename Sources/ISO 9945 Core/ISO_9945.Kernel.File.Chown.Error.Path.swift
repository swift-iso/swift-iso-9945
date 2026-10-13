extension ISO_9945.Kernel.File.Chown.Error {

    public enum Path: Swift::Error, Sendable, Equatable {
        case notFound
        case tooLong
        case loop
    }
}
