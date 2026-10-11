extension ISO_9945.Kernel.File.Chown.Error {

    public enum Permission: Swift.Error, Sendable, Equatable {
        case denied
        case notPermitted
        case readOnlyFilesystem
    }
}
