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
            return .ENODEV

        case .deviceUnavailable:
            return .ENXIO

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

        case _ where code == .ECONNRESET:
            self = .reset

        case .EIO:
            self = .hardware

        case .ESPIPE:
            self = .illegalSeek

        case .ENODEV:
            self = .deviceUnsupported

        case .ENXIO:
            self = .deviceUnavailable

        case _ where code == .ENOTSUP:
            self = .unsupported

        default:
            return nil
        }
    }
}
