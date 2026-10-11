extension ISO_9945.Kernel.Descriptor.Validity.Error {

    @inlinable
    public var code: Error::Error.Code {
        switch self {
        case .invalid:
            return .EBADF

        case .limit(let limit):
            return limit.code
        }
    }
}

extension ISO_9945.Kernel.Descriptor.Validity.Error.Limit {

    @inlinable
    public var code: Error::Error.Code {
        switch self {
        case .process:
            return .EMFILE

        case .system:
            return .ENFILE
        }
    }
}

extension ISO_9945.Kernel.Descriptor.Validity.Error {

    @inlinable
    public init?(code: Error::Error.Code) {
        switch code {
        case .EBADF:
            self = .invalid

        case .EMFILE:
            self = .limit(.process)

        case .ENFILE:
            self = .limit(.system)

        default:
            return nil
        }
    }
}
