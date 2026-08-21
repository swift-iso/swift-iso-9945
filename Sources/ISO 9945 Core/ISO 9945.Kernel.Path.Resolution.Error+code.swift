public import Path_Primitives

extension Path.Resolution.Error {

    @inlinable
    public init?(code: Error_Primitives.Error.Code) {
        switch code {
        case .POSIX.ENOENT:
            self = .notFound

        case .POSIX.EEXIST:
            self = .exists

        case .POSIX.EISDIR:
            self = .isDirectory

        case .POSIX.ENOTDIR:
            self = .notDirectory

        case _ where Error_Primitives.Error.Code.POSIX.isENOTEMPTY(code):
            self = .notEmpty

        case _ where Error_Primitives.Error.Code.POSIX.isELOOP(code):
            self = .loop

        case .POSIX.EXDEV:
            self = .crossDevice

        case _ where Error_Primitives.Error.Code.POSIX.isENAMETOOLONG(code):
            self = .nameTooLong

        default:
            return nil
        }
    }
}
