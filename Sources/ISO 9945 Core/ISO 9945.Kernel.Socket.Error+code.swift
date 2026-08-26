extension ISO_9945.Kernel.Socket.Error {

    @inlinable
    public var code: Error.Error.Code {
        switch self {
        case .platform(let e): return e.code
        case .interrupted: return Error.Error.Code.POSIX.EINTR
        }
    }
}

extension ISO_9945.Kernel.Socket.Error {

    @inlinable
    public init(code: Error.Error.Code) {
        self = .platform(Error.Error(code: code))
    }
}
