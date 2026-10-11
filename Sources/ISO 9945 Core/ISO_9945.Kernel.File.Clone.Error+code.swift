extension ISO_9945.Kernel.File.Clone.Error {

    public init(from syscall: Syscall) {
        switch syscall {
        case .notSupported:
            self = .notSupported

        case .platform(let code, let operation):
            self.init(code: code, operation: operation)
        }
    }

    @_spi(Syscall)
    public init(code: Error::Error.Code, operation: Operation) {
        switch code {
        case _ where code == .ENOENT:
            self = .sourceNotFound

        case _ where code == .EEXIST:
            self = .destinationExists

        case _ where code == .EACCES,
            _ where code == .EPERM:
            self = .permissionDenied

        case _ where code == .EXDEV:
            self = .crossDevice

        case _ where code == .EISDIR:
            self = .isDirectory

        case _ where Error::Error.Code.POSIX.isENOTSUP(code):
            self = .notSupported

        default:
            self = .platform(code: code, operation: operation)
        }
    }
}
