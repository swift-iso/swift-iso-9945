extension ISO_9945.Kernel.File.Open.Error {

    @_spi(Syscall)
    @inlinable
    public init(code: Error_Primitives.Error.Code) {
        if let e = Path.Resolution.Error(code: code) {
            self = .path(e)
            return
        }
        if let e = ISO_9945.Kernel.Descriptor.Validity.Error(code: code) {
            self = .handle(e)
            return
        }
        self = .platform(Error_Primitives.Error(code: code))
    }
}
