public import Path

extension Path.Resolution.Error {

    @inlinable
    public init?(code: Error::Error.Code) {
        switch code {
        case .ENOENT:
            self = .notFound

        case .EEXIST:
            self = .exists

        case .EISDIR:
            self = .isDirectory

        case .ENOTDIR:
            self = .notDirectory

        case _ where Error::Error.Code.POSIX.isENOTEMPTY(code):
            self = .notEmpty

        case _ where Error::Error.Code.POSIX.isELOOP(code):
            self = .loop

        case .EXDEV:
            self = .crossDevice

        case _ where Error::Error.Code.POSIX.isENAMETOOLONG(code):
            self = .nameTooLong

        default:
            return nil
        }
    }
}
