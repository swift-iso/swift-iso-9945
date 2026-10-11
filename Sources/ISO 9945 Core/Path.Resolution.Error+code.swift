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

        case _ where code == .ENOTEMPTY:
            self = .notEmpty

        case _ where code == .ELOOP:
            self = .loop

        case .EXDEV:
            self = .crossDevice

        case _ where code == .ENAMETOOLONG:
            self = .nameTooLong

        default:
            return nil
        }
    }
}
