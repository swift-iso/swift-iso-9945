extension ISO_9945.Kernel.IO.Error {

    @inlinable
    public var code: Error_Primitives.Error.Code {
        switch self {
        case .broken:
            return .POSIX.EPIPE

        case .reset:
            return .POSIX.ECONNRESET

        case .hardware:
            return .POSIX.EIO

        case .illegalSeek:
            return .POSIX.ESPIPE

        case .deviceUnsupported:
            return .POSIX.ENODEV

        case .deviceUnavailable:
            return .POSIX.ENXIO

        case .unsupported:
            return .POSIX.ENOTSUP
        }
    }
}

extension ISO_9945.Kernel.IO.Error {

    @inlinable
    public init?(code: Error_Primitives.Error.Code) {
        switch code {
        case .POSIX.EPIPE:
            self = .broken

        case _ where Error_Primitives.Error.Code.POSIX.isECONNRESET(code):
            self = .reset

        case .POSIX.EIO:
            self = .hardware

        case .POSIX.ESPIPE:
            self = .illegalSeek

        case .POSIX.ENODEV:
            self = .deviceUnsupported

        case .POSIX.ENXIO:
            self = .deviceUnavailable

        case _ where Error_Primitives.Error.Code.POSIX.isENOTSUP(code):
            self = .unsupported

        default:
            return nil
        }
    }
}
