extension ISO_9945.Kernel.IO.Error {

    @inlinable
    public var code: Error::Error.Code {
        switch self {
        case .broken:
            return .EPIPE

        case .reset:
            return .ECONNRESET

        case .hardware:
            return .EIO

        case .illegalSeek:
            return .ESPIPE

        case .deviceUnsupported:
            return .POSIX.ENODEV

        case .deviceUnavailable:
            return .POSIX.ENXIO

        case .unsupported:
            return .ENOTSUP
        }
    }
}

extension ISO_9945.Kernel.IO.Error {

    @inlinable
    public init?(code: Error::Error.Code) {
        switch code {
        case .EPIPE:
            self = .broken

        case _ where Error::Error.Code.POSIX.isECONNRESET(code):
            self = .reset

        case .EIO:
            self = .hardware

        case .ESPIPE:
            self = .illegalSeek

        case .POSIX.ENODEV:
            self = .deviceUnsupported

        case .POSIX.ENXIO:
            self = .deviceUnavailable

        case _ where Error::Error.Code.POSIX.isENOTSUP(code):
            self = .unsupported

        default:
            return nil
        }
    }
}
