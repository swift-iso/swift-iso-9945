extension ISO_9945.Kernel.Descriptor.Validity.Error {

    @inlinable
    public var code: Error_Primitives.Error.Code {
        switch self {
        case .invalid:
            return .POSIX.EBADF

        case .limit(let limit):
            return limit.code
        }
    }
}

extension ISO_9945.Kernel.Descriptor.Validity.Error.Limit {

    @inlinable
    public var code: Error_Primitives.Error.Code {
        switch self {
        case .process:
            return .POSIX.EMFILE

        case .system:
            return .POSIX.ENFILE
        }
    }
}

extension ISO_9945.Kernel.Descriptor.Validity.Error {

    @inlinable
    public init?(code: Error_Primitives.Error.Code) {
        switch code {
        case .POSIX.EBADF:
            self = .invalid

        case .POSIX.EMFILE:
            self = .limit(.process)

        case .POSIX.ENFILE:
            self = .limit(.system)

        default:
            return nil
        }
    }
}
