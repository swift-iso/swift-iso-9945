extension ISO_9945.Kernel.IO.Blocking.Error {

    @inlinable
    public var code: Error.Error.Code {
        switch self {
        case .wouldBlock:
            return .POSIX.EAGAIN
        }
    }
}

extension ISO_9945.Kernel.IO.Blocking.Error {

    @inlinable
    public init?(code: Error.Error.Code) {
        if Error.Error.Code.POSIX.isEAGAIN(code) {
            self = .wouldBlock
        } else {
            return nil
        }
    }
}
