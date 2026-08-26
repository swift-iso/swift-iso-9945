extension ISO_9945.Kernel.File.Control.Error {

    @usableFromInline
    internal init(code: Error.Error.Code) {
        if let e = ISO_9945.Kernel.Descriptor.Validity.Error(code: code) {
            self = .handle(e)
            return
        }
        self = .platform(Error.Error(code: code))
    }
}
