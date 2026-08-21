extension ISO_9945.Kernel.Socket.Error {

    @inlinable
    public var code: Error_Primitives.Error.Code {
        switch self {
        case .platform(let e): return e.code
        case .interrupted: return Error_Primitives.Error.Code.POSIX.EINTR
        }
    }
}

extension ISO_9945.Kernel.Socket.Error {

    @inlinable
    public init(code: Error_Primitives.Error.Code) {
        self = .platform(Error_Primitives.Error(code: code))
    }
}
