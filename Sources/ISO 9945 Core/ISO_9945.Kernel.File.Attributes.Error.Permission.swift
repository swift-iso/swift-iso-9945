extension ISO_9945.Kernel.File.Attributes.Error {

    public enum Permission: Swift::Error, Sendable, Equatable {
        case denied
        case notPermitted
        case readOnlyFilesystem
    }
}
