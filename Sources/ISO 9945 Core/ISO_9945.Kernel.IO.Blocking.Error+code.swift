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
        if (code == .EAGAIN || code == .EWOULDBLOCK) {
            self = .wouldBlock
        } else {
            return nil
        }
    }
}
