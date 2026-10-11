extension ISO_9945.Kernel.Storage.Error {

    @inlinable
    public var code: Error::Error.Code {
        switch self {
        case .exhausted:
            return .ENOSPC

        case .quota:
            return .EDQUOT
        }
    }
}

extension ISO_9945.Kernel.Storage.Error {

    @inlinable
    public init?(code: Error::Error.Code) {
        switch code {
        case .ENOSPC:
            self = .exhausted

        case _ where code == .EDQUOT:
            self = .quota

        default:
            return nil
        }
    }
}
