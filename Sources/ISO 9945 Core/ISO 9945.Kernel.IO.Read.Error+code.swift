extension ISO_9945.Kernel.IO.Read.Error {

    @inlinable
    public var code: Error.Error.Code {
        switch self {
        case .handle(let e): return e.code
        case .blocking(let e): return e.code
        case .platform(let e): return e.code
        }
    }
}

extension ISO_9945.Kernel.IO.Read.Error {

    @inlinable
    public init(code: Error.Error.Code) {
        if let e = ISO_9945.Kernel.Descriptor.Validity.Error(code: code) {
            self = .handle(e)
            return
        }
        if let e = ISO_9945.Kernel.IO.Blocking.Error(code: code) {
            self = .blocking(e)
            return
        }
        self = .platform(Error.Error(code: code))
    }
}
