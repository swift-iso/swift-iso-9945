extension ISO_9945.Kernel.Close.Error {

    @inlinable
    public init(code: Error.Error.Code) {
        if let e = ISO_9945.Kernel.Descriptor.Validity.Error(code: code) {
            self = .handle(e)
            return
        }
        self = .platform(Error.Error(code: code))
    }
}
