extension ISO_9945.Kernel.IO.Blocking.Error {

    @inlinable
    public var code: Error::Error.Code {
        switch self {
        case .wouldBlock:
            return .EAGAIN
        }
    }
}

extension ISO_9945.Kernel.IO.Blocking.Error {

    @inlinable
    public init?(code: Error::Error.Code) {
        guard code == .EAGAIN || code == .EWOULDBLOCK else {
            return nil
        }
        self = .wouldBlock
    }
}
