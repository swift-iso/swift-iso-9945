extension ISO_9945.Kernel.Permission.Error {

    @inlinable
    public init?(code: Error::Error.Code) {
        switch code {
        case .EACCES:
            self = .denied

        case .EPERM:
            self = .notPermitted

        case .EROFS:
            self = .readOnlyFilesystem

        default:
            return nil
        }
    }
}
