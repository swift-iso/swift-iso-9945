extension ISO_9945.Kernel.Pipe.Error {

    @inlinable
    public init(code: Error_Primitives.Error.Code) {
        if let e = ISO_9945.Kernel.Descriptor.Validity.Error(code: code) {
            self = .handle(e)
            return
        }
        self = .platform(Error_Primitives.Error(code: code))
    }

    @inlinable
    public var code: Error_Primitives.Error.Code {
        switch self {
        case .handle(let e): return e.code
        case .platform(let e): return e.code
        }
    }
}
