extension ISO_9945.Kernel.IO.Blocking.Error {

    @inlinable
    public var code: Error_Primitives.Error.Code {
        switch self {
        case .wouldBlock:
            return .POSIX.EAGAIN
        }
    }
}

extension ISO_9945.Kernel.IO.Blocking.Error {

    @inlinable
    public init?(code: Error_Primitives.Error.Code) {
        if Error_Primitives.Error.Code.POSIX.isEAGAIN(code) {
            self = .wouldBlock
        } else {
            return nil
        }
    }
}
