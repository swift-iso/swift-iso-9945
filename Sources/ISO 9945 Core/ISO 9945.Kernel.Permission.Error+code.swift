extension ISO_9945.Kernel.Permission.Error {

    @inlinable
    public init?(code: Error.Error.Code) {
        switch code {
        case .POSIX.EACCES:
            self = .denied

        case .POSIX.EPERM:
            self = .notPermitted

        case .POSIX.EROFS:
            self = .readOnlyFilesystem

        default:
            return nil
        }
    }
}
