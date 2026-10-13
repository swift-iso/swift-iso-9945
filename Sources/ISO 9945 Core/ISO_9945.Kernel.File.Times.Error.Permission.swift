extension ISO_9945.Kernel.File.Times.Error {

    public enum Permission: Swift::Error, Sendable, Equatable {
        case denied
        case notPermitted
        case readOnlyFilesystem
    }
}
